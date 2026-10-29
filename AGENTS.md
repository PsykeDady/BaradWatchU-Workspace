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

## 5. Scope and operator control

- Implement only what the operator requests and what is consistent with `REQUIREMENTS.md`; ask before making material architectural or scope changes.
- Do not treat planned roadmap features as already implemented.
- After substantial work, provide a concise summary of changes, tests actually run and their results, remaining issues, and any manual Git commands the operator may wish to execute.
- Never claim tests passed or files were created without verifying them.
