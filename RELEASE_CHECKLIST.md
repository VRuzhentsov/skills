# Release Checklist

Use this checklist before publishing or tagging a release.

## 1) Content Safety

- [ ] Run a private-data scan across repo text for company identifiers, domains, project keys, and internal links.
- [ ] Confirm no private skills are present in this repo.
- [ ] Confirm examples use neutral placeholders (`TICKET-123`, `owner/repo`, `https://example.com/...`).

Suggested scan command:

```bash
grep -RniE "atlassian.net|eleven|BND-|CM\b|internal runbook|private" .
```

## 2) Skill Validation

- [ ] Validate `create-ticket` SKILL frontmatter and structure.
- [ ] Validate `skill-orchestrator` SKILL frontmatter and structure.
- [ ] Validate `skill-ops` SKILL frontmatter and structure.
- [ ] Validate `start-ticket` SKILL frontmatter and structure.
- [ ] Validate `ticket-markdown` SKILL frontmatter and structure.

Commands:

```bash
python -m scripts.quick_validate ./create-ticket
python -m scripts.quick_validate ./skill-orchestrator
python -m scripts.quick_validate ./skill-ops
python -m scripts.quick_validate ./start-ticket
python -m scripts.quick_validate ./ticket-markdown
```

Run these from the skill-creator script directory.

## 3) Package Public Skills

- [ ] Package `create-ticket`.
- [ ] Package `skill-orchestrator`.
- [ ] Package `skill-ops`.
- [ ] Package `start-ticket`.
- [ ] Package `ticket-markdown`.
- [ ] Verify artifacts exist under `dist/`.

Commands:

```bash
python -m scripts.package_skill ./create-ticket ./dist
python -m scripts.package_skill ./skill-orchestrator ./dist
python -m scripts.package_skill ./skill-ops ./dist
python -m scripts.package_skill ./start-ticket ./dist
python -m scripts.package_skill ./ticket-markdown ./dist
```

Run these from the skill-creator script directory.

## 4) Install Smoke Test

- [ ] Install each skill from GitHub.
- [ ] Run one smoke prompt per skill.
- [ ] Confirm provider detection works for Jira and GitHub references.
- [ ] Confirm fallback mode produces paste-ready payloads/commands.

Install commands:

```bash
npx skills@latest add <owner>/<repo>/create-ticket
npx skills@latest add <owner>/<repo>/skill-orchestrator
npx skills@latest add <owner>/<repo>/skill-ops
npx skills@latest add <owner>/<repo>/start-ticket
npx skills@latest add <owner>/<repo>/ticket-markdown
```

Suggested smoke prompts:

- `create-ticket`: "Create a GitHub issue for login timeout with labels bug and backend."
- `skill-orchestrator`: "Update my skill routing and decide which skill repo this belongs in."
- `skill-ops`: "Run the skill-ops loop on this SOP against my 5-case checklist and keep only edits that improve the score."
- `start-ticket`: "Start ticket owner/repo#42 and produce implementation plan with TDD-first tests."
- `ticket-markdown`: "Create local markdown note for TICKET-123 with related links and frontmatter."

## 5) GitHub Release Hygiene

- [ ] `git status` is clean.
- [ ] Commit message clearly describes release prep.
- [ ] `README.md` install commands still match repository path.
- [ ] Tag/release notes include what changed and any migration notes.
