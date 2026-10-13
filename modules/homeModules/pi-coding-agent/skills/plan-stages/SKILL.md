---
name: plan-stages
description: Break a task into stages, then run each stage in its own fresh sub-agent context (sequentially or in parallel) using acp_delegate, forwarding only a per-stage summary. Use when a request is large, multi-part, or benefits from staged fan-out or parallel work with isolated contexts.
---

# Plan in stages, dispatch each stage to a fresh context

Implements a four-phase workflow: **Recon → Plan → Dispatch → Synthesize**.
The parent agent owns the plan and the synthesis; each stage runs in a fresh
sub-agent context that sees ONLY the stage summary you hand it.

## Phase 1 — Recon (optional, cheap)

If you do not already know the shape of the work, dispatch one `researcher`
(or `planner`) delegate with `async: false` to map the relevant files and
constraints. Read its result; do not spawn recon stages you do not need.

## Phase 2 — Plan

Produce a plan and write it to disk so it survives context pressure:

```
.pi/plan/<slug>/plan.json
```

Shape:

```json
{
  "goal": "<one sentence>",
  "stages": [
    {
      "id": "1",
      "title": "short name",
      "agent": "researcher|planner|worker|reviewer|oracle",
      "mode": "parallel|sequential",
      "dependsOn": [],
      "summary": "Self-contained brief: scope, files, constraints, definition of done, expected output format.",
      "output": ".pi/plan/<slug>/stage-1.md"
    }
  ]
}
```

Rules for the plan:

- **One stage = one sub-agent context.** A stage must be completable from its
  `summary` alone; the sub-agent has no access to this conversation.
- **`mode: "parallel"`** when a stage shares no state with siblings and can run
  concurrently (independent files/areas, read-only recon, separate reviews).
- **`mode: "sequential"`** when a stage consumes another stage's output, edits
  files another stage reads, or must observe prior results before starting.
- Keep `summary` short. Do NOT paste the whole plan into every stage — forward
  only what that stage needs, plus the paths of prior stage output files if a
  later stage depends on them.

## Phase 3 — Dispatch with `acp_delegate`

`acp_delegate` runs ONE task per call in a fresh `pi` process. Fan out by
calling it multiple times.

- **Independent stages (parallel):** launch each with the default
  `async: true` (returns a `runId` immediately), collect the runIds, then call
  `acp_delegate_wait({ runId })` for each. Do not poll; a completion
  notification is injected when a run finishes.
- **Dependent stages (sequential):** either call `acp_delegate({ ..., async:
  false })` and wait for the result inline, or launch `async: true` and wait on
  that stage's runId before launching the next. Feed the prior stage's output
  (or its output file path) into the next stage's `task`.
- **Respect the dependency DAG.** A stage may only start once every id in its
  `dependsOn` has completed.
- Pass `cwd` when a stage should operate somewhere other than the current
  project dir. Pass `model`/`thinkingLevel` only when a stage warrants it.
- **Every task string is self-contained.** Include: repo working dir, the goal
  in one line, the stage scope, the exact files, the constraints, the
  definition of done, and the required output format. Tell it to write its
  artifact to the stage's `output` path.

Stage summary → `task` template:

```
Repo: <abs path>
Goal: <plan.goal>
Stage <id> — <title>
Scope: <summary>
Files: <paths>
Constraints: <what must not change / style / tooling>
Definition of done: <checkable>
Output: write the result to <output> and finish with a <=10 line summary.
```

## Phase 4 — Synthesize

After all stages settle, read each `output` file (or the wait results), verify
against the goal, and combine into the final answer. Do the verification
yourself — do not delegate the final judgement.

## Failure handling

- A `FAILED` notification (⚠️) means that stage produced no usable result. Read
  the error excerpt and result file, then re-dispatch that stage.
- A cancelled/failed run keeps its output files and can be continued with
  `acp_delegate({ resumeFrom: "<runId>" })` — prefer resuming over re-dispatching
  when its partial work is worth keeping.
- If a `acp_delegate_wait` call times out, do NOT retry in a loop: continue with
  other ready stages and let the completion notification arrive.

## Context hygiene

- Write stage outputs to `.pi/plan/<slug>/` so later stages read files, not
  conversation. Keep the parent context holding only summaries.
- Never forward raw tool transcripts between stages — forward conclusions and
  file paths.
- One clear objective per stage. If a stage needs a plan of its own, it is
  really several stages — split it.
