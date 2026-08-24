---
name: git-workflow
description: Use before any Git branch, switch/checkout, commit, push, pull, merge, rebase, worktree, or pull-request operation. Enforces the user's two-path repository workflow: direct verified default-branch delivery or a branch with an opened PR; never leave a standalone remote branch.
---

# Git Workflow

## Purpose

Use this skill before changing Git state or remote repository state. It applies to any repository and governs branch selection, branch creation, checkout/switch, commits, pushes, pulls, rebases, merges, worktrees, and pull-request operations.

The user permits exactly two delivery paths:

1. **Direct default-branch delivery** — commit and push to the repository's verified default branch (`main`, `master`, or another actual configured default) when the repository's own rules permit it.
2. **Pull-request delivery** — create a scoped branch only to open the corresponding PR in the same task.

A pushed branch without an opened PR is not an acceptable result.

## Preflight

Before any Git mutation:

1. Read the repository's local instructions and relevant workflow skills.
2. Inspect `git status --short --branch`, remotes, default branch, Git author identity, and existing staged paths.
3. Classify the repository and apply its stricter local policy. A repository may be direct-default, PR-only, or have additional hosting/account requirements.
4. Preserve unrelated tracked and untracked changes. Do not stash, clean, reset, discard, or stage them to make Git operations convenient.

Use the literal verified default branch. Do not assume `main` where the repository uses `master`, or vice versa.

## Choose the Delivery Path

### Direct default-branch delivery

Use this path only when the repository's local instructions allow it and the requested scope fits that repository's direct-delivery policy.

1. Verify the local default branch and its remote-tracking branch are current.
2. Stage and commit only the requested paths.
3. Push normally to the verified default branch.
4. Fetch/read back and confirm the local and remote default branches point at the intended commit.

Do not create a branch for direct-default delivery.

### Pull-request delivery

Use this path when repository rules require review, the requested scope requires review, or the user explicitly asks for a PR.

1. Start from the verified current remote default branch.
2. Create one purpose-named branch for the requested change.
3. Commit and push only the intended scope.
4. Open the PR immediately in the same task, targeting the verified default branch.
5. Read back the PR: URL, open state, source branch, destination branch, and source commit.
6. Do not merge a PR without the user's explicit instruction.
7. After the PR is merged, remove the source branch when the repository policy permits and refresh the persistent checkout safely.

Never use a feature, fix, documentation, experiment, or temporary branch merely as a place to push work. If a PR cannot be opened, stop and report the blocker; do not leave the branch as a substitute for a PR.

## Dirty Checkouts and Worktrees

When the persistent checkout is dirty or is on a user-owned branch, keep it untouched. Use a detached temporary worktree from the verified remote default branch for the selected delivery path. Transfer only the named files, verify the exact diff, and remove the temporary worktree after the remote result is verified.

A detached worktree is isolation, not a delivery branch. Do not use it to bypass a repository's PR-only policy.

## Scope and Safety

- A commit/push request authorizes Git transport, not unrequested content edits.
- Stage only the requested or already-established deliverables.
- Run `git diff --check` on the intended diff; do not use a failure as permission to rewrite unrelated content.
- Never force-push, reset, discard, rebase shared history, or delete a branch without explicit user authorization.
- Before a hosting write, confirm the active API identity and Git remote match the repository scope.

## Completion Evidence

For every Git delivery, report:

- the selected path: direct default branch or PR;
- the verified default branch and remote;
- the commit ID and exact committed files;
- either remote default-branch synchronization or the PR URL/open state/source/destination;
- intentionally preserved unrelated working-tree state.
