---
description: Run the software factory pipeline (Define → Design → Build → Verify → Review → Ship) on a feature, requirement, or bug
argument-hint: "<feature | requirement | bug>"
---
Run the `software-factory` skill end-to-end on the request below. Read the skill
first, then execute its stages in order and honour every gate; do not write code
before Define and Design are settled.

Request: ${@:-<describe the feature, requirement, or bug to deliver>}

Constraints:
- Treat the request as stage 0 input: restate the goal, scope, non-goals, and
  checkable acceptance criteria; stop and ask if it is ambiguous.
- Dispatch each stage to its mapped fresh subagent (Define→oracle,
  Design→researcher, Build→worker, Verify→worker, Review→reviewer) unless the
  change is trivial single-step work.
- Keep artifacts under `.pi/factory/<slug>/`; forward paths, not transcripts.
- Stay inside this repo's policy (AGENTS.md/README): never run owner-only,
  destructive, or switch/deploy/install commands.
