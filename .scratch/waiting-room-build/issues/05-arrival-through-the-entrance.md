# 05: Arrival through the entrance

**Spec:** `.scratch/waiting-room/spec.md`, section 4 ("Arrival", "Room state on join", "Leave") and the kit request for a door leaf in Further Notes. Vocabulary: arrival, entrance, joiner.

**What to build:** Walking into a friend's room is a walk in, not a teleport, and everyone already there knows a friend has arrived without a toast. Leaving reads the same way in reverse.

For the joiner: fade to black when the join begins, the host's room loads, fade up standing in the doorway on the `Entrance` marker facing −Z, with the full host-owned state already applied: where the others stand, their palettes, and (once tickets 07 to 08 land) their picks and holds. Nothing resets because someone walked in. The joiner is palette 02 or 03 by arrival order regardless of what the host has done.

For everyone in the room: the entrance door leaf swings open, the learner appears, the door closes after a couple of seconds, and one positional placeholder door sound plays at the entrance, loud enough to hear from anywhere in the room. That is the room's only join notification: no toast, no examiner. Until Astra's closed door leaf lands, the sound alone carries it; build the theatre so the leaf can be dropped in.

A deliberate departure (a guest's Leave, ticket 09, or a dev-transport instance quitting cleanly) runs the theatre in reverse and the leaver's pick and hold are freed by the room state. What the room shows when a friend *drops* mid-room is a build-time call in the spec's Further Notes; decide it here, write the decision down, and append a line to `docs/corrections.md` if you were steered.

**Blocked by:** 04 (three learners in one room).

**Status:** ready-for-agent

- [ ] A joining instance fades to black, then fades up on the `Entrance` marker facing into the room.
- [ ] On the machines already in the room the door opens (or the sound alone plays until the leaf exists), the learner appears in the doorway, the door closes, and one door sound is heard positionally from the entrance, audible from the far corner.
- [ ] The joiner sees the others where they actually stand, in their existing palettes, on the first visible frame; nothing about the room resets.
- [ ] The joiner is the next palette by arrival order.
- [ ] A clean departure plays the theatre in reverse; the leaver's slot, pick, and hold are freed on every remaining machine.
- [ ] The mid-room drop behaviour is decided and written into the ticket's Comments; no silent default.
- [ ] Demoed with three local instances under `--transport=enet`.

## Comments

**From ticket 01 (orchestrator).** Headless scripts that fail an `assert` hang forever instead of exiting; run them with a timeout. The editor drops `~libgodotsteam...dll` copies in `addons/godotsteam/win64/` while open; `.gitignore` covers `addons/**/~*`.