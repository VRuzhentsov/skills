---
name: expectations
description: Recover from unmet user expectations and make the appropriate future behavior durable. Use whenever a user says they expected something else, asks why an action was missed, says "I expected you to…" or "you should have…", or indicates that an immediate fix also needs to prevent recurrence.
---

# Expectations

Use this skill when the user identifies a gap between delivered behavior and a reasonable expectation. Resolve the immediate problem and make the smallest durable improvement that will prevent the same class of miss.

## Response Loop

Follow this order:

1. State the missed expectation in concrete terms.
2. Complete or repair the immediate user-visible task when it is still outstanding.
3. Identify the behavior change that would have prevented the miss.
4. Apply that change at the narrowest appropriate durable surface.
5. Verify the changed instruction, skill, memory, configuration, or automation.
6. Briefly state what changed and where.

Do not stop at "I will remember" when a durable instruction, skill, configuration, memory, or mechanical guard is appropriate.

## Choosing Where To Persist

Choose the smallest surface that will actually be available in future relevant work:

- **Existing skill:** The expectation belongs to a specific reusable workflow.
- **New skill:** The behavior applies across several workflows and has clear triggers.
- **Workspace instruction:** The rule is specific to a repository, environment, or all work in that workspace.
- **Configuration or automation:** The behavior is deterministic and can be enforced or checked mechanically.
- **Memory:** The expectation is a stable preference or contextual fact, rather than a procedure.

Before creating a new skill, search for a suitable existing umbrella. Extend that source instead of creating an overlapping skill whenever it can own the behavior clearly.

## Scope Control

Keep the correction proportional:

- Preserve the user's actual expectation; do not turn one correction into a broad unrelated policy.
- Avoid changes that make unrelated work slower, more hesitant, or less useful.
- Do not introduce services, public actions, credentials, or provider-specific workflows without explicit user direction.
- Do not rewrite unrelated instructions or skills while resolving one missed expectation.
- If the expectation conflicts with a higher-priority safety rule, explain the conflict and apply the closest safe alternative.

## Verification

Verify both the write and the future read path:

1. Confirm the intended source file, configuration, or automation changed.
2. Confirm the relevant runtime, project, or skill loader can discover it.
3. Run a focused check when the behavior is mechanically testable.
4. Report the evidence rather than asserting the change is complete without it.

## Reply Shape

Keep the closeout direct:

- Acknowledge the expectation without defensiveness.
- Separate the immediate repair from the durable behavior change.
- Name changed files, commands, or commits when applicable.
- Keep the response concise unless review is needed.
