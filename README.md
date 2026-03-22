# Portable Ticket Skills

Open-source skills for creating, planning, and documenting tickets across Jira and GitHub.

This repository intentionally avoids company-specific defaults (project keys, domains, internal workflows, and private naming).

## Included Skills

- `create-ticket` - Create tickets in Jira or GitHub Issues with provider auto-detection and safe fallback payloads.
- `start-ticket` - Turn an existing ticket into a concrete implementation plan with clarifying questions and repo exploration.
- `ticket-markdown` - Keep local ticket notes consistent with an Obsidian-first markdown format and generic metadata.

## Install

Install directly from this repository:

```bash
npx skills@latest add VRuzhentsov/skills/create-ticket
npx skills@latest add VRuzhentsov/skills/start-ticket
npx skills@latest add VRuzhentsov/skills/ticket-markdown
```

## Quick Start

Example prompts after install:

- "Create a GitHub issue for this bug and save a local ticket note."
- "Start ticket https://github.com/owner/repo/issues/123 and draft an implementation plan."
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
