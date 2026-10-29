# BaradWatchU — Requirements & Roadmap

> **Status:** Draft v0.7 · 2026-10-29  
> **Scope:** shared product specification for `BaradWatchU-Server` and `BaradWatchU-Client`  
> **Authority:** this file is the canonical requirements and milestone plan; no separate `ROADMAP.md`.

## 1. Identity and purpose

**BaradWatchU** (*Barad-dûr Watch U*) is a cross-platform endpoint security compliance auditing platform for an enterprise PC fleet. It inventories endpoints, executes configurable checks, records verifiable evidence, identifies policy drift and generates audit reports. Later milestones add narrowly authorized remediation, continuous monitoring and fleet governance.

**Server subtitle (English):**
> One Server to rule them all, One Server to find them, One Server to bring them all and in security bind them.

**Server subtitle (Italian):**
> Un server per domarli, un server per trovarli, un server per ghermirli ed alla sicurezza incatenarli.

**Client subtitle (English):**
> Nine were given to the Devs, who await their sorrowful bugs; seven to the SysAdmins, in their halls of servers; three to the Security Officers, keepers of the secret policies.

**Client subtitle (Italian):**
> Nove di questi furono dati ai Dev, che i tristi bug attendono; sette ai SysAdmin, nelle loro sale di server; tre ai Security Officer, custodi delle policy segrete.

The subtitle for each component must appear directly below its title in both `README.md` (English) and `LEGGIMI.md` (Italian). Keep both documents functionally equivalent and cross-linked.

## 2. Workspace and repository rules

The AI operator starts in the **parent workspace**, not inside an individual repository:

```text
BaradWatchU/
├── AGENTS.md                 # local agent rules; NOT versioned
├── MEMORY.md                 # local compact project memory; NOT versioned
├── REQUIREMENTS.md           # this canonical specification; NOT versioned
├── BaradWatchU-Server/       # independent Git repository
│   ├── README.md
│   ├── LEGGIMI.md
│   └── ...
└── BaradWatchU-Client/       # independent Git repository
    ├── README.md
    ├── LEGGIMI.md
    └── ...
```

- Do not create or duplicate `AGENTS.md`, `MEMORY.md`, `REQUIREMENTS.md` or `ROADMAP.md` inside the two repositories.
- Directory names are case-sensitive and must remain `BaradWatchU-Server/` and `BaradWatchU-Client/`.
- Do not create a separate `ROADMAP.md` anywhere: the roadmap is §11 of this file.
- Do not assume the parent folder is a Git repository. Each child repository has its own history and releases.
- Keep the parent files out of both repositories; no automatic commits, adds, pushes, destructive Git operations or remote modifications by AI agents unless explicitly authorized in future instructions. Read-only Git inspection is allowed.
- The local parent files are intentionally unversioned; their backup, sharing and continuity are the operator's responsibility. Public repositories may contain non-sensitive, derived user-facing documentation.
- `MEMORY.md` is a compact technical map for AI agents (paths, decisions, commands, checkpoints), not a human-facing changelog. Keep it concise and update after substantive work.
- `AGENTS.md` governs agent behavior; this file governs product requirements. In case of ambiguity, report the conflict rather than silently inventing a requirement.

## 3. Product principles

1. **Audit first:** L1 only observes; it never silently changes OS configuration.
2. **Independent agent:** audit must work offline, without a running GUI or reachable server, using a locally validated policy.
3. **Server-owned desired policy:** checks are enabled, disabled and parameterized centrally per endpoint or group; offline fallback uses the last trusted applied policy.
4. **Two-sided custom-check registration:** custom executable/script must be authorized in server policy and registered locally with matching identity, version and content digest.
5. **Built-in and custom checks share one result contract**, but not necessarily the same trust level.
6. **Least privilege:** normal agent runs with minimal privileges; privileged inspection or remediation uses a narrow, authenticated helper only when necessary.
7. **No remote shell:** server cannot execute arbitrary commands on endpoints. Remediation uses an explicit, typed allowlist of operations.
8. **Evidence over assertion:** distinguish a verified observation from an untrusted script's claim. Do not treat a reported PASS as a cryptographic guarantee of machine integrity.
9. **Platform-specific implementations, platform-neutral semantics:** Fedora, Ubuntu, Arch Linux, Windows and macOS must map to the same logical controls where feasible.
10. **Measurable milestones:** every milestone has demonstrable acceptance tests; avoid implementing future levels prematurely.

## 4. Deployment and components

### 4.1 Server (`BaradWatchU-Server`)

- Linux executable/service with an embedded or co-hosted Angular web dashboard.
- API for enrollment, policy assignment, audit ingestion, evidence retrieval, inventory and reports.
- Stores historical policy versions, check results, timestamps and device identities.
- Generates machine-readable JSON/CSV and human-readable PDF reports; audit trails must include relevant policy/check versions.
- Supports authentication, role-based authorization, tenant/organizational separation if later required, TLS and audit logs.
- Bootstrap technology baseline: **Rust + Axum**, Angular. SQLite remains the planned first persistence adapter, with module boundaries allowing PostgreSQL later; no database model or adapter is implemented yet.
- Deployment must not require AWS or any other public cloud; on-premises operation is supported.
- Linux distribution channels: source installer, Arch `pacman`, Debian/Ubuntu `.deb`, Fedora `.rpm`. Source installation is distinct from package-manager ownership; source uninstallation must never remove package-owned files.
- Planned system locations: executable `/usr/bin` (packages) or `/usr/local/bin` (source), web assets `/usr/share/baradwatchu-server/web`, configuration `/etc/baradwatchu/server`, persistent state `/var/lib/baradwatchu/server`. L0.1.1 source install writes only executable/assets/manifest and creates no service/config/data.
- Server systemd packaging/service lifecycle is deferred; local installation is a manually launched development binary. Startup validates an IP:port address from `BARADWATCHU_SERVER_ADDR`, enables Tokio I/O/time drivers, reports failures with exit 1 (CLI misuse: 2), and drains connections on SIGINT/SIGTERM. The HTTP router and configuration are independent of process startup for tests.

### 4.2 Agent (`BaradWatchU-Client`)

- A **background OS service**, independent of the user interface:
  - Linux: `systemd` system service (Ubuntu, Fedora, Arch Linux).
  - Windows: Windows Service.
  - macOS: `launchd` LaunchDaemon.
- Current implementation: Rust bootstrap plus the explicitly authorized L1.1 Checkpoint 1 standalone audit slice (§5.3), with native platform boundaries. Background lifecycle, Python/custom checks and signed-policy handling remain deferred.
- Provides device inventory, policy validation, audit execution, evidence collection, secure server sync and offline JSON output.
- Future responsibilities: scheduler, notification dispatch, typed privileged remediation and post-remediation audit.
- Never rely on an open user session for background checks or server communications.
- Linux distribution channels: source installer, Arch `pacman`, Debian/Ubuntu `.deb`, Fedora `.rpm`; Windows client `setup.exe`; macOS client `.dmg`. A channel is supported only after its actual artifact passes clean install/upgrade/uninstall tests on its target OS.
- Planned Linux system locations: executable `/usr/bin` (packages) or `/usr/local/bin` (source), UI assets `/usr/share/baradwatchu-client/web`, configuration `/etc/baradwatchu/client`, persistent identity/audit/custom-check state `/var/lib/baradwatchu/client`. Source installer writes only executable/assets/manifest and does not install a system service.
- User-local paths are development-only: executable under `~/.local/bin`, future configuration under `~/.config/baradwatchu/client`, data under `~/.local/share/baradwatchu/client`. A user-local copy is not a system agent and provides no privileged/system-wide auditing.
- Linux package service ownership will use a systemd system unit. Windows service registration requires administrator authorization and a signed package; macOS uses an admin-authorized `launchd` LaunchDaemon and signed/notarized distribution. Service lifecycle integration is deferred until explicit lifecycle tests exist.

### 4.3 Local client UI

- Angular UI launched by a desktop shortcut/application launcher.
- Read-only status, local audit results and history initially; it is **not** the process responsible for background notifications, scheduling or remediation.
- It may open in a local browser or a desktop shell; **Tauri is optional**, not a requirement.
- Use authenticated local IPC or a carefully secured loopback interface; localhost alone is not an authorization boundary.
- UI runs without administrative privileges and must not access device secrets.
- Desktop viewer launcher/package is separate from the background service lifecycle. Development `npm start` runs on loopback: Server UI port 4200, Client UI port 4201. It neither starts nor controls a Rust process. Select Node 20 >=20.11.1 using `web/.nvmrc`; preflight and npm engine checks reject incompatible Node versions.

### 4.4 Product versioning and distribution (L0.1.1)

The product version follows Semantic Versioning (`MAJOR.MINOR.PATCH`). Server and Client have independent release lifecycles; each starts at `0.0.1`. Each repository has one authoritative Rust workspace version in root `Cargo.toml` (`[workspace.package].version`); crate versions inherit it. Rust binaries expose `--version`/`-V` and `--help`/`-h`, and version reporting must not start a server, agent service, browser or privileged component. Angular package/UI versions and package metadata must be generated or synchronized from that repository's authoritative version. Product version is not a protocol/schema version; wire compatibility versions remain separately defined.

Installer requirements:

- Linux source `install.sh` in both repositories supports `--help`, `--missing-deps`, `--dry-run`, `--no-build`, `--build-only`, `--local`, `--uninstall`, `--prefix=DIR`, and optionally `--build-dir=DIR`; invalid args return 2, execution/validation errors 1, success 0.
- Read-only dependency audit recognizes Arch, Fedora, Debian and Ubuntu via `/etc/os-release` `ID`/`ID_LIKE`, checks build/runtime versions and local Angular npm dependencies, separates optional tools, and prints package-manager/project-dependency-specific suggestions. It never installs system dependencies.
- Release builds run unprivileged in a marked project cache using Cargo `--locked` and npm `ci` against an isolated Angular source copy; checkout node_modules is preserved. npm/node-gyp caches and logs stay under the build directory. Cache format v2 records source origin/fingerprint (including install.sh and lockfiles), platform, product version, artifact digest and build-host glibc. `--no-build` verifies content and requires glibc at least as new as the build host without executing cached binaries. Legacy v1 caches require rebuilding. Stage artifacts before installation; no root build or automatic service action.
- Source install/uninstall is manifest-owned and hash-checked; refuse files owned by `pacman`, `dpkg`/`apt` or `rpm`/`dnf`, and refuse modified files. Preserve configuration, enrollment identity/keys, audit history and custom checks by default. Do not mix source and package-manager ownership.
- User-local installation is explicitly development-only, with no system service or privileged checks. System-wide installation must not silently create a production service. Agent systemd lifecycle and desktop viewer launcher are separate.
- `--dry-run` shows version, scope, prefix, cache, dependencies and operations without changing files or services. Do not claim transactional rollback unless verified.
- Distribution targets are source install, Arch `pacman`, Debian/Ubuntu `.deb`, Fedora `.rpm`; Client additionally targets Windows `setup.exe` and macOS `.dmg`. Release formats, service registration, signing/notarization and OS-native uninstallation remain deferred until artifacts pass target-platform tests.

| ID | Requirement | Target/status |
|---|---|---|
| REL-VER-001 | Server and Client versions evolve independently; initial SemVer is `0.0.1` | L0.1.1; source configured |
| REL-VER-002 | Rust `--version`/`-V` and `--help`/`-h` work before service startup | L0.1.1; source implemented |
| REL-VER-003 | Cargo workspace version is authoritative per repo; Angular UI/package and future packages derive/sync from it | L0.1.1; package/UI metadata and production builds verified at 0.0.1 |
| REL-VER-004 | Product release version is distinct from API/protocol/schema compatibility versions | L0.1.1 decision; wire versions pending L0 |
| REL-DIST-001 | Both repos provide the Linux source installer interface and safe exit codes | L0.1.1; isolated prebuilt install/update/uninstall verified; build-only Rust passes, npm completion blocked offline |
| REL-DIST-002 | Dependency audit is read-only, distro-aware, version-aware, and prints exact package/project commands | L0.1.1; passed on Arch host; other distro families pending |
| REL-DIST-003 | Marked cache, locked release build, source/platform/version/glibc/artifact integrity validation, staging, non-root builds | L0.1.1; v2 cache reuse/tamper/stale/incomplete checks pass; Angular build workspace is isolated |
| REL-DIST-004 | Hash manifest owns source-installed payload only; package managers own their payloads; upgrades/uninstall preserve data and refuse cross-ownership | L0.1.1; isolated actual payload install/update/uninstall and modified-file/data preservation pass; distro package-owner tests pending |
| REL-DIST-005 | Least privilege; user-local is development-only; no implicit production service or service restart | L0.1.1 source behavior implemented; systemd integration deferred |
| REL-DIST-006 | Arch, Debian/Ubuntu and Fedora package plans for both products; Client Windows/macOS plan | L0.1.1 plan documented; artifacts deferred |
| REL-DIST-007 | Windows service/installer and macOS LaunchDaemon/DMG require admin authorization, signing/notarization and data-preserving uninstall | Later client packaging milestone |
| REL-DIST-008 | A channel is advertised as supported only after real artifact install/upgrade/uninstall validation on target OS | Release gate; pending |
| REL-BOOT-001 | Server runtime drivers, validated configuration, actionable startup errors, health contract, SIGINT/SIGTERM drain | 8 Server Rust tests; operator health/dev-server/shutdown smoke passed; active connection drain untested |
| REL-BOOT-002 | Independent frontend development commands, supported Node preflight, authoritative version section parsing | Dev serving operator-confirmed; production builds and 4 tooling tests per repo pass |
- Future user-session helper handles OS-native notifications at the agent's request (e.g. desktop notification service on Linux); system services must not assume direct access to a graphical session.

## 5. Security checks: initial catalog

All thresholds and applicability rules are policy parameters, not constants baked into agent code. The catalog below is the agreed initial baseline, subject to validation against official corporate policy before production certification.

| ID | Built-in control | Initial desired requirement | Important verification notes |
|---|---|---|---|
| SEC-001 | OS updates | Updates at least every 90 days / quarterly | Define which update timestamp and security patches count; offline repositories can make status unknown. |
| SEC-002 | Installed software and licenses | No unapproved or improperly licensed software | Inventory alone cannot prove license validity; may require approved inventory/license source or custom check. |
| SEC-003 | Antivirus/endpoint protection | Approved protection installed, active and healthy | Product-specific health APIs; ESET where mandated, alternatives only if policy permits. |
| SEC-004 | DNS filtering | Approved DNS configuration/filtering | Verify active resolver and, where possible, effective enforcement, not merely a file value. |
| SEC-005 | Chrome Secure DNS | Independent Secure DNS disabled where required | Check managed policy and effective configuration; browser/user scope matters. |
| SEC-006 | Data/disk encryption | Approved encryption enabled | LUKS, BitLocker, FileVault or approved equivalent; check actual protected volumes/scope. |
| SEC-007 | Screen lock | Automatic lock within 5 minutes | Account for user vs device policies and inactive sessions. |
| SEC-008 | Password expiry | Maximum password age 60 days | OS/local vs directory/IdP authority must be identified. |
| SEC-009 | Password expiry warning | Warning 10 days before expiry | Not universally available as a device-level setting; UNKNOWN or N/A where justified. |
| SEC-010 | Password complexity | At least 14 characters and required character classes | Validate policy enforcement, never collect actual passwords. |
| SEC-011 | Corporate VPN | Cato SDP installed/configured when assigned | Applicability is per device/group; installation, service health and connection are distinct. |
| SEC-012 | TPM | TPM 2.0 present/available where required | Some Mac models use different hardware trust architecture; policy must express applicability. |
| SEC-013 | Secure Boot | Enabled where supported/required | Platform-specific boot integrity mechanisms; do not equate unsupported with PASS. |

**Important:** SEC-011 is not mandatory for every employee. All controls, including built-ins, are individually assignable. A check disabled by policy is **SKIPPED/DISABLED**, not PASS and not a compliance failure; an inapplicable enabled check is **NOT_APPLICABLE** with rationale.

### 5.1 Check result states

- `PASS`: check executed successfully and verified its defined criterion.
- `FAIL`: check executed successfully and found a policy violation.
- `WARN`: completed observation is inconclusive or has unverified coverage/freshness; never a successful compliance result.
- `ERROR`: observation could not execute/parse safely (missing tool, permission, timeout, malformed output, unavailable read-only guard); never PASS.
- `UNKNOWN`: planned aggregate for undetermined outcomes in future policy/custom-check contracts. The Checkpoint 1 Client report explicitly distinguishes WARN from ERROR; this is a separately versioned local observation contract, not an assertion that the future fleet schema is finalized.
- `NOT_APPLICABLE`: check is assigned but demonstrably inapplicable to the device/context.
- `SKIPPED`: check disabled or intentionally excluded by effective policy; recorded separately from executed checks.
- Execution/transport errors must be recorded with structured reason codes; they must not silently become PASS.

### 5.2 Evidence requirements

Each result must include check ID, implementation type, check version, device identity, OS/platform details, policy version and digest, execution time, outcome, structured reason, collection method, privilege level and evidence metadata. Avoid secrets, full license keys, credentials and unnecessary personal data. Preserve evidence provenance and retention settings.

### 5.3 L1.1 / Checkpoint 1 — Standalone Audit Foundation

Explicitly authorized vertical slice, Client Rust only. Use reusable platform-neutral `Check` and report/result/evidence types; isolate OS detection and command execution in native adapters. Provide `baradwatchu-agent audit` (human) and `audit --format json`, preserving bootstrap/version/help. No Server/UI dependency, network calls, elevation, package/configuration changes, services, scheduling, custom checks, policy processing or extra checks.

- Stable IDs: `SYS-OS-001` OS identity, `SEC-001` pending RPM updates, `SEC-006` root block encryption. Descriptions and implementation versions accompany each result.
- Client observation schema `baradwatchu.audit-report.v1` is independent of product `0.0.1` and future shared fleet protocols. JSON includes agent version, OS/support details, integer UTC Unix-millisecond report/check timestamps, five exact states (`PASS`, `FAIL`, `WARN`, `ERROR`, `NOT_APPLICABLE`), structured reason/evidence/source/scope and deterministic counts. Device identity, policy versions/digests, signatures and ingestion are absent rather than invented; §5.2 remains the future complete contract.
- Parse `/etc/os-release` as data, fallback to `/usr/lib/os-release` only if missing; do not execute shell. Exact Fedora ID/numeric version qualifies; ID_LIKE derivatives, other platforms and image/ostree/Atomic Fedora do not. Identity may be observed successfully on an unsupported OS; Fedora probes then do not run, their results are NOT_APPLICABLE, and overall status is WARN. Identity read/parse failures are ERROR.
- Updates: fixed DNF5 cache-only `check-upgrade`, no plugins/refresh/transaction, no libsolv cache generation or persistent log output; DNF5 must support --skip-file-locks to avoid creating the system-repository lock. Existing persistent state remains readable but cannot be written; queries are not transaction-locked snapshots. Mandatory child-only Landlock ABI 3+ write/create/remove/rename/truncate restriction and no_new_privs; refuse unprotected execution if unavailable. Exit 100 => FAIL for observed pending updates; exit 0 => WARN/NO_CACHED_UPDATES (freshness/coverage unverified), missing cache/no repositories => WARN, missing tool/permissions/timeout/invalid command or execution/guard failures => ERROR. No update PASS or quarterly-policy certification in this checkpoint.
- Encryption: identify `/` using findmnt major:minor, trace all observed lsblk backing paths; PASS only for simple disk/partition/LVM paths each containing active dm-crypt directly backed by LUKS metadata. A proven plain root path => FAIL; unrelated LUKS is irrelevant. Btrfs, RAID/multipath, loop, overlay/network root, incomplete/conflicting metadata or unproven dm-crypt => WARN; tool/permission/parse/execution failures => ERROR. Scope excludes separate home, boot/EFI, swap, external drives and hardware/key-strength certification.
- Fixed native tool paths, minimal C-locale environment/no inherited secrets, null stdin, 30 s timeout and 256 KiB per output stream. No package lists, raw stderr, disk serials/UUIDs or repository URLs in reports. Local observations are not cryptographic proof against a compromised OS.
- Overall precedence ERROR > FAIL > WARN > PASS; skipped/inapplicable or empty coverage cannot create an overall PASS. CLI: 0 PASS/info/bootstrap, 1 execution failure, 2 invalid CLI, 3 FAIL without ERROR, 4 inconclusive/unsupported without ERROR/FAIL. Completed audits emit reports even with nonzero outcome codes; fatal clock/output errors can prevent a complete report.
- Gate: standalone CLI, three explainable structured checks, safe unsupported behavior, stable valid JSON, fixture-based domain/platform/command/error tests without root or real host configuration, fmt/tests/Clippy/debug/release builds. Real Fedora DNF5/storage smoke remains distinct from fixture evidence.

## 6. Policy management and double-sided configuration

### 6.1 Desired, applied and observed

- **Desired Policy:** versioned policy assigned by the server to device/group; controls enabled/disabled, parameters, platform constraints and custom-check manifest digests.
- **Applied Policy:** last server-authorized policy validated and stored by the agent, including signature, version and digest.
- **Observed State:** audit outcomes produced against a specific applied policy and check implementation versions.
- Server compares desired/applied versions and digests; mismatches are `POLICY_DRIFT` and must not be silently certified compliant with the new policy.
- A client can audit offline against its last trusted policy, reporting its age and whether it is stale; the server decides whether such results satisfy current reporting rules.
- Assignment precedence (global → group → device), group membership, exception approval and conflict resolution must be defined in L0.
- Server can disable any built-in or custom check for a device/group; local users cannot silently override server-required checks.
- Local policy files must have OS-appropriate integrity/access protections. Signed policy alone does not prevent a fully privileged local attacker from tampering with runtime behavior.

### 6.2 Custom Security Checks (AQTRunCat-style extensibility)

- Built-in checks ship with the agent; custom checks are external scripts/executables with the **same result schema**.
- Custom checks may be implemented in Bash, PowerShell, Python or native binaries where the target OS supports their runtime.
- A custom check is executable only when **(a)** the server policy assigns/enables its ID, **(b)** the client has the locally registered artifact, **(c)** ID/version/content digest and authorized manifest match, **(d)** platform and execution permissions match.
- The server may register and assign metadata but **must not push arbitrary executable content for immediate execution** in the initial design.
- Custom artifacts are installed/approved locally by an administrator through an explicit trusted procedure. Automated distribution, if ever supported, requires a separate reviewed signing/approval model.
- Run custom checks unprivileged by default, with bounded timeout, output size, resource limits, working directory and restricted access to secrets; sandboxing should be implemented where supported. A script must not inherit the agent's private key or server credentials.
- A custom check must not call the privileged helper as a generic shell bridge. Any privileged inspection requires a separately implemented and authorized typed operation.
- Missing/mismatched custom artifact results in `UNKNOWN` with reason such as `CHECK_NOT_INSTALLED`, `DIGEST_MISMATCH`, `UNSUPPORTED_PLATFORM`, `TIMEOUT` or `EXECUTION_ERROR`, and an explicit configuration/coverage issue.
- Script output is treated as lower-trust evidence than a native trusted probe; the report must indicate provenance and limitations.
- Example: `CUSTOM-INTELLIJ-LICENSE` on workstation X checks installation and licensing status. Merely finding the `idea` executable **does not prove license validity**; a genuine license verification method must be supplied by the check author.

### 6.3 Illustrative custom-check manifest

```json
{
  "id": "CUSTOM-INTELLIJ-LICENSE",
  "version": "1.0.0",
  "platforms": ["linux"],
  "entrypoint": "controllo_intellij.sh",
  "sha256": "<actual-artifact-sha256>",
  "timeoutSeconds": 15,
  "requiresElevation": false,
  "outputSchema": "baradwatchu.check-result.v1"
}
```

This is an illustrative manifest, not a finalized wire contract. Do not accept client-supplied `requiresElevation` as authority to grant privileges.

## 7. Trust, enrollment and privileged operations

### 7.1 Enrollment

- First installation requires an authorized administrative enrollment step; USB/offline bootstrap is a supported candidate, not mandatory for all deployments.
- Prefer one-time short-lived enrollment credentials; **never distribute the server/CA private signing key to clients**.
- Each endpoint generates its own keypair locally; use TPM, OS key store or secure enclave protection where available. Server registers device identity and public key/certificate.
- Authenticate communications (TLS, preferably mTLS or equivalent per-device credentials); provide revocation, rotation and lost-device recovery.
- Cryptographic authorization does **not** itself grant root/admin privileges; OS permissions and installed privileged components do.

### 7.2 Privilege boundaries

- The long-running agent should be non-privileged wherever feasible.
- L0/L1 must measure which checks are feasible without elevation on each platform. Insufficient privileges produce ERROR in Checkpoint 1 (UNKNOWN remains a future aggregate), never PASS.
- If required, use a separately authenticated and tightly scoped privileged helper. Never expose arbitrary shell, unrestricted process execution, arbitrary file write or arbitrary command-line flags through the helper.
- Helper verifies caller identity, typed operation, arguments, authorization, expiration, target device, replay protection and local constraints independently.
- Remediation commands must be explicitly implemented and allowlisted; signed server instructions do not bypass these checks.
- Remediation must support approval policy, dry-run where meaningful, audit trail, bounded execution, post-action audit and rollback/recovery where feasible.

### 7.3 Candidate future remediation operations (L3, not L1)

`SET_SCREEN_LOCK_TIMEOUT`, `CONFIGURE_APPROVED_DNS`, `CONFIGURE_PASSWORD_POLICY`, `START_OS_UPDATES`, `RESTART_APPROVED_SERVICE`, `CONFIGURE_BROWSER_POLICY`. Each requires platform-specific safety analysis; high-impact changes may need local user/admin approval or a maintenance window.

## 8. Functional requirements

| ID | Requirement | Target |
|---|---|---|
| FR-AUD-001 | Run local offline audit without server or UI | L1.1 CP1 local slice implemented/tested; fleet contract deferred |
| FR-AUD-002 | Execute built-in checks through a common interface | L1.1 CP1 local slice implemented/tested; fleet contract deferred |
| FR-AUD-003 | Produce versioned JSON results with evidence and reason codes | L1.1 CP1 local slice implemented/tested; fleet contract deferred |
| FR-AUD-004 | Expose an explicit CLI audit command and useful exit codes | L1.1 CP1 local slice implemented/tested; fleet contract deferred |
| FR-SRV-001 | Register and authenticate endpoints | L1.2 |
| FR-SRV-002 | Ingest, validate and retain audits and evidence metadata | L1.2 |
| FR-SRV-003 | Show device inventory, compliance status and audit history in Angular | L1.2 |
| FR-SRV-004 | Export JSON, CSV and PDF audit reports | L1.2 |
| FR-UI-001 | Launch local Angular status UI without admin rights | L1.3 |
| FR-UI-002 | UI must not be required for audit, notification or remediation | L1.3 |
| FR-POL-001 | Enable/disable and parameterize each check from server | L1.2 |
| FR-POL-002 | Assign policies per device and group | L1.2 |
| FR-POL-003 | Version/sign/hash policy and detect drift | L1.1–L1.2 |
| FR-POL-004 | Retain last trusted policy for offline audit | L1.1 |
| FR-CUS-001 | Register local custom scripts/binaries with manifest | L1.1 |
| FR-CUS-002 | Require matching server authorization and local artifact | L1.1–L1.2 |
| FR-CUS-003 | Verify content digest, version, platform and permissions | L1.1 |
| FR-CUS-004 | Bound execution and standardize custom results | L1.1 |
| FR-CUS-005 | Report missing/mismatched checks as coverage errors | L1.1–L1.2 |
| FR-MPL-001 | Support Ubuntu, Fedora and Arch adapters | L2.1 |
| FR-MPL-002 | Support Windows Service and Windows checks | L2.2 |
| FR-MPL-003 | Support macOS LaunchDaemon and macOS checks | L2.3 |
| FR-MPL-004 | Evaluate platform applicability centrally | L2.4 |
| FR-FIX-001 | Execute only typed, authorized remediation operations | L3.1 |
| FR-FIX-002 | Request/approve/track remediation from server | L3.2 |
| FR-FIX-003 | Verify remediation by a fresh audit | L3 |
| FR-MON-001 | Schedule periodic and boot-time audits | L4.1 |
| FR-MON-002 | Track drift, notifications, trends and alerts | L4.2 |
| FR-GOV-001 | Manage agent lifecycle and approved configuration distribution | L5.1 |
| FR-GOV-002 | Manage roles, exceptions, groups and enterprise integrations | L5.2 |

## 9. Non-functional requirements

- **NFR-SEC:** secure defaults, least privilege, no arbitrary remote execution, protected credentials, authenticated IPC, signed policies and immutable/tamper-evident server audit history where feasible.
- **NFR-PRIV:** collect minimum device/user data necessary for compliance; configurable retention, redaction and access control. No passwords or full license secrets in reports.
- **NFR-PORT:** architecture supports Linux/Windows/macOS; OS-specific checks must report unsupported features honestly.
- **NFR-REL:** offline audits continue despite network outage; buffered results sync later with idempotency and bounded local storage.
- **NFR-OBS:** structured logs, correlation IDs, check duration and actionable errors without leaking secrets.
- **NFR-EXT:** checks are modular, versioned and testable independently; custom checks never modify core binaries.
- **NFR-PERF:** background operation must avoid disruptive CPU, disk, network or battery usage; concrete resource budgets established by benchmark during L1.
- **NFR-COMPAT:** explicit support matrix for OS versions, architectures and security APIs; support boundaries are documented and tested.
- **NFR-TEST:** automated unit, contract and integration tests; test doubles must not be misrepresented as real OS compliance results.
- **NFR-DEPLOY:** server can run on-premises on Linux without mandatory third-party cloud services.

## 10. Initial contracts and CLI (L0 design targets)

Define versioned schemas for:

```text
shared-contracts/
  device.schema.json
  policy.schema.json
  check-manifest.schema.json
  check-result.schema.json
  audit-report.schema.json
  enrollment.schema.json
  remediation-request.schema.json   # design only until L3
```

These are **logical artifacts**, not a mandate to create a third Git repository. Since the workspace has two independent repositories, decide in L0 how to publish and pin shared schemas (e.g. versioned package or generated copies with compatibility tests). Avoid silently drifting copies.

Example desired CLI, subject to L0 design:

```bash
baradwatchu-agent audit --offline --output report.json
baradwatchu-agent status
baradwatchu-agent checks list
baradwatchu-agent policy show
```

Example result (illustrative):

```json
{
  "schemaVersion": "1.0",
  "deviceId": "endpoint-042",
  "policyVersion": 12,
  "policyDigest": "sha256:<digest>",
  "checkId": "SEC-011",
  "checkVersion": "1.0.0",
  "checkType": "builtin",
  "status": "SKIPPED",
  "reasonCode": "DISABLED_BY_POLICY",
  "observedAt": "2026-10-28T18:00:00Z",
  "evidence": []
}
```

The canonical wire format, timestamps, hashes, schema versioning, signing and validation behavior must be finalized in L0.

## 11. Roadmap and acceptance gates

**L0 — Foundation**
- Specify trust boundaries, device identity/enrollment, effective policy precedence, check contracts, evidence provenance, shared schema distribution, local IPC and privileged-helper boundaries.
- Freeze initial security-check catalog and classify per-platform privileges and applicability.
- Produce automated schema/contract validation tests and architecture decisions.
- **Gate:** both repositories can consume the same versioned schemas; sample built-in/custom results validate; security decisions and unresolved questions are documented. No full agent/server implementation required.

**L0.1.1 — Versioning & Distribution Foundation**
- Give Server and Client independent SemVer lifecycles, both initially `0.0.1`; root Cargo workspace version is authoritative, Rust packages inherit it, and Angular package/UI metadata sync from it. Product version remains distinct from wire/schema versions.
- Add non-starting Rust `--version`/`-V` and `--help`/`-h` output.
- Add both Linux source-installer interfaces: read-only distro/dependency audit, safe dry-run, unprivileged marked release cache/build-only workflow, strict no-build validation, staging, system/local prefixes, package ownership refusal, hash-manifest update/uninstall and data preservation. Do not install packages or configure services.
- Document package ownership, paths and lifecycle plans for Arch, Debian/Ubuntu and Fedora. Document Client Windows setup and macOS DMG plans, including privilege/signing requirements; do not produce those artifacts here.
- **Gate:** metadata and CLI versions agree; installer help/dependency/dry-run/argument/no-build tests pass; isolated manifest ownership/uninstall tests pass; Rust and Angular release outputs build on a supported Linux environment. Channels remain unclaimed until real artifacts pass target-platform install/update/uninstall tests.
- **L0.1.1 maintenance review (2026-10-29): implementation complete; remaining release/installer validation is technical debt.** Fixed a real startup defect: the manually built Tokio runtime had no enabled I/O drivers. Server now enables drivers, validates IP:port configuration before startup, returns actionable errors instead of panicking, separates configuration/router from process lifecycle, and implements SIGINT/SIGTERM graceful shutdown. At bootstrap review Server had 8 Rust tests (runtime/config/router/CLI) and Client 3 CLI/bootstrap tests; the Client suite is extended by Checkpoint 1. Rust format, Clippy with warnings denied, debug/release builds and tests pass. The agent verified `/health` in-process; its network attempts encountered sandbox `EPERM`. The operator subsequently confirmed real Server `/health` HTTP 200 with expected JSON, both Angular dev servers working, and launcher Ctrl+C stopping the services. Connection draining under load is not validated.
- Angular production builds and 4 version-tooling test cases per repo pass with Node 20.20.2/npm 10.8.2. `npm start` now resolves configured loopback dev-server targets (4200 Server, 4201 Client); it remains separate from Rust lifecycle. Node 20 >=20.11.1 is checked explicitly, `.nvmrc` selects 20, npm enforces engines, and version synchronization reads only `[workspace.package]`, supports read-only `--check`, and avoids rewriting unchanged files. Both Cargo.lock files and `.nvmrc` exist and are tracked; npm locks remain untracked but are not ignored. Client npm v1 lock still emits legacy/alias metadata warnings; no existing dependency versions were upgraded. Tokio signal support added two locked transitive crates. Previous npm audit attempts and a current registry DNS probe remain blocked; vulnerability status is unknown.
- Installers now use an isolated Angular source workspace and project cache for dependency/build outputs; npm ci does not replace checkout node_modules. Cargo runs locked from the correct repository root. Fixed RPM ownership detection (only successful queries confer ownership), canonical-root/empty-path rejection, normalized failure exit codes, artifact integrity/glibc checks and cache-binary execution during no-build. Both syntax/ShellCheck and isolated actual-artifact install/update/uninstall, modified/data preservation, dry-run non-mutation, cache tampering/staleness and simulated RPM ownership checks pass. Full build-only was executed for both: Rust release stage passes; fresh npm ci is blocked by unavailable packages in the offline cache (`ENOTCACHED`). Incomplete caches are rejected, temporary workspaces cleaned, original node_modules preserved. Cache generation was also exercised with only npm ci provisioning substituted by the existing installed dependency tree: real Cargo/Angular builders completed and the generated v2 cache passed install/update/uninstall; this is not a successful fresh npm ci validation. Native package installs also encounter sandbox process/cache restrictions in diagnostics. No system installation, service modification or Git mutation occurred. HTTP/dev-server/launcher shutdown smoke is now operator-confirmed; complete fresh-cache source-build, real distro package-owner/dependency-audit matrices and vulnerability audits remain technical debt. Packaging formats/services remain deferred; no untested installer or audit path is marked passed.

**L1 — Audit & Reporting (pilot Linux, Fedora first)**
- **L1.1 Client Audit Agent:** standalone Rust service/CLI, read-only Fedora checks, offline policy cache, built-in and local custom check engine, JSON evidence, no UI dependency.
- **L1.1 / Checkpoint 1 — Standalone Audit Foundation:** authorized Client-only slice specified in §5.3; reusable domain, Fedora identity/cache-only updates/root encryption, human/JSON CLI and fixture-based automated validation. Policy cache, custom checks and service features in the broader L1.1 milestone are not included. Validation results are recorded in parent MEMORY.md; no automatic progression to Checkpoint 2.
- **Checkpoint 1 validation (2026-10-29):** 38 Rust tests passed (contracts/CLI/fixtures/real bounded subprocesses and kernel write-denial fixture), fmt, Clippy with warnings denied and locked offline debug/release builds passed. Both binaries execute human/JSON audit on this Arch host: identity PASS, two Fedora NOT_APPLICABLE, overall WARN/exit4; version/help/bootstrap compatibility verified. Fedora DNF5/root-storage observations are fixture-validated only (no Fedora runtime here), so target-host smoke remains open; no full Fedora acceptance or Checkpoint 2 progression is claimed.
- **L1.2 Server Audit & Reporting:** Linux backend, enrollment, per-device/group desired policies, audit ingestion, drift evaluation, historical storage, Angular dashboard and JSON/CSV/PDF exports.
- **L1.3 Client Status UI:** Angular local status page with desktop launcher; no background scheduling/notification ownership.
- **Gate:** a real Fedora endpoint completes an offline audit, syncs to server, shows correct assigned/disabled checks and produces a traceable report; custom check with missing or mismatched artifact is rejected/reported; agent runs without UI.
- **L1.4 — Linux Package Release (planned after L1.1 and L1.2):** produce Arch `pacman`, Debian/Ubuntu `.deb` and Fedora `.rpm` from the shared release payload. Add package-owned systemd units only after lifecycle review. **Gate:** actual artifacts pass clean install, upgrade, ownership-conflict, service-state and data-preserving uninstall tests on each target distro.

**L2 — Multiplatform**
- **L2.1 Linux:** Ubuntu, Fedora and Arch Linux adapters, package managers, encryption, authentication and desktop differences.
- **L2.2 Windows:** Windows Service, native check adapters, secure installation and local UI launcher.
- **L2.3 macOS:** launchd daemon, native check adapters, signing/notarization strategy as required and local UI launcher.
- **L2.4 Server platform awareness:** applicability, capabilities, platform/version support matrix and cross-platform reporting.
- **L2.5 Client Windows/macOS packaging:** signed Windows `setup.exe` with explicitly authorized service registration; signed/notarized macOS `.dmg` with admin-authorized LaunchDaemon installation. **Gate:** target-OS install, upgrade, service lifecycle, signing/notarization and uninstall/data-preservation tests pass.
- **Gate:** representative test endpoints on all required OS families run the assigned checks and produce comparable, correctly qualified results. **L1 + L2 together are the first fleet-wide audit release**.

**L3 — Controlled Remediation**
- **L3.1 Client:** typed allowlisted operations, privileged helper where necessary, explicit authorization, dry-run, rollback where feasible and post-fix audit.
- **L3.2 Server:** approval workflow, signed/authorized remediation requests, execution tracking and post-remediation certification from new evidence.
- **Gate:** unauthorized/replayed/unlisted operations fail closed; approved operations are logged and verified by fresh audit; no arbitrary remote shell.

**L4 — Continuous Compliance**
- **L4.1 Client:** periodic and boot-time audits, retry/buffering, notification dispatcher and user-session delivery helper.
- **L4.2 Server:** schedules, trend analysis, drift alerts, compliance notifications and historical comparisons.
- **Gate:** schedule/boot triggers and offline-to-online sync are tested without requiring an open UI.

**L5 — Fleet Governance**
- **L5.1 Client:** agent lifecycle, controlled updates and approved configuration deployment.
- **L5.2 Server:** enterprise groups, RBAC, exception approvals, policy governance and integrations.
- **Gate:** approved updates/configuration changes are traceable, reversible where practical and respect group/device policy and authorization.

Milestones may be broken into smaller checkpoints, but do not silently redefine acceptance gates. Client/server submilestones may proceed in parallel once their shared contract is stable.

## 12. Verification and agent workflow

- Work from the parent workspace and read `AGENTS.md`, this file and `MEMORY.md` before implementation.
- For each checkpoint: state scope, implementation plan, out-of-scope, touched repositories, tests and acceptance evidence.
- Execute appropriate automated tests and show actual commands/results; clearly disclose unavailable OS test environments.
- Prefer minimal, modular changes. No speculative L3–L5 implementation during L0/L1.
- Update `MEMORY.md` with a compact checkpoint, decisions, relevant paths and next action.
- After substantive changes, provide a concise operator-facing summary and list any manual Git steps; do not run prohibited Git mutations.
- Keep `README.md` (English) and `LEGGIMI.md` (Italian) aligned within each repository, including the correct project-specific subtitle.

## 13. Open decisions for L0

1. Finalize desktop UI packaging: Rust/Axum and Angular are the bootstrap baseline; browser launcher vs optional Tauri remains open.
2. Define canonical schema distribution across the two Git repositories without introducing an unwanted third repo.
3. Define effective policy precedence, offline expiration/staleness, assignment inheritance and exception approvals.
4. Define trusted evidence and certification wording for custom scripts, including what can actually be proven about software licensing.
5. Decide initial enrollment mode, USB bootstrap format, credential rotation and revocation.
6. Determine exact per-OS privileges for each check and how user-scoped policies are audited from a system service.
7. Specify storage retention, report signatures, audit immutability and initial authentication/RBAC for dashboard users.
8. Confirm corporate policy details and exceptions before production rollout; the 13 controls are a working baseline, not an external certification.
9. Establish test matrix, supported OS versions, architectures and CI approach.
10. Define first production deployment model, backups and operational ownership.

## 14. Explicit exclusions from initial MVP

- No arbitrary remote shell, generic sudo wrapper or script execution as root.
- No silent automatic remediation in L1.
- No requirement for a running GUI to audit or communicate with the server.
- No assumption that a locally reported PASS proves resistance to a compromised administrator/root account.
- No mandatory cloud provider, MDM replacement, remote desktop or software deployment platform in L1.
- No automatic distribution/execution of unknown custom scripts from the server in L1.
- No invented PASS results for unsupported, unobservable or insufficiently privileged checks.

---

**Current checkpoint:** L1.1 / Checkpoint 1 (§5.3), explicitly authorized independently of the remaining L0 design decisions. Finish its validation/handoff and obtain operator authorization before Checkpoint 2. Shared trust/policy/fleet-schema decisions remain open; do not treat this local observation schema as the completed fleet contract.
