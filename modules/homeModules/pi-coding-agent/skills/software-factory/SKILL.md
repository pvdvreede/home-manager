---
name: software-factory
description: Language- and product-agnostic pipeline that turns a request into shipped, verified software through fixed stages (Define → Design → Build → Verify → Review → Ship) with explicit gates and on-disk artifacts. Use for feature work, bug fixes, greenfield builds, refactors, or release prep when you want a repeatable, reviewable process instead of ad-hoc edits. Scale the process with plan-stages (subagents) for large work.
---

# Software factory

One repeatable loop from request to shipped artifact. Every stage has an input
contract, an output artifact, and an exit gate. Do not skip gates; do not advance
a stage whose artifact is missing or stale.

Generic: applies to any language, framework, or product (library, CLI, service,
app, infra, docs). Substitute the concrete toolchain per repo.

## Loop

| # | Stage   | Agent        | In            | Out (on disk)              | Gate to advance                        |
|---|---------|--------------|---------------|----------------------------|----------------------------------------|
| 0 | Define  | `oracle`     | request       | `spec.md` (goal, scope, non-goals, acceptance) | acceptance criteria are checkable |
| 1 | Design  | `researcher` | spec          | `design.md` (approach, interfaces, risks, alternatives) | chosen approach + rejected alternatives recorded |
| 2 | Build   | `worker`     | design        | code + docs                | builds/typechecks; smallest coherent change |
| 3 | Verify  | `worker`     | build         | test/evidence log          | every acceptance criterion has evidence |
| 4 | Review  | `reviewer`   | diff + verify | findings                   | all findings dispositioned |
| 5 | Ship    | parent       | reviewed diff | release notes + handoff    | owner approves apply/deploy |

Run each stage as a fresh subagent context via the `subagent` tool (`async: true`),
handing it a self-contained packet and binding its output to the stage artifact.
The parent keeps Define's acceptance gate, dispositions Review, and owns Ship — it
never delegates final judgement. Inline stages in the parent only for trivial
single-step changes (see Scaling).

## Stage rules

**0 Define** — Restate the goal in one sentence. List in-scope, out-of-scope, and
concrete acceptance criteria. Stop and ask if the request is ambiguous or needs
extra work; do not invent scope.

**1 Design** — Before writing code, state the approach and the interfaces it
touches. Record 1–2 rejected alternatives with why. Research current APIs/versions
via web search first; do not rely on memory. If design changes the plan
materially, update `spec.md`.

**2 Build** — Make the smallest change that satisfies the design. Follow repo
conventions discovered from the tree (formatter, linter, layout, test style).
No new dependencies, comments, or abstractions without a stated reason. One
writer per working tree.

**3 Verify** — Run the repo's real validation: build/typecheck, lint, and the
tests that cover the change. Prefer the narrowest command that still fails on a
regression. Capture the exact command and result as evidence. Never claim a pass
without a run, and never activate/deploy to verify.

**4 Review** — Review the diff with a fresh-context, read-only `reviewer` for
correctness, regressions, and missing coverage. Disposition every finding
yourself: fix, defer, or reject with reason. A reviewer verdict never approves
scope or architecture.

**5 Ship** — Summarize user-visible change, breaking changes, and how to verify.
Include migration/rollback notes when relevant. Owner approves any apply,
deploy, install, or irreversible action; the factory never does it unprompted.

## Artifacts

Keep artifacts beside the work (e.g. `.pi/factory/<slug>/`). Later stages read
files, not conversation, so context stays small. Forward paths and short
summaries, never raw tool transcripts. Delete artifacts once merged, or fold
them into the repo's docs.

## Guardrails

- Fail fast: on missing info, ambiguity, or repeated failure, stop and ask.
- Evidence over assertion: no "done" without a command output or artifact.
- No scope creep: new requirements get their own spec entry and gate.
- Reviews and verification are always fresh-context and read-only.
- Respect repo policy (AGENTS.md/README): never run owner-only or destructive
  commands; never switch/deploy/install unless the owner explicitly asks.
- VCS: prefer `jj`; use `git` only when `jj` is unavailable.

## Dispatch

- Default: one stage = one fresh child context, launched `async: true`; yield and
  let the completion notification wake you. Block only when the turn cannot end
  without the result (e.g. Build → Verify is sequential).
- Packet per stage: repo working dir, one-line goal, stage scope, exact files,
  constraints, definition of done, output format, stop/ask conditions. Forward
  prior artifacts by path, never raw transcripts.
- `oracle` and `researcher` are read-only; `worker` writes; `reviewer` is
  read-only adversarial. One writer per cwd/worktree — use `worktree: true` for
  concurrent writers.
- Model/thinking overrides only when a stage warrants them.

## Scaling

Small, single-file change: stages 0–5 inline in the parent, no plan.
Large or multi-part work: write the plan (see `plan-stages`), run the loop per
work-item, dispatch Build and Verify as parallel lanes where independent (one
writer per worktree), and run Review as a separate fresh context. The parent owns
the plan and final synthesis.
