---
name: adr-draft
description: Draft, review, create, update, accept, reject, deprecate, or supersede Architecture Decision Records (ADRs). Use for significant technical decisions, architecture alternatives, hard-to-reverse choices, ADR folders or indexes, and when an agent needs the decision rationale, scope boundaries, implementation guidance, or verification evidence before changing code.
---

# ADR Draft

Use ADRs to preserve the reasoning behind significant technical decisions. A useful ADR is not a generic form. It is a self-contained decision record that lets future engineers and agents understand the constraints, rejected options, scope boundaries, and evidence without reconstructing the original discussion.

## Trigger boundary

Use this skill when a decision:

- changes how a system is built, operated, secured, integrated, or evolved;
- is expensive to reverse or establishes a reusable pattern or boundary;
- has credible alternatives and meaningful trade-offs;
- needs to guide later implementation, review, onboarding, or follow-up work.

Do not create an ADR for routine implementation within an established pattern, a narrow bug fix, a formatter or style preference, or a disposable experiment. Do not silently create a second decision record for a choice already captured by an ADR; update the existing record or write a new one that explicitly supersedes it.

## Start with repository evidence

Before drafting or changing an ADR:

1. Read repository guidance and search for ADR locations, including `docs/adr/`, `docs/decisions/`, `architecture/adr/`, and `.adr-dir`.
2. Read the closest one to three ADRs, any ADR index, and relevant project instructions.
3. Determine the established directory, numbering, filename, H1 style, metadata, status vocabulary, language, and heading structure.
4. Inspect the underlying decision evidence: relevant code, tests, issue or specification, operational constraints, and authoritative external documentation when applicable.
5. Identify whether the request creates a new record, revises a proposed record, or changes a previous decision.

Existing repository convention is authoritative. Do not impose a new location, title format, frontmatter, template, or status model when the repository already has one. Surface conflicts in the available evidence instead of guessing.

If no convention exists, use `docs/adr/NNNN-short-kebab-title.md`, start at `0001`, continue zero-padded numbering, and title it `# NNNN — Decision title`. Keep metadata minimal unless the repository has a metadata convention.

## Capture decision inputs

Establish enough evidence to write a decision that can be acted on responsibly:

- Decision and status: proposed, accepted, rejected, deprecated, or superseded.
- Context: problem, forces, constraints, affected users or systems, current implementation, and why a decision is needed now.
- Decision drivers: measurable requirements, risks, operational limits, compatibility needs, team or ownership constraints, and reversibility.
- Options: the viable alternatives and their concrete failure modes or trade-offs.
- Chosen direction: boundaries, interfaces, invariants, migration strategy, and versioning where relevant.
- Consequences: benefits, costs, risks, follow-up work, and conditions that would reopen the decision.
- Evidence: tests, benchmarks, code paths, environment limits, or external source material that support the conclusion.

Do not invent rationale, constraints, consensus, test results, implementation state, or outcomes. Ask for missing material only when it changes the decision materially. Otherwise label uncertainty or use a concise placeholder in a proposed ADR.

## Draft at the decision's actual depth

Match the closest existing ADR's section map. Do not force a short template onto a complex decision. For a technical decision with several coupled choices, make `Decision` a set of named subsections. Each subsection should connect a local problem, the choice, rejected alternatives, and the resulting invariant or constraint.

Use diagrams, pseudocode, interfaces, commands, schemas, or code snippets when they clarify an architectural boundary or make the choice implementable. Keep them decision-relevant: they should explain why the boundary exists or what future work must preserve, not duplicate implementation detail that belongs in source code.

A complete technical ADR commonly contains the following material. Adapt headings to the repository rather than adding every heading mechanically:

```markdown
# NNNN — Decision title

## Status
Accepted. State what is implemented now, what remains proposed, and what is deliberately deferred.

## Context
Explain the problem, current state, constraints, decision drivers, and why the decision is needed now.

## Decision

### Architecture and boundaries
Show the layers, contracts, ownership, invariants, or diagram needed to make the decision understandable.

### Decision-specific rationale
Explain each consequential choice alongside the alternatives rejected and why they do not meet the drivers.

### Deferred work and non-goals
State what is deliberately not being built, why, and what future condition could revisit it.

### Verification strategy
Embed tests, benchmarks, observability, or known environment limits beside the decision they substantiate when that is clearer than a standalone checklist.

## Consequences
State positive effects, costs, risks, compatibility or migration impacts, follow-ups, and the accepted trade-offs.
```

## Alternatives and non-goals

Name credible alternatives. For each, describe the relevant advantage and the specific reason it was not selected. Put an alternative next to the decision it informs when that preserves the causal reasoning; use a dedicated alternatives section when it improves scanning.

Explicitly state deliberate exclusions and deferred work. Non-goals prevent scope creep and make it possible to distinguish an accepted trade-off from an omission. Include the trigger that would justify reopening a deferred choice when one is known.

## Implementation and verification

An accepted ADR must be actionable, but the evidence can be organized in the form that best fits the repository:

- If the repository uses implementation-plan or checklist sections, follow that convention.
- Otherwise, embed concrete implementation constraints, files or components affected, tests, and verification evidence in the relevant decision subsections.
- Distinguish proof already obtained from future validation. State environment or hardware limitations plainly and name the remaining validation boundary rather than implying unperformed testing.
- Prefer precise, checkable claims: exact behavior, invariants, test names, benchmark criteria, compatibility assumptions, or observable outcomes.

Do not claim that an ADR's decision is implemented merely because it has been accepted. Status text should separate accepted direction, completed work, follow-up work, and unverified assumptions.

## Lifecycle management

Treat ADRs as historical records:

- Keep previous ADRs. Do not delete them because the decision changed.
- Change a proposed ADR to accepted or rejected only when the decision has actually been made.
- When replacing an accepted decision, write a new ADR that references the earlier record and marks the relationship according to repository convention.
- Use deprecated for an ADR whose guidance is no longer appropriate but remains historically useful.
- Update an ADR index if the repository maintains one, preserving its ordering and format.

## Review before writing

Before creating or materially revising a record, present the proposed path, title, status, and concise draft or section outline for review when the user has not already supplied approved content. Make the requested decision, open questions, evidence gaps, and deferred items visible.

For a confirmed write:

1. Create or update only the intended ADR and any established index.
2. Preserve unrelated documents and existing history.
3. Re-read the final Markdown and confirm links, numbering, status references, and supersession links are internally consistent.
4. Run the repository's documentation checks when available. At minimum, run `git diff --check`.
5. Report the path, status, decision, evidence or limitations, follow-up items, and checks actually run.

## Public-safe reference patterns

This skill combines convention-first drafting, rich technical decision analysis, explicit non-goals, lifecycle management, and implementation-ready verification. Apply those patterns generically; do not copy private system details, organization-specific workflows, credentials, or machine-local paths into public ADRs.
