---
name: explain-how-it-works
description: >-
  Use ONLY when Robert explicitly asks for a study note, final explanatory write-up, or synthesis
  of a technical topic. Produces a concise reference note in ~/brain/study/ from settled discussion
  and relevant source material. Do not use for code documentation, repository documentation,
  pointed technical questions, follow-up exploration, brainstorming, or ordinary explanations in
  chat.
---

# Explain how it works

Write the shortest self-contained note that captures the settled mental model. The default is a
clear reference, not a transcript, tutorial, essay, or exhaustive survey.

Pointed questions and exploratory follow-ups stay in chat. The output is a note in
`~/brain/study/` only after Robert explicitly asks for a write-up. Chat then gets a short pointer
to the note, not a second copy of the explanation.

`~/brain/study/databases.md` is the primary style reference. Read it before creating a note. Its
strengths are the target: it categorises the topic immediately, distinguishes commonly confused
terms, uses concrete production examples, and stops when the mental model is complete. Do not copy
its exact headings or force a table where one does not help.

## 1. Procedure

1. Review the exploration in the conversation and identify the conclusions that survived it.
2. Verify those conclusions against the relevant code or source material.
3. List `~/brain/study/` and search for a relevant note. Extend one if it already covers the topic.
4. Read `~/brain/study/databases.md` as the style reference.
5. Choose the smallest answer shape from §2. Use one settled example only when it shortens the explanation.
6. Draft the note. Remove abandoned explanations, conversational repetition, and every detail the final mental model does not require.
7. Write the file and reply in chat with the path and one sentence describing what it covers.

Do not create `plan.md` for a study note.

## 2. Choose the answer shape

The question decides the structure. Do not default to chronology.

### Categories, comparisons, and examples

Use for questions such as "data lake vs warehouse", "what are the right labels?", or "give me
production examples".

1. Open with one or two sentences placing the terms in the correct taxonomy.
2. Use one compact table with only the dimensions needed, such as `Category | Examples | Purpose`.
   Include examples when they make an abstract category concrete.
3. Add one short distinction below the table only when it prevents a likely confusion.

The result should resemble `data-bases.md`: easy to scan, useful six months later, and complete in
roughly one screen when the topic permits.

### Mechanisms and request flows

Use for questions such as "what happens when I run cargo build?" or "how does CDC work?".

1. State the outcome first.
2. Follow one small, familiar user action from start to finish.
3. Introduce only the components encountered along that path.
4. Prefer a 3 to 6 step list or a small flow diagram over several narrative sections.

An example is useful here when the mechanism is otherwise abstract. Choose it yourself from the
user's real system or a familiar minimal case. Quantify it only when performance, scale, capacity,
or cost is part of the explanation.

### Layered systems

Use a compact hierarchy or ASCII diagram when the main question is how parts fit together, such as
engine vs service vs provider or storage service vs file format vs table format vs compute engine.
Follow it with only the distinctions the diagram cannot carry.

### Broad concepts

Combine the minimum necessary forms. A broad topic may need a short orientation, one table, and one
small flow. It does not automatically need history, alternatives, implementation internals, a
concept glossary, a recap, quick answers, or an appendix.

## 3. Size and structure

Most notes should fit on one screen and use 1 to 4 sections. Use as few words as the mental model
requires. Exceed 800 words only when the question itself spans several load-bearing mechanisms and
shortening it would make the explanation wrong.

Use `~/brain/study/<kebab-case-topic>.md`. Open on an H1 with no YAML frontmatter.

Do not add any of these by default:

- `No prior context assumed.`
- a concept table separate from the useful comparison table
- a journey recap
- quick answers
- an appendix
- a history section
- a naive version that fails
- numbered sections

Add one only when it resolves a concrete ambiguity or replaces more prose than it adds.

## 4. Content rules

1. **Answer first.** The opening sentence should place the concept in the correct category and, when
   useful, distinguish it from the nearest thing the reader may confuse it with.
2. **Use the user's vocabulary, then make it precise.** Correct the mental model without replacing
   it with unnecessary jargon.
3. **Prefer concrete names when they orient the category.** "Snowflake is a warehouse" teaches more
   than "cloud-native analytical platform", but a product list that adds no clarity is noise.
4. **Separate categories from products and layers.** Say whether something is a workload, service,
   storage engine, file format, table format, compute engine, framework, or provider.
5. **Use a small user flow only when sequence matters.** One action, one path, 3 to 6 steps. Do not
   invent scale, a failure story, or a persona when they are not load-bearing.
6. **Keep caveats local and short.** Include a nuance only when omitting it would leave the reader
   with a materially wrong model.
7. **One idea per sentence.** Delete throat-clearing, repeated conclusions, section previews, and
   summaries.
8. **Do not hard-wrap prose.** Keep each paragraph and list item on one source line; preserve line
   breaks for Markdown structure only.
9. **Use plain ASCII punctuation.** Never use an em dash.

## 5. Tables and diagrams

Use a table when the reader needs to compare categories along the same dimensions. Keep cells short,
parallel, and concrete. A four-row table is usually better than four definition sections.

Use a diagram only when spatial structure or control flow is clearer than prose. Default to ASCII
for hierarchy and containment. Use Mermaid `flowchart` or `sequenceDiagram` only for genuine flow
between several actors, and keep it under ten nodes.

Do not put the same information in prose, a table, and a diagram. Pick the form that says it once
most clearly.

## 6. Extending an existing note

Put the answer at the point where it belongs. Preserve the useful shape and voice already there.
Make the smallest local addition that answers the follow-up; do not rebuild the note or append an
unrelated essay.

If the existing note is verbose, that is not permission to make it larger. Tighten only the nearby
material when needed to fit the new answer cleanly.

## 7. Default shapes

### Concise taxonomy

```markdown
# <Topic categories>

<One or two sentences giving the umbrella category and the key distinction.>

| Category | <Useful comparison dimension> | Purpose |
| --- | --- | --- |
| **A** | Concrete examples | Short practical role |
| **B** | Concrete examples | Short practical role |

<One short paragraph correcting the likely remaining confusion, if needed.>
```

### Concise mechanism

```markdown
# What happens when you <do the thing>

<Outcome first.>

1. You <first action>.
2. <Component> does <specific work>.
3. <Next component> receives <specific result>.
4. You observe <final result>.

<One short paragraph explaining the important constraint or distinction.>
```

These are defaults, not mandatory templates. Use less when less is enough.
