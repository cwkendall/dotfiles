---
name: managing-macos-workstation
description: Audits and safely maintains macOS Homebrew packages, public dotfiles, backups and recovery settings. Use when reviewing, recommending, installing, updating or removing workstation software, changing dotfiles bootstrap behaviour, or assessing backup readiness.
compatibility: macOS with Homebrew; package and system mutations require user approval
---

# Managing a macOS workstation

Keep the workstation reproducible and recoverable without turning maintenance
into a framework or browsing for tools during unrelated work.

## Homebrew stewardship

- Treat `Brewfile` as the minimal default workstation and `Brewfile.optional`
  as the opt-in capability catalogue. Keep both portable and give every package
  a plain-English comment explaining its purpose.
- Before recommending a package, check whether an installed or declared tool
  already covers the need. Inspect candidates with `brew search` and `brew info
  --json=v2`; prefer Homebrew core/casks or an upstream official tap. Consider
  maintenance, licence, overlap and fit before classifying a tool as default,
  optional or a commented candidate.
- Consult Homebrew's 30-day install-on-request analytics only when asked what is
  current or popular. Popularity is a discovery signal, not sufficient reason
  to install something.
- Ask before installing, tapping, updating, upgrading, removing, cleaning up or
  starting a service. Record approved global software in the appropriate
  Brewfile. Use `--no-upgrade` for routine reconciliation unless upgrades were
  requested, and never force `brew bundle cleanup` against only one bundle.
- Report disabled, deprecated, vulnerable or materially outdated packages;
  never silently change them.

For a read-only audit, use the smallest relevant subset of:

```bash
HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --file Brewfile
HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --file Brewfile.optional
HOMEBREW_NO_AUTO_UPDATE=1 brew outdated --json=v2
brew bundle dump --file=/tmp/installed.Brewfile --force
```

Compare the temporary snapshot with both tracked bundles. Do not confuse
transitive dependencies with intentionally installed packages, and remove the
temporary snapshot when finished.

## Public dotfiles hygiene

- Never commit secrets, recovery material, personal or employer details,
  account identifiers, private hosts or machine-specific absolute paths.
- Prefer standard configuration and direct symlinks over custom management
  machinery. Inspect and preserve an existing destination before replacing it.
- Keep bootstrap changes idempotent and reviewable. Validate syntax and links;
  do not execute an install script merely to test it.
- Keep optional target-state settings commented in their owning config instead
  of scattering fragments. Update documentation whenever bootstrap behaviour
  or installed paths change.

## Backups and recovery

- Distinguish Git history, iCloud synchronisation and actual backups. Prefer
  encrypted Time Machine plus an independent encrypted offsite backup, and test
  restores periodically rather than trusting job status alone.
- Ask before changing Time Machine, FileVault, iCloud optimisation, exclusions,
  retention or recovery settings. Never expose encryption recovery keys,
  backup passwords, password-manager recovery kits, MFA recovery codes, private
  keys or cloud credentials.
- Before destructive cleanup, confirm irreplaceable data has a real, restorable
  backup. Exclude reproducible caches, model weights or container disks only
  after user review.
- Prefer standard backup products over custom scripts unless they cannot meet a
  demonstrated requirement.
