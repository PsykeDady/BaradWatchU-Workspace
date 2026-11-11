# AGENTS.md — BaradWatchU

> These instructions apply to AI agents launched from the parent `BaradWatchU/` workspace. They govern both child repositories: `baradwatchu-server/` and `baradwatchu-client/`.

## 1. Startup: read context, then wait

On **every new session**, before analyzing or modifying the project:

1. Look for `MEMORY.md` in the workspace root (also recognize `memory.md` if that is the existing filename).
2. If it exists, read it to recover project context, architecture, repository structure, current progress, and prior decisions.
3. If it does not exist, create `MEMORY.md` with a minimal, accurate initial structure based only on verified workspace contents and available requirements.
4. **Stop and wait for the operator's instructions.** Do not autonomously start implementing tasks, refactoring, testing, or modifying project files just because you loaded the context.

Read `REQUIREMENTS.md` when needed to understand requirements, scope, or the integrated roadmap. It is the reference for planned work; `MEMORY.md` is the compact operational index.

## 2. Keep MEMORY.md useful and token-efficient

Create and **continuously update** `MEMORY.md` as work progresses, including after meaningful implementation, architectural decisions, discovered constraints, or completed milestones.

`MEMORY.md` is **for AI agents, not human-facing documentation**. Optimize it for the **lowest practical token cost** when another agent takes over an arbitrary task:

- Keep a compact overview of the product and the two repositories.
- Maintain a concise, navigable project tree or path index, describing the purpose of important files and directories. Update paths when the structure changes.
- Record architectural boundaries, interfaces, contracts, important commands, and where to find the relevant code/tests.
- Record decisions **and their rationale or trade-offs** when needed to avoid revisiting settled questions.
- Track the current milestone, completed steps, pending steps, blockers, and known pitfalls.
- Prefer terse English, structured sections, paths, tables, and links/references to source files over verbose explanations or copied code.
- Keep it factual and synchronized with the actual repository state; distinguish **implemented**, **planned**, and **unverified**.
- Remove obsolete details and consolidate duplicates instead of endlessly appending notes.
- Never store secrets, tokens, credentials, private keys, or sensitive operational data.

When a task changes the code or a decision, update `MEMORY.md` **within that task**, without waiting for a separate reminder. Do not create an additional memory file inside either repository.

## 3. Git: read-only for the agent

The agent may run **read-only Git commands** to inspect history, branches, tags, diffs, status, and repository metadata (for example: `git status`, `git diff`, `git log`, `git show`, `git branch --list`, `git remote -v`).

**Never execute Git commands that mutate the working tree, index, refs, history, or remote state**, including but not limited to:

- `git add`, `git commit`, `git push`, `git rm`
- `git checkout`, `git switch`, `git reset`, `git restore`, `git clean`, `git rebase`, `git merge`, `git cherry-pick`
- `git pull`, `git fetch`, `git tag` creation/deletion, `git branch` creation/deletion
- `git stash`, `git init`, `git config` changes

If such an operation is needed, **explain the exact command to the operator and let them run it manually**. Never circumvent this restriction through shell scripts, aliases, libraries, IDE tools, or another agent.

This restriction concerns Git operations; ordinary file edits explicitly requested by the operator are permitted.

## 4. Workspace and documentation boundaries

Expected layout:

```text
BaradWatchU/
├── AGENTS.md                 # Local agent rules; not versioned
├── MEMORY.md                 # Local AI handoff context; not versioned
├── REQUIREMENTS.md           # Local requirements and integrated roadmap; not versioned
├── baradwatchu-server/       # Independent Git repository
│   ├── README.md             # English
│   └── LEGGIMI.md            # Italian
└── baradwatchu-client/       # Independent Git repository
    ├── README.md             # English
    └── LEGGIMI.md            # Italian
```

- The three root Markdown files remain **outside both Git repositories** and must not be moved into them or versioned.
- There is **no separate `ROADMAP.md`**: roadmap and acceptance checkpoints belong in root `REQUIREMENTS.md`.
- Keep each repository's `README.md` and `LEGGIMI.md` equivalent in technical meaning, commands, capabilities, and limitations. Preserve their approved Tolkien-inspired subtitles.
- Do not assume a path exists merely because it appears in the expected layout; inspect the workspace when needed.

## 5. One ecosystem, two distinct responsibilities

**BaradWatchU-Client is the implementation reference for shared behavior and visual conventions.** Before implementing or changing a Server feature that has a Client equivalent, inspect the actual Client code, configuration, assets, tests and documentation. Match existing contracts and user-visible behavior; do not invent competing schemas, layouts, installers or algorithms. Do not blindly copy Client-only features into Server. If exact reuse is impractical, preserve observable compatibility and document the reason. Ask the operator before introducing a divergent contract.

- **Client:** audits its own host, evaluates requirements, produces and caches audit JSON/PDF, maintains local history and consent, and exposes its own local dashboard.
- **Server:** manages recognized/trusted Clients, requests remote audits, tracks requests, receives/reads/displays/prints Client-produced reports and validates their integrity. **It must not run a host audit of itself or generate a new audit report.**
- **Shared contracts:** requirement definitions/configuration where applicable, audit JSON interpretation, report display/printing, PDF styling, integrity/SHA-256 verification, localization, branding, token/session-handling conventions where applicable, and installer UX. Inspect actual semantics before porting; do not equate an SHA-256 integrity check with cryptographic proof of authorship.
- **UI:** Server dashboard must match Client branding, logo, design language and relevant report presentation. Its homepage is the managed/recognized Client fleet, with a request-audit action per Client, not a fictitious Server audit. Include Server settings; preserve Server-specific navigation and functionality.
- **Installers:** use the Client installer's structure, conventions, validation and lifecycle as the reference. **Installation scope/privileges and authentication mode are independent:** a root/system-wide Server installation may run in LOCAL mode. Do not interpret LOCAL as `--local`/per-user installation.
- **Coexistence:** Client and Server may be installed and running on the same host. Use distinct service ports, names, runtime state, identities, trust stores and session/token namespaces; inspect both apps for collisions. Deliberately shared preferences (e.g. PDF theme) may use common settings; do not accidentally share secrets or private keys.
- **Server configuration:** resolve an explicit path via `BARADWATCHU_SERVER_CONFIG` first, then the applicable system location under `/etc/baradwatchu`, then the user location under `~/.config/baradwatchu`, following verified file naming/conventions. If no configuration exists, default the Server to **LOCAL** mode. Keep mode configurable and document precedence; do not infer mode from installation privileges.
- **Authentication:** LOCAL is for trusted loopback-only operation without Google; OIDC retains its existing authentication and admin authorization. Never expose an unauthenticated LOCAL bypass over a network or in OIDC mode. An environment variable such as `$USER` may label a local operator but does not prove the browser user's identity, particularly for a service account. Google real-account testing may be deferred until final validation; preserve and test OIDC behavior with isolated tests in the meantime.
- **Remote audit security:** preserve existing Server–Client Ed25519/mTLS trust, local Client consent and the 120-second consent deadline. Requester names are informational metadata, not substitutes for trust or authorization. Do not alter the remote protocol or Client behavior beyond the operator's requested scope.

When changing shared behavior, verify both applications against the same contract. Prefer the smallest coherent changes and reuse over parallel implementations. Do not add speculative backward compatibility, enterprise infrastructure or features for hypothetical deployments without a requirement.

## 6. Scope and operator control

- Implement only what the operator requests and what is consistent with `REQUIREMENTS.md`; ask before making material architectural or scope changes.
- Do not treat planned roadmap features as already implemented.
- After substantial work, provide a concise summary of changes, tests actually run and their results, remaining issues, and any manual Git commands the operator may wish to execute.
- Never claim tests passed or files were created without verifying them.
