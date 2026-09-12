# When should a disastrous test end?

Label: wayfinder:grilling
Type: grilling
Status: resolved
Parent: ../map.md
Blocked by: 02

## Question

Given the candidate test structure, should a serious accident fail the group and end after its physical aftermath, or should players finish and receive an overall pass or fail based on their performance? Compare comedy, stakes, repeated failures, and time spent in an already hopeless attempt. Decide candidate scoring and termination behavior, including timer expiration, and what playtest comparison will settle uncertain choices. The user explicitly reopened the existing immediate-serious-fault rule; update the design documentation only when its replacement or retention is agreed.

## Comments

- 2026-09-12: User accepted the first candidate: a serious accident guarantees failure, and the test ends after its physical aftermath and examiner response. Minor-fault scoring, timer expiration, and validation remain open; the ticket remains claimed.


- 2026-09-12: User proposed passing despite minor faults, earning the license while receiving a lower performance rating, then replaying to improve toward higher ratings. Noob, pro, and veteran were illustrative names, not agreed labels. Whether minor faults can ever fail the test, rating criteria, and best-result retention remain open.
- 2026-09-12: User accepted timer expiration guaranteeing failure at zero, while allowing a crash already unfolding to finish before ending the test. Begin playtesting with a six-minute limit against the roughly five-minute successful-attempt target.


- 2026-09-12: User agreed that completing every required manoeuvre before the timer expires, without a serious fault, always passes regardless of minor-fault count. Minor faults determine the quality of the pass; a messy completion still earns the stamp. Rating criteria and thresholds remain open. Updated the Minor fault glossary definition; reconcile the remaining design-document scoring text when this ticket is finalized.


- 2026-09-12: User agreed that passing-attempt ratings depend only on minor faults, with no reward for faster completion. The timer supplies time pressure.
- 2026-09-12: User agreed that retries preserve the best rating alongside the earned stamp, while showing the latest attempt result for comparison. A worse retry never removes the stamp or replaces the best rating.


- 2026-09-12: User accepted three passing-rating bands as playtest candidates: 4+ minor faults, 1-3 minor faults, and zero minor faults. User authorized choosing funnier names. Working names selected: Technically Licensed (4+), Mostly Harmless (1-3), and Suspiciously Competent (0).
- 2026-09-12: User agreed that small mistakes such as clipping a cone are minor faults; dangerous accidents such as hitting a worker or driving into the ravine are serious faults. Exact route-specific fault triggers belong with the route and manoeuvre decisions.


## Answer

Resolved with the user on 2026-09-12 as a candidate requiring three-player playtesting. The user confirmed the full candidate and validation approach.

- Complete every required manoeuvre before the timer expires without a serious fault to pass and earn the monster-truck stamp. Minor faults never cause failure.
- Small mistakes such as clipping a cone are minor faults. Dangerous accidents such as hitting a worker or driving into the ravine are serious faults. Exact route-specific triggers remain with [Which route, manoeuvres, and moving hazards make the scrapyard test work?](09-scrapyard-route-and-hazards.md).
- A serious fault guarantees failure immediately, but the test ends after its physical aftermath and examiner response. Do not continue the remaining route with a guaranteed failure. At timer zero, failure is guaranteed; an unfolding crash may finish before the test ends.
- Start with a six-minute timer against the roughly five-minute successful-attempt target. This is a playtest candidate.
- Ratings depend only on minor faults, never completion speed. Working names and thresholds: Technically Licensed for 4+ minor faults, Mostly Harmless for 1–3, Suspiciously Competent for zero. The user authorized choosing humorous names; names and thresholds are provisional.
- Preserve the earned stamp and best rating across worse retries. Show the latest attempt result for comparison. Storage and result-flow details remain a follow-up decision.
- Validate with exactly three players over repeated attempts: enough time to enjoy the accident, desire to restart after failure, and desire to improve a passing rating. Compare shorter and longer aftermath windows if timing feels wrong; tune timer and rating thresholds from observed attempts. This is not evidence that the candidate already works.

Validation lives in [Does the five-minute scrapyard test sustain three-player chaos?](10-test-structure-playtest.md). Result handling lives in [How are results, best ratings, and retries shared?](11-results-and-retries.md). README.md, docs/design.md, and CONTEXT.md have been reconciled with the decision. No game implementation was produced.
