# licensed

A 3-player co-op party game where three friends share one vehicle and have to pass its driving test. This is the vocabulary the design doc (`README.md`) uses; use these words in code, issues, and tests.

## Language

### Vehicles and tests

**Vehicle**:
A level. One set of controls, one role split, one test. The campaign is a list of vehicles.
_Avoid_: level, stage, map

**Test**:
The scored attempt at one vehicle's license. Ends in pass or fail for all three players at once.
_Avoid_: level, round, mission, run, match

**Test item**:
One manoeuvre the examiner asks for during a test (parallel park, hill start, emergency stop). Test items are reusable across vehicles.
_Avoid_: task, objective, station (that word belongs to the waiting room, see _Station_), challenge, stage

**Hazard**:
Something the world throws at the players mid-test that the roles have to coordinate around (a cyclist, rain, a question from the examiner).
_Avoid_: obstacle, event, distraction

**Timer**:
The time limit on a test. Reaching zero fails the test regardless of the drive.
_Avoid_: clock, countdown

### Roles

**Player**:
One of exactly three humans in a test. Never fewer, never more, never an AI.
_Avoid_: user, teammate, participant

**Role**:
What one player holds for one vehicle: a mix of ingredients no other player has. Roles are per vehicle; there is no fixed set.
_Avoid_: class, seat, position, job, character

**Ingredient**:
One of the three things a role can be made of: control, sight, or knowledge.
_Avoid_: ability, power, responsibility

**Control**:
Hands on something the vehicle needs: wheel, pedals, throttle, balance, gears, indicators.
_Avoid_: input, mechanic

**Sight**:
A view no other role has: forward, mirrors, the ground, an instrument.
_Avoid_: camera, view, perspective

**Knowledge**:
Information no other role has: the test sheet, the route, a procedure, what the examiner just said.
_Avoid_: info, intel

**Role split**:
How one vehicle divides its ingredients among the three roles.
_Avoid_: loadout, assignment, role set

**Test sheet**:
The dry, precise, slightly ambiguous document describing the vehicle's procedures and the test. Held by one role, read aloud to the others.
_Avoid_: manual, handbook, instructions, guide

**Driver**, **Spotter**, **Navigator**:
The monster truck's three candidate roles, named so the role pickup can show them: hands on the controls with a hood view that hides the ground; outside the cab seeing the ground and the cones; holding the test sheet and the route. The split is a playtest candidate; the names are placeholders until it is.
_Avoid_: instructor, reader, clerk, operator

**Random**:
Picking no role and being dealt whichever is left when the test starts. Any number of players may pick it; it is not a fourth role.
_Avoid_: auto, any, fill

**Hold**:
The relationship between a player and a role at the role pickup: a player holds at most one role or random, and a held role is unavailable to the others. Its verbs are take, drop, and swap.
_Avoid_: own, lock, claim, reserve, select

### Scoring

**Examiner**:
The deadpan NPC with the clipboard who scores the test and comments on it. Heard by everyone.
_Avoid_: instructor, judge, referee, narrator

**Minor fault**:
A point on the examiner's sheet. Enough of them fail the test.
_Avoid_: penalty, warning, strike, error

**Serious fault**:
An immediate fail: a crushed cone, a stall in the junction, the examiner's car.
_Avoid_: critical fault, game over, major fault

**Comment**:
One line from the examiner, spoken to all three players.
_Avoid_: bark, quip, voice line, dialogue

### Progression

**License**:
The one record shared by all three players of which vehicles they have passed.
_Avoid_: profile, save, progress

**Stamp**:
One passed vehicle on the license. The license card shows filled stamps and visibly empty slots.
_Avoid_: badge, achievement, unlock, star

**Campaign**:
The mode: pass each vehicle's test to unlock the next, until the license is full.
_Avoid_: story, career

### The waiting room

**Waiting room**:
The test centre's waiting room: the 3D space players spawn into and gather in before a test. It is the lobby, and there is no menu in front of it.
_Avoid_: lobby, main menu, hub, title screen

**Room**:
One running waiting room and the players in it. Every player who starts the game is in a room of their own until they join a friend's; a room holds at most three.
_Avoid_: lobby, session, instance, server

**At the test centre**:
The state of a friend whose copy of the game is running, and who can therefore be invited or joined.
_Avoid_: online (that is a Steam state, not ours), in-game, playing

**Invite**:
Asking a friend who is at the test centre to come to your room. Reaches them only while their game is running.
_Avoid_: summon, call, request

**Join**:
Walking into a friend's room from your own, whether by accepting their invite or by choosing their room at the reception desk. Only a player alone in their room can join.
_Avoid_: connect, enter, accept (as a verb for the whole act)

**Leave**:
Walking out of a friend's room and back into a room of your own. Only a guest leaves; the host's room is the host's.
_Avoid_: disconnect, exit, quit (that means quitting the game)

**Arrival**:
A player appearing in the room through the entrance, and the door that opens and closes for it.
_Avoid_: spawn, connect, join event

**Learner**:
A player's body in the world. Wears the player's Steam name; there is one per player and it goes where the player goes.
_Avoid_: character, avatar, pawn, candidate

**Name tag**:
The player's Steam name floating above their learner, seen by the other players and never by themselves.
_Avoid_: nameplate, label, username

**Station**:
A place in the waiting room a learner walks up to and uses: the reception desk, the booking board, a chair. Every station is used the same way.
_Avoid_: interactable, terminal, kiosk, menu

**Station screen**:
The surface on a station where its controls are drawn and worked while the player is using it. The room has no other screens.
_Avoid_: UI, panel, popup, HUD

**Reception desk**:
The station in the waiting room where a player invites Steam friends, joins a friend's room, or leaves one. Everything about who is in which room happens here.
_Avoid_: invite menu, friends list (as a place), terminal

**Entrance**:
The door joiners arrive through.
_Avoid_: spawn point, spawn

**Booking board**:
The station in the waiting room where each player chooses which vehicle's test to sit. Shows the vehicles that can be booked and the locked ones.
_Avoid_: level select, vehicle select, carousel, menu

**Pick**:
A player's current vehicle choice on the booking board. A player has at most one; its verbs are pick, drop, and switch. Three matching picks make a booking.
_Avoid_: vote, selection, choice, preference

**Pick chip**:
The mark on a booking board row that names a player who has picked that vehicle, in that player's colour. Up to three per row.
_Avoid_: pin, marker, badge, token

**Booking**:
The vehicle all three players in the room have picked. It forms on the third matching pick and dissolves the moment a pick changes or a player leaves. No booking, no test.
_Avoid_: selection, choice, vote

**Role pickup**:
The role column of the booking board, where a player takes one of the booked vehicle's roles, or random. A role held by one player is unavailable to the others. Dead until there is a booking; every held role is released if the booking dissolves.
_Avoid_: role select, class select, loadout

**Occupant strip**:
The strip on each role of the role pickup that names who holds it, in that player's colour. Blank when the role is free.
_Avoid_: label, slot, owner field

**Ready-up**:
Signalling you are ready to start the test by sitting in one of the waiting room's chairs; standing up takes it back. The test starts when three players are seated, there is a booking, and every player holds a role or random.
_Avoid_: ready check, start, launch, go

**Notice board**:
The sign in the waiting room that states, in one line, what the room is still waiting for before the test can start, and counts down once nothing is. Nobody uses it; it is not a station.
_Avoid_: status display, HUD, departures board, screen

**Test area**:
The scene beyond the waiting room's Test Area door where a vehicle's test happens. Until the first vehicle is built it is a stub car park where the three learners stand together.
_Avoid_: level, arena, game scene, match, stub (in the spec)

**Voice**:
The players talking to each other inside the game. Always on by default and heard from the learner's body; every player can always hear every other.
_Avoid_: voice chat, VoIP, comms

**Escape overlay**:
The small panel opened with Escape anywhere in the waiting room or the test area: mic mode, mute, quit, and for the host in the test area, back to the waiting room. Not a menu, not a pause; the room runs on behind it.
_Avoid_: pause menu, settings menu, options, main menu
