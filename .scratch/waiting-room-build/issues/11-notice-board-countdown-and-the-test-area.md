# 11: Notice board, countdown, and into the test area

**Spec:** `.scratch/waiting-room/spec.md`, section 7 (ready-up, notice board, examiner line, countdown, deal, transition) and section 8 (the test area). Copy in section 13. Read `docs/design.md`: the examiner's register for the one spoken line, the signage register for the board, *Polish before funny* for the car park.

**What to build:** Three players seated with a booking and a role each hear the examiner say "Monster truck.", watch the notice board count three, two, one, and fade up together in a car park with their roles over their heads and the booked vehicle on a sign. Until then the notice board says, in one line, what the room is waiting for.

Notice board: the kit's spare display becomes the room's one sign, always on, readable from the chairs, not a station. It renders the room state's line (ticket 02): "Waiting for 2." / "Waiting for 1." / "No booking." / "Roles: 2 of 3." / "Seated: 1 of 3." / "Monster truck. 3." / "2." / "1.", counting out of N under `--min-players`.

Ready-up and countdown: evaluated by the host on every state change (the room state does this; the view listens). When it first fires, the examiner calls the booking: "Monster truck.", TTS, voice only, no body, heard by all ("Monster truck, when you're ready." is acceptable if the terse form reads as a glitch in TTS). Three seconds counted on the board. Cancelled silently by any stand, pick change, hold drop, or departure; the board returns to its state line, nothing announced; re-arming says the line again identically. It is the only examiner line in the room; signage never speaks.

The deal: at the end of the count, the instant the fade starts, the host deals the remaining named roles to the Random holders (room state). The board's strips do not update; the reveal is in the test area.

Transition: fade to black over about one second; the entrance door's placeholder sound reused as the Test Area door; the music fades on its player over the same second. No door animation.

The test area: a flat asphalt plane with painted bays as boxes, daylight, nothing else. Three learners appear in a row in three bays 1.5 m apart facing the same way, same first-person controller, fade in on arrival. Name tags over the other two carry the role line, now the dealt role for former Random holders. Your own role, named or dealt, as one line of small text in a corner of your screen. One sign reading MONSTER TRUCK. No music, no examiner, no truck, nothing to do. Back to the waiting room is ticket 12; for this ticket the test area is a dead end and Escape releases the mouse.

**Blocked by:** 06 (seated state), 08 (holds and Random).

**Status:** ready-for-agent

- [ ] The notice board shows exactly the room state's line at all times and changes the instant the state does; it is not a station.
- [ ] With fewer than N players it reads "Waiting for k."; at N without a booking "No booking."; with a booking "Roles: x of N." then "Seated: x of N."; the counts match the room.
- [ ] When N players are seated with a booking and a hold each, every machine hears TTS "Monster truck." once and the board reads "Monster truck. 3.", "2.", "1." over three seconds.
- [ ] Standing, changing a pick, dropping a hold, or a departure during the count returns the board to its state line with no sound and no line; re-arming replays the call.
- [ ] At "1." the room fades to black over about a second with the door sound and the music fading on its player; no door opens.
- [ ] Everyone fades up in the car park in three bays 1.5 m apart facing the same way, walking with the same controller; nobody is missing or duplicated.
- [ ] Each former Random holder sees a distinct dealt named role in the corner line; named holders see their own; the other two learners' name tags show the same roles.
- [ ] A sign reading MONSTER TRUCK is visible in the car park.
- [ ] Works with `--min-players=1` alone and with three local instances.
