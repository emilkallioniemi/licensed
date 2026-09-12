---
name: orchestrate
description: "Drive a ticketed spec to done AFK: cut a spec branch, then dispatch one fresh /implement subagent per ticket across the frontier until every ticket is done."
disable-model-invocation: true
---

A spec has been broken into tickets (`/to-tickets`) and they are `ready-for-agent`. Orchestration walks the whole set without a human in the loop: one **spec branch** for the spec, one fresh subagent per ticket running `/implement`, working the **frontier** (open tickets whose blockers are all done) until nothing is left open.

The orchestrator **dispatches and verifies**. Every line of code lands through a subagent; the orchestrator's own edits are to ticket files and nothing else. The pull to fix one small thing yourself between dispatches is the signal to write a ticket comment and dispatch again.

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

1. **Claim**: set its status to `claimed` and commit (`Claim NN: <title>`).
2. **Dispatch** a subagent with the brief below, filled in. It has none of your context; the brief is everything it knows.
3. **Verify** the report against the tree, since the report is the claim and the tree is the evidence: working tree clean, new commits on the spec branch since the claim, every acceptance criterion ticked in the ticket file. An untidy tree or an unticked criterion is a failure even when the report says done.
4. **Record**. On success, set the status to `done` and commit (`Done NN: <title>`); if the report carries notes for later tickets, append each under that ticket's Comments. On failure, append the report under the ticket's Comments, set the status back to `ready-for-agent`, and dispatch once more with a fresh subagent. A second failure **parks** the ticket: status `ready-for-human`, both reports in its Comments. The frontier flows around a parked ticket; whatever it blocks waits for the human.

Recompute the frontier and repeat until it is empty.

<dispatch-brief>

You are implementing one ticket of a spec. All work is committed to the current branch, `spec/<slug>`; that is the only branch you touch.

- Spec: `<spec path>`. Read it for context; build only your ticket.
- Ticket: `<ticket path>`. Read it in full, including its Comments.
- Work already on this branch: `git log <base>..HEAD --oneline`.
- Fixed point for your review: run `git rev-parse HEAD` before your first edit and use that.

Call the Skill tool with "implement" (or read `.agents/skills/implement/SKILL.md` and follow it). As you verify each acceptance criterion, tick it in the ticket file and commit that file with the work. Leave the ticket's `Status` line as you found it.

Report back in exactly this shape:

```
Outcome: done | blocked
Commits: <one line per commit>
Unmet criteria: <one per line, or none>
Notes for later tickets: <NN: one line each, or none>
```

</dispatch-brief>

### 4. Close out

When the frontier is empty:

1. If every ticket is `done`, call the Skill tool with "code-review" against the base, with the spec as the Spec-axis source. Per-ticket reviews checked each ticket; this one checks the spec as a whole.
2. Report to the user: commits landed, tickets done, tickets parked with the reason from their Comments, and the review's findings. The spec branch stays for the human to review and merge; orchestration ends at the branch.
