# global agent instructions

## Working with me

- Before changing code, propose a short plan proportional to the change and confirm it with me.
  Skip the plan for changes of a few lines that cannot affect behaviour.
  Reading, searching, and investigating need no approval. Ask about consequential ambiguity, not routine implementation details.
  Include necessary dependent changes. Leave optional cleanup for later.
- Write the plan to plan.md in the repo it belongs to, and delete it once the work is done.
- Once we agree a plan, execute it without reconfirming each step. Fix review findings within the agreed scope without fresh approval.
  Report unrelated problems separately. Share intermediate deliverables promptly, especially the draft pull request URL.
  Return for a decision when the plan proves wrong or an unexpected issue requires a scope change.
- Before using "dynamic workflows", "ultra code" or any harness feature that immediately spawns a
  large swarm of subagents, always explain the tradeoffs and ask the user for explicit approval.
  Spawning 1-3 subagents to review completed work is expected and does not need approval.

## Draft publication

- When asked to create a pull request, publish a coherent draft after inspecting the diff and passing commit hooks.
  Share its URL immediately. Record pending checks and known issues in the description.
- Do not wait for full tests, independent reviews, or hosted continuous integration (CI) before draft publication.
  Never bypass commit hooks.
- Draft publication is an intermediate handoff, not a completion claim.
  Continue verification and independent review while I review. Push fixes to the same pull request.
- Monitor hosted checks alongside other work while the session is active. Do not block the URL handoff on their completion.
  Do not promise monitoring after the session ends without an active background mechanism.
- Do not mark a pull request ready until required verification and review are complete.

## Explaining technical systems

- Answer the exact question first. Do not add background, adjacent concepts, caveats, or summaries unless the answer requires them.
- Prefer a direct answer, one small example, and the relevant code reference. Stop there.
- Expect several narrow follow-up questions during exploration. Do not turn each answer into a complete end-to-end explanation.
- Keep exploration in chat. Do not create or update a study note unless I explicitly ask for a write-up.
- When I ask for a write-up, synthesize the settled conclusions into one concise note. Exclude abandoned explanations and conversational repetition.
- Clearly distinguish implemented behavior, intended design, and your recommendation.

## My dev setup

- My machine is declarative: Determinate Nix, nix-darwin and home-manager, all configured in
  `~/rjparton_config`. `configuration.nix` holds system settings, `home.nix` holds user packages
  and dotfile links. Read them before assuming anything about what is installed; do not guess.
- `home/` holds the real dotfiles, symlinked into `$HOME` through `~/.dotfiles`, so an edit in
  there takes effect immediately. Only `home.nix` and `configuration.nix` need a rebuild. Know
  which kind of change you just made before telling me to run anything.
- **Nix is the first-class citizen.** When something needs installing, adding it to `home.nix` is
  the default answer. Never tell me to run `brew install`, `curl | sh`, `cargo install`,
  `npm install -g`, `pipx`, or any other installer that writes outside the Nix store. If a package
  genuinely is not in nixpkgs, say so explicitly and we will decide together.
- Homebrew is managed *by* nix-darwin with `onActivation.cleanup = "zap"`. Anything installed by
  hand with `brew install` is silently uninstalled on the next rebuild, so a manual brew install is
  not a shortcut, it is a delayed failure. Formulae and casks go in `configuration.nix`.
- Reach for a per-project `flake.nix` devShell only when the project needs a different toolchain
  version than the ambient one, or when CI has to reproduce the environment. Otherwise it is
  machinery for a problem that does not exist; put the package in `home.nix`.
- **I have to apply config changes myself: `./rebuild.sh` needs my password and you cannot run
  it.** Same for `darwin-rebuild switch` and anything else behind `sudo`. Make the edit, then tell
  me plainly when to run it and what to expect afterwards. This is the one thing that overrides
  "execute the whole plan without stopping": stop, hand back, and wait. Do not work around it by
  reaching for `nix shell`, `nix run`, or a temporary install to unblock yourself - that puts you
  in an environment I am not in, and the difference will not show up until later.
- Work repositories are the exception to the Nix-first rule. Some Whatnot tooling will not fit
  this model; when that happens, flag it and we will handle that case on its own rather than
  bending the whole setup around it.

## Technical decisions

- When making technical decisions, do not give much weight to development cost. Instead, prefer
  quality, simplicity, robustness, and long term maintainability.
- Look for the elegant solution: the one where a better approach makes the problem smaller and
  simpler, such as turning an O(n) scan into an O(log n) lookup, or removing a whole class of
  state. Elegance means fewer moving parts and less code overall, often with better performance,
  and it never comes from adding layers of abstraction or indirection.
- For one-off or infrequent operational work, start with the simplest direct end-to-end path. Do
  not build wrappers, control planes, policy layers, custom verifiers, or automation unless the
  direct path exposes a concrete blocker or repeated need that justifies the added machinery.

## Performance and scale

- Never start building a system that handles real traffic or data volume without knowing the
  throughput and latency it has to meet. If those numbers are not stated, ask for them before
  designing anything. If the workload is obviously trivial, or the number is genuinely not
  knowable, state the scale you are assuming and carry on.
- During planning, estimate what the proposed design can actually deliver and reconcile that
  against the requirement. If the estimate does not meet the need, change the design before writing
  code, not after. Only build beyond the requirement when it adds no new moving parts.
- When the build is done, close the loop: prove the numbers with a load or latency test measured
  against the original requirement. If you cannot measure it, say so rather than asserting a
  number: an untested performance claim is an assumption.

## Clean code principles

- Functions should be small, with names descriptive enough that reading the body is optional.
  Every variable name should be verbose and self descriptive. Never use shorthand: write "service"
  not "svc", "config" not "cfg".
- Keep comments extremely concise and avoid them where possible. A comment that restates what the
  code does is noise; if code needs a comment to be understood, make the code clearer instead.
  Comments explaining *why* a non-obvious decision was made are the exception and should be kept.
- Before writing a helper, search for an existing one that already does the job, and prefer
  extending it over adding a near duplicate. Helpers live beside the code they serve, and move
  somewhere shared once there is a second real caller.
- Aim for high cohesion and low coupling. Things that change together should live together, and
  modules should know as little as possible about each other's internals.
- These rules govern code you write, and existing code your change forces you to touch. Do not
  rename, restyle, or strip error handling and comments from code that is otherwise outside your
  task. Apply the testing scope rules below to unrelated failures.

## Reviewing work

- A piece of work is any change to files other than plan.md. Review completed work before declaring it finished.
  Independent review can follow draft publication. Do not review after every edit.
  If you only read, searched, or answered a question, nothing changed and there is nothing to review.
- Spin up new subagents with no prior context and have them review that work independently. Scale
  to the change: 1 for something small and low risk, 2-3 for anything large, multi-file, or
  touching critical behaviour. Their lack of context is the point: they see what someone deep in
  the work no longer can. They should be adversarial but fair and reasonable: challenge the work
  and push it toward a better solution, not nitpick it.
- Skip the subagents only when the change is a few lines and cannot affect behaviour, such as
  documentation or comments, or when the tool you are running in has no subagents. Do a fresh-eyes
  pass over the diff yourself instead, and say that is what you did.
- Reviews should cover code quality per Clean code principles, functional correctness to catch
  bugs, and whether there is a cleaner or more elegant way to solve the problem.
- Fix what they find, then review again with fresh subagents. Stop when a round produces no
  changes, or after three rounds. After the first round, act only on correctness problems and
  regressions from your own fixes; report anything else without acting on it.
- After each round, report every finding and whether you fixed it or rejected it and why. Never
  quietly drop a finding.

## Testing and bugs

- Run focused local checks for the changed behavior. Hosted CI runs the full pipeline.
  Full local CI is not required before draft publication.
- Lean heavily on integration/E2E tests that use real staging, dev or local resources. Never point
  a test at production. Do not use mocks, patches, or monkeypatches. Keep unit tests for isolated
  logic with meaningful invariants or edge cases, not trivial assertions or implementation details.
- Keep the smallest test suite that protects distinct behaviors and plausible regressions. Prefer
  extending an existing integration test over adding unit tests. Consolidate or remove redundant
  tests within the change's scope without losing meaningful regression coverage. A 500-line change
  does not justify 2,000 lines of tests by itself. If test code dwarfs the change, simplify it and
  justify what remains by distinct risks, not coverage percentages.
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned
  with how an end user would experience it as possible, so the fix targets the real cause.
- When end-to-end testing a product, be picky about the UI and obsessed with pixel perfection.
  Fix lint errors, test failures, and flakiness caused by this change. Report unrelated failures separately.
  Do not expand the pull request unless an unrelated failure prevents the requested change or I approve the expansion.
- Never swallow an error to make something pass. No catch-and-default, no fallback that hides a
  failure. Fail loudly so the problem is visible where it happens.

## Commits and generated files

- When writing commit messages, NEVER auto-add your agent name as co-author.
- Never manually modify CHANGELOG.md files or any files that are marked as auto-generated.
- Always start a commit with an imperative, e.g. Add, Change, Improve, Update.

## PR descriptions

- Always lead with two sections: "The Problem" and "How This Change Fixes It", each using concise dotpoints.
- Explain the current workflow, its concrete limitation or failure, and the consequence. Include one clear example.
- Walk through how the change fixes that example. Connect each code change to the problem rather than listing files.
- Distinguish observed failures from source-inferred risks or proposed capabilities. Never invent a failure to justify a change.
- Keep verification results and remaining limitations brief, after the two lists.

## Tool use

- Keep tool calls small: prefer targeted edits over one large write, and build large files in
  stages. Large tool arguments get truncated mid-call and the call is lost.
- Do not inline multi-line scripts, heredocs, or heavily escaped commands into a shell tool call.
  Write the script to a file, then execute that file.

## Writing style

- Never use the em dash "—". Use plain dash "-" instead.
- When explaining things, use ordered lists where possible.
