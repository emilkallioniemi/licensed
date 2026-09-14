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
A vehicle-specific responsibility made from control, sight, or knowledge. In the monster truck, players choose responsibilities by occupying seats and can trade during the test; roles are not assigned to players beforehand.
_Avoid_: class, seat, position, job, character

**Ingredient**:
One of the three things a role can be made of: control, sight, or knowledge.
_Avoid_: ability, power, responsibility

**Control**:
Hands on something the vehicle needs: wheel, pedals, throttle, balance, gears, indicators.
_Avoid_: input, mechanic

**Sight**:
A view available to a player that others may lack: forward, mirrors, the ground, an instrument. Seated monster-truck learners share the same elevated sight; on foot, sight follows the learner's position.
_Avoid_: camera, view, perspective

**Knowledge**:
Information no other role has: the test sheet, the route, a procedure, what the examiner just said.
_Avoid_: info, intel

**Role split**:
How one vehicle divides its ingredients among the three roles.
_Avoid_: loadout, assignment, role set

**Test sheet**:
The dry, precise, slightly ambiguous document describing a vehicle's procedures and test, held by one role and read aloud to the others when the vehicle uses one. The monster truck has no test sheet; its examiner requests manoeuvres, with physical signs and markings identifying the route.
_Avoid_: manual, handbook, instructions, guide

**Driver**, **Spotter**, **Navigator**:
Names from the earlier monster-truck role-split candidate: driving, spotting hazards, and reading the test sheet. They remain existing waiting-room placeholders, not preassigned monster-truck roles in the current design.
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
A point on the examiner's sheet. In the monster-truck test, minor faults lower the rating but never cause failure.
_Avoid_: penalty, warning, strike, error

**Serious fault**:
A fault that guarantees failure. In the monster-truck test, dangerous accidents such as hitting a worker or driving into the ravine qualify; the test ends after the physical aftermath and examiner response.
_Avoid_: critical fault, game over, major fault

**Comment**:
One line from the examiner, spoken to all three players.
_Avoid_: bark, quip, voice line, dialogue

**Rating**:
The quality of a monster-truck pass, determined only by minor faults. The best rating is retained alongside the earned stamp across retries.
_Avoid_: rank, level, experience

### Progression

**License**:
A player's personal record of passed vehicles and best ratings, retained across hosts and groups of friends. Represented by a physical card bearing their portrait, earned stamps, and best ratings that their learner can hold up.
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
The role column of the booking board for vehicles with preassigned roles: a player takes an available role or random, and all holds end when the booking dissolves. The monster truck does not use preassigned roles.
_Avoid_: role select, class select, loadout

**Occupant strip**:
The strip on each role of the role pickup that names who holds it, in that player's colour. Blank when the role is free.
_Avoid_: label, slot, owner field

**Ready-up**:
Signalling you are ready to start the test by sitting in one of the waiting room's chairs; standing up takes it back. Starting requires three seated players and a booking, plus a role or random held by each player only for vehicles with preassigned roles.
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
The small panel opened with Escape anywhere in the waiting room or the test area: mic mode, mute, quit, and during the monster-truck test, a proposal to concede that requires all three players' agreement. Not a menu, not a pause; the room runs on behind it.
_Avoid_: pause menu, settings menu, options, main menu
