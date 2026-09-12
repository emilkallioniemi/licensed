# 12: The Escape overlay: quit, and Back to the waiting room

**Spec:** `.scratch/waiting-room/spec.md`, section 3 ("Escape precedence"), section 8 ("Back", "Shared fate on the other exit"), section 9. Copy in section 13. Vocabulary: Escape overlay (not a menu, not a pause).

**What to build:** Escape opens a small panel over the world with a way to quit that is not Alt-F4; in the test area the host also gets Back to the waiting room, which returns everyone through the entrance with the room reset for another go. Mic mode and mute are added to this panel by ticket 13.

Escape precedence: while a station screen is open, Escape closes it; when nothing is open, Escape opens the overlay. The overlay is never opened over a station screen. Escape or a close control dismisses it. The mouse is released while it is open and captured again on close. The room and voice run on behind it; it pauses nothing. It is the room's only 2D panel and its only way to quit; there is no kit prop for it. Plain Control theme, signage register: "Quit to desktop", and "Back to the waiting room" for the host in the test area only.

Back: everyone returns together to the same room, each arriving through the entrance one after another with the arrival theatre (ticket 05), with all state cleared by the room state's return command (ticket 02): no picks, no holds, nobody seated, notice board "No booking.", desk header "3 of 3", music loop restarted.

Shared fate: if any player drops or quits in the test area, the remaining players are returned to the waiting room the same way (a room of two, nothing booked). If the host drops, guests land in fresh rooms of their own (ticket 09's path). No host migration, no late join.

Ticket 03's stand-in (Escape merely releasing the mouse) is replaced by this.

**Blocked by:** 11 (the test area).

**Status:** ready-for-agent

- [ ] With a station screen open, Escape closes the screen and does not open the overlay; a second Escape opens the overlay.
- [ ] In the waiting room the overlay shows "Quit to desktop" only; in the test area the host also sees "Back to the waiting room" and guests do not.
- [ ] While the overlay is open the other learners keep moving on your screen and the mouse is a cursor; closing it recaptures the mouse.
- [ ] "Quit to desktop" quits; there is no other in-game way to quit.
- [ ] Host presses Back: every player arrives back in the same room through the entrance with the door theatre; the board has no chips, the strips read "No booking.", no chair is flooded, the notice board reads "No booking.", the desk header reads "3 of 3", the music is playing from the start.
- [ ] A guest quitting in the test area returns the other two to the waiting room with nothing booked.
- [ ] The host quitting in the test area lands each guest alone in a fresh room of their own.

## Comments

**From ticket 03 (orchestrator).** Escape currently releases the mouse (`Learner._unhandled_input` on `ui_cancel`) and should be replaced by this overlay. The mouse is recaptured only by becoming local again, not on a second Escape.

**From ticket 07 (orchestrator).** Escape closes the station screen while it is open (`StationScreen`); the overlay must not open over a station screen. Precedence: station open → Escape closes it; nothing open → Escape opens this overlay.

**From ticket 11 (orchestrator).** The test area is a boxed car park (`scripts/test_area.gd`); Escape still only releases the mouse. Host Back must return everyone through the entrance with `RoomState.return_from_test_area()` (clears picks, holds, seats). Shared fate: guest quit in test area returns the rest; host quit lands guests in fresh rooms (`leave_to_own_room()`). Music restarts. Notice board is `scripts/notice_board.gd` reading `notice_board_line()`.
