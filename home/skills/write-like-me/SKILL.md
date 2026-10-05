---
name: write-like-me
description: >-
  Use when Robert asks to draft, rewrite, tighten, polish, or review prose in his voice, including
  design docs, strategy docs, proposals, technical explanations, and internal communication. Also
  use when turning Robert's notes into finished prose. Preserve another author's voice when asked;
  do not use for code, ordinary conversation, or document planning without prose to write.
---

# Write like Robert

Write the clearest version of what Robert means, not a polished substitute for it. His voice is
direct, concrete, technically grounded, and comfortable making a decision. The writing earns
confidence by showing the problem, the numbers, the workflow, and the consequences.

Read `references/examples.md` before drafting, rewriting, or reviewing prose in Robert's voice. It
distils the strongest patterns from available writing samples. Treat the examples as evidence
alongside the explicit preferences in this skill, not as a mandatory template.

## 1. Preserve the thought

When editing, keep the author's argument, confidence, terminology, and useful informality. Improve
the expression without quietly changing the decision.

1. Make the smallest change that materially improves the passage.
2. Keep concrete examples, strong claims, and explicit judgments.
3. Do not turn plain language into corporate language.
4. Do not make every sentence equally formal or polished. Natural directness is part of the voice.
5. Preserve uncertainty when evidence is incomplete. Do not strengthen a hypothesis into a fact.
6. If the meaning is ambiguous, ask rather than choosing the more polished interpretation.

When drafting from notes, identify the claim and its support before writing. Do not preserve the
notes' order when a clearer causal order exists.

## 2. State the point early

Give the reader the section's controlling point early. A reader should understand what question the
section answers before encountering implementation detail.

1. Open with the problem, recommendation, or behavior the section exists to explain.
2. Lead with the recommendation when its basis is already shared.
3. Use problem, evidence, decision when the evidence is necessary to make the decision credible.
4. Keep evidence next to the claim it supports.
5. End when the argument is complete. Do not add a ceremonial summary.

Prefer:

> We need one deployment path that developers can run locally and CI can reproduce.

Not:

> As the platform evolves, it is important to consider how deployment can support stakeholders.

## 3. Explain systems from the user's entry point

For a system, interface, or workflow, begin with what the user or caller does. Follow that action
end to end. Introduce each component when the path reaches it, not in an inventory at the start.

1. Name the actor and their concrete goal.
2. Show the entry point: the command, SDK call, request, file, or action they use.
3. Follow the request, artifact, or piece of data in chronological order.
4. At each step, say which component acts, what it does, and what it produces next.
5. Finish at the result the user observes.
6. Then explain internals, alternatives, or component details that the walkthrough made relevant.

Use headings such as `Overview of Development Workflow`, `Life of a Request`, `Life of a Feature`,
or `Life of a Piece of Data` when they accurately name the path. A numbered sequence is usually the
clearest form.

Do not open with a catalogue of services. A component list says what exists; an end-to-end path
explains how the system works. Use a component list afterward as a reference when needed.

## 4. Move from concrete to abstract

Make an abstraction earn its place with a problem or example.

1. Start with a real use case.
2. Name the smallest abstraction that makes the use case simpler.
3. Define its responsibility and boundary in plain language.
4. Give a concrete example immediately.
5. Show how it composes with the rest of the system.

A good definition says what a thing is, why it is grouped that way, and what becomes simpler as a
result. Avoid abstractions whose only justification is future flexibility.

## 5. Make claims testable

Replace adjectives with facts wherever the facts exist.

1. Use numbers for latency, throughput, cost, scale, time, and availability.
2. State the baseline when a target is relative.
3. Put comparable requirements in a table.
4. Distinguish a measured result, a target, and an estimate.
5. Name the concrete failure behind words such as `slow`, `complex`, or `unreliable`.

Prefer `10M rows in 20 minutes` to `fast processing`. Prefer `40ms p50, 90ms p95` to `low latency`.

## 6. Explain decisions where they bite

Do not collect every decision into detached rationale at the end. Explain a consequential choice
next to the interface or behavior it changes.

For each important choice, answer only what matters:

1. What did we choose?
2. What does the choice simplify or guarantee?
3. What do we give up?
4. Is it difficult to reverse?

Say `not initially`, `out of scope`, or `there is no real gain` when that is the reasoning. Do not
invent strategic language to make a deliberately small choice sound larger.

Describe alternatives when there was a real tradeoff. Compare them on named axes with a short table
when that is clearer than prose. Do not add rejected alternatives merely to make the work look
thorough.

## 7. Express simplicity already present

Make the source's design taste visible when it is already part of the argument: fewer moving parts,
high cohesion, low coupling, and no machinery without a demonstrated need. These are not permission
to redesign the system while editing its prose.

1. Describe the direct end-to-end path before exceptions when the source supports that ordering.
2. Explain an interface as small only when it is actually small.
3. Preserve the source's distinction between current requirements and deferred, reversible additions.
4. State component boundaries that the source establishes; do not invent new ones.
5. Do not turn speculative future needs into current design constraints.

## 8. Use the form that reads fastest

Use prose for an argument, ordered lists for a sequence, bullets for an unordered set, tables for
comparison, code for an interface, and diagrams for topology or flow. Do not explain the same point
in all five forms.

1. Keep paragraphs focused on one claim.
2. Use descriptive headings that say what the section answers.
3. Include a concrete interface or usage example when behavior would otherwise stay abstract.
4. Keep examples realistic and use the document's actual domain language.
5. Use bold sparingly for labels or the conclusion a reader must retain.
6. Use a plain dash, never an em dash.

Formatting supports the argument; it is not a substitute for one. Avoid excessive headings,
decorative callouts, repeated summaries, and lists created only to break up prose.

## 9. Voice

1. Use plain, precise words.
2. Prefer active constructions that name the actor or component.
3. Keep sentences compact, but allow a longer sentence when it carries one coherent causal chain.
4. Make recommendations directly.
5. Say why a detail matters.
6. Use `we` for an owned decision and name the user when describing their experience.
7. Retain useful domain terms; explain them instead of replacing them with vague language.
8. Be professional without sanding off conviction or occasional informality.

Robert's writing can say `which is fine`, `latency doesn't`, or `there is nothing to keep warm`
because the surrounding explanation makes the judgment precise. Do not add informality as a mannerism;
keep it only when it closes an argument cleanly.

## 10. Never

1. Add throat-clearing: `It is worth noting`, `In today's rapidly evolving landscape`, `As we can
   see`, `In order to`, `This comprehensive approach`.
2. Use management-consulting filler: `unlock`, `leverage`, `holistic`, `best-in-class`, `robust`
   without a concrete property, `stakeholder alignment` without naming the decision.
3. Repeat the introduction at the end of every section.
4. Hide the recommendation behind a balanced catalogue of options.
5. Replace a precise example with an abstract category.
6. Force an artificial three-part list or uniform paragraph rhythm.
7. Present implementation details before the reader understands the user workflow.
8. Add architecture, future-proofing, or caveats that the source argument does not require.
9. Smooth away a sentence's useful force merely because it sounds informal.
10. Use an em dash.

## 11. Drafting procedure

When asked to draft prose:

1. Identify the audience, decision or understanding required, and evidence available from context.
2. Write the section's controlling point first, then choose recommendation-first or
   problem-evidence-decision ordering as described in section 2.
3. Order the remaining support causally.
4. For systems, replace abstract architecture-first ordering with the user-entry-point path in
   section 3.
5. Add only the examples, numbers, interfaces, tables, or diagrams that make a claim concrete.
6. Cut every sentence whose removal loses no meaning.
7. Check the finished prose against section 10.

If the task is to plan a document rather than write prose, do not impose a generic structure from
this skill. Work out the document's audience, decision, and argument separately. Apply this skill
when drafting the resulting prose.

## 12. Editing and review procedure

When asked to rewrite or tighten:

1. State internally what the passage means before touching it.
2. Remove filler and repetition.
3. Order the point and its support as described in section 2.
4. Replace vague claims with existing concrete evidence; do not fabricate evidence.
5. Restore the actor and end-to-end sequence where passive architecture prose has hidden them.
6. Preserve terms, examples, confidence, and judgments unless they are the source of confusion.
7. Edit an identified file in place unless Robert asks for a proposed rewrite. For pasted prose,
   return the revision in chat. Explain edits only when asked or when a change could alter intent.

When asked to review writing, prioritize findings that affect the argument, clarity, evidence, or
reader's model. Do not produce a wall of copyediting preferences.
