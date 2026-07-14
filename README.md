# Portable Skills

Open-source skills for ticket workflows and resilient desktop/workstation setup.

This repository intentionally avoids company-specific defaults, private machine assumptions, project keys, domains, internal workflows, and private naming.

## Included Skills

- `create-ticket` - Create tickets in Jira or GitHub Issues with provider auto-detection and safe fallback payloads.
- `expectations` - Recover from unmet user expectations and persist the smallest verified behavior change that prevents recurrence.
- `skill-orchestrator` - Maintain custom skill routing, repository taxonomy, install docs, and publishing boundaries.
- `skill-ops` - Iteratively optimize a prompt/SOP document against a gradeable task set with a keep/revert loop, tracking editable targets in a machine-local registry.
- `start-ticket` - Turn an existing ticket into a concrete implementation plan with clarifying questions and repo exploration.
- `sustainable-home-system` - Set up resilient Fedora KDE workstation restore for desktop sessions, Chrome tabs, and tmux terminals.
- `ticket-markdown` - Keep local ticket notes consistent with an Obsidian-first markdown format and generic metadata.

## Install

Install any skill directly from this repository by replacing `<owner>`, `<repo>`, and `<skill-name>` with the target repository and skill directory name:

```bash
npx skills@latest add <owner>/<repo>/<skill-name>
```

Known skills:

```bash
npx skills@latest add <owner>/<repo>/create-ticket
npx skills@latest add <owner>/<repo>/expectations
npx skills@latest add <owner>/<repo>/skill-orchestrator
npx skills@latest add <owner>/<repo>/skill-ops
npx skills@latest add <owner>/<repo>/start-ticket
npx skills@latest add <owner>/<repo>/sustainable-home-system
npx skills@latest add <owner>/<repo>/ticket-markdown
```

## Quick Start

Example prompts after install:

- "Create a GitHub issue for this bug and save a local ticket note."
- "Update my skill routing and decide which skill repo this belongs in."
- "Start ticket https://github.com/owner/repo/issues/123 and draft an implementation plan."
- "Set up a sustainable home system on Fedora Bazzite so KDE windows, Chrome tabs, and terminal sessions recover after reboot."
- "Sync this Jira ticket into markdown with references and frontmatter."

## Publish Workflow

1. Run the release checklist in `RELEASE_CHECKLIST.md`.
2. Package each public skill into `.skill` artifacts.
3. Commit and push to `main`.
4. Verify install commands above from a clean environment.

## Design Principles

- Vendor-flexible: supports Jira and GitHub in one workflow.
- Safe defaults: explicit confirmation before creating or modifying remote tickets.
- Fallback-ready: emits paste-ready payloads/commands when API access is unavailable.
- Local-first notes: structured markdown notes for stable context and planning.

## License

MIT. See `LICENSE`.
