# Portable Skills

Open-source skills for ticket workflows and resilient desktop/workstation setup.

> `create-ticket` is intentionally project-local: the target project's `.agents/skills/create-ticket/` owns its ticket-creation behavior. It is not a public repository skill.

This repository intentionally avoids company-specific defaults, private machine assumptions, project keys, domains, internal workflows, and private naming.

## Included Skills

- `expectations` - Recover from unmet user expectations and persist the smallest verified behavior change that prevents recurrence.
- `skill-orchestrator` - Maintain custom skill routing, repository taxonomy, install docs, and publishing boundaries.
- `skill-ops` - Iteratively optimize a prompt/SOP document against a gradeable task set with a keep/revert loop, tracking editable targets in a machine-local registry.
- `start-ticket` - Turn an existing ticket into a concrete implementation plan with clarifying questions and repo exploration.
- `sustainable-home-system` - Set up resilient Fedora KDE workstation restore for desktop sessions, Chrome tabs, and tmux terminals.
- `ticket-markdown` - Keep local ticket notes consistent with an Obsidian-first markdown format and generic metadata.

## Install

No `make` command or repository-specific install wrapper is required. Install any individual skill by substituting the repository location and its directory name:

```bash
npx skills@latest add <owner>/<repo>/<skill-name>
```

From a local clone, run the same skill-agnostic flow from the repository root:

```bash
npx skills add . --global --agent <agent-name> --skill <skill-name> --yes
```

Replace `<skill-name>` with a directory listed above. The source repository remains canonical; rerun the appropriate command after updating a skill.

## Quick Start

Example prompts after install:

- "Create a GitHub issue for this bug and save a local ticket note."
- "Update my skill routing and decide which skill repo this belongs in."
- "Start ticket https://github.com/owner/repo/issues/123 and draft an implementation plan."
- "Set up a sustainable home system on Fedora Bazzite so KDE windows, Chrome tabs, and terminal sessions recover after reboot."
- "Sync this Jira ticket into markdown with references and frontmatter."

## Design Principles

- Vendor-flexible: supports Jira and GitHub in one workflow.
- Safe defaults: explicit confirmation before creating or modifying remote tickets.
- Fallback-ready: emits paste-ready payloads/commands when API access is unavailable.
- Local-first notes: structured markdown notes for stable context and planning.

## License

MIT. See `LICENSE`.
