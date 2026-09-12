# How will the first playable build validate three-player cooperation?

Label: wayfinder:grilling
Type: grilling
Status: resolved
Parent: ../map.md
Blocked by: 01

## Question

Define the first playable checkpoint of the actual monster-truck implementation: its candidate controls, physical layout, minimum driving situations, and the observations that would require revision. This ticket resolves the checkpoint requirements and evaluation plan with the user, not the gameplay verdict. Build and run it after `/to-spec` and `/to-tickets`, retaining useful implementation and iterating toward the complete vehicle. The evaluation below is a future implementation requirement, not a prerequisite for resolving this planning ticket.

Use the candidate in [What makes the monster truck require three players?](01-cooperation-and-truck.md) to test a tight reversing manoeuvre, a moving turn, and stopping to climb onto the roof. Does front steering / rear steering / throttle-and-brake give all three players satisfying decisions and funny consequences, while physical movement and swapping preserve the need for three active contributors?

Run with exactly three humans and rotate everyone through the controls. After familiarisation, have one player deliberately stop contributing while remaining in the session; compare against coordinated attempts and attempts where players swap or seek better sight. Can the other two succeed by leaving rear steering fixed or hopping between controls? Does each control demand anticipation without becoming confusing or tedious? Does getting up add enjoyable physical interaction, and can all three appreciate the consequences?

During implementation, compare observed handling and sight adjustments one at a time where needed. Record observations and the human players' reactions, including reasons to revise the split: optional rear steering, an unengaging throttle/brake responsibility, two active players doing all the work, or movement erasing the blind spots. Link the playable build and record whether to retain or revise the candidate. Do not claim the split is validated from agent-only testing or conversation.

This is a bounded checkpoint within the complete vehicle build. Use a minimal test wrapper consistent with the specification; full test format and serious-fault termination are separate decisions. Any temporary treatment of falls, overturned trucks, and resets must be identified and replaced by the specified behaviour in later implementation checkpoints.

## Comments

- 2026-09-12: Resumed the existing claim with the user's authorization; no other session is working on this ticket. Continue deciding the implementation checkpoint, preserving the arcade handling target and future three-human validation requirement.

- 2026-09-12: User questioned the separate prototype prerequisite and reiterated building the actual complete vehicle, including substantial asset and animation production. Reframed this ticket as planning an implementation checkpoint. The handling candidate remains unvalidated until three humans play it; resolving the checkpoint plan must not be reported as validating cooperation.

- 2026-09-12: User clarified the handling target: not realistic, a little hard, and still fun. Treat arcade coordination as the source of difficulty; exact steering inputs and tuning remain candidates, not accepted decisions. This does not resolve the required three-human playable comparison.

## Answer

Resolved with the user on 2026-09-12, accepting all three checkpoint recommendations. This resolves the implementation checkpoint plan; the handling candidate remains unvalidated until three humans play it.

- Steering inputs gradually turn their respective axle within a limited range, with quick response. Releasing the input holds the angle rather than centring it; operators must deliberately unwind turns. Leaving the control also retains its setting. Target arcade coordination that is a little hard and fun, not realistic handling; exact rates, limits, and bindings remain implementation tuning and control-guidance work.
- Place front steering on the left, throttle/service brake on the right, and rear steering behind them facing backward, in a roomy cab with a climbable roof. Everyone can look around; bodywork limits sight from each physical position and creates information to communicate. Dimensions remain adjustable during implementation. Preserve physical handovers, exclusive occupancy, unattended-control behaviour, and the separate parking brake already agreed.
- The first playable checkpoint includes boarding, a moving turn, tight reversing, and parking to climb onto the roof. Build it as part of the actual vehicle after `/to-spec` and `/to-tickets`, using rough geometry, a running timer, and placeholder examiner audio. Preserve useful implementation as the complete vehicle develops.
- Rotate exactly three human players through every control. After familiarisation, compare coordinated attempts with one player deliberately not contributing, including attempts to leave rear steering fixed or hop between controls. Observe whether each operator anticipates consequences, enjoys their responsibility, and can appreciate the physical comedy; also examine whether moving for sight erases the need to communicate.
- Revise the candidate if rear steering becomes optional, throttle/brake feels dull, or two active contributors succeed by swapping. Compare handling and sight adjustments one at a time, recording player reactions and linking the playable build. Conversation and agent-only checks cannot establish fun or three-player necessity.
- This checkpoint does not need the complete route, finished art, or full presentation. Existing recovery and failure decisions remain the target; identify any temporary checkpoint treatment and replace it in later implementation checkpoints. Full-test pacing and replay validation belong to [How will the complete playable test validate pacing and replay?](10-test-structure-playtest.md); detailed bindings, hints, and timer visibility belong to [How do players learn the controls and see test information under pressure?](13-control-guidance-and-test-information.md).
