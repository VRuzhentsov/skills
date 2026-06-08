---
name: start-ticket
description: Bootstrap implementation planning from Jira or GitHub tickets using provider-aware context fetch, clarifying questions, and repo exploration. Trigger on start/plan ticket prompts, ticket URLs, or ticket keys.
---

# Start Ticket

Turn an existing ticket into an executable implementation plan.

## Provider model

Support Jira and GitHub.

Detect provider from ticket reference:

- Jira keys (`PROJ-123`) or Atlassian URLs.
- GitHub issue URLs or `owner/repo#123`.

If detection is ambiguous, ask one targeted question with the `question` tool and confirm provider before fetching.

## Workflow

1. Parse ticket reference and provider.
2. Fetch ticket context.
3. Ask clarifying questions.
4. Explore repository context.
5. Produce implementation plan with TDD-first testing approach.
6. Optionally sync/update local note with `ticket-markdown`.

## Context fetch

### Jira

- `atlassian_getJiraIssue`
- `atlassian_getJiraIssueRemoteIssueLinks`
- Fetch related issues from links/parent/subtasks when available.

### GitHub

- `gh issue view` for title, body, labels, assignees, and status.
- Follow linked issues/PRs from issue body when present.

If provider tooling is unavailable, ask user for the ticket body and metadata directly, then continue planning.

## Clarifying questions

Always ask a baseline set before finalizing the plan.

Required dimensions:

1. Outcome (what must be true when done)
2. Scope and non-goals
3. Acceptance criteria
4. Impacted users/systems
5. Constraints (timeline, performance, security, compatibility)
6. Data/schema implications
7. Rollout/backward compatibility
8. Quality gates (tests, lint, typecheck, build)

Rules:

- Ask one targeted question at a time using the `question` tool.
- Include your best assumption and ask user to confirm or correct.
- Prefer closed choices with custom override when possible.

## Repository exploration

- Search for modules matching ticket keywords.
- Locate existing tests and similar implementations.
- Check recent history related to ticket key or topic.

## Plan output format

Plan
- Step 1
- Step 2
- Step 3

Tests
- TDD decision and rationale
- First failing test(s) to write
- Full verification commands

Risks
- Risk 1 and mitigation
- Risk 2 and mitigation

Unresolved questions
- ...

## Draft sync

When asked to save planning notes, load and apply `ticket-markdown` and store the draft in the resolved local ticket path.

## Safety guardrails

- Do not include company-specific identifiers or private URLs in reusable plan templates.
- Separate assumptions from confirmed facts.
- Keep action steps concrete and testable.

## Trigger examples

- "start ticket PROJ-421"
- "Plan this issue: https://github.com/owner/repo/issues/88"
- "Create implementation plan from this Jira"
