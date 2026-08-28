# global agent instructions

## Working with me

- Do not jump straight into implementation. Before writing or modifying code, work the request up
  into an exhaustive plan and confirm it with me. Skip the plan only when the change is a few lines
  and cannot affect behaviour; just make it. Reading code, searching, and investigating are always
  fine without asking first; changing things is not. If a request is ambiguous, ask rather than
  guessing and building the wrong thing.
- Write the plan to plan.md in the repo it belongs to, and delete it once the work is done.
- Once we have agreed a plan, execute all of it without stopping to re-confirm each step. Fixes
  arising from review, and problems you notice in passing, are part of the work and do not need
  fresh approval. Come back to me when the plan is finished, when it turns out to be wrong, or when
  you hit something it did not anticipate.
- Before using "dynamic workflows", "ultra code" or any harness feature that immediately spawns a
  large swarm of subagents, always explain the tradeoffs and ask the user for explicit approval.
  Spawning 1-3 subagents to review completed work is expected and does not need approval.

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
  task. Fixing failing lint or tests in that code is the exception.

## Reviewing work

- A piece of work is any change to files other than plan.md. Review it before handing it back, not
  after each edit along the way. If you only read, searched, or answered a question, nothing
  changed and there is nothing to review.
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

- Lean heavily on integration/E2E tests that use real staging, dev or local resources. Never point
  a test at production. Do not use mocks or patches. Use unit tests only where they actually prove
  something, e.g. a math function can test that 2 + 2 = 4. Do not write lots of brittle unit tests.
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned
  with how an end user would experience it as possible, so the fix targets the real cause.
- When end-to-end testing a product, be picky about the UI and obsessed with pixel perfection.
  Apply the same standard to lint errors, test failures, and test flakiness. Fix them even when
  your work did not cause them.
- Never swallow an error to make something pass. No catch-and-default, no fallback that hides a
  failure. Fail loudly so the problem is visible where it happens.

## Commits and generated files

- When writing commit messages, NEVER auto-add your agent name as co-author.
- Never manually modify CHANGELOG.md files or any files that are marked as auto-generated.
- Always start a commit with an imperative, e.g. Add, Change, Improve, Update.

## Tool use

- Keep tool calls small: prefer targeted edits over one large write, and build large files in
  stages. Large tool arguments get truncated mid-call and the call is lost.
- Do not inline multi-line scripts, heredocs, or heavily escaped commands into a shell tool call.
  Write the script to a file, then execute that file.

## Writing style

- Never use the em dash "—". Use plain dash "-" instead.
- When explaining things, use ordered lists where possible.
