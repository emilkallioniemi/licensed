# How are results, best ratings, and retries shared?

Label: wayfinder:grilling
Type: grilling
Status: resolved
Parent: ../map.md
Blocked by: 03, 07

## Question

Given [When should a disastrous test end?](03-failure-and-scoring.md), how does the group see its latest result, compare its best rating, retry, or return to the waiting room? Decide who initiates each transition and what agreement is required from the three players. Keep earned stamps and best ratings across worse retries.

Apply [How do players recover after leaving or overturning the truck?](07-movement-and-recovery.md): the group can concede a failed attempt and retry when physical rescue proves impossible. Decide who initiates concession, what agreement it requires, and how it reaches results and retry. Concession abandons the attempt; it never frees a learner within the current test.

What owns and retains the shared best rating when the room ends or the group changes? Inspect the existing license and multiplayer foundation before proposing persistence behavior. Distinguish the shared attempt result from any retained record without introducing individual performance scores. Coordinate visual and audio presentation with [What presentation makes the monster truck feel complete?](05-finished-experience.md); this ticket owns flow and record semantics, not final artwork.

## Answer

Resolved with the user after confirmation of the complete flow on 2026-09-12.

- Each player owns a personal license retained across hosts and groups of friends. A pass awards all three players the vehicle's stamp and the same attempt rating; each retains their own best rating. There is no individual performance scoring. This supersedes the exact-trio ownership decision following the user's explicit reopening and confirmation during [How are personal licenses saved and test transitions kept consistent?](14-trio-license-and-transition-consistency.md).
- Keep the agreed marked results sheet over the aftermath, showing the latest shared result, minor faults, passing rating when applicable, and the retained best for comparison. Worse retries and failures never remove stamps or reduce the best rating.
- Each player chooses Retry or Waiting room on the results sheet. Choices remain changeable while waiting; three matching choices trigger the transition.
- Retry resets the scrapyard and places learners beside the parked truck, parking brake engaged and examiner seated. The timer starts immediately, as on first arrival. Skip booking and chairs between retries.
- Anyone can propose Concede test through the Escape overlay. All three must agree, with the timer continuing during the decision. Agreement abandons the attempt as a shared failure and opens the usual results flow. It never rescues a learner within the current attempt.
- Replace the existing host-only immediate return action with concession. Anyone can still quit. A disconnect abandons an unfinished attempt without changing earned records: guest departure returns survivors to the waiting room; host departure sends guests to their own rooms. Completed results remain earned.

The License glossary reflects personal ownership. This resolves player-facing record semantics and flow, not storage or replication architecture. [How are personal licenses saved and test transitions kept consistent?](14-trio-license-and-transition-consistency.md) owns durable result recording, restoration, and transition races against departures. No game implementation or gameplay validation was performed.

## Comments

- 2026-09-12: User confirmed one license per exact trio, independent of who hosts. Changing one player selects a separate license; reuniting the original trio restores its stamps and best ratings. Each player can belong to several trios, each with its own shared license. Updated the License glossary definition. This supersedes the host-owned proposal.

- 2026-09-12: User agreed that Retry restarts directly beside the reset truck, parking brake engaged and examiner seated, with the timer starting immediately; no booking or chair sequence between retries.
- 2026-09-12: User agreed to replace the host's immediate return with the concession flow. Anyone can still quit. A disconnect abandons an unfinished attempt without changing earned records: guest departure returns survivors to the waiting room; host departure sends guests to their own rooms. Completed results remain earned.
- 2026-09-12: User proposed that the license stays with the group of friends who earned it rather than the host's room, and asked whether this is a good idea. Exact-trio ownership, host independence, and returning-group restoration are under discussion; persistence is not yet settled.

- 2026-09-12: User agreed that each player chooses Retry or Waiting room on the results sheet, can change that choice while waiting, and three matching choices trigger the transition.
- 2026-09-12: User agreed that anyone can propose Concede test through the Escape overlay, all three must agree, and the timer keeps running during the decision. Agreement ends the attempt as a failure and opens the usual results flow.
- 2026-09-12: Implementation inspection found no license, stamp, rating, or test-result persistence. The host owns replicated room state. The existing host-only Escape action returns everyone immediately; guest departure during a test returns survivors, and host loss sends guests to fresh rooms of their own. Result agreement intentionally changes the existing host-only return flow; active-test exit and retained-record ownership remain to settle.
