# BaradWatchU — agent memory (compact; for AI handoff)
Legend: ✅ implemented+verified · 🟡 implemented, runtime unverified · ⏳ planned/open. Details/history → `git log` of each repo, `REQUIREMENTS.md` (§7.4 identity, §7.5 remote, §7.6 Barad Policy, §11 roadmap), repo README/LEGGIMI, Client `docs/remote-protocol.md`.

## 0. Workspace / rules
- Root `BaradWatchU/` = workspace git repo (tracks MEMORY/REQUIREMENTS/.idea). Child repos (independent, CamelCase): `BaradWatchU-Client/`, `BaradWatchU-Server/`. Root-only files: AGENTS.md, MEMORY.md, REQUIREMENTS.md, catalogo-requisiti-proposto.md.
- Git read-only for agent (give operator the commands). README.md (EN) ≡ LEGGIMI.md (IT), keep Tolkien subtitles.
- Client = reference for shared contracts (report JSON, PDF, catalog, locales, installer UX). Server never audits itself; only requests/receives/displays Client reports.
- State 2026-11-25: Client HEAD `a91b16c`, Server HEAD `1711f5f` (UX + translation fix + Windows fixes committed). Uncommitted in both: GPL license change (§9).
- Translation: IT keeps `trusted` for Client↔Server trust; `attendibile` only for Barad Policy file trust. Tool/Device ID/Fingerprint/CLI stay English. All diagnostics via catalog keys.
- Operator refs: audit criteria `~/.claude/skills/audit-postazione/SKILL.md` (R1–R7); installer inspiration `~/Codici/bash/AQTRunCat`; operator custom check `~/.config/baradwatchu/custom-checks/CUSTOM-001` (copy is a unit test). Headless screenshots: `google-chrome-stable --headless=new --screenshot=…`.

## Active task — Client dashboard UX (2026-11-17)
- Authorized: improve Client layout/usability autonomously in small checkpoints; save each checkpoint here. No Server/protocol changes.
- CP1 analysis ✅: clean Client worktree; Angular single template + global CSS. Header overcrowded, 8–11px UI text, mobile history precedes controls, titles ellipsized, no global focus style. Preserve Ash & Ember tokens/eye and existing translations.
- CP2 ✅: two-row header separates navigation/actions; wrapping navigation; global keyboard focus incl. upload labels; nav uses aria-current instead of incomplete tab semantics; filters expose aria-pressed. Verified by production build and browser.
- CP3 ✅: readable titles (wrap), larger result/form/history text and interaction targets, metric grid, wrapping metadata/actions, single-column content ≤1000px; mobile controls precede history, stacked technical facts and 16px inputs. Brand tokens/eye unchanged.
- CP4 ✅: Node20 production build + npm test (1 test) + git diff --check pass. Isolated Chrome/CDP fixture: 1440/1024/768/390/320px, no horizontal overflow, navigation fits, titles wrap, controls before history; metric filter/reset, expand details, search/clear, history selection pass. Visually inspected screenshots `/tmp/bwu-ux-{1440,390}.png`. Fixtures/scripts only in /tmp; no real audits/settings modified.
- Completed: only Client `web/src/{main.ts,styles.css}` edited; no new strings/contracts/API changes or Git mutations. Browser evidence covers overview with synthetic data, not native Win/mac or all secondary-page states.

## Follow-up — dashboard translations / Server UX (2026-11-17)
- Client bug: locale keys existed but six UI keys absent from Rust dashboard_catalog export (package import + identity SHA). Added exports + regression test scanning literal UI calls against exported catalog in IT/EN; all 3 messages tests pass. Rebuild/reinstall Client agent required to update live /api/messages. Earlier fixture sent full locales, so did not catch API subset omission.
- Server CP1 ✅ analysis: clean worktree; fleet rows dominated by SHA blocks, same primary styling for all actions, cramped header, small type, flex children lack min-width constraints. Client CSS/template reviewed.
- Server CP2 ✅: fleet search + all/connected/disconnected counts, expandable technical SHA/fingerprint, audit action emphasized over configuration, nav aria-current and report filter aria-pressed. Verified in browser.
- Server CP3 ✅: Client-style two-row navigation, global keyboard focus, readable wrapping titles/results, larger filters, fleet rows split identity/actions, responsive one-column forms/cards, mobile report modal and technical facts. Production build + npm test pass. Browser caught report focus loss: auditRows getter recreates rows on change detection. Added trackBy requestId (and Client ID for polling) so dialogs restore focus to persistent controls; browser confirms focus restoration.
- Server CP4 ✅: production build + npm test (1 test) + both repo diff checks pass. Chrome isolated fixture: fleet 1440/1024/768/390/320px no horizontal overflow; report modal 1440/390/320px; requirements/settings 320px. Connection counts/filters, search/reset, disconnected audit disabled, technical details, SHA dialog/Escape, history/report filtering, focus restoration pass. Screenshots `/tmp/bwu-server-ux-{1440,390}.png`; mobile visually inspected.
- Completed: Server only web/src/{main.ts,styles.css}; auth/trust/consent/report contracts untouched. No installation, real remote audit, native Windows/mac or real OIDC validation in this task. No Git mutations. Client translation fix tests 3/3 + fmt check pass; live agent rebuild remains operator step.

## 1. Open work / next (priority)
1. ⏳ Adapt stale inbound test harnesses to outbound tunnel — NOT authorized yet (ask operator): Client `crates/agent/tests/remote_service.rs` (6 FAIL + 1 ignored), Server `src/client_fixture.rs` + `src/e2e_tests.rs` (need Client service connected to `app.tunnels`). Server `web/dashboard.smoke.mjs` also stale (fixture lacks /api/custom-checks, /api/requests).
2. 🟡 Windows (VM): reinstall needed to verify consent toast display/click, dashboard Accept/Reject, setup `CloseRunningPrograms` (ISCC compiles, never run), quit on live dashboard/tray. Suspected MSIX virtualization: Claude-app shells see stale `%LOCALAPPDATA%\baradwatchu\state\run\dashboard.json` — don't trust runtime-dir reads from this app.
3. 🟡 Barad Policy runtime: root `systemd-run`/launchd/SCM periodic runs, live Client→Server change-report push, real askpass prompt, macOS compile of policy code. No builtin declares `privilegeReason` yet. Windows compile ✅ 2026-11-16 (uncommitted fix: `LocalFree` import in `periodic.rs::windows_session`; `policy::set_test_policy` → `cfg(all(test, unix))`); Windows fmt/clippy -D warnings/`cargo test --workspace` pass (agent lib 106, tray 10).
4. 🟡 Never verified: real Google OIDC (no OAuth project; operator accepted deferral), root systemd service & sudo installs on real host (operator OK needed), macOS root LaunchDaemon, tray menu/notification clicks on Win/mac, real login autostart, GravityZone on a real BEST endpoint (provider written from docs), Cato adapter Up-state, REQ-008 Windows complexity vs `secedit`, Intel/T2/macOS 13–26.
5. ⏳ UX: guided manual Client↔Server connection flow in dashboard/docs (no discovery exists). Linux re-run after shared build.rs/requirements changes from macOS session.
- Known gaps: Client `/api/history` list fails on a damaged report; toast stays visible if decided elsewhere; `build.rs` never prunes old Angular bundles; GNOME needs AppIndicator; same-user processes can decide consent via CLI; same-user tampering accepted as inherent.

## 2. Client (`BaradWatchU-Client`) — Rust workspace + Angular 18
| Path | Role |
|---|---|
| `crates/agent/src/requirements.rs` | catalog discovery, custom checks, runner, audit, CLI, dashboard JSON; `TestEnv` at bottom |
| `…/dashboard.rs` | loopback HTTP bridge (token+Host/Origin/Content-Type), static web, `dashboard [--no-browser] [--open status\|custom\|history\|notifications\|settings]`; `/api/shutdown`, `/api/consent/decide` |
| `…/configuration.rs` | Settings API (`/api/configuration`, autostart toggle via tray CLI) |
| `…/pdf.rs` + `assets/report-brand-mark.png` | native A4 PDF from cached JSON (template 1.3.0); copied verbatim into Server |
| `…/history.rs` | history list/delete/clear (stamp-owned `.json/.log/.pdf`) |
| `…/events.rs` | events.jsonl, notif prefs, `lock_dir`, `audit_lock`/`try_audit_lock`, `tray_running`, `process_executable` |
| `…/consent.rs` | consent (TTL default 120 s), sources LOCAL_SIMULATION/REMOTE_SERVER, channels CONSENT_WINDOW/CLI/NOTIFICATION/DASHBOARD |
| `…/identity.rs` | Ed25519 identity + Server trust store, export incl. `executableSha256` |
| `…/ipc.rs` | Unix socket / pipe `\\.\pipe\baradwatchu-agent`, JSON lines `baradwatchu.ipc.v1` |
| `…/service.rs` | `service run` (root/SYSTEM): registrations, outbound tunnel, periodic thread, Windows SCM |
| `…/remote.rs` | protocol types, RPK TLS helpers, `remote link\|enable\|disable\|status` |
| `…/policy.rs`, `cron.rs`, `periodic.rs`, `elevation.rs` | Barad Policy (§5) |
| `…/cli.rs`, `main.rs`, `lib.rs` | CLI routing; usage errors exit 2 |
| `crates/messages/` | `locales/{it_IT,en_EN}.json` embedded (messages, diagnostics, req metadata incl. `windows_description`/`macos_description`, CLI help); `language.json` system\|italian\|english |
| `crates/tray/` | `baradwatchu-tray` (rust ≥1.92): app.rs, model.rs (pure+tests), agent.rs (agent subprocess, spawns `remote link --watch-stdin`), `platform/{linux,windows,macos,native_loop}.rs` |
| `catalog/checks{,-windows,-macos}/REQ-00{1..9}/` | builtin checks (configuration.json + scripts/providers) |
| `catalog/builtin-tools.sha256` | per-file trusted hashes (`ID platform path sha`), embedded `BUILTIN_MANIFEST`; regen `scripts/update-builtin-hashes.sh` (macOS: run via `bash`) |
| `web/src/{main.ts,styles.css}` | routes `#/ #/history #/custom #/notifiche #/impostazioni #/connessioni`; theme "Ash & Ember" (don't change brand CSS/eye) |
| `install.sh` / `install-macos.sh` / `install.ps1` | installers (§6) |
| `packaging/service/` | systemd unit, launchd plist, `install-service.{sh,ps1}`; `packaging/windows/baradwatchu-client.iss`; `packaging/policy/barad-policy.example.json` |
| `crates/agent/build.rs` | stages catalog (target OS only) + web dist beside artifacts; profile dir detection for Cargo 1.100 build-dir; `BARADWATCHU_TEST_INSTALL_ROOT` |
| tests | `crates/agent/tests/{cli,identity_cli,policy_cli,req003_firewall,req004_005_methods,workstation_criteria,macos_checks,remote_service}.rs` |

## 3. Server (`BaradWatchU-Server`) — Axum + Angular, MSRV 1.88
| Path | Role |
|---|---|
| `crates/server/src/main.rs` | start/`dashboard [--no-browser]`, `setup identity generate\|export`, `setup admin allow\|revoke SUB`, `setup client import FILE NAME` |
| `config.rs` | config resolution + `authMode` LOCAL\|OIDC |
| `auth.rs` | Google OIDC code+PKCE; LOCAL sessions (random cookie/CSRF, 8 h) |
| `http.rs` | APIs, CSRF/exact Origin, LOCAL Host guard (421), static Angular |
| `launcher.rs` | LOCAL launch token, `$XDG_RUNTIME_DIR/baradwatchu-server/{dashboard.json,open-dashboard.html}` |
| `tunnel.rs` | Client tunnel sessions, change-report receive; listen addr 0.0.0.0:7445 set in `main.rs` (`BARADWATCHU_SERVER_TUNNEL_ADDR`) |
| `storage.rs` | SQLite: identity, trusted Clients, admins, baselines, received_reports, `client_executable_sha`, `client_policy_sha`, `policy_sha_default`, expected_manifest |
| `report.rs`, `report_integrity.rs` | Client report types + coherence/compare (incl. `compare_policy`) |
| `manifest.rs` | parse Client `builtin-tools.sha256` (linux/windows/macos), `compare_with_digest` |
| `requirement_config.rs`, `custom_checks.rs`, `client_catalog.rs` | requirement definitions, custom-check packages (never executed), embedded exact Client catalog `crates/server/client-catalog/` |
| `pdf.rs`, `preferences.rs` | Client renderer copy; shared report theme/language prefs |
| `tls.rs` | RPK TLS (copied from Client) |
| `oidc_tests.rs`, `e2e_tests.rs`, `client_fixture.rs` | tests (e2e stale, §1) |
| `tools/test-remote-history.py`, `tools/test-installer-lifecycle.py` | harnesses (use history harness; plain `--ignored` reads the real report theme) |
| `web/src/main.ts` | home = fleet (request audit per Client), audit list + modal, history, requirements, settings |

## 4. Contracts (shared)
- **Check folder** schema `baradwatchu.custom-checks.v1` (deny unknown): schemaVersion,id,name,description,priority,enabled,toolPath|providers,arguments,parameters,expectedSha256,version,timeoutSeconds?,overrideBuiltinId,privilegeReason?. Custom IDs `CUSTOM-[A-Z0-9-]+`, dir `$XDG_CONFIG_HOME/baradwatchu/custom-checks`. Invalid custom ⇒ ERROR control; invalid builtin ⇒ hard error.
- **Local changes = CUSTOM overrides only**: `settings.json` never read. Config-only override = CUSTOM folder with only configuration.json + `overrideBuiltinId` (takes enabled/priority/parameters, runs official files). `apply_local_change` used by CLI/dashboard.
- **Providers** (REQ-002): `providers:{id:{name,toolPath,parameters,timeoutSeconds?}}`; all run; `acceptedProviders` empty ⇒ one PASS enough, else all listed must PASS. Results in `extensions.providers`.
- **Runner**: direct exec (needs `#!`; Windows .ps1 via powershell -File, .exe), cwd=tool folder, clean env, process group/Job Object killed on timeout, stdout ≤64 KiB. Default timeout 20 s (max 300). Output `{id?,status PASS|FAIL|WARN(ING)|ERROR|NOT_APPLICABLE,summary,details}`.
- **Integrity**: hash checked before every run; mismatch ⇒ ERROR, not executed. `installation_integrity()` hashes installed builtin files vs embedded manifest ⇒ `AuditReport.installation` (VERIFIED/MODIFIED/MISSING/UNEXPECTED/UNSAFE); non-verified folder ⇒ its builtin ERROR. Agent self-hash in report (evidence, not proof).
- **Audit report** `baradwatchu.audit.v1`: initiator LOCAL/REMOTE/SCHEDULED, client version+sha256, installation, results (+description snapshot), `policy`. Cached in `$XDG_CACHE_HOME/baradwatchu/audit/` with `<stamp>.pdf`; PDF failure never changes outcome. PDF subtitle keys LOCAL/REMOTE/SCHEDULED/unknown identical in Client and Server.
- **Identity**: fingerprint `SHA256:hex`, Device ID `BWU-…`, Server ID `SRV-…` (8 bytes sha256(domain‖pk)); public file `baradwatchu.public-identity.v1` (+optional `executableSha256`). Storage `state/identity/`, atomic `state.json` commit; Unix 0700/0600.
- **Remote (outbound tunnel)**: Client service dials trusted Server DNS/IP:7445, pinned-key TLS1.3 RPK Ed25519; Server authenticates imported Client key + hello Device ID; heartbeat 10 s; frames = 4-byte BE length + JSON (≤9 MiB). Requests create/status/result. Consent 120 s; busy ⇒ BUSY (no queue); no user/tray ⇒ UNAVAILABLE (`TRAY_NOT_RUNNING`). Requester names = metadata only. Old inbound listener/discovery removed 2026-11-12.
- **Service IPC**: intents REGISTER|UNREGISTER|STATUS|LINK|UPDATE; service dir `BARADWATCHU_SERVICE_DIR` or /var/lib/baradwatchu | `/Library/Application Support/BaradWatchU/service` | `%ProgramData%\BaradWatchU\service`; socket `BARADWATCHU_SERVICE_SOCKET` or /run/baradwatchu/agent.sock (macOS path <104 bytes). Service uses the registered user's key (`identity::load_for_service`, owner checks).
- **Server comparison** `serverRequirementComparison`: per-requirement SHA, manifest (per-file + digest, overrides), `clientExecutable` (override > imported identity SHA; never learned from report), `baradPolicy` (per-Client > fleet; MATCH only APPLIED+equal). mTLS-authenticated Client claims, not attestation. Red warning in report modal on mismatch.
- **Server auth**: config `BARADWATCHU_SERVER_CONFIG` > `/etc/baradwatchu/server.json` > `$XDG_CONFIG_HOME|~/.config/baradwatchu/server.json`; none ⇒ LOCAL on 127.0.0.1:3000 (`BARADWATCHU_SERVER_ADDR`). LOCAL: loopback only, launch token `?k=` → header `X-BaradWatchU-Token` on `/api/session`, label `localOperatorName`/$USER/`server.localOperator` (descriptive only). OIDC: Google, issuer/sub allowlist, `__Host` cookies. Unreadable selected config ⇒ startup fails. Mode independent of install privileges.
- **Server data**: `BARADWATCHU_SERVER_DATA_DIR` (default XDG_STATE_HOME/baradwatchu-server), 0700/0600; request routing in memory (24 h, lost on restart); received reports in SQLite per operator (automatic reports operator `@client`, visible to all admins).
- **Ports/namespaces**: Server 3000 (dev Angular 4300), tunnel 7445; Client dashboard ephemeral loopback (dev 4200). Runtime namespaces `baradwatchu-server` vs `baradwatchu`.
- **Client paths**: config `$XDG_CONFIG_HOME/baradwatchu` (Win `%APPDATA%\baradwatchu`), state `$XDG_STATE_HOME/baradwatchu` (Win `%LOCALAPPDATA%\baradwatchu\state`), runtime `$XDG_RUNTIME_DIR/baradwatchu` (fallback state/run), PDF themes `config/themes/<id>.json` + `report-theme.json`.

## 5. Barad Policy (2026-11-14, 🟡)
- Policy file owner root 0644 with root-owned parents (Unix, O_NOFOLLOW) / Windows owner SYSTEM|Admins; states APPLIED/ABSENT/INVALID/UNTRUSTED; `policy status [--json]`.
- Periodic audit by service AS the registered user (Linux `systemd-run --uid --pipe --wait`, macOS setuid+initgroups, Windows WTSQueryUserToken+CreateProcessAsUserW) via `audit --json --scheduled` (no history/PDF; event recorded with `scheduled:true` + "(automatico)" title, tray toasts only new non-repeated WARN/CRIT — 2026-11-16, uncommitted); 5-field local cron, single catch-up, 5-min retry; state `periodic/<principal>.json`; push change report on tunnel only if ack `accepts` CHANGE_REPORTS (resend 60 s, retry 300 s).
- `privilegeReason` ⇒ `sudo -k [-A]` with askpass (zenity/kdialog/osascript via `BARADWATCHU_ASKPASS`); never for scheduled/override/custom; fallback PASS→WARN; Windows UNAVAILABLE.
- Installers read `policy status --json`: startOnBoot false ⇒ service disabled/manual.

## 6. Installers
- **Client Linux `install.sh`**: build unprivileged, sudo re-exec for writes; default `/usr/local` (system ⇒ service always installed/updated) or `--local`/user prefix (no service/remote). Manifest-based install/reinstall/uninstall, refuses changed/foreign files; SIGTERM running instances by exact exe (never SIGKILL, `BARADWATCHU_STOP_TIMEOUT` 10 s); tray default + autostart on fresh install (`--tray-autostart`/`--no-tray-autostart`, `--without-tray`). nvm Node 20 from `web/.nvmrc`.
- **Client Windows**: SYSTEM INSTALL ONLY (2026-11-12). `install.ps1` = build → `-Package` Inno setup → `agent quit` → elevated silent setup → check service `BaradWatchU` Running; `-Uninstall` removes legacy per-user install + HKLM uninstaller; unknown args exit 2. `Start-Elevated` (2026-11-16, uncommitted): refused/missed UAC ⇒ `Retry the UAC prompt? [y/N]` loop (only if interactive console: stdin not redirected, no `-NonInteractive`), else Fail exit 1 (non-interactive path tested; interactive prompt not exercised). `.iss`: admin only, `{sysnative}` PowerShell, `CloseRunningPrograms` (quit → wait → taskkill under {app}). `install-service.ps1` uses `New-Service`/registry, `$env:ProgramW6432`.
- **Client macOS `install-macos.sh`**: bash 3.2, creates `BaradWatchU.app` (/Applications or ~/Applications), tray LaunchAgent `io.baradwatchu.tray`, service LaunchDaemon `io.baradwatchu.agent` via `install-service.sh`.
- **Server `install.sh`**: default `/usr/local`, sudo after unprivileged build, Client-style lifecycle (exact exe, SIGTERM); never writes auth config.

## 7. Platform specifics / pitfalls
- Windows scripts: UTF-8 **BOM** + CRLF (`.gitattributes`), PS 5.1; no `’` inside single-quoted PS strings; never `2>&1` a native exe under `$ErrorActionPreference='Stop'`; Inno setup is 32-bit (use `{sysnative}`); Inno `{…}` comments can't contain `}`; `sc.exe binPath=` quoting broken in PS 5.1. Linux catalog hashes = LF bytes.
- Windows IPC: client opens pipe with `access_mode(0x12018b)` + `SECURITY_IDENTIFICATION` QoS; verifies pipe OWNER `O:SY` via GetSecurityInfo; SCM handler must not `process::exit` inside the handler.
- Windows checks: BitLocker/TPM/SecureBoot cmdlets need admin ⇒ Shell property/registry/Tbsi; avoid localized outputs (net accounts, powercfg labels).
- macOS scripts: `#!/bin/bash` 3.2-safe, `plutil` for params (no python), absolute tool paths; shebang-less tools refused; remote requests need a running tray (fake tray must be a real binary; copied /bin/sleep gets killed).
- REQ decisions: REQ-002 explicit off ⇒ FAIL; REQ-004 one complete method (dnsmasq ≥1000 rules or HaGeZi hosts ≤30 d); REQ-005 Win = Cato presence, not connected ⇒ WARN; REQ-007 timeout ≤5, grace 0, lock on resume; REQ-008 max age 60 d; REQ-001 no age threshold. macOS Bitdefender provider never PASS (WARN).
- Tests must isolate XDG (`TestEnv`, writes Italian language.json); unisolated tests once touched the operator's real config.
- Clippy/MSRV: Client uses `map_or(true, …)` not `is_none_or` (MSRV 1.80); `too_many_arguments` allowed on pdf `draw_header`.

## 8. Commands
- Client: `cargo fmt --all --check`; `cargo clippy --workspace --all-targets -- -D warnings`; `cargo test --workspace --locked` (remote_service.rs fails: stale); `cd web && npm ci && npm run build && npm test` (Node 20 via nvm; Arch default node is 14).
- Server: same cargo commands; e2e `python3 tools/test-remote-history.py --client /abs/path/baradwatchu-agent`; web as Client.
- Windows VM: PS 5.1 only, user not admin; refresh PATH from Machine+User; `powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1`.
- Last test counts: Client lib 118 (Arch 2026-11-14), Server 57 + 2 ignored.

## 9. Settled decisions (don't revisit)
- Tray = separate process, talks to agent only via fixed CLI subprocess; notifications owned by tray; Windows consent = toast, Linux/macOS = window.
- Identity per user; service uses the registered user's key; consent 120 s; busy ⇒ BUSY; firewall manual.
- Trust baselines come from imported Client identity JSON / admin overrides, never from the report under check.
- Dashboard API stays a per-user loopback process (not served by the service).
- Client audit history in XDG cache, no auto-pruning; Server history in SQLite (multi-operator).
- Server LOCAL default; OIDC never has an unauthenticated bypass.
- License (2026-11-25): both repos `GPL-3.0-or-later` (canonical gnu.org text in `LICENSE`; Cargo workspace + web/package.json; README/LEGGIMI `## License`/`## Licenza`; Client notes custom checks = separate processes, not GPL-bound). AGPL rejected: corporate AGPL bans hurt adoption. Prior Cargo `MIT` declared w/o LICENSE file. Open: confirm copyright with Brainy Labs + co-author Michael Bonelli (1 commit/repo).
