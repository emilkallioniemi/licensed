# Design judgment

The judgment to carry when building anything for licensed: a vehicle, a test item, a screen, an examiner line, a control. `README.md` is the design doc; this file is the part of it an agent has to *act on*, rewritten so each rule is observable. Every line here traces to a decision in the README or to a correction that repeated in `docs/corrections.md`. Vocabulary is in `CONTEXT.md`.

## The moment we are building

Three friends on voice chat, sharing one vehicle, failing a driving test in a way worth clipping. Everything below serves that moment. The prototype question is whether it is funny with boxes for art; if a piece of work would only be funny with art, change the design instead.

## Pillars, as observable rules

1. **Every role is necessary.** Each of the three roles holds at least one ingredient (control, sight, or knowledge) the other two lack. Check: remove any one player and the test cannot be passed. Voice can carry information; it cannot carry a view or a hand.
2. **Awkward, learnable, funny to get wrong.** Every control has a consequence the operator has to anticipate rather than a direct mapping from input to result, and a new player operates it within a minute of being shouted at. Realism is not a target; a control that behaves exactly like the real thing is a placeholder.
3. **Timer and examiner, always.** Every test has a timer that fails you at zero and an examiner who records minor faults, guarantees failure for serious ones, and comments. In the monster truck, minor faults lower the passing rating but never cause failure; complete every required manoeuvre in time without a serious fault to pass. Failure leaves time for the physical aftermath and examiner response before the test ends. The timer makes you hurry; the examiner punishes hurrying. Both are present in every test.
4. **Shared fate.** Exactly three players, one result. A pass awards all three players the same stamp and attempt rating on their personal licenses; each keeps their own best rating across groups. See ADR-0001.
5. **Failure is the content.** Every serious fault produces something to look at and one examiner comment. Failing is designed to be frequent and more entertaining than passing.
6. **Vehicles add controls and splits, never systems.** A new vehicle is a set of controls, a role split, and ways to fail, built on the test items, examiner, timer, and lobby that already exist. If a vehicle needs a new system, the system belongs to the game, and the first vehicle should have needed it too.

## Named drifts

The defaults an agent reaches for when a gap is left open. Recognise them by name; the target beside each is what to build instead.

- **Sim drift**: handling that rewards skill and feels like driving. Target: arcade, forgiving physics whose awkwardness is designed, not simulated.
- **Omniscient HUD**: a screen that shows every player the timer, the cones, the sheet, and the mirrors. Target: each role sees what its ingredients grant and nothing else; what a role can see is a design decision, not a convenience.
- **Helpful examiner**: an examiner who explains the rule, encourages, warns before the fault, or raises his voice. Target: the register below.
- **Scaling**: solo mode, two players, four players, an AI teammate, a bot filling an empty seat. Target: a lobby that holds exactly three and waits.
- **Second vehicle first**: work on a new vehicle, mode, or system while the monster truck's test, examiner, lobby, and UI are unfinished. Target: one vehicle done properly, then decide.
- **Polish before funny**: art, VO, particles, or menus before the slice has been played by three people. Target: boxes, TTS, and a playtest.

## The examiner's register

Humourless, clipboard, coffee. Heard by all three players. His lines are the thing players will quote, so every line is written to this register:

- One sentence. Full stops. No exclamation marks.
- States what happened, or what he would like to see, as plain fact. The rule is never explained and the player is never addressed by role.
- Understatement scales with severity: the worse the fault, the milder the line.
- Reads well through text-to-speech: no stage directions, no sounds, no ellipses doing the acting.

The register, by example:

> "That was a bicycle."
> "I'd like to see that again, if you don't mind."
> "You may indicate whenever you feel ready."
> "We'll call that a controlled stop."

Off-register, for contrast: "Whoa, watch the cyclist!", "Remember to check your mirrors before pulling out.", "Nice recovery!"

## Undecided: surface, do not default

These are open in the README and are answered by playing the monster truck slice, not by an agent picking one. When work touches one, name the choice you would have to make and stop there.

- **What a level is**: a route, a closed course, a single test item, or a mix.
- **The monster truck's role split**: the README table is a candidate for playtesting, not a decision.
- **Timer visibility**: HUD countdown, the examiner checking his watch, or one role's sight.
- **Name**, **art direction**, **character customisation**: all open. Placeholder names and box art are correct until decided.

## How this file grows

This file is earned, not written. The loop, from Vercel's `design.md` method:

1. When you steer an agent (or yourself) on tone, feel, split, scope, or a screen, add one line to `docs/corrections.md`, written as something observable.
2. A correction that appears once stays in the log.
3. A correction that repeats gets promoted to the narrowest place that enforces it: judgment becomes a rule here; a repeatable mechanic becomes a shared resource or scene (a theme, a vehicle definition, an examiner line format); anything checkable becomes a script.
4. Lines here that stop being corrected in practice have done their job; lines that keep being corrected are unclear and get rewritten, not repeated.
