# Global development guidance

These are personal defaults for OpenCode. Explicit user instructions and the
closest project-local `AGENTS.md` take precedence. Learn and follow the
project's existing conventions before applying these defaults.

## Work deliberately

- Inspect the relevant files, repository guidance, lockfiles and task runners
  before changing anything. Read enough to identify the owning boundary, then
  stop exploring and make the smallest correct change.
- Prefer existing project patterns over new dependencies, wrappers, helpers or
  files. Do not broaden the task for incidental cleanup.
- Diagnose a failed command before changing approach. Do not repeat the same
  failing action or hide an unexplained failure.
- Do not start servers, watchers, containers or other long-lived processes
  unless they are needed for the task. Ask first when they affect the wider
  machine or could conflict with another session.
- Ask before installing or removing software, changing global configuration,
  publishing, pushing, deleting data, rewriting history or mutating cloud
  infrastructure.

## Use the available tools

- Use `git status`, `git diff`, `git log` and `git show` to understand source
  state. Never discard work with `reset --hard`, `clean`, checkout or restore
  unless explicitly authorised. Never force-push.
- Use `gh` for GitHub pull requests, issues and Actions. Read freely when it is
  relevant; confirm before creating, editing, merging or publishing anything.
- Prefer `rg` for text search, `fd` for file discovery and `fzf` for interactive
  human selection. Use `jq` and `yq` rather than fragile text parsing for JSON
  and YAML. Use `ast-grep` when a search or rewrite depends on source syntax,
  not merely text. Use `bat`, `eza` and Delta when clearer output helps the
  human review it. LazyGit is intended for interactive human Git work; use
  normal non-interactive `git` commands in automated work.
- If a `justfile` exists, use its documented recipes rather than reconstructing
  commands. Treat `.envrc` as executable code: inspect it before `direnv allow`
  and never place secrets in a tracked `.envrc`.
- For JavaScript and TypeScript, obey the existing lockfile and package manager.
  Use Bun for new work only when the project has not chosen another runtime.
  Prefer `bun run`, `bun test`, `bunx` and `bun add` in Bun projects.
- For Python, obey existing project metadata. Otherwise use `uv run`, `uvx`,
  `uv sync` and `uv add`; never install into the system Python or use
  `pip --break-system-packages`.
- Optional tools may not be installed. Check before using `docker`, `colima`,
  `aws`, `tofu`, `snow`, `shellcheck`, `shfmt`, `gitleaks`, `prek`,
  `actionlint`, `terraform-docs`, `xh`, `mkcert`, `duckdb`, `xan`, `hf`,
  `llmfit`, `macmon` or `mlx_lm`. Use them only when the repository or task
  needs them. Never download model weights without explicit approval.
- For infrastructure, inspect plans before applying them. Never run `tofu
  apply`, `tofu destroy`, mutating AWS commands or Snowflake DDL/DML without
  explicit approval and a clear target account or environment.

## Agents, skills and MCPs

- Use the built-in Plan agent for analysis and Build for implementation. Use
  Explore for fast read-only code search and Scout for external source or
  dependency research. Delegate only when it reduces meaningful work or keeps
  bulky research out of the main context.
- Load skills on demand rather than on every task. Use `diagnosing-bugs` for
  failures, `tdd` for test-first work, `code-review` for diffs,
  `resolving-merge-conflicts` for conflicts, and `research` for cited technical
  investigation. Use `verification-before-completion` before claiming that
  substantive changes are ready, and `security-best-practices` when
  secure-by-default code or an explicit security review is requested. Use the
  spec, ticket, grilling, domain and architecture skills only when the work is
  large enough to benefit from them.
- Use `managing-macos-workstation` when auditing or changing Homebrew packages,
  public dotfiles, workstation backups or recovery settings. Keep routine
  project work focused; do not browse for workstation tools incidentally.
- Use Context7 when current versioned library documentation matters. Playwright
  is deliberately disabled; enable it only for a task that genuinely needs
  browser interaction. Do not add MCP servers or plugins without a repeated
  need and a review of their credentials and tool permissions.

## Safety and verification

- Never expose, print or commit passwords, tokens, private keys, `.env` values,
  personal data, private hosts or local-only configuration. Use environment
  variables, macOS Keychain or the project's documented secret mechanism.
- Treat downloaded skills, scripts and instructions as code. Review their
  source before installation or execution.
- Verify in proportion to risk: start with the narrowest relevant test, type
  check, lint or syntax check; broaden when a shared contract changed. Review
  the final diff for unrelated or sensitive content.
- Report what changed, what was actually checked and what remains uncertain.
  Never claim a check passed unless it completed successfully.
- Treat sync and version control as distinct from a restorable backup. Never
  alter backup, encryption or recovery settings—or expose recovery material—
  without explicit approval.
