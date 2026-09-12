# licensed (working title, name not decided)

**Three friends. One vehicle. One driving test. Everyone passes or nobody does.**

A 3-player co-op party game where you share control of a single vehicle and have to
pass the driving test for it. Each vehicle is a level with its own awkward controls,
its own split of who-controls / who-sees / who-knows, and its own ways to fail. Get the
license, unlock the next vehicle, repeat until you have a license for everything.

> Status: design phase. No name, no engine, no level format decided yet. "licensed" is
> just the folder.

---

## The pitch in one breath

You and two friends are taking your driving test together. One of you is holding the
wheel. One of you is the only person who can see the mirrors. One of you is the only
person who can read the test sheet. The examiner is in the passenger seat with a
clipboard, and he does not think this is funny.

---

## Design pillars

These are the things the game is *for*. If a feature doesn't serve one of them, it's
probably not needed.

1. **Talking helps but isn't enough.**
   Everyone can hear everyone, always. The chaos comes from two gaps voice can't close:
   nobody sees what you see, and nobody can drive for you.

2. **Awkward on purpose.**
   Every vehicle has controls that are deliberately weird and learnable in one panicked
   minute. Realism is not the goal. Being funny to get wrong is.

3. **Two kinds of pressure.**
   Every test has a timer: run out and you fail. And every test has a deadpan examiner
   who records minor faults, guarantees failure for serious ones, and comments on
   everything. The timer makes you hurry. The examiner punishes you for hurrying.

4. **Shared fate.**
   Exactly three players, always. All three receive the same test result, earning
   stamps on their personal licenses together. One player's mistake fails everyone.

5. **Failure is the content.**
   A moped with three people on it falling over is the trailer. Design so that failing
   is more entertaining than succeeding, and frequent.

6. **Vehicles are levels.**
   Every vehicle is a new set of physics jokes and a new role split. The roadmap is as
   long as the list of things humans drive.

---

## The three roles

There is no fixed set of roles. Each vehicle decides how its controls, views, and
information get divided between the three players. The only rule:

**Every player has their own responsibility, and without that person you can't pass.**

What a role gets is some mix of three ingredients, and different vehicles mix them
differently:

- **Control**: hands on something the vehicle needs (wheel, pedals, throttle, balance,
  gears, indicators, the trailer, the collective).
- **Sight**: a view nobody else has (forward, mirrors, behind the trailer, the balance
  meter, the buoy chart, the instruments).
- **Knowledge**: information nobody else has (the test sheet, the route, the vehicle's
  procedures, what the examiner just said).

Some examples of how that can land, to show the range rather than to prescribe it:

- On a car, one player might have steering and pedals with a forward view, another the
  mirrors and indicators, a third the test sheet.
- On a moped, one player might steer and throttle while another *is* the balance, and
  the third reads the test from the back.
- On a helicopter, all three players might each hold one control and share the same
  view, with nobody holding the manual at all.

The test sheet is written like a real manual: dry, precise, slightly ambiguous. Whoever
holds it has to translate procedure into shouted instructions for whoever is doing the
thing.

Players choose (or are dealt) their role per vehicle, so over time everyone learns every
awkward control from both sides.

---

## Vehicles (levels)

The demo ships with **one vehicle**. If one vehicle, its test, the examiner, the lobby,
and the UI are nailed, every vehicle after that is a new set of controls and a new role
split on top of systems that already work. Adding vehicles is the easy part; getting the
first one right is the whole job.

### Demo vehicle: the monster truck

A monster truck taking an ordinary driving test on an ordinary test route. Parallel
park between two cones. Reverse around a corner. Don't hit the bicycle.

Why this first: it's still a wheeled vehicle, so the physics are solved and reliable in
every engine and week one goes into finding out whether the *design* is funny rather
than fighting physics. And it's the funniest possible vehicle to put on a driving test.
The cones are tiny. The truck is enormous. Nobody in the cab can see the ground. The
examiner is very far from the ground and knows it.

Candidate split (to be playtested, not fixed):

| Ingredient | Who might hold it |
|---|---|
| Steering + throttle + brake, view over a hood that hides everything within ten metres | Player A |
| Spotter on the running board or roof: sees the ground, the cones, what's under the wheels, hears the examiner | Player B |
| Test sheet, route map, the procedures | Player C |

Signature awkwardness: suspension that bounces for seconds after every bump, a turning
circle the size of a car park, throttle that lifts the front wheels, and a driver's seat
so high that the cones, the bicycle, and the examiner's own car are all invisible from
it. Crushing things is easy. Not crushing things is the test.

### Roadmap (unordered, after the demo)

Car (manual gearbox with a clutch that stalls, indicators the driver can't reach), moped
(someone *is* the balance; three people on one moped), truck + trailer (someone stands
on the trailer and sees everything behind; trailer swing; height limits), van, bus,
forklift, tractor, jet ski, boat (helm / throttle / buoy chart below deck), snowmobile,
tank, helicopter (cyclic / collective / pedals: three controls, three players), plane
(yoke / throttle + instruments / radio, only the radio player hears the tower), hot air
balloon.

---

## What a level is

**Undecided.** This is the biggest open design question and it should be answered by
playing the monster truck slice, not by writing. A few shapes it could take:

- **A route.** Like a real test: drive from the test centre through a small town, and
  the examiner calls out manoeuvres along the way. Closest to the fantasy, most content
  to build per vehicle, hardest to make replayable.
- **A course.** A closed test ground with a fixed sequence of stations (park here,
  reverse here, stop here). Cheap, readable, easy to remix, but less "driving test" and
  more "obstacle course".
- **A single task.** One level is one manoeuvre. Very short rounds, very repeatable, and
  it makes the campaign a list of tasks rather than a list of vehicles.
- **Some mix.** A short route with two or three stations dropped into it, procedurally
  chosen from a pool so no two tests are the same.

Whatever the shape, the things a test asks you to do should be reusable pieces that
every vehicle remixes, so new vehicles and new tests don't need new systems. Candidates
for that pool, none of them confirmed:

parallel park, three-point turn, emergency stop, hill start, roundabout, reverse around
a corner, follow the signs to X, controlled stop in a marked area, bay parking, lane
change with indicator, and vehicle-specific ones (balance through a slalom, reverse a
trailer into a bay, hold a hover, dock).

### Hazards

Things the world throws at you that force whoever holds the test sheet to find the
relevant procedure while whoever can see the danger is yelling and whoever holds the
controls is improvising: pedestrians, cyclists, a sudden hill, a gear you haven't used
yet, a parked car where the bay should be, rain, the examiner asking a question.

---

## The examiner

The mascot. Humorless, clipboard, coffee. Sits in the passenger seat (or the sidecar,
or the back of the trailer). Everyone hears him.

**Scoring combines driving faults with a timer:**

- **Timer**: every test has a time limit. Run out and you fail, regardless of how clean
  the drive was. How visible the timer is (a HUD countdown, the examiner checking his
  watch, only one player able to see it) is open.
- **Minor fault**: a point on the sheet. In the monster-truck test, small mistakes
  such as cone clips lower the passing rating but never cause failure.
- **Serious fault**: guarantees failure. Monster-truck examples include hitting a
  worker or driving into the ravine. Let the physical aftermath and examiner
  response play out before ending the test; timer expiration likewise allows an
  unfolding crash to finish.
- **Monster-truck pass**: complete every required manoeuvre before the timer expires
  without a serious fault. Earn the stamp regardless of minor-fault count. Ratings
  depend only on minor faults, with no speed bonus; preserve the stamp and best
  rating across retries, and show the latest result for comparison.
- **Playtest candidates**: a six-minute limit against a roughly five-minute successful
  attempt; passing ratings of Technically Licensed (4+ minor faults), Mostly Harmless
  (1–3), and Suspiciously Competent (zero). Names and thresholds remain provisional.
- **Comments**: occasional, deadpan, devastating. These are the lines people will quote.

Examples of the register we want:

> "That was a bicycle."
> "I'd like to see that again, if you don't mind."
> "You may indicate whenever you feel ready."
> "We'll call that a controlled stop."

---

## Modes

One mode to begin with.

**Campaign**: the license progression. Pass each vehicle's test to unlock the next. Your
license card fills with stamps. In the demo that's one vehicle, one test, and a card with
one stamp and visibly more empty slots.

Each player keeps a personal license across hosts and groups of friends. A pass awards
all three players the vehicle's stamp and the same attempt rating; each retains their
own best rating. There is no individual performance scoring. Learners can hold up a
physical license showing their portrait, stamps, and best ratings. The booking board
shows which current players already hold each vehicle's stamp.
The license follows the player's Steam account across computers and reinstallations,
using local saving with Steam Cloud backup; local saving works independently.

Other modes (an endless test, a custom sandbox with the examiner's strictness and hazards
as knobs) are ideas for after the campaign works, not commitments.

---

## What this game is not

- Not a driving sim. Physics are arcade and forgiving; the awkwardness is designed, not
  simulated.
- Not a silent game. Voice is always on. The laughing is the product.
- Not a big game. One vehicle, one examiner, a handful of test items, done properly.
  Ship the demo, then decide.

---

## Prototype plan

The goal of the first slice is to answer one question: **is three roles with split
cameras and a strict examiner funny with boxes for art?** If it isn't funny with boxes,
it won't be funny with art. Change the design, not the art.

1. **Slice 0: connected.**
   Three players in a lobby over Steam (or a relay), each dealt a role.

2. **Slice 1: the monster truck, one test item.**
   One monster truck, three roles, separate cameras per role. Test sheet visible only to
   whoever holds it. The ground visible only to the spotter. One test item (parallel
   park) with cones. Examiner fails you for crushing a cone and says one line.
   *Play it with two friends. Decide if it's funny.*

3. **Slice 2: the monster truck, the full test.**
   Five or six test items chained into a route. Minor and serious faults. Hazards.
   Examiner comments. The license card at the end.

4. **Slice 3: the wrapper.**
   Lobby, role selection, results screen, the UI everyone will look at for the whole
   session. Crude deliberate art. The examiner gets a voice.

5. **Demo.**
   One vehicle, done properly. Free on Steam. Send it to small streamers who play Pico
   Park and Chained Together. Watch whether clips happen without asking.

6. **Then** add the second vehicle, and decide how big the full game is.

---

## Open decisions

- **What a level is**: route, course, single task, or a mix. See "What a level is".
  Answer with the monster truck slice.
- **Engine**: Godot 4 vs Unity 6. Deferred. Both have usable vehicle physics
  (`VehicleBody3D` / `WheelCollider`) and Steam networking options (GodotSteam /
  Facepunch.Steamworks).
- **Name**: not decided. "licensed" is the repo name, nothing more. Ideas so far, none
  favoured: LICENSED!, L PLATES, THREE-POINT TURN, PASS OR CRASH. Tagline idea:
  *alone, together*.
- **Art direction**: style undecided; deliberately crude and stylized is the default
  assumption. Characters are most likely human, and customizable (players dress their
  own learner). Not final.
- **Player count**: decided. Exactly three, as a hard constraint. No solo, no AI
  teammate, no scaling to two or four. It's the most-cited complaint about BOMBANANA and
  also part of why it works; we're making the same trade.
- **Examiner voice**: text-to-speech placeholder for the prototype, real VO later.

---

## Influences

- **BOMBANANA!** for the three-role asymmetry, the panic loop, and proof that a
  one-sentence premise plus a demo funnel can carry a tiny team.
- **Keep Talking and Nobody Explodes** for the manual-vs-operator split.
- **Human Fall Flat / Chained Together / Peak** for physics failure as comedy.
- **Overcooked** for role chaos under time pressure.
- Real driving tests, for the scoring system and the examiner.
