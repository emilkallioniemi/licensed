# 33: Navigate and survive the track

Status: ready-for-human
Parent: [Navigation and survival revision](../navigation-survival.md)

Authorized 2026-10-08: improve the game after getting all existing work onto main.

## Acceptance

- [x] Consolidate and push all existing branch work to main before implementation.
- [x] Remove balance inputs, learner leaning, examiner body, speech and guidance.
- [x] Steering / speed / navigation, with report access exclusive to the occupied navigation seat and driving authority exclusive to the driving seats.
- [x] A physically traversable track with recoverable wall contacts, exposed edges, real missing spans, ordered crossings and a shared finish.
- [x] Lethal falls/crushing lose for everyone; righting on supporting road cannot rescue a fall or revive a dead learner.
- [x] Shared results, retry with fresh layout, and departure handling verified over three local peers.
- [x] Debug-only solo rehearsal with role views, input recording/replay, contribution disabling and save/load; excluded from exports.
- [x] Agent-owned state, collision, scene, rehearsal and network checks; inspect rendered navigator/steering views.
- [ ] Three humans rotate roles and evaluate navigator participation, fair danger, recoverable mistakes and repeated enjoyment.
- [ ] Actual Steam play verifies responsive controls and consistency across the intended machines.

## Comments

- Implementation and agent checks complete. See [verification](../navigation-evidence/README.md) and [rehearsal instructions](../../../docs/navigation-rehearsal.md). The track is a gameplay experiment; equal role enjoyment is not established by automated checks.
