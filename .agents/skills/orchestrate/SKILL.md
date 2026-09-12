---
name: orchestrate
description: "Drive a ticketed spec to done AFK: cut a spec branch, then dispatch one fresh /implement subagent per ticket across the frontier until every ticket is done."
disable-model-invocation: true
---

A spec has been broken into tickets (`/to-tickets`) and they are `ready-for-agent`. Orchestration walks the whole set without a human in the loop: one **spec branch** for the spec, one fresh subagent per ticket running `/implement`, working the **frontier** (open tickets whose blockers are all done) until nothing is left open.

The orchestrator **dispatches, verifies, and commits**. Every line of code is written through a subagent; the orchestrator's own edits are to ticket files and nothing else. The pull to fix one small thing yourself between dispatches is the signal to write a ticket comment and dispatch again.

**One ticket, one commit.** The orchestrator owns the commit. Keep claim updates, implementation, tests, review fixes, retry work, and final ticket status together in the working tree until the ticket is done or parked, then commit them together. This overrides `/implement`'s commit step for dispatched agents.

The issue tracker and triage label vocabulary should have been provided to you. If not, tell the user to run `/setup-matt-pocock-skills`. Where a spec's tickets, blocking, frontier, claim, and done physically live is tracker-specific: consult the tracker doc's "Orchestration operations" section.

## Process

### 1. Load the spec

The user passes a spec (a path, feature slug, or issue reference). Read it in full, then list its tickets with each one's status and blockers. Sort them:

- **In play**: `ready-for-agent`, or `claimed`/`done` left by a previous run. Resumption is free: the tracker carries the state, so a run that was interrupted picks up where it stopped.
- **Out of play**: any other status (`needs-triage`, `needs-info`, `ready-for-human`, `wontfix`). These are never dispatched, and the tickets they block stay blocked.

Present the plan: the spec branch name, the in-play tickets in dependency order, the out-of-play tickets and why. One confirmation, then go AFK.

### 2. Cut the spec branch

Require a clean working tree; stop and say so otherwise. Branch `spec/<feature-slug>` from the current branch and record that branch point (`git rev-parse HEAD`) as the **base**. If the spec branch already exists, check it out: this is a resumption, and the base is `git merge-base <parent-branch> HEAD`.

### 3. Work the frontier

One ticket at a time, lowest number first among the frontier: one working tree, one linear history. A tracer bullet is sized to a fresh context window, and a fresh subagent is exactly that.

For each ticket:

1. **Claim**: record `git rev-parse HEAD` as the **ticket base**, then set its status to `claimed` without committing. Keep this base through retries.
2. **Dispatch** a subagent with the brief below, filled in. It has none of your context; the brief is everything it knows.
3. **Verify** the report against the tree, since the report is the claim and the tree is the evidence: HEAD still equals the ticket base, the uncommitted diff contains only this ticket's work, required checks and review passed, and every acceptance criterion is ticked in the ticket file. An unticked criterion is a failure even when the report says done.
4. **Record**. On success, set the status to `done`; if the report carries notes for later tickets, append each under that ticket's Comments. On failure, append the report under the ticket's Comments, set the status back to `claimed`, and dispatch once more with a fresh subagent, preserving the uncommitted work and ticket base. A second failure **parks** the ticket: status `ready-for-human`, both reports in its Comments. Have the subagent remove incomplete implementation that would break subsequent tickets before parking; record any retained partial work in the ticket. The frontier flows around a parked ticket; whatever it blocks waits for the human.
5. **Commit once** after success or parking: stage this ticket's work and all associated tracker updates together, then commit as `NN: <title>` (or `Park NN: <title>`). Verify a clean working tree and `git rev-list --count <ticket-base>..HEAD` equals `1` before moving to the next ticket. An unexpected commit from a subagent must be consolidated with this ticket's changes before advancing; rewrite only this run's unpushed ticket commits.

Recompute the frontier and repeat until it is empty.

<dispatch-brief>

You are implementing one ticket of a spec on the current branch, `spec/<slug>`; that is the only branch you touch. Leave your work uncommitted for the orchestrator to include in the ticket's single commit.

- Spec: `<spec path>`. Read it for context; build only your ticket.
- Ticket: `<ticket path>`. Read it in full, including its Comments.
- Work already on this branch: `git log <base>..HEAD --oneline`.
- Fixed point for your review: `<ticket-base>`. Review the complete uncommitted ticket diff against it, including work retained from an earlier attempt.

Call the Skill tool with "implement" (or read `.agents/skills/implement/SKILL.md` and follow it), deferring its commit step to the orchestrator. Pass this commit ownership rule to any agents you delegate to. As you verify each acceptance criterion, tick it in the ticket file. Leave the ticket's `Status` line as you found it. Complete testing, review, and review fixes before reporting back.

Report back in exactly this shape:

```
Outcome: done | blocked
Changes: <summary of uncommitted work>
Validation: <checks and review results>
Unmet criteria: <one per line, or none>
Notes for later tickets: <NN: one line each, or none>
```

</dispatch-brief>

### 4. Close out

When the frontier is empty:

1. If every ticket is `done`, call the Skill tool with "code-review" against the base, with the spec as the Spec-axis source. Per-ticket reviews checked each ticket; this one checks the spec as a whole.
2. Report to the user: commits landed, tickets done, tickets parked with the reason from their Comments, and the review's findings. The spec branch stays for the human to review and merge; orchestration ends at the branch.
