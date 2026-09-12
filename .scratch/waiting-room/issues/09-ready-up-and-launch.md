# 09. Ready-up and the launch stub

Type: grilling
Status: resolved
Blocked by: 07, 08
Map: ../map.md

## Question

Three learners, one booking, three roles held. How do you say "we're ready", and where do you end up?

The kit has three numbered chairs (`WaitingChairs`, 01/02/03) and a closed "Test Area" door (`TestDoor`, separate leaf, but the wall behind it is solid; an opening needs kit work). The waiting-room loop `please_take_a_number.wav` is there to fade under a transition.

1. **Ready-up.** Candidate: each player sits in a chair; when all three are seated, the test door opens and the examiner calls the booking ("Monster truck. This way."). Alternatives: a button at the desk, a hold-to-ready. Whatever it is, it must be undoable until the last moment, and it must refuse (visibly, in register per `docs/design.md`) if there is no booking, a role is missing, or there are not three of you. The debug override from Testing alone applies here.
2. **Transition.** Fade, door, countdown. Short. Music fades on the player, not in the asset.
3. **The stub.** The three learners standing together somewhere (the car park outside the test centre is the obvious place), able to run around, each with their role shown over their head. Nothing else. It exists to prove role and input carried across the network and to be the scene Slice 1 grows the truck into.
4. **Back.** Is there a way back to the waiting room from the stub in this slice, or do you quit? Cheap to add, and it makes the stub demoable more than once.

Deliverable: an answer recording the ready-up mechanic, its refusals, the transition, and the stub's contents.

## Comments

- 2026-09-12, from [The reception desk](06-reception-desk.md): the room is a FRIENDS_ONLY Steam lobby of max three from boot, and the desk header counts "N of 3"; the refusal for "not three of you" can lean on that count. Guests can Leave from the desk and the host cannot, so "host leaves" is not a ready-up state this slice. On-screen copy in the room so far is a dry *signage* register (the desk) distinct from the examiner's spoken lines; item 1's examiner call ("Monster truck. This way.") would be his first line in the waiting room, which the map's fog still holds open; decide it here or hand it to an examiner ticket, but do not let it happen by default. Item 4 ("Back") now has a precedent: Leave puts a guest in a fresh room of their own; a way back from the stub could reuse that path for everyone.
- 2026-09-12, from [Role pickup](08-role-pickup.md): three things land here. (1) The gate reads "every player holds a named role **or Random**"; Random is not exclusive, so two or three Randoms is a valid ready state. (2) **Random is dealt at launch confirmation**: the host shuffles the remaining named roles onto the Random holders. The rule is decided; the *theatre* is yours: lean toward the board's strips filling with the dealt names and the name tag lines updating for a beat before the door or fade, so the room shows the final deal, versus revealing it only in the stub. (3) The name tag already carries a second line with the held role, so item 3's "role shown over their head" in the stub is that line carried across, not a new element. Also: roles are released whenever the booking dissolves, so "no booking" and "a role is missing" refusals cannot both be true at once; if there is no booking there are no roles.
- 2026-09-12, from [The booking board](07-booking-board.md): both blockers are now resolved; this ticket is the frontier. What the board hands over: (1) a **booking** exists only when all three players in the room have picked the same vehicle, so "no booking" and "not three of you" overlap heavily: with fewer than three there is never a booking, and the only refusal that can stand alone at three is "a role is missing". Order the refusals accordingly. (2) `--min-players=N` now gates the booking as well as the ready-up (amendment on Testing alone), so the debug override is one number, not two. (3) The booked row reads **BOOKED** and the moment of booking has a placeholder sound from the board; if the ready-up wants a moment of its own (door, examiner call), it should be a different sound and a bigger one. (4) The board's copy is signage register; the examiner's first line in the waiting room is still yours to decide or hand off, not the board's. (5) A guest leaving dissolves the booking and releases every role, so a ready state cannot survive a departure; "undoable until the last moment" gets that for free.
- 2026-09-12: one round of eleven questions, each with a recommendation; Emil gave the agent free hands and every recommendation stands.

## Answer

Decided in conversation on 2026-09-12 (one round, recommendations accepted as-is). Kit facts from `assets/waiting_room/README.md`: three individually grouped chairs (`WaitingChairs`, 01/02/03) on the left wall; a spare notice board (`FutureDisplay`); a `TestDoor` whose leaf is separate geometry but whose rear wall is solid; the learner (`assets/slice_0/player/learner.tscn`) is rigid meshes with no rig and cannot sit. Station grammar, first person, palettes by arrival order and the name tag are [Waiting room walkthrough](04-waiting-room-walkthrough.md); the booking and its dissolution are [The booking board](07-booking-board.md); roles, Random and the name tag's role line are [Role pickup](08-role-pickup.md); host-owned state, Leave and the arrival theatre are [The reception desk](06-reception-desk.md); the Escape overlay is [Voice: in this slice or not](10-voice-in-or-out.md).

### 1. The mechanic: chairs

- **Sitting is readying; standing is un-readying.** The three chairs are stations under the one grammar: walk into the zone, prompt, **E** to sit; **E or any movement key** to stand. Seated, the camera drops to about 1.2 m and mouse look stays live, so you can watch the door and the board.
- **Any chair, first come.** Chairs are not assigned to seat numbers; the numbers are decor. An occupied chair floods with the sitter's palette colour (one material swap per chair group), the same visual language as the strips and chips. No refusal exists for "wrong chair" because there is no wrong chair.
- **The chair never refuses.** Sitting is allowed in any room state. Readiness is simply "seated"; what is missing is stated on the notice board (section 2).
- The **ready-up fires** when, evaluated by the host on every state change: the room holds three players (`--min-players=N` under the dev transport), a booking exists, every player holds a named role or Random, and every player is seated. Rejected: a Ready button on a station screen (a lobby with extra steps) and hold-to-ready.

### 2. The notice board: the room's one sign

- The kit's spare notice board (`FutureDisplay`) becomes the **notice board**: one line of signage text (the desk's dry register, not the examiner's), always on, readable from the chairs. It is **not a station and not a station screen**: nobody uses it; it states what the room is waiting for.
- Copy, by priority (the first true line shows):
  - fewer than three in the room: **"Waiting for 2."** / **"Waiting for 1."**
  - three, no booking: **"No booking."**
  - booking, roles missing: **"Roles: 2 of 3."** (count of players holding a named role or Random)
  - roles held, not all seated: **"Seated: 1 of 3."**
  - everything held: the countdown, **"Monster truck. 3."**, **"Monster truck. 2."**, **"Monster truck. 1."**
- Under `--min-players=N` every count is out of N.

### 3. The examiner's one line

- When the ready-up first fires, the examiner **calls the booking**: one TTS line, voice only, no body, heard by everyone in the room. The line is **"Monster truck."** (the longer form, "Monster truck, when you're ready.", is acceptable if the terse one reads as a glitch in TTS). Signage never speaks; this is the only examiner line in the waiting room this slice.
- If the launch is cancelled and re-armed, he says it again, identically.
- Everything else about the examiner in the room (a body, a door of his own, an entry line such as "Please take a seat.", where he stands) is **ruled out of this map's scope**: Slice 1 owns the examiner and can seat him in the room then. The map's "examiner in the waiting room" fog closes on this.

### 4. The countdown

- **Three seconds** from the ready-up firing, counted on the notice board. The examiner line plays at the start; the transition begins at the end.
- Any of these **cancels silently**: a player stands, a pick changes, a role is dropped, a player leaves. The notice board returns to its state line; nothing is announced. Standing is the deliberate undo; the rest dissolve the state anyway per the board and the role pickup.

### 5. The transition

- **Fade to black over about one second.** The entrance door's placeholder sound is reused as the Test Area door opening. The waiting-room loop fades on its `AudioStreamPlayer` over the same second, not in the asset.
- **No door animation** this slice. The leaf would open onto a solid wall; an opening in the rear wall is a kit request for a later slice, and a corridor or walk-through is not wanted.

### 6. The Random deal

- The host deals the remaining named roles to the Random holders, shuffled, one each, **at the end of the countdown**, the instant the fade starts. Nothing is dealt during the count, so a cancel has nothing to revert.
- The **reveal happens in the test area**, not on the board: the other two's roles on their name tag's second line (already carried across), and **your own role as one line of small text in a corner of your screen**, for named and dealt roles alike. First person never shows your own name tag, so without this line a Random holder would never learn what they were dealt. The board's strips do not update; nobody is looking and the room is about to be left.

### 7. The test area stub

- The **car park** outside the test centre: a flat asphalt plane with painted bays (boxes; no kit request), daylight, nothing else.
- Three learners spawn in a row in three bays, 1.5 m apart, facing the same way, with the same first-person controller: solid to each other, no shove, 3 m/s, no jump. Fade in on arrival.
- Shown: name tags with the role line over the other two; your own role in the corner; **one sign reading the booked vehicle** (MONSTER TRUCK), so the booking is visibly carried across as well as the roles.
- Voice runs unchanged, positional from the body. No music, no examiner, no truck, nothing to do. It is Slice 1's starting scene; the corner role line and the vehicle sign are the only two elements it commits Slice 1 to.

### 8. Back

- The **Escape overlay in the test area** gains one item, **"Back to the waiting room"**, shown to the **host only**; guests see the usual three items (mic mode, mute, quit to desktop).
- Everyone returns together to the same room, arriving through the entrance one after another with the arrival theatre reused, with **all state cleared**: no picks, no roles, nobody seated, notice board reading "No booking." The ritual is the demo, so it is done again from the start.
- **Shared fate on the other exit:** if any player drops or quits in the test area, the remaining players are returned to the waiting room the same way (a room of two, nothing booked). No host migration and no late join, as the map already rules; if the host drops, guests land in fresh rooms of their own, as the reception desk decided.

### 9. Kit request

One: a **seated variant of the learner** (`learner_seated`, same six palettes) from Astra, since the rigid model cannot bend. Until it lands the build places the standing learner on the chair's footprint facing into the room; the chair's colour flood is the ready signal either way.

### 10. Under the dev transport

Same rules. `--min-players=N` is the count in every notice board line and the count the ready-up waits for. Solo: pick, take a role, sit, and the count starts. Nothing on the chairs, the notice board, or the test area knows which transport it is on.

### Glossary

Updated in `CONTEXT.md`: **Ready-up** reworded (seated in a chair is ready, standing is not); added **Notice board** and **Test area**; **Escape overlay** now covers the test area too.

### Corrections logged

None: no steer this session, the recommendations were accepted.

Unblocks: [Write the spec](11-write-the-spec.md), the map's arrival. Comments left there and on Voice (Escape overlay item) and The reception desk (return-to-room reuses the arrival).
