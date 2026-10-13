---
name: plan-stages
description: Break a large task into stages, then run them in fresh sub-agent contexts with the pi-subagents `subagent` tool and workflow scripts (runs.run/runs.all/runs.lanes), forwarding only per-stage summaries and artifact paths. Use when a request is large, multi-part, or benefits from staged fan-out, parallel lanes, or isolated contexts that keep the parent context small across long sessions.
---

# Plan in stages, dispatch each stage to a fresh context

Implements a four-phase workflow: **Recon → Plan → Dispatch → Synthesize**.
The parent owns the plan and the synthesis; each stage runs in a fresh
sub-agent context that sees ONLY the stage packet you hand it.

Use the native pi-subagents `subagent` tool. Keep the parent as the orchestrator
and sole decision-maker; children never launch subagents unless you explicitly
assign a fanout stage.

## Phase 1 — Recon (optional, cheap)

If you do not already know the shape of the work, run one `scout` (codebase) or
`researcher` (web) child and read its result. Do not spawn recon you do not need.

```
subagent({ agent: "scout", task: "<map the relevant files, contracts, and constraints>", async: true })
```

Wait only if the plan depends on it; otherwise yield and let the completion
notification wake you.

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
      "agent": "scout|researcher|worker|reviewer|oracle|delegate",
      "mode": "parallel|sequential",
      "dependsOn": [],
      "packet": "Self-contained cold-start packet: scope, files, constraints, definition of done, expected output.",
      "output": "stages/1-<slug>.md"
    }
  ]
}
```

Rules for the plan:

- **One stage = one child context.** A stage must be completable from its
  `packet` alone — the child has no access to this conversation.
- **`mode: "parallel"`** when a stage shares no state with siblings and can run
  concurrently (independent files/areas, read-only recon, separate reviews).
- **`mode: "sequential"`** when a stage consumes another stage's output, edits
  files another stage reads, or must observe prior results before starting.
- **One writer per cwd/worktree.** Reads, recon, and reviews parallelize freely;
  concurrent writers need `worktree: true` isolation.
- Keep `packet` short. Do NOT paste the whole plan into every stage — forward
  only what that stage needs, plus the artifact paths of prior stages it depends
  on.

## Phase 3 — Dispatch with `subagent`

Choose the smallest launch shape that covers the plan:

- **One bounded stage:** a direct `subagent({ agent, task, async: true })` call.
- **A coordinated multi-stage wave (preferred):** ONE top-level workflow script.
  Write the script in a single ```js workflow fenced block in your reply, then
  call `subagent({ workflow: true, async: true })` in the same reply. Launch
  children only inside that one workflow — do not construct a second top-level
  orchestration.
  - `await runs.run(key, { label, agent, task, output })` for a keyed stage.
  - `await runs.all([{ key, label, agent, task, output }, ...])` for parallel
    stages. It resolves to an ordered array, not a key map.
  - `await runs.lanes([{ key, stages: [...] }])` for a broad plan of independent
    lanes with ordered stages; later stages use `resume: "previous"` to continue
    the lane's retained child.
- **Sequential dependency:** consume the prior stage's `output` (or artifact path)
  and feed it into the next stage's `task`; respect the `dependsOn` DAG.

Workflow example:

```js workflow
const scan = await runs.run("scan", {
  label: "Map codebase seams",
  agent: "scout",
  task: "<packet>"
});
const reviews = await runs.all([
  { key: "correctness", label: "Review correctness", agent: "reviewer", task: "<packet>. Context:\n" + scan.output },
  { key: "tests", label: "Review test coverage", agent: "reviewer", task: "<packet>. Context:\n" + scan.output }
]);
return reviews.map(result => result.output);
```

Dispatch rules:

- **Async by default.** Launch workflow scripts and independent children with
  `async: true`, then return control. Pi wakes the parent with a completion
  notification — do not poll, and do not call `bg_wait()` merely because a child
  is active. Only use `async: false` (or a blocking `bg_wait`) when the current
  turn cannot end without the result.
- **Bind outputs.** Set `output` on each child that produces a durable artifact;
  read the returned `outputReference` / `artifactPaths` and forward those paths,
  not transcripts.
- **Cold-start packets.** Every `task` is self-contained. Include: repo working
  dir, the goal in one line, the stage scope, the exact files, the constraints,
  the definition of done, the required output format, and stop/ask conditions.
- Pass `cwd` when a stage operates somewhere other than the current project dir.
  Pass `model`/`thinkingLevel` only when a stage warrants it.
- Use a fresh-context `reviewer` for adversarial review, and `oracle` (forked)
  only for continuity/advice.

Packet → `task` template:

```
Repo: <abs path>
Goal: <plan.goal>
Stage <id> — <title>
Scope: <packet>
Files: <paths>
Constraints: <what must not change / style / tooling>
Definition of done: <checkable>
Output: bind with output=<path> and finish with a <=10 line summary.
```

## Phase 4 — Synthesize

After the workflow settles, read the aggregate result and each `output` artifact,
verify against the goal, and combine into the final answer. Do the verification
yourself — do not delegate the final judgement. If a writer produced a candidate,
run a fresh-context `reviewer` before declaring done, then disposition every
finding (fix, defer, reject with reason).

## Failure handling

- A failed child produces no usable result: read its `status`, error excerpt, and
  output file, then re-dispatch that stage.
- Inspect a run with `subagent({ action: "status", id })`; list resumable
  children with `subagent({ action: "children.list" })`; continue a
  paused/failed one with `subagent({ action: "resume", id, message })`.
- Only a top-level single run can be steered with `subagent({ action: "steer", id, message })`.
- A setup/launch/tooling failure is a lane infrastructure blocker: stop, report
  the exact failure and worktree/run state, verify a clean worktree or capture
  the partial diff, then retry the same protocol. Do not silently fall back to a
  foreground or external CLI mode.
- If a stage blocks, record the blocker and named next action; keep independent
  lanes moving.

## Context hygiene

- Write stage outputs under `.pi/plan/<slug>/` so later stages read files, not
  conversation. Keep the parent context holding only summaries and paths.
- Never forward raw tool transcripts between stages — forward conclusions, the
  artifact path, and the next decision.
- One clear objective per stage. If a stage needs a plan of its own, it is really
  several stages — split it.
