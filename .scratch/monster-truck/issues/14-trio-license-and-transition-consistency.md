# How are personal licenses saved and test transitions kept consistent?

Label: wayfinder:grilling
Type: grilling
Status: resolved
Parent: ../map.md
Blocked by: 11

## Question

Given [How are results, best ratings, and retries shared?](11-results-and-retries.md), how will each player's personal license survive room closure, host changes, and playing with different friends, and how will result completion, unanimous choices, and departures produce one consistent outcome?

Inspect the existing host-authoritative room and Steam identity foundation. Define stable player identity, where records are retained, how returning players restore and reconcile records, and when a completed result becomes durably earned. Address missing or stale copies and host loss around result completion without silently promising storage guarantees the implementation cannot provide. Preserve each player's stamps and best ratings monotonically; another player's existing achievements are never transferred merely by sharing a room.

Define the ordering and reset rules for concession, timer expiration, result completion, retry/return agreement, and departure. Specify what happens to pending choices when the attempt or membership changes. Keep the settled rule that an unfinished attempt is abandoned on departure, while completed results remain earned. Establish observable multi-client validation cases for host changes, returning trios, worse retries, and departure races.

This is a planning decision about persistence and transition consistency, not implementation. Personal ownership supersedes exact-trio ownership by explicit user direction. Preserve unanimous transitions and the no-host-migration departure flow. Physical simulation synchronization remains separate map fog.

## Comments

- 2026-09-12: User delegated interrupted-save recovery. Decision: retain a receipt of the host-settled result on participating players' machines, naming the attempt, vehicle, participants, and shared result. When participants next share a room, a surviving receipt may restore only the recipient's own missing stamp or improved rating from that attempt, never another player's unrelated achievements. Recovery does not require the original trio to reunite. This is recovery from an existing settled result, not permission to infer a pass from an unfinished attempt. If no saved copy survives, recovery cannot be guaranteed.
- 2026-09-12: User accepted expiring pending concession and Retry/Waiting room choices when the attempt ends or room membership changes. Choices never carry into another attempt; a late concession cannot change a settled result, and departure uses the previously agreed return flow.

- 2026-09-12: User confirmed that a pass becomes earned when the test completes, before the examiner's assessment finishes or anyone chooses Retry. Departures before completion abandon the unfinished attempt; departures afterward preserve the earned result. Saving and distributing that settled result must begin at completion, not on dismissal of the results sheet. Interrupted delivery or saving still needs a recovery rule; logical completion alone does not guarantee a surviving durable copy.

- 2026-09-12: User confirmed that the personal license must follow the player's Steam account across reinstallations and computers. Accepted local saving plus Steam Cloud backup, with local saving operating independently. Cloud setup and verification are explicit implementation requirements; this does not establish that Cloud is configured or that every recent local save has uploaded. Durable result recording, interrupted distribution, and reconciliation still need to be specified.

- 2026-09-12: User confirmed personal ownership: a shared pass awards all three players the stamp and same attempt rating, with each keeping their own best rating across groups. Updated the previous results decision, map index, glossary, README, and design judgment to supersede exact-trio ownership. User also confirmed a personal physical card showing portrait, stamps, and best ratings, and booking-board ownership shown side by side for current players. Detailed card interaction and assets remain presentation planning; storage and transition consistency remain unresolved here.

- 2026-09-12: User explicitly reopened exact-trio ownership, superseding this ticket's restriction against reopening it. Proposed personal licenses that retain each player's earned vehicles across different groups, show which current players hold a vehicle's license, and can be physically held up to show off. Ownership and physical presentation are under discussion; the previous exact-trio decision and glossary must be reconciled once the replacement is confirmed.
- 2026-09-12: User accepted failure winning when final manoeuvre completion coincides in the same simulation step with timer expiration or a serious fault. Once a pass is settled, later chaos during the examiner's assessment cannot undo it. Durable recording and departure races remain open.

## Answer

Resolved with the user after confirmation of the full behavior on 2026-09-12. Personal ownership and physical presentation supersede the earlier exact-trio design; the results decision, glossary, README, and design judgment have been reconciled.

- Each player owns a license across friend groups, with one shared pass awarding all three participants the vehicle's stamp and same attempt rating. Each player retains their own best. The physical license shows its owner's portrait, stamps, and best ratings; the booking board shows current players' stamp ownership side by side. [Which presentation assets and checks are required to finish the monster truck?](12-presentation-assets-and-validation.md) owns remaining physical-card interaction, asset, and readability decisions.

- Personal saves are scoped to the signed-in Steam account. Store durable Steam IDs without precision loss; transient network peer IDs and display names are not license identity. Development transport uses isolated test records.
- Local saves retain stamps and best ratings monotonically, along with recoverable result receipts. Reconcile older local, cloud, or receipt data by retaining earned stamps and best ratings for that account, rather than replacing progress with whichever file was written last. A receipt can restore awards only for its named participants. Steam Cloud setup, supported conflict handling, and multi-computer verification are implementation requirements, not established capabilities of the current project.
- The host settles one result per uniquely identified attempt. Final completion passes only with time remaining and no serious fault; timer expiration or a serious fault wins a same-step tie. A pass is earned at completion, before the examiner's assessment ends. Save locally and distribute the result immediately; recipients save and acknowledge it. Cloud upload is not a prerequisite for gameplay or a promise of immediate backup.
- Once settled, a result is immutable. Concession requires three current agreements while the attempt is active and cannot override a settled outcome. Process commands under host authority with attempt and phase checks; a departure abandons an attempt only if it is still unfinished. Membership changes invalidate pending choices. A retry creates a fresh attempt with no inherited choices; duplicate or delayed commands and result deliveries have no additional effect.
- Interrupted delivery may leave some players without the result until a surviving receipt is exchanged. Never claim that the save or cloud upload succeeded without confirmation. If local saving fails, retain the result in memory, continue replication to the other participants, visibly report that it could not be saved, and allow saving to be retried without trapping the group in the results flow. If every durable copy is lost, no recovery guarantee is possible.
- Validate host changes and different friend groups; account separation on one computer; worse retries; stale save reconciliation; one participant missing result delivery; recovery with just one original friend; duplicate receipts; unrelated-account receipt rejection; completion/deadline/serious-fault ties; concession and departure races; delayed choices after retry; local write failure; and the supported Steam Cloud reinstall/computer-change flow. Use multiple actual Steam accounts to verify shipping identity and Cloud behavior. Local transport fixtures alone are insufficient.

[What Steam Cloud setup and reconciliation support personal licenses?](15-steam-cloud-license-support.md) owns the remaining external capability and configuration investigation. No game implementation or persistence validation was performed in this decision session.
