# Release Checklist

Use this checklist before publishing or tagging a release.

## 1) Content Safety

- [ ] Run a private-data scan across repo text for company identifiers, domains, project keys, and internal links.
- [ ] Confirm no private skills are present in this repo (public repo should contain only `create-ticket`, `start-ticket`, `ticket-markdown`).
- [ ] Confirm examples use neutral placeholders (`TICKET-123`, `owner/repo`, `https://example.com/...`).

Suggested scan command:

```bash
grep -RniE "atlassian.net|eleven|BND-|CM\b|internal runbook|private" .
```

## 2) Skill Validation

- [ ] Validate `create-ticket` SKILL frontmatter and structure.
- [ ] Validate `start-ticket` SKILL frontmatter and structure.
- [ ] Validate `ticket-markdown` SKILL frontmatter and structure.

Commands:

```bash
python -m scripts.quick_validate ./create-ticket
python -m scripts.quick_validate ./start-ticket
python -m scripts.quick_validate ./ticket-markdown
```

Run these from the skill-creator script directory.

## 3) Package Public Skills

- [ ] Package `create-ticket`.
- [ ] Package `start-ticket`.
- [ ] Package `ticket-markdown`.
- [ ] Verify artifacts exist under `dist/`.

Commands:

```bash
python -m scripts.package_skill ./create-ticket ./dist
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
npx skills@latest add VRuzhentsov/skills/create-ticket
npx skills@latest add VRuzhentsov/skills/start-ticket
npx skills@latest add VRuzhentsov/skills/ticket-markdown
```

Suggested smoke prompts:

- `create-ticket`: "Create a GitHub issue for login timeout with labels bug and backend."
- `start-ticket`: "Start ticket owner/repo#42 and produce implementation plan with TDD-first tests."
- `ticket-markdown`: "Create local markdown note for TICKET-123 with related links and frontmatter."

## 5) GitHub Release Hygiene

- [ ] `git status` is clean.
- [ ] Commit message clearly describes release prep.
- [ ] `README.md` install commands still match repository path.
- [ ] Tag/release notes include what changed and any migration notes.
