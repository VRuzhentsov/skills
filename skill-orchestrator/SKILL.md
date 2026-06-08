---
name: skill-orchestrator
description: Orchestrate the user's custom skill ecosystem. Use when maintaining skill routing, SKILLS.md, custom skill repositories, repository taxonomy, install docs, or publishing boundaries. Do not use for generic third-party skill discovery or one-off use of an existing skill.
---

# Skill Orchestrator

Use this skill to manage a user's local skill ecosystem without mixing personal, private, and organization boundaries.

`SKILLS.md` is the ambient routing file for custom skill repositories and skill orchestration. Maintain that file when skill routing, repository taxonomy, or orchestration defaults change, while keeping this skill as the detailed operational workflow.

## Trigger Boundary

Use this skill for custom skill ecosystem work only:

- Maintaining `SKILLS.md`, skill routing rules, or skill repository taxonomy.
- Creating, improving, publishing, or installing a skill that lives in one of the user's custom skill repositories.
- Classifying a skill into the correct personal public, personal private, organization shared, or organization private source.
- Updating skill repository README install docs, repository taxonomy, or GitHub multi-account publishing setup.
- Moving, cloning, or publishing one of the user's skill repositories.

Custom skill ecosystem means user-owned repositories and boundaries defined in the user's local routing file.

Do not use this skill for generic third-party skill installation. A prompt like `install skill <third-party-skill-url>` should be handled as a normal external skill install, not as orchestration, unless the user explicitly asks to add, fork, classify, or maintain that skill in their custom repositories.

## Required Skill Delegation

Use companion skills for the parts they own:

- Invoke `skill-creator` whenever the user asks to create a new skill, improve an existing skill, tune skill descriptions, write evals, package a skill, or turn a repeated workflow into a skill.
- Invoke `grill-me` whenever requirements are being established, even if the request looks mostly clear. Use it to pin down repository classification, public/private boundary, organization/personal boundary, publishing target, and expected behavior before editing.

Apply this skill as the orchestrator around those specialist skills: choose the repository, preserve boundaries, check install docs, manage Git remotes, and verify the final state.

## Repository Taxonomy

Use the user's local `SKILLS.md` routing file as the single source of truth for repository classification. The repository names below are role descriptions, not prescribed local paths:

| Repository Role | Meaning | Use When | Common Shorthand |
| --- | --- | --- | --- |
| Personal public source | Portable public skills | The skill avoids organization-specific defaults, internal domains, private workflows, and machine-specific assumptions. | "personal skills repo" unless the user says private |
| Personal private source | Private personal skills | The skill is machine-specific, non-organization, or private personal context. | "personal private skills" |
| Organization shared source | Shared organization skills | The skill is organization-specific and safe for the intended team to use. | "work skills" or "shared skills" |
| Organization private source | Private organization skills | The skill is organization-specific but personal, experimental, sensitive, or not broadly distributable. | "personal work private skills" or "organization private skills" |

Keep custom skill repositories in predictable, documented locations so they are easy to discover and classify.

Do not maintain a duplicated inventory of individual skills in this skill. Discover current skills from each repository README and `**/SKILL.md` files when needed.

## Installed Skill Copies

Treat installed global skill copies under `~/.agents/skills/**` as runtime artifacts. Do not edit them directly except for emergency diagnosis. Make durable skill changes in the source repository selected from the taxonomy, then reinstall or update the installed copy from that source.

When changing an existing installed skill:

1. Identify the source repository from the user's local `SKILLS.md` and repository taxonomy.
2. Edit the source `SKILL.md`.
3. Commit and push the source repository change when requested.
4. Reinstall or update the skill from the source repository.
5. Verify the installed copy matches the source.

## Boundary Rules

Classify before creating or moving a skill:

- Use the repository taxonomy table as the decision matrix.
- Treat personal-private and organization-private as separate scopes. Personal-private is for the user's own non-organization or machine-specific context. Organization-private is for the user's private organization context.
- Ask one targeted classification question before writing files when the taxonomy does not clearly identify the destination.

Do not let personal-private skills drift into organization-private skills.

## Discovery Workflow

Start by inspecting the smallest relevant set of files:

1. Read the user's local `SKILLS.md` for current skill routing and repository classification.
2. Read the target repository `README.md`.
3. Search the target repository for `**/SKILL.md`.
4. Read one or two existing `SKILL.md` files to match style.
5. Check `git status --short`, `git remote -v`, and recent commits before committing or publishing.

Avoid broad sweeps across unrelated project repositories unless the user explicitly asks for inventory.

## Creating A Skill

Use the standard skill layout:

```text
skill-name/
└── SKILL.md
```

Use lowercase hyphenated names. The directory name and `name` frontmatter must match.

Required frontmatter:

```yaml
---
name: skill-name
description: What the skill does and when to use it.
---
```

Write the description as the trigger contract. Include concrete user phrases, repository names, filenames, or workflow names that should trigger the skill.

Keep the body practical:

- Scope and trigger boundaries.
- Repository or file paths.
- Step-by-step workflow.
- Safety and privacy constraints.
- Verification steps.

Prefer one `SKILL.md` unless the skill genuinely needs bundled scripts, references, or assets.

## README Install Documentation

Every skill repository README should include an install command with `<skill-name>`.

For public personal skills, prefer repository-addressed install docs with placeholders rather than a real user, organization, or repository name:

```bash
npx skills@latest add <owner>/<repo>/<skill-name>
```

For local/private/shared repositories, prefer local checkout install docs and substitute the target repository path from the user's local taxonomy:

```bash
npx skills@latest add <repo-path> --agent opencode claude-code --skill <skill-name> --global --yes
```

If the repo README lists included skills, update the list when adding or removing a skill.

Do not create a `Makefile` just because another skill repository has one. Add build/install automation only when the user asks for it or the repo already depends on it.

## GitHub Multi-Account Workflow

Use GitHub CLI for API-backed actions such as creating repositories, PRs, releases, and issues.

Check active accounts:

```bash
gh auth status -a
```

Switch API identity when multiple accounts are authenticated:

```bash
gh auth switch -h github.com -u <username>
```

Keep `gh` git operations on SSH:

```bash
gh config set git_protocol ssh -h github.com
```

Use account-specific SSH aliases for Git remotes only when they are documented in the user's local private configuration. Alias names such as `github-personal` and `github-work` are acceptable examples, but public skill repositories should avoid real organization names, private usernames, or internal hostnames:

```text
git@github-personal:<owner-or-org>/<repo>.git
git@github-work:<owner-or-org>/<repo>.git
```

Verify SSH identity without reading key material:

```bash
ssh -o BatchMode=yes -T git@github-personal
ssh -o BatchMode=yes -T git@github-work
```

Remember the split:

- `gh` active account controls API actions such as repository creation.
- Git remote SSH alias controls push/pull identity.
- SSH keys can push to an existing repository but cannot create a GitHub repository through the API.

## Publishing Workflow

Before publishing:

1. Inspect `git status --short` and `git diff`.
2. Stage only intended files.
3. Commit with a short imperative message.
4. Confirm the correct GitHub account and SSH alias.
5. Create the remote repository with `gh repo create` only while the correct account is active.
6. Push through the correct SSH alias.
7. Verify repository visibility and URL with `gh repo view`.

Use private visibility by default for private personal, shared organization, and private organization skill sources.

## Communication Pattern

Start with a concise contract:

```text
Target outcome: <what will change>. In scope: <repos/files>. Out of scope: <what will not be touched>.
```

Report concrete evidence when done:

- files created or changed
- detected skills
- install command present
- git commit hash, when committed
- remote URL and visibility, when published

If a repo boundary is ambiguous, pause and ask exactly one targeted question.
