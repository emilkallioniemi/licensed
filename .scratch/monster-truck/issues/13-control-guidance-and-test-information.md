# How do players learn the controls and see test information under pressure?

Label: wayfinder:grilling
Type: grilling
Status: resolved
Parent: ../map.md
Blocked by: 06, 08

## Question

With the timer starting on arrival and E seating learners at physical controls, what information lets players begin operating the monster truck under pressure? Specify how input bindings are communicated using subtle highlights for visible controls and small UI hints for unseen controls such as pedals. Decide whether a test sheet remains necessary, what it contains and who can access it, and where the timer is visible. Preserve sight from physical position and necessary communication rather than supplying every learner with every instrument or instruction.

Coordinate exact driving inputs and cabin arrangement with [How will the first playable build validate three-player cooperation?](06-cooperation-playable-comparison.md). Follow [How does the monster truck connect to the waiting room without preassigned roles?](08-waiting-room-integration.md) for boarding and E interaction; do not reopen those decisions. Cover initial examiner instructions and any further teaching, and identify what implementation playtests must demonstrate about learning and information visibility. This is a planning decision, not UI production.

## Comments

- 2026-09-13: User accepted a physical timer beside throttle/brake, readable by other learners only from a position with sight of it; the operator can call out remaining time.
- 2026-09-13: User accepted removing the monster-truck test sheet. Examiner requests and physical signs/markings convey the route and required manoeuvres; the results sheet remains separate and unchanged.
- 2026-09-13: User accepted brief binding labels on occupying a control, available again when needed, and the first destination requested immediately without a tutorial pause or examiner driving advice. The timer continues during learning. Detailed bindings, information feedback, and validation remain to settle.
- 2026-09-13: User accepted A/D steering, W throttle, S service brake, R switching forward/reverse while stopped, and Space toggling the parking brake at throttle/brake. E leaves a control; driving keys do not stand the learner up. Steering continues holding its angle on release.
- 2026-09-13: User accepted physical axle-angle pointers beside each steering control and forward/reverse plus parking-brake indicators beside throttle/brake. Other learners need sight of the instruments or a spoken call.
- 2026-09-13: User accepted subtitles for spoken examiner lines and a key to repeat the current manoeuvre request, without added advice or stopping the timer. Exact supporting keys, rear-steering direction convention, and final validation checks remain to confirm.
- 2026-09-13: User accepted truck-relative steering at both axles, H/T/L/B supporting keys, and the proposed three-human learning and information-visibility checks, confirming the complete guidance decision.

## Answer

Resolved with the user on 2026-09-13 after three rounds of confirmation. This is a planning decision; usability and cooperation remain subject to implementation playtests.

### Driving and supporting bindings

| Context | Binding | Behaviour |
| --- | --- | --- |
| Either steering control | A / D | Turn the controlled axle toward the truck's left/right, irrespective of where the learner looks. The rear operator faces backward but uses the same truck-relative convention. Reversing does not invert the bindings. |
| Throttle/brake | W | Apply throttle in the selected travel direction. |
| Throttle/brake | S | Apply the service brake. |
| Throttle/brake | R | Switch forward/reverse while stopped. |
| Throttle/brake | Space | Toggle the separate parking brake. |
| Available or occupied control | E | Occupy an available control or leave the occupied control, as already agreed. Driving keys do not stand the learner up. |
| Occupied control | H | Redisplay that control's binding hints. |
| Active test | T | Request the current manoeuvre again. Repeated presses do not stack requests or interrupt fault comments. |
| Hands free | L | Show or put away the personal license, preserving its agreed interaction restrictions. |
| Hands free | Hold B, release to select | Open the emote wheel and perform the selected emote, preserving its agreed interaction restrictions. |

Steering adjusts gradually with quick response and holds its angle when input is released or the learner leaves. Throttle and service brake release unattended; parking-brake state persists. These bindings preserve the accepted control behaviour and free looking. Scope driving actions to occupied controls so on-foot movement, jump, and existing interaction behaviour remain available in their own contexts.

### Guidance and information

- Show brief binding labels when a learner occupies a control, with subtle highlights on visible physical controls and small UI hints for unseen controls such as pedals. H makes those hints available again. Handovers show guidance for the newly occupied control.
- Put a physical timer beside throttle/brake. Other learners can read it from a position with sight of it or hear the operator call out the remaining time.
- Put a physical axle-angle pointer beside each steering control, and forward/reverse plus parking-brake indicators beside throttle/brake. Their information follows physical sight and communication, rather than appearing on every learner's screen.
- The monster truck has no test sheet. Examiner manoeuvre requests, painted route arrows, numbered signs, and physical markings convey the required route and manoeuvres. The agreed results sheet remains part of the aftermath presentation.
- Request the first destination immediately on arrival. The timer starts on arrival and continues during boarding, learning, and repeated instructions; there is no tutorial pause or examiner driving advice.
- Subtitle spoken examiner lines. T repeats the current manoeuvre request without adding advice; fault comments retain priority. Subtitles convey the examiner's speech, not extra instrument or hazard information.

### Implementation validation

With exactly three new human players, verify that each control can be discovered and operated within a minute, rotating learners through all controls. Check that learners understand the held steering angle, truck-relative rear steering, stopped-only direction selection, and separate service/parking brakes. Confirm players can recover a missed manoeuvre request and interpret the physical indicators.

Check that handovers display the correct hints, H restores them, driving keys do not leave a control, and repeated T presses neither stack requests nor interrupt fault comments. Exercise license and emote restrictions alongside control occupancy. Verify timer and instrument readability from intended positions, with other positions requiring movement or communication; subtitles must not supply additional sight.

Revise confusing bindings or unreadable presentation during implementation. These checks join the existing cooperation and complete-test checkpoints; they are planned requirements, not evidence already gathered. No new decision ticket is required by this resolution.
