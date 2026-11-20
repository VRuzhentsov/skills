---
name: project-skill-orchestration
description: Set up or audit the skill orchestration architecture inside a project repository. Use when adding project-local agent skills, creating a project's `dev` entry skill, splitting a project skill into scoped skills, deciding whether content belongs in a skill or in `docs/`, or unifying `AGENTS.md`/`CLAUDE.md` and `.agents/skills`/`.claude/skills`.
---

# Project Skill Orchestration

Use this skill to shape how agent skills are organized inside one project. It prescribes the architecture only: one entry skill, scoped skills, routing, and single sources of truth. Each project defines its own rules inside that structure.

For the workstation-level custom skill ecosystem (skill repositories, installation, publishing), use `skill-orchestrator` instead.

## One Entry Skill

- Give each project one main entry skill at `.agents/skills/dev/SKILL.md`.
- Make `dev` own the project's development process: the order of steps the agent follows and the checks it runs before handing work back.
- Route from `dev` to scoped skills, for example `backend`, `frontend`, `devops`, `ui-ux-design`, `testing`. State plainly which scope loads for which kind of change.
- Keep each scoped skill focused on its own area and link back to `dev` for the shared process.
- Use kebab-case names; the directory name matches the `name` frontmatter.

```text
.agents/skills/
├── dev/SKILL.md          # entry: process + routing
├── backend/SKILL.md
├── frontend/SKILL.md
└── testing/SKILL.md
```

## Skills Versus Docs

- Put project knowledge in `docs/`, for example `docs/code-style.md` and architecture docs. Docs serve humans and agents alike.
- Put agent process in skills: how the agent works and helps the developer, step by step, so the developer can predict the agent's behaviour.
- Reference docs from skills: say where to find the code style and which related docs to read at which step. Link to the doc; let the doc own its content.
- Treat a skill that dictates documentation content as a smell. Move that content into `docs/` and replace it with a link.

## Single Sources Of Truth

These are required:

- `AGENTS.md` is the only instruction file; `CLAUDE.md` is a symlink to it.
- `.agents/skills/` is the only skills directory; `.claude/skills` is a symlink to it.

Create the links from the repository root:

```bash
ln -s AGENTS.md CLAUDE.md
mkdir -p .claude
ln -s ../.agents/skills .claude/skills
git add CLAUDE.md .claude/skills
```

Commit them as git symlinks (mode `120000`), not as copied files. On Windows, enable Developer Mode or symlink privileges and set `git config core.symlinks true` before cloning or creating the links; otherwise git checks symlinks out as plain text files.

When a project already has content in both files or both directories, merge it into `AGENTS.md` and `.agents/skills/` first, then replace the duplicates with the symlinks.

## Audit Checklist

- [ ] `.agents/skills/dev/SKILL.md` exists and is the single entry skill.
- [ ] `dev` describes the development process and routes to every scoped skill.
- [ ] Each scoped skill has a clear area and no overlap with siblings.
- [ ] Skills describe agent steps only; project knowledge lives in `docs/` and skills link to it.
- [ ] No skill restates code style, architecture, or other doc content.
- [ ] `AGENTS.md` is the only instruction file; `CLAUDE.md` is a symlink to it.
- [ ] `.agents/skills/` is the only skills directory; `.claude/skills` is a symlink to it.
- [ ] `git ls-files -s CLAUDE.md .claude/skills` shows mode `120000` for both.
- [ ] Skill and directory names are kebab-case and match their `name` frontmatter.

Report each failed item with the file path and the smallest fix.
