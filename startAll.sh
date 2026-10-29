#!/usr/bin/env bash
set -Eeuo pipefail
# setsid deve mantenere il PID del figlio anche se il chiamante usa job control.
set +m

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SERVER="$ROOT/BaradWatchU-Server"
CLIENT="$ROOT/BaradWatchU-Client"
declare -a PIDS=()
declare -a NAMES=()

usage() {
    cat <<'HELP'
Uso: ./startAll.sh [--help]

Avvia l'ambiente di sviluppo locale: bootstrap Client Rust, Server Rust e
le due UI Angular. Ctrl-C arresta soltanto i processi avviati dallo script.
Richiede Bash, setsid (util-linux), Cargo, npm, Node 20 >=20.11.1 e dipendenze
Angular gia installate con npm ci in ciascuna directory web/.

BARADWATCHU_SERVER_ADDR configura l'API (default 127.0.0.1:3000).
Usare una porta fissa da 1 a 65535; la porta dinamica 0 non e supportata qui.
Le UI usano host/porte dei rispettivi web/angular.json. Usare una sola istanza.
Questo script non installa dipendenze e non gestisce servizi di sistema.
HELP
}

case "$#:${1-}" in
    0:) ;;
    1:--help|1:-h) usage; exit 0 ;;
    *) printf 'Argomenti non validi; usare --help.\n' >&2; exit 2 ;;
esac

fail() {
    printf 'Errore: %s\n' "$*" >&2
    exit 1
}

for dir in "$SERVER" "$CLIENT"; do
    [[ -f "$dir/Cargo.toml" && -f "$dir/web/angular.json" ]] ||
        fail "Progetto incompleto o mancante: $dir"
done

# Usa Node gia compatibile oppure seleziona la versione installata con nvm.
if ! command -v node >/dev/null || ! node "$SERVER/web/check-node.mjs" >/dev/null 2>&1; then
    nvm_script="${NVM_DIR:-$HOME/.nvm}/nvm.sh"
    if [[ -s "$nvm_script" ]]; then
        # nvm e uno script esterno che puo leggere variabili non definite.
        set +u
        # shellcheck disable=SC1090
        source "$nvm_script"
        nvm use 20 >/dev/null || fail 'Node 20 non disponibile in nvm; usare nvm install 20.'
        set -u
    fi
fi

for tool in setsid cargo node npm; do
    command -v "$tool" >/dev/null || fail "Comando mancante: $tool (vedere --help)."
done
for dir in "$SERVER" "$CLIENT"; do
    node "$dir/web/check-node.mjs" || fail 'Selezionare Node 20 >=20.11.1.'
    [[ -f "$dir/web/node_modules/@angular/cli/bin/ng.js" ]] ||
        fail "Dipendenze Angular mancanti: eseguire npm ci in $dir/web"
done

# L'indirizzo esportato e anche quello effettivamente passato al Server Rust.
export BARADWATCHU_SERVER_ADDR="${BARADWATCHU_SERVER_ADDR-127.0.0.1:3000}"
if ! urls="$(node --input-type=module - "$SERVER/web/angular.json" "$CLIENT/web/angular.json" <<'JS'
import { readFileSync } from 'node:fs';
import { isIP } from 'node:net';

function url(host, port) {
    if (host === '0.0.0.0') host = '127.0.0.1';
    if (host === '::' || host === '[::]') host = '::1';
    if (isIP(host) === 6) host = `[${host}]`;
    if (typeof host !== 'string' || !host || /[\s/@?#]/.test(host)) {
        throw new Error('Host di sviluppo non valido.');
    }
    if (!Number.isInteger(port) || port < 1 || port > 65535) {
        throw new Error('Usare una porta di sviluppo fissa da 1 a 65535 (non 0).');
    }
    return new URL(`http://${host}:${port}`).origin;
}
try {
    const match = /^(\[[^\]]+\]|[^:]+):([0-9]+)$/.exec(process.env.BARADWATCHU_SERVER_ADDR);
    const host = match?.[1].replace(/^\[|\]$/g, '');
    if (!match || !isIP(host) || (match[1].startsWith('[') && isIP(host) !== 6)) {
        throw new Error('BARADWATCHU_SERVER_ADDR deve essere IP:porta (IPv6: [::1]:3000).');
    }
    console.log(url(host, Number(match[2])));
    for (const file of process.argv.slice(2)) {
        const workspace = JSON.parse(readFileSync(file, 'utf8'));
        const projects = Object.values(workspace.projects);
        if (projects.length !== 1) throw new Error(`Atteso un solo progetto Angular: ${file}`);
        const serve = projects[0].architect.serve;
        const options = { ...serve.options, ...serve.configurations?.[serve.defaultConfiguration] };
        console.log(url(options.host, options.port));
    }
} catch (error) {
    console.error(`Errore configurazione: ${error.message}`);
    process.exit(1);
}
JS
)"; then
    fail 'Correggere la configurazione prima di avviare i processi.'
fi
mapfile -t URLS <<< "$urls"

alive() {
    kill -0 -- "-$1" 2>/dev/null || kill -0 "$1" 2>/dev/null
}

signal_owned() {
    # Il secondo tentativo copre la breve finestra prima che setsid crei il gruppo.
    kill -"$1" -- "-$2" 2>/dev/null || kill -"$1" "$2" 2>/dev/null || true
}

cleanup() {
    local status=$?
    trap - INT TERM EXIT
    ((${#PIDS[@]})) || return "$status"
    printf '\n==> Arresto dei processi BaradWatchU avviati dallo script...\n'
    local pid running deadline
    for pid in "${PIDS[@]}"; do
        signal_owned TERM "$pid"
    done
    deadline=$((SECONDS + 5))
    while (( SECONDS < deadline )); do
        running=0
        for pid in "${PIDS[@]}"; do
            if alive "$pid"; then running=1; break; fi
        done
        (( running == 0 )) && break
        sleep 0.2
    done
    for pid in "${PIDS[@]}"; do
        if alive "$pid"; then
            printf '    Gruppo %s ancora attivo dopo 5 s: arresto forzato.\n' "$pid" >&2
            signal_owned KILL "$pid"
        fi
        wait "$pid" 2>/dev/null || true
    done
    printf '==> Arresto completato.\n'
    return "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

start() {
    local name="$1" dir="$2" pid
    shift 2
    printf '==> Avvio %s\n' "$name"
    (
        cd "$dir"
        exec setsid -- "$@"
    ) &
    pid=$!
    PIDS+=("$pid")
    NAMES+=("$name")
    printf '    PID/PGID: %s\n' "$pid"
}

# Il Client attuale termina dopo il bootstrap: non e ancora un daemon.
start 'Client Rust (bootstrap)' "$CLIENT" cargo run -p baradwatchu-agent --locked
if wait "${PIDS[0]}"; then
    printf '==> Bootstrap Client completato. Nessun servizio agent avviato.\n'
else
    fail 'Bootstrap Client fallito; ambiente di sviluppo non avviato.'
fi
PIDS=()
NAMES=()

start 'Server Rust' "$SERVER" cargo run -p baradwatchu-server --locked
start 'Angular Server' "$SERVER/web" npm start
start 'Angular Client' "$CLIENT/web" npm start

printf '\n========================================\n'
printf ' BaradWatchU - Ambiente DEV\n'
printf '========================================\n'
printf ' Dashboard Server: %s\n' "${URLS[1]}"
printf ' Viewer Client:    %s\n' "${URLS[2]}"
printf ' Server API:       %s\n' "${URLS[0]}"
printf ' Health API:       %s/health\n' "${URLS[0]}"
printf '\n Avvio in corso: verificare i log dei processi e /health.\n'
printf ' Premi CTRL+C per arrestare tutto.\n\n'

# Un servizio persistente che termina rende incompleto l'ambiente DEV.
while true; do
    for index in "${!PIDS[@]}"; do
        if ! kill -0 "${PIDS[$index]}" 2>/dev/null; then
            status=0
            wait "${PIDS[$index]}" || status=$?
            printf 'Errore: %s terminato (codice %s); arresto ambiente DEV.\n' \
                "${NAMES[$index]}" "$status" >&2
            (( status != 0 )) || status=1
            exit "$status"
        fi
    done
    sleep 0.2
done
