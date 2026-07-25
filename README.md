# Personal macOS dotfiles

A public-safe macOS development setup with useful defaults but no shell
framework or automatically started services:

- Bun for JavaScript and TypeScript
- `uv` for Python runtimes, projects and command-line tools
- plain zsh with Starship, fzf, zoxide and direnv
- Git, GitHub CLI, LazyGit, Delta and common data/search utilities
- Rust-built `eza` and `ast-grep` for clearer listings and structural code work
- Ghostty and Zed
- OpenCode Go for coding agents, with local MLX tools kept optional
- `just` for memorable repository-local commands

The repository deliberately contains no identity, API keys, private hosts,
corporate certificates or provider-specific credentials.

## Bootstrap

Review [`Brewfile`](./Brewfile) and [`install.sh`](./install.sh), then run:

```bash
git clone https://github.com/cwkendall/dotfiles.git ~/public/dotfiles
cd ~/public/dotfiles
./install.sh
```

After reviewing the repository, the equivalent one-liner on a new Mac is:

```bash
git clone https://github.com/cwkendall/dotfiles.git ~/public/dotfiles && cd ~/public/dotfiles && ./install.sh
```

The bootstrap uses Homebrew's conventional official `curl | bash` installer
when Homebrew is absent. Review the current installer URL and this script
before running it if that trust model is unsuitable.

The installer:

1. Installs Apple's Command Line Tools if missing and asks you to rerun it.
2. Installs Homebrew if needed.
3. Installs the uncommented Brewfile entries.
4. Backs up existing destinations under `~/.dotfiles-backup/`.
5. Links the tracked shell, Git, Ghostty, Zed and OpenCode configuration.
6. Prompts for any missing Git author name or email and stores it only in the
   untracked `~/.gitconfig.local` overlay.
7. Installs any public OpenCode skills explicitly uncommented in
   [`config/opencode/skills.txt`](./config/opencode/skills.txt). None are
   enabled by default.

It does not authenticate services, start background services or download local
models. It also does not install [`Brewfile.optional`](./Brewfile.optional).

After installation, authenticate only the tools you use:

```bash
gh auth login --hostname github.com --git-protocol https --web
opencode
```

The tracked Git configuration deliberately contains no identity. The installer
prompts for missing values, or they can be set later without modifying the
public repository:

```bash
git config --file ~/.gitconfig.local user.name "Your Name"
git config --file ~/.gitconfig.local user.email "your-address"
```

Inside OpenCode, run `/connect`, select **OpenCode Go**, paste the API key from
your Go subscription, then use `/models` to verify the current catalogue.
Credentials are stored locally by OpenCode and are never kept in this repo.

## Shell and project workflow

This setup uses plain zsh rather than Oh My Zsh. Native completion, fzf and
Starship provide the interactive shell experience without a plugin framework.

- `zoxide` learns frequently and recently visited directories. Use `z name` to
  jump to the best match and `zi` for an interactive fzf list.
- `direnv` loads and unloads a reviewed project's `.envrc` as you enter and
  leave it. A new or changed file remains blocked until `direnv allow` is run.
- `just` runs recipes from a repository's `justfile`, such as `just test` or
  `just dev`, without pretending to be a build system.
- `eza` provides the `ll` directory listing with Git state while leaving `ls`
  unchanged, and `ast-grep` performs syntax-aware searches and rewrites where
  a regular expression would be fragile.
- `lazygit` is installed by default but never invoked automatically. It is
  particularly useful for reviewing and staging agent-generated changes,
  while ordinary scripts and agents should continue to use `git` directly.

Direnv and just are default tools because they are small, language-independent
and useful across Bun, Python and infrastructure projects. Neither does
anything until a project opts in with an `.envrc` or `justfile`.

Bun is the default JavaScript runtime and package manager. Node and fnm are not
installed explicitly. Respect a project's existing lockfile and add Node only
if that project requires it.

## Keychain

Use Apple Passwords for website credentials and passkeys. Store a small number
of developer API keys as generic macOS Keychain entries:

```bash
keychain_store OPENAI_API_KEY
keychain_secret OPENAI_API_KEY
```

The first command prompts for the value without putting it in shell history.
Do not commit secrets or export every secret into every shell. Retrieve and
inject only the credential needed by the current tool.

## OpenCode and local AI

OpenCode uses its native Build and Plan agents plus the read-only Explore and
Scout subagents. The tracked global configuration adds one focused review
subagent, disables session sharing, asks before common destructive or
machine-wide shell commands and enables Context7 for current library
documentation. This deny-list complements the written agent guidance; it is
not a complete process sandbox. Playwright is present but disabled until
browser automation is actually needed.

The tracked configuration uses only OpenCode Go models. DeepSeek V4 Pro handles
Build and General work, GLM-5.2 handles Plan and Review, and DeepSeek V4 Flash
handles Explore, Scout and lightweight operations such as title generation.
This keeps routine navigation inexpensive while using a different model family
to review DeepSeek's implementation work. Kimi K3, MiniMax M3 and the rest of
the Go catalogue remain available for deliberate escalation through `/models`;
they are not assigned to frequently invoked agents. Credentials remain local.

No global Agent Skills are installed by default. The commented catalogue in
[`config/opencode/skills.txt`](./config/opencode/skills.txt) includes Matt
Pocock's maintained engineering workflows, Superpowers' completion
verification, this repository's focused macOS workstation stewardship,
Karpathy's concise coding guidelines and OpenAI's secure-coding guidance. The
older names `diagnose`, `to-prd`, `to-issues` and `write-a-skill` have been
superseded upstream by `diagnosing-bugs`, `to-spec`, `to-tickets` and
`writing-great-skills`. Uncomment only the entries wanted and rerun
`install.sh`. Skills are instructions, not always-on agents; OpenCode exposes
installed, permitted skills by name and description and loads their full
instructions only on demand.

Skill sources are intentionally human-readable owner/repository entries rather
than vendored copies, so rerunning the installer fetches their current upstream
versions. Review upstream changes before rerunning on an established machine;
the manifest is curated but not revision-pinned.

The catalogue also includes opt-in frontend art direction, design-system
extraction, shadcn/ui, motion craft, UI review, Three.js, cinematic scroll,
threat modelling and MCP server development. For durable consistency, use a
selected skill to establish the design and record the resulting project-specific
tokens, component rules and interaction principles in `DESIGN.md`; do not load
several competing taste skills for every task.

[Rams](https://www.rams.ai/skill) is a complementary design reviewer rather
than a design generator. Its free `/rams` command performs a stateless,
surface-level accessibility and visual-consistency pass; its hosted MCP and
GitHub App provide the commercial scored engine. Rams uses its own installer
rather than the standard skills manifest, so it is deliberately not run by
this bootstrap. Review its current installer before opting in manually:

```bash
curl -fsSL https://rams.ai/install | bash
```

Commenting an installed standard skill does not uninstall it. Remove one
explicitly with:

```bash
bunx skills remove SKILL_NAME --global --agent opencode --yes
```

Re-enable it by uncommenting the manifest line and rerunning the installer.
For a temporary logical block without uninstalling, add the skill name with a
`deny` rule under OpenCode's `permission.skill`; use `ask` when it should remain
available only after approval. There is no native enable/disable command in the
skills CLI.

The setup deliberately omits Oh My OpenAgent and similar orchestration plugins.
They add model routing, large agent teams and parallel execution, but also add
configuration, prompt and maintenance overhead. OpenCode's native agents and
on-demand skills are the better baseline; add an orchestration layer only after
a repeated need for coordinated parallel sessions appears.

oMLX is a commented option and is not an OpenCode provider in this setup.
Uncomment it only for repeated local inference where keeping models warm,
batching requests or reusing KV caches is valuable. It stays stopped after
installation; start it manually only for the task that needs it.

For private dictation, OpenSuperWhisper is in `Brewfile.optional`. Handy is a
good lighter cross-platform alternative, but is best installed from its
official release until its package-manager story settles. Install one, not
both.

## Optional bundle

The main `Brewfile` is the default workstation. `Brewfile.optional` is one
separate bundle containing shell QA, container, cloud, data, browser,
dictation and local-AI tools. Every entry has a comment explaining its purpose.
The optional bundle installs the small, complementary `hf`, `llmfit`, `macmon`
and `mlx-lm` tools, but no model weights. Overlapping model servers, desktop
managers, harnesses and workflow TUIs remain commented out.

Review it and remove anything unwanted before installing it; running this
command installs every uncommented option, including the larger Brave and
OpenSuperWhisper desktop applications:

```bash
brew bundle --file ~/public/dotfiles/Brewfile.optional
```

Homebrew Bundle supports uv tools directly, so the optional bundle's
`uv "snowflake-cli"` entry is equivalent to:

```bash
uv tool install snowflake-cli
```

For AWS and Snowflake development, the relevant optional entries are AWS CLI,
OpenTofu, Snowflake CLI, DuckDB and xan. `~/.local/bin` is already on `PATH`, so
uv-installed commands such as `snow` are available in a new shell. DuckDB
queries local CSV, JSON and Parquet extracts with SQL; xan provides fast,
streaming CSV inspection and transformation.

AWS Vault and Granted are documented as commented alternatives, not installed
together. Use AWS Vault when long-lived access keys must be stored in macOS
Keychain. Prefer Granted for an IAM Identity Center/SSO-first account and role
switching workflow.

Use OpenTofu with the standard AWS provider first. Add the `awscc` provider
only where a Cloud Control resource fills an actual coverage gap. AWS CDK is
not required. Install SAM per project when local Lambda or API Gateway testing
is useful.

The optional bundle uses Colima plus the Docker command-line tools instead of
Docker Desktop. After installing those options, merge the Homebrew plugin
directory into `~/.docker/config.json` so conventional `docker compose` and
`docker buildx` commands can find their plugins on Apple Silicon:

```json
{
  "cliPluginsExtraDirs": [
    "/opt/homebrew/lib/docker/cli-plugins"
  ]
}
```

Preserve any existing keys in that file rather than replacing it wholesale.
For occasional Vercel work, prefer `bunx vercel` or a project dependency over a
global CLI. Brave is optional for Chromium DevTools and built-in ad/tracker
blocking; Safari remains the zero-install default.

## Optional local models on Apple Silicon

The local-AI tools serve different purposes rather than forming one required
stack. Installing the optional bundle adds the first four entries but does not
download weights or start a service:

| Tool | Use it for |
| --- | --- |
| `hf` | Search the Hub, maintain a curated Collection, download models and inspect the shared cache. |
| `llmfit` | Rank models against the current Mac's available hardware before downloading them. |
| `macmon` | Observe Apple Silicon GPU, CPU, memory and power while local inference runs. |
| `mlx-lm` | Lean, direct text generation, batch classification and fine-tuning. |
| `mlx-vlm` | Direct image, audio, video and omni-model prompts. This is the primary Gemma 4 CLI. |
| `llm` + `llm-mlx` | Convenient pipes, templates, aliases and searchable prompt logs for text models. |
| oMLX | A manually started server for repeated or concurrent calls where a warm model and cache reuse matter. |
| LM Studio | An optional polished desktop browser and MLX/GGUF server; use instead of oMLX when its GUI workflow is preferable. |

Uncomment only the additional tools wanted in `Brewfile.optional`, then run the
optional bundle. Avoid installing both oMLX and LM Studio until their distinct
workflows justify the overlap. If `llm` is enabled, add its MLX text-model
plugin separately:

```bash
llm install llm-mlx
```

The Hugging Face `hf` CLI is the simplest catalogue and download layer shared
by these runtimes. Search interactively from the terminal with:

```bash
hf models ls --search "gemma-4" --sort downloads --limit 20
```

The following commands prefetch selected weights into Hugging Face's cache
without loading them. Every command is commented out: choose a model and remove
its leading `#` when wanted. They are never run by `install.sh` or either
Brewfile.

```bash
# About 5.2 GB: the practical everyday image/audio/text model on a 24 GB Mac.
# hf download mlx-community/gemma-4-e4b-it-4bit

# About 11 GB: the 12B Unified omni model; use on demand rather than keeping warm.
# hf download mlx-community/gemma-4-12B-4bit

# About 12 GB: community MLX conversion of the 21B REAP-pruned 26B-A4B model.
# This is not an official Google or Cerebras checkpoint; review its model card first.
# hf download deadbydawn101/gemma-4-21b-REAP-Tool-Calling-mlx-4bit

# About 5.6 GB: strong general, coding and vision alternative; use with mlx-vlm.
# Apache 2.0; this is the best first non-Gemma model to compare on this machine.
# hf download mlx-community/Qwen3.5-9B-MLX-4bit

# About 5 GB: predictable text-only instruction following, tool calls and RAG.
# Apache 2.0; use with mlx-lm for structured batch and enterprise-style tasks.
# hf download mlx-community/granite-4.1-8b-4bit

# About 2-3 GB: fast text-only classification, routing, coding and tool use.
# Uses NVIDIA's Nemotron open-model licence; review it before commercial use.
# hf download mlx-community/NVIDIA-Nemotron-3-Nano-4B-4bit

# About 2.2 GB: compact text-only reasoning, maths and code under the MIT licence.
# Use with mlx-lm when latency matters more than broad multimodal capability.
# hf download mlx-community/Phi-4-mini-instruct-4bit
```

`mlx-lm`, `mlx-vlm` and `llm-mlx` also download missing models automatically on
first use, so prefetching is optional. The cache normally lives under
`~/.cache/huggingface/`; never commit model weights to this repository. On a
24 GB fanless Mac, the 4-9B models are the comfortable daily tier, 12B is an
on-demand tier, and the 21B REAP model is an experiment with limited memory
headroom. REAP removes inactive experts from the original 26B-A4B weights; it
reduces storage and memory but is a community-derived model whose quality and
provenance need more scrutiny than the established conversions above. Larger
MoE models may compute with only a few active parameters per token, but their
full quantized weights still consume memory; do not treat active parameter
count as the amount of RAM required.

Zed stays intentionally small. It loads reviewed direnv environments and
automatically installs only the Terraform, GitHub Actions and Dockerfile
extensions. Its native support already covers the common Git, terminal,
JavaScript/TypeScript, Python, JSON, YAML and Markdown workflows. Keep VS Code
as a project-specific fallback only when an extension has no practical Zed
equivalent, such as AWS Toolkit or a specialised container-management UI.

## Coding agents and harnesses

OpenCode is the only coding-agent CLI installed by default. It is an established
open-source, multi-provider harness and avoids installing several overlapping
front ends. Claude Code and Codex are also leading choices, but are best added
only when their model subscriptions or sandbox behaviour provide a concrete
advantage. Most developers need one primary coding agent, not every agent.

The practical July 2026 pattern is less exotic than the marketing: use one
strong interactive coding agent, give it concise repository instructions and
small tasks, and close the loop with deterministic tests, linters, review and
Git. Claude Code, Codex, OpenCode, Amp and IDE agents such as Cursor are the
main front ends; the durable advantage comes from the harness around them, not
from running all of them. `AGENTS.md`/`CLAUDE.md`, on-demand skills, scoped tool
permissions, worktrees, CI and human approval are the common building blocks.

More autonomous tools fit into distinct layers:

| Layer | Current examples | Add it when |
| --- | --- | --- |
| Bounded loop | Ralph-style loops, test-fix-review hooks, autoresearch-style optimise-and-measure cycles | A task has a reliable machine-checkable success condition and a strict budget. |
| Parallel orchestration | Agent Orchestrator, Conductor, FirstMate and managed background agents | Coordinating several independent worktrees is repeatedly faster than supervising one agent. |
| Personal persistent agent | Hermes Agent | Scheduled research, messaging, memory and reusable workflows matter beyond a single repository. |
| Memory/context add-on | Native session history, Context Mode, AgentMemory or OpenMemory | Repeated rediscovery is measurable; start with one system and keep its store inspectable. |
| Isolation | Native agent sandboxes, containers or OpenShell | Work is unattended, code is untrusted, or credentials and host files need a hard boundary. |

Hermes is currently the interesting experiment for a persistent personal agent:
it can retain factual memory, create procedural skills from completed work and
revise those skills later. That is useful compounding configuration, not true
recursive self-improvement of the underlying model. Its separate
`hermes-agent-self-evolution` project uses evaluations plus DSPy/GEPA to propose
better skill or prompt variants; only skill optimisation is implemented today,
while tool descriptions, system prompts, code evolution and a continuous loop
remain planned. Treat generated memories and skill edits as untrusted diffs to
review, not as an authority allowed to rewrite the workstation unattended.

[FirstMate](https://github.com/kunchenguid/firstmate) is a young agent distro
for supervising several coding-agent sessions in separate worktrees. It is not
a Homebrew package or another model: its repository supplies instructions,
skills and scripts to an existing Claude Code, Codex, OpenCode, Pi or Grok
harness. Try it later if coordinating parallel agents becomes a recurring
problem; it adds tmux/session, worktree and fleet-management complexity that a
minimal bootstrap does not need.

[No Mistakes](https://github.com/kunchenguid/no-mistakes) is a separate local
Git push gate that runs review, tests, lint, documentation, PR and CI checks in
an isolated worktree. It is more immediately useful than multi-agent
orchestration when agent-written changes need a repeatable shipping gate, but
it is still young and deliberately changes the push workflow. Review and test
it on a disposable repository before adopting it; do not bootstrap it
silently.

Keep further agent extensions small. Project `AGENTS.md` files should define
project-specific setup, architecture and checks; the global file supplies only
personal operating defaults and tool guidance. Add another MCP, skill or agent
only for a repeated workflow that the built-in tools and curated skills cannot
handle. A large extension set increases credentials, prompt surface and
maintenance without necessarily improving results.

## Memory and self-improving agents

Do not install an agent-memory stack by default. Start with Git-tracked
`AGENTS.md` files, decisions, runbooks and normal agent session history. They
are inspectable, portable and sufficient until repeatedly re-explaining prior
work becomes a measurable problem.

Obsidian is a good local Markdown notebook, not a required agent memory layer.
Add it only if its human note-taking and linking workflow is useful in its own
right. The public Obsidian skills teach agents its Markdown, Bases, Canvas and
CLI formats; they do not turn a vault into semantic memory.

If long OpenCode sessions later waste context on large logs, API responses or
browser output, evaluate `context-mode` first as a local context-efficiency
plugin. If cross-session, cross-agent semantic recall is the actual problem,
evaluate `agentmemory` instead. Do not start with both: each captures session
data, injects context and adds local state that must be audited, pruned and kept
free of secrets.

The future OpenCode target state is kept as comments and disabled entries in
the single tracked [`opencode.jsonc`](./config/opencode/opencode.jsonc), rather
than split across profiles or fragments. Enable Context Mode by uncommenting
its `plugin` line. Enable AgentMemory or Playwright by changing the relevant
MCP's `enabled` value to `true`. Review the Git diff and restart OpenCode after
any change. Do not activate both Context Mode and AgentMemory until there is
evidence that their overlapping capture and recall behaviour is useful rather
than noisy.

Hermes Agent is a separate autonomous-agent harness rather than an OpenCode
upgrade. Its memory, session search, learned skills and scheduled/messaging
workflows are useful for an always-on personal agent. Keep it outside this base
bootstrap and run it in a reviewed Docker or OpenShell policy when experimenting
with broad tools or credentials. Its separate self-evolution project optimises
skills against evaluations and requires human review; it is not a safe reason
to let an agent rewrite these dotfiles unattended.

"Karpathy Brain" usually refers to Andrej Karpathy's LLM Wiki pattern: source
material is periodically compiled into linked, curated Markdown knowledge. It
is a useful transparent pattern, not an official product to install. The
existing `karpathy-guidelines` skill is coding discipline and is unrelated to
persistent memory.

[Karpathy's autoresearch](https://github.com/karpathy/autoresearch) is another
separate idea: an agent repeatedly changes one ML training program, runs a
fixed-time experiment and keeps only changes that improve a locked metric. It
is not a general memory or self-improving-dotfiles tool. The official project
requires an NVIDIA GPU and does not support macOS CPU or MPS, so it has no
default or inactive local configuration here. Reuse its bounded
hypothesis-run-measure-keep loop only where a project has a trustworthy,
isolated evaluation—not for unattended changes to the development machine.

## Agent sandbox reference: OpenShell

[NVIDIA OpenShell](https://github.com/NVIDIA/OpenShell) is promising for
running OpenCode, Codex, Claude Code and, through NemoClaw, Hermes Agent behind
filesystem, process and network policies. On macOS it can use containers or
Hypervisor.framework-backed microVMs.

It is currently alpha software and installs a local gateway service, so it is
documented rather than included in the bootstrap. When needed, review its
current release notes and install it with the already-installed uv:

```bash
uv tool install -U openshell
openshell sandbox create -- opencode
```

Do not assume a container alone is a sufficient security boundary. Review the
OpenShell policy and mounted paths before giving an agent credentials or source
code.

## Local AWS emulator reference

Do not install an AWS emulator globally. Add one to the project or its Compose
or Testcontainers setup when its tests need it. These projects are young and
must be backed by tests against real AWS before release:

| Tool | Prefer it when |
| --- | --- |
| [Floci](https://github.com/floci-io/floci) | Broad, lightweight LocalStack-compatible coverage matters more than exact edge-case fidelity. This is the best first trial for general local development. |
| [fakecloud](https://github.com/faiscadev/fakecloud) | Its smaller supported service set covers the project and deeper behaviour, real Lambda execution or cross-service wiring matters. Note its AGPL licence. |
| [MiniStack](https://ministack.org/) | A project needs only common Community-era LocalStack APIs and its tests prove compatibility. It is currently too new to be the default recommendation. |
| [Moto](https://github.com/getmoto/moto) | Python unit tests need fast in-process boto3 mocks rather than a wire-compatible local cloud. |

None meaningfully emulates Amazon Connect. Test Connect integration code with
SDK stubs locally, use SAM where Lambda is involved, and verify end-to-end
behaviour against an isolated real AWS development environment.

Avoid multiple JavaScript version managers, multiple local model servers and a
large global MCP or skill bundle. Add capabilities to the project that proves
it needs them.
