---
name: review-pr
description: >
  Use when asked to review a pull request, PR, diff, or branch, whether authored by the user or
  someone else. Reviews correctness, design, and clarity: finds real bugs, identifies where a
  simpler approach would achieve the same outcome, and flags misleading names and functions doing
  several jobs. Returns an ordered list, each finding with the file and line to comment on and a
  draft review comment. Do not use for reviewing the agent's own uncommitted work.
---

# Review a pull request

Three questions get asked of every pull request, not one: does this work, is this the right way to
do it, and can the next person read it.

Produce findings worth the author's time. Say nothing otherwise. Never post to GitHub; output the
findings and let the user decide what to post.

## 1. Gather

Resolve `<owner>/<repo>` first and pass it explicitly to every command. You are frequently not
standing in a clone of the repo under review, and `gh` will otherwise resolve against the wrong
repository or fail outright.

```
gh pr view <n> --repo <owner>/<repo> \
  --json title,body,author,baseRefName,headRefName,headRefOid,files,additions,deletions
gh pr view <n> --repo <owner>/<repo> --comments
gh api --paginate repos/<owner>/<repo>/pulls/<n>/comments
gh api --paginate repos/<owner>/<repo>/pulls/<n>/files
```

`--paginate` is not optional. Both endpoints stop at 30 items without it and report no error, so a
large PR silently loses its later files and its older review threads. The files endpoint caps at
3000 files regardless.

The files endpoint is what makes a commentable line number possible: it returns each file's patch
with `@@` hunk headers. `gh pr diff` is fine for reading but carries no line numbers.

**Get the code.** A diff is not enough for pass one, which needs whole files and the ability to
search for callers:

```
git clone --filter=blob:none --no-checkout https://github.com/<owner>/<repo> <tmpdir>
git -C <tmpdir> fetch origin <headRefOid>
git -C <tmpdir> checkout <headRefOid>
```

Read every file at the head SHA, never at the default branch. Hunk headers and the line numbers you
will cite are relative to the head, and on a merged PR the default branch has moved on.

With no PR number, review the current branch against its resolved base:

```
git diff "origin/$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)"...HEAD
```

Read the description for stated intent. A change that does not do what its description claims is
itself a finding.

Read the existing review comments before writing any of your own. Never re-raise a point already
raised, whether or not the thread looks resolved, and never re-raise one the author has answered.
The one exception is an answer that is factually wrong, in which case address that answer directly
rather than restating the original point. Comments authored by bots, and auto-generated replies,
do not count as raised or answered.

## 2. Scope

Exclude generated code, vendored dependencies and lock files: `*.lock`, `*.sum`,
`package-lock.json`, `vendor/`, anything with a "do not edit" header, and any protobuf, OpenAPI or
ORM output. Findings against machine-authored code are worthless.

Review test fixtures and golden files for one thing only: whether they actually assert the
behaviour claimed. Nothing in section 4 beyond that applies to them.

State in one line which paths you skipped.

## 3. Fan out when large

Measure after exclusions: more than 15 files, or more than 800 changed lines counting additions
plus deletions. Above either, split by area rather than by file count and dispatch 2-3 read-only
subagents, one per area.

Subagents do **pass one only**. Give each of them section 5, section 6, and the first nine bullets
of section 4, which are the correctness categories. Withhold the last three bullets and both
`Anything already raised` and `Anything in a generated file` from section 5, since a subagent has
neither the comment list nor the exclusion list. They start with no context and will otherwise
invent their own bar.

Do passes two and three yourself over the whole PR. Both need to see the change as a whole, and a
subagent holding one area cannot judge whether a better approach exists or whether a name collides
with one elsewhere.

Require subagents to return findings in the section 12 format. Merge, dedupe, and apply the bar to
their findings as strictly as to your own.

Below the threshold, or in a host without subagents, review directly.

## 4. What qualifies

Report a finding only if it is one of these:

- **Incorrect behaviour.** Wrong result, wrong branch taken, off-by-one, an unhandled nil, empty or
  error case that will actually occur.
- **Security.** Injection, authorization gap, secret exposure, unsafe deserialisation.
- **Data loss or corruption.** Destructive migration, non-idempotent retry, lost write.
- **Concurrency.** Race, deadlock, unsafe shared mutation.
- **Resource and performance.** Leak, unbounded growth, N+1 or accidental quadratic on a path that
  carries real volume.
- **Contract break.** An API, schema or serialisation change that breaks an existing caller.
- **Error handling that hides failure.** Swallowed error, catch-and-default, a fallback masking a
  fault.
- **Divergence from stated intent.** The change does not do what its description says it does.
- **A named untested failure mode.** Not "needs tests": a specific case that will break and is not
  covered.
- **A materially better approach exists.** Qualified by pass two.
- **A name misleads.** Qualified by pass three.
- **A function does more than one thing.** Qualified by pass three.

## 5. Never report

Not even when true:

- Formatting, whitespace, import order, or anything a linter or formatter owns.
- A name that is merely improvable. A synonym swap is not a finding; a misleading name is.
- Function length on its own. Line count is not a defect.
- "Consider extracting this" with no concrete cost named.
- Speculative future-proofing for requirements that do not exist.
- Missing tests in general. Only a named failure mode qualifies.
- Anything in a generated, vendored or lock file.
- Anything already raised in an existing review thread.
- Restating what the code does.
- Praise, a summary of the PR, or "looks good overall" padding.
- Preferences dressed as problems. If the code works and the objection is taste, drop it.

## 6. Pass one: correctness

Read past the diff. For every non-trivial hunk, open the whole file at the head SHA, then find the
callers and callees of anything changed.

Most real bugs are invisible in a diff, because the caller, the schema or the concurrent path is
not in it. A review that reads only the diff produces diff-shaped observations, and diff-shaped
observations are nits.

Where a finding turns on how an external tool, library or runtime actually behaves, run it and
find out. Do not reason about it from memory. Say what you ran. This regularly kills findings that
looked solid on paper, which is the point.

## 7. Pass two: design

Reviewing only "does it work" is half a review. The other half is "is this the right way", and it
is the half that gets skipped, because reading a solution anchors you to it.

**Break the anchor first.** Before evaluating the implementation, state in one sentence the outcome
the change is trying to achieve, in terms of behaviour and not of mechanism. Then work out what the
simplest thing that achieves that outcome would be, arriving at it independently. Only then compare
against what the PR does. In the other order you will comment on their method instead of finding a
better one. Report that one-sentence outcome and your verdict in the output header, whether or not
it produces a finding.

**The bar for raising an alternative.** All four must hold:

1. It can be stated concretely in two or three sentences. A gesture at "a cleaner approach" is not
   a finding, it is a feeling.
2. It is strictly better on a named axis, and you name it: fewer moving parts, less code, one less
   layer of indirection, one less dependency, a whole class of state or bug removed, or a better
   complexity class.
3. It is better against the requirements that exist today, not ones that might arrive.
4. You state the cost of switching honestly, including when that cost exceeds the PR's scope.

**Where to look.** These are signals, not findings in themselves:

- A new abstraction, interface or wrapper with exactly one implementation or one caller. A plain
  named function extracted from a longer one does not count, however few callers it has.
- Hand-rolled logic that the standard library or an existing helper in this repo already does.
  Search for that helper before raising it.
- The same state held in two places and kept in sync by hand.
- A scan or nested loop where an index or map turns the work into a lookup.
- Boolean flags threaded through signatures to make one function behave as two.
- A cache added to paper over slowness that a better data structure would remove outright.
- A ladder of special cases that one uniform representation would collapse.
- Defensive checks compensating for an invariant that could be made unbreakable by construction.
- Config, policy or control-plane machinery built for what is a one-off operation.
- Retry, timeout or reconciliation logic wrapped around a design that could avoid needing it.

**Never, in this pass.** It is the highest-noise category in any review, so it carries its own
exclusions on top of section 5:

- Proposing a design pattern by name as the improvement. Adding a layer is not elegance. If the
  alternative has more parts than the original it is not better, it is different.
- Suggesting a rewrite of code the PR merely touched or moved.
- Trading working, obvious code for clever, compact code. Fewer lines is not the axis; fewer moving
  parts is.
- Library or framework swaps with no concrete named gain.
- Alternatives that are only better under hypothetical future requirements.
- Raising an alternative without having read enough surrounding code to know why the author might
  have chosen theirs. Constraints you cannot see are still constraints.

**Scope honesty.** When the better method is larger than the PR, say so in both the explanation and
the comment, and label it worth logging rather than worth blocking. Demanding a refactor as the
price of merging a small change is how people learn to stop asking for reviews.

**Tone.** Design findings are proposals, not verdicts. The author has context you do not, so ask
whether the alternative works here and name what it would remove, rather than instructing. That is
not hedging: the claim about what the alternative removes stays concrete and unqualified. Only the
decision is left open.

## 8. Pass three: clarity

Naming and function size are the classic nit factories, and this skill exists not to produce nits.
They are in scope anyway, because they are cheap to fix before a merge and expensive after: a bad
name propagates to every caller, and a function doing three things accretes a fourth. Pre-merge is
the only moment where the fix is one line.

The answer is a sharper standard, not a softer one.

**The naming bar.** Report a name only when it would cause a reader to form a wrong belief, and you
can state the wrong belief in the finding. That is the whole test, and every form below has to pass
it:

- The name says one thing and the code does another: `getUser` that also writes, `isValid`
  returning a count, `deleteX` that soft-deletes.
- A negated boolean producing double negatives at call sites: `notDisabled`, `shouldNotSkip`.
- One name used for two different things in the diff, or two names used for one thing.
- A missing unit or type where the ambiguity has a cost: `timeout` rather than `timeoutMillis`,
  `size` rather than `sizeBytes`.
- A `get`-prefixed name that performs IO, a network call or heavy computation.
- Shorthand whose expansion a reader would get **wrong**, not merely have to look up: `dt` holding
  a duration rather than a date, `res` holding a request rather than a response. Only in code this
  PR adds. Shorthand that is merely terse is not a finding, and an abbreviation the codebase
  already uses consistently is never one.

Never report a synonym swap or a preference between two clear names. "I would have called it
something else" is not a wrong belief. A PR is the wrong place to relitigate an existing
convention, and a reviewer who does it is fighting the codebase rather than reviewing the change.

**The function size bar.** Line count is never the finding. A long linear function, such as a
config builder, a table of match arms or a sequence of setup steps, is fine. Do not report it.

Report only when both hold:

1. The function has more than one reason to change, or mixes levels of abstraction in one body. The
   quick test is the word "and": if describing what it does requires "and", it does two things.
   That test also joins the two halves of this pass, because a function doing two things cannot
   have an honest name.
2. You can name the seams concretely, such as "lines 40 to 58 are the retry loop", and name the
   gain: a part becomes independently testable, a part already exists duplicated elsewhere, or the
   mixing is where a bug is hiding.

**What you may propose.** Only a split into named functions in the same file. If the split needs a
new type, interface, strategy object, module or file to work, do not raise it: that is a pass two
design question, and usually one of pass two's anti-patterns.

**Cap clarity findings.** At most three, and never more than one plus the number of bug and design
findings. A clean PR is therefore still entitled to one, and a PR with a single bug to two. Past
the cap, add one closing line stating how many more of the same kind exist, without listing them.
The ratio is the load-bearing part: it keeps clarity proportional on a small PR, where a handful of
naming comments is the wall of noise this skill exists to prevent.

## 9. Verify before reporting

**Correctness findings** must name the concrete code path that breaks and, where relevant, the
input or condition that triggers it. If you cannot point at that path, drop the finding or
downgrade it to a question.

Mark each one `confirmed` or `suspected`, mechanically:

- `confirmed`: you can name the exact source lines that produce the failure, and the trigger.
- `suspected`: the path depends on behaviour you could neither read nor run.

The marker changes the wording of the draft comment: confirmed states, suspected asks.

**Design findings** carry no marker. Section 7's four-part bar is their verification.

**Clarity findings** carry no marker. State the wrong belief, or the seams and the gain.

## 10. Order the findings

Rank by tier, then by blast radius within a tier:

1. **Breaks in production.** Data loss, security, corruption, a crash on a live path.
2. **Wrong behaviour.** Incorrect results, contract breaks, hidden failures, divergence from stated
   intent, named untested failure modes.
3. **Wrong approach.** A materially better method exists, per pass two.
4. **Will bite later.** Leaks, unbounded growth, races on cold paths.
5. **Costs the next reader.** Misleading names, functions doing several jobs, per pass three.

No scores. The order is the priority.

Design sits above "will bite later" because an approach is only cheap to change before the merge.
Promote a design finding into tier 1 or 2 when the approach is itself the cause of a correctness or
performance defect. Promote a clarity finding only when the confusing name or overloaded function
is the demonstrated cause of a bug found in pass one; a promoted clarity finding is typed `bug`,
carries a marker, and does not count against the clarity cap.

## 11. Cite a line that can actually be commented on

GitHub accepts an inline comment only on a line that falls inside a diff hunk. Use the `@@` headers
from the `pulls/<n>/files` response to work the number out. A wrong line number silently attaches
the comment to unrelated code, so count carefully and use the header's own line count as a check:
`@@ -29,6 +31,11 @@` means the new side runs 11 lines from line 31.

- **Added or context line inside a hunk:** give `path:line` using the new-file number. Unchanged
  context lines inside a hunk are commentable, which covers the common case of a root cause sitting
  a line or two above the edit.
- **Deleted line:** give the old-file number and mark it `side: LEFT`.
- **Outside every hunk:** give the real location, note that it is not inline-commentable, and say
  it belongs in the top-level review body.
- **File with no `patch` in the API response:** binary files, renames and diffs too large to return
  have no hunks at all. Not inline-commentable; give the real location and route it to the review
  body.

Before emitting any finding, open the file at the line you are about to cite and confirm the
content there is the code the finding is about. This catches every off-by-N and costs one read.
Verify against the head SHA for a normal citation, and against the base ref for a `LEFT` citation,
since the old-file number does not point at the same code in the head.

## 12. Output format

Open with a header, always, whether or not there are findings:

```
Skipped: <paths excluded, or "none">
Size: <n> files, <n> lines after exclusions. <Reviewed directly | Fanned out to <n> subagents>.
Approach: <the one-sentence behavioural outcome from pass two, then the verdict: either "the
approach is the right one" with the reason, or a pointer to the design finding below.>
```

Then one block per finding, in priority order. Bugs carry a marker; design and clarity findings
omit that field entirely:

```
### 1. <short title>
`path/to/file.ext:142` · tier <n> · bug · <confirmed|suspected>

### 2. <short title>
`path/to/file.ext:88` · tier <n> · <design|clarity>
```

Under the header line of each block:

```
<Explanation for the user, not the author. For a bug: what breaks, the path it takes to break, and
the trigger. For a design finding: the outcome the code is reaching for, why the current method
costs more than it needs to, and what the alternative removes. For a clarity finding: one or two
sentences naming the wrong belief the name creates, or the responsibilities the function mixes.>

> <Draft comment for the author.>
```

When the root cause sits outside every hunk, add `root cause: path/to/other.ext:88` beneath the
header line. When clarity findings hit the cap, close with the single line stating how many more
exist.

With no findings at all, output the header and then one line: `No findings that clear the bar.`

## 13. Comment style

The explanation is for the user. The draft comment is for the author. Keep them different.

- 1 to 3 sentences. No greeting, no praise, no preamble.
- Plain dash, never an em dash.
- No "Great work", "Nice catch", "Just a thought", "It might be worth considering".
- For a confirmed bug, write the concrete observation first. Do not weaken confirmed behavior into
  a vague possibility.
- Then leave the conclusion open when the author can have context the reviewer lacks. Prefer `What do
  you think?`, `Can you look into this?`, or `Can you have a think about this?` over prescribing a
  specific implementation.
- For design, clarity, and suspected-bug comments, use the collaborative cadence Robert and Jason
  use where natural: `So I was thinking ...`, `Have you thought about ...`, `This is interesting
  ...`, or `I'm thinking ...`. The same sentence must name the concrete cost, uncertainty, or wrong
  belief. Do not put a stock opener on every comment, and do not use `This is interesting` as empty
  praise.
- Confirmed bugs state what happens, then ask about the desired resolution. Suspected bugs ask a
  direct question about the missing invariant or execution path.
- Design findings state the concrete cost, propose a direction without dictating it, and ask what the
  author thinks.
- Naming findings are one sentence and offer the replacement name outright.
- Function size findings are one sentence naming the seams and the single gain.
- Suggest the fix only when it is short enough to state in a clause.
- Do not hide the finding behind politeness. Collaborative and open-ended does not mean vague.
- Do not apologise for the review.

Prefer:

> We still commit the source offset after this write fails, which means the records won't get
> replayed. Can you have a think about how we want to handle the failure?

Not:

> This is wrong. Change `run` to return a `Result` and abort the process here.

## 14. Finding nothing is a valid result

If nothing clears the bar, say exactly that and stop. Do not pad, do not lower the bar to fill
space, do not add a "minor observations" section. For pass two in particular, "the approach is the
right one" is the normal outcome.
