# 11. Write the spec

Type: task
Status: resolved
Blocked by: 01, 02, 03, 04, 05, 06, 07, 08, 09, 10
Map: ../map.md

## Question

Every decision on the map is made. Assemble them into `.scratch/waiting-room/spec.md`: the destination, written as one document a build session (or a ticket-cutting session) can work from without reopening the tickets.

Contents, in the order a player meets them: launch and Steam init (and the "Steam not running" state), the waiting room and the learner, the reception desk and arrival, the booking board, role pickup, ready-up and refusals, the launch stub, voice (in or out), the solo-testing seam, and the GitHub release package. Each section points back to the ticket that decided it. Anything the tickets left open is listed at the end as a build-time call, not silently decided here.

This is the map's arrival, not a decision: it earns its place because nothing can be built or ticketed until it exists.

**How to resolve it**: do not hand-write the spec inside a wayfinder session. Once every other ticket is resolved, open a fresh session and run `/to-spec` against this map; it collapses the linked decisions into `spec.md`. Then `/to-tickets` on the spec, then `/implement` per ticket with cleared context between each. Resolving this ticket means the spec exists and the map is closed.

## Comments

- 2026-09-12, from [Ready-up and the launch stub](09-ready-up-and-launch.md): every blocker is now resolved; this ticket is the frontier and the map's last. Two things to carry into the spec's structure: the section list in the question says "ready-up and refusals, the launch stub"; the glossary now calls the stub the **test area** and the refusals live on the **notice board**, so name the sections that way. The map's remaining Not yet specified lines (departure theatre in the room, shoving, return after a real test, what the test area grows into) are the spec's build-time open list, none of them tickets. The kit requests across the map are two: a closed entrance door leaf (walkthrough) and a seated learner (ready-up); the spec should list both in one place.

## Answer

Resolved 2026-09-12 by a fresh `/to-spec` session against the map, as the question asked. The spec is [`../spec.md`](../spec.md), `Status: ready-for-agent`.

- Sections run in the order a player meets them (launch and Steam, room and learner, stations, reception desk and arrival, booking board, role pickup, ready-up and notice board, test area, Escape overlay, voice, dev transport and `--min-players`, release package), each naming its ticket; all copy is gathered in one table; the two kit requests sit in one place; the map's Not yet specified lines are the spec's build-time list.
- Two spots where tickets met were reconciled in the spec rather than left open, and are marked as such: Escape closes an open station screen before it opens the Escape overlay (tickets 04 and 10); the Random deal is revealed in the test area, not on the board (ticket 09 over ticket 08's lean).
- Two minimal calls the tickets never made are stated and put on the build-time list: the Steam-not-running state's two lines, and the palette's shirt colour as the flood colour.
- Testing seam: one, the host-owned room state as a plain script driven by commands, tested with headless `SceneTree` scripts in the shape of `assets/slice_0/verify_assets.gd`; everything touching Steam, rendering, or three people is checked by the three-instances protocol, the real-Steam check with a friend, and the voice echo.

Next: `/to-tickets` on the spec, then `/implement` per ticket with cleared context. The map is closed.
