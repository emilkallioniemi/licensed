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
_Avoid_: task, objective, station, challenge, stage

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
