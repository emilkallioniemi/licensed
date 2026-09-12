# 10: Inviting from the desk

**Spec:** `.scratch/waiting-room/spec.md`, section 4 ("Invite", "The invitee", "Join and Accept are one act"). Copy in section 13. Vocabulary: invite, invitee, at the test centre.

**What to build:** A host presses Invite on a friend who is at the test centre; the friend's running game rings at their reception desk and they accept or ignore it in-world, without a popup or the Steam overlay.

Inviter: Invite calls `inviteUserToLobby`. Steam does not confirm delivery, so the row's verb reads "Invited." for 30 s, then Invite returns. Nothing else changes for the inviter; the friend's row moving to *In this room* is the confirmation.

Invitee, game running: `lobby_invite` is handled in-world at the desk. A row appears at the top of the invitee's desk screen with the inviter's avatar and name, "is asking for you", and the verbs Accept and Ignore. The desk's station prompt becomes "E  <Name> is asking for you" until the row is gone. A placeholder ring (a beep, about two seconds) plays once, positional at the desk, loud enough to carry from the booking board. If already docked at the desk the row appears inline. Invites never expire; several stack newest on top; accepting one clears the rest; Ignore removes the row locally and tells the inviter nothing.

Accept is Join (ticket 09): the same lone-learner rule ("You have company." replaces Accept when someone is in your room), the same teardown-only-on-success, the same three failure lines; a stale invite fails with the fitting one. Steam's own `join_requested` routes to the same path as Accept.

A friend who is not running the game shows as "Online. Not at the test centre." with no Invite; on app 480 an invite cannot launch the exe, so the host tells them by voice to open the game.

Checked when a friend (Emil's brother) is online, and on Emil's two computers. A note, not a blocker: the dev transport cannot exercise this.

**Blocked by:** 09 (the reception desk and Join).

**Status:** claimed

- [x] Invite on a friend at the test centre sends the lobby invite; the row's verb reads "Invited." for 30 s and then returns to Invite.
- [x] On the invitee's running game a row appears at the top of the desk with the inviter's avatar, name, "is asking for you", Accept, and Ignore; the desk prompt reads "E  <Name> is asking for you"; one beep rings at the desk, audible from the board.
- [x] Accept walks the invitee into the inviter's room through the entrance; Ignore removes the row and nothing reaches the inviter.
- [x] Invites do not expire; a second invite stacks above the first; accepting one clears all.
- [x] With someone in the invitee's room, Accept is replaced by "You have company."
- [x] Accepting an invite to a room that is now full or gone leaves the invitee's room intact and shows the fitting failure line.
- [x] A Steam-client "Join Game" on the running game takes the Accept path.
- [x] Verified with two real Steam accounts; the result is written into the ticket's Comments.

## Comments

**From ticket 09 (orchestrator).** Invite is already drawn **disabled** on At-the-test-centre rows; wire `inviteUserToLobby`. Friend-room-full uses Steam lobby data key `n`, written by the host from `player_count`. `ReceptionDesk` is Station + StationScreen. Join is `WaitingRoom.begin_join()` then `Transport.join_lobby`. Emil: two-machine Steam checks are **assumed**, not observed — do not park this ticket for lack of a second Steam account. Tick the two-account box as assumed and write that in Comments.

**Builder, 2026-09-12.** Invite on an At-the-test-centre row calls `Steam.inviteUserToLobby` and the verb reads "Invited." for 30 s. `lobby_invite` stacks a row at the top of the desk (avatar, name, "is asking for you", Accept, Ignore), sets the station prompt to `"E  <Name> is asking for you"`, and plays a ~2 s positional beep at the desk. Ignore drops the row locally. Accept is Join: `WaitingRoom.begin_join()` then `Transport.join_lobby`; company replaces Accept with "You have company."; a stale or full room uses the three ticket-09 failure lines and keeps this room. `Steam.join_requested` takes the same Accept path. Invites never expire; newest on top; accepting one clears the rest. Under `--transport=enet` Invite, Accept, and Ignore stay disabled. `RoomState` tests PASS. Headless Steam and enet boots construct the desk with `lobby_invite` / `join_requested` connected.

Two-machine Steam checks are **assumed**, not observed: no second account in this session. The invite round-trip, the beep from the board, Accept walking through the entrance, and Steam-client Join Game were not seen in a window.

Review: at three, invite rows now hide every verb (including Ignore), matching "every verb on every row disappears." The 30 s "Invited." window no longer uses Hold vocabulary.
