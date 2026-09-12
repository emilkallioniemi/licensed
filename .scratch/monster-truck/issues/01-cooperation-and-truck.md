# What makes the monster truck require three players?

Label: wayfinder:grilling
Type: grilling
Status: resolved
Parent: ../map.md

## Question

Which monster-truck difficulties and division of controls, sight, and knowledge create repeated, necessary contributions from exactly three players? Consider a concrete driving situation and a group that already knows the instructions. The existing Driver, Spotter, Navigator split may be replaced entirely. Establish candidate handling and role splits and identify what needs playable comparison; do not claim that conversation proves fun or necessity.

## Comments

- 2026-09-12: User accepted sight following the learner's physical position, with windows, bodywork, and height creating blind spots; no permanently assigned view or overhead camera. User accepted a parking brake beside the throttle/brake control that stays engaged when unattended, allowing everyone to leave a secured truck. This is separate from the service brake, which releases when unattended.

- 2026-09-12: User accepted dropping preassigned roles for the monster truck. Players physically move to controls; one operator per control, with handovers requiring the current operator to let go and the replacement to take over. User also accepted unattended steering retaining its setting, throttle releasing, and the service brake releasing: the truck may coast or roll downhill. A means to secure it while all players leave the controls remains to decide. Glossary updated for roles and the monster-truck exception to role pickup and ready-up; implementation is unchanged.

- 2026-09-12: User accepted leaving controls at any time, including while moving. User proposed swapping places during the test to match players' strengths and questioned locking roles before the test. Physical handover rules and removing pre-test role selection are proposed, not yet settled. Reopens the existing role-pickup and ready-up prerequisite for this vehicle. Three-player necessity must survive flexible occupation of controls.

- 2026-09-12: For the proposed three-control split, the user tentatively prefers everyone riding in the vehicle, but worries that being fixed in place would become boring. Players should be able to move around, such as jumping onto the roof together to inspect the mess they made. When movement is available, what happens to unattended controls, and how movement interacts with exclusive sight remain open; this is not acceptance of permanently fixed driving positions.

- 2026-09-12: User accepted blind spots and coordinated steering as the primary monster-truck difficulty, with bouncing amplifying mistakes.
- 2026-09-12: User prefers distinct roles while ensuring every player experiences the fun. Whether all three hold physical controls depends on the vehicle; no universal requirement was accepted. User asks the agent to ground its monster-truck recommendation in how the vehicle works. Front steering / rear steering / throttle-and-brake remains an unaccepted candidate.
- 2026-09-12: [Monster-truck factual grounding](../monster-truck-facts.md) supports independent rear steering as a real ingredient. Three-player operation, exclusive sight, and exaggerated bounce remain game inventions. Agent recommends testing front steering / rear steering / throttle-and-brake with distinct sight and shared visibility of major consequences; enjoyment and necessity remain unproven.

## Answer

Resolved with the user on 2026-09-12. The user accepted the following candidate for playable testing, not a claim that the split is proven fun or requires three people.

- Divide operation into front steering, rear steering, and throttle/service brake. Blind spots and coordinated steering supply the primary difficulty; exaggerated bouncing amplifies mistakes. This is an arcade adaptation, not a simulation requirement. The factual grounding is linked above.
- All three players ride the truck but are free to leave controls and move around at any time, including while moving. They can climb onto the roof together and inspect the mess they made.
- No preassigned monster-truck roles or role-selection prerequisite before the test. Any player can physically take over an available control. Each control has one operator; swapping requires letting go, moving, and taking over, without a swap menu or automatic exchange.
- Sight follows physical position. Windows, bodywork, and height create blind spots; there is no permanently assigned view or magical overhead camera. Getting a better look can require leaving a control.
- Unattended steering retains its setting. Throttle and service brake release, so the truck may coast or roll downhill. A separate parking brake beside the throttle/brake control stays engaged when unattended, allowing all three players to leave a secured truck.
- Distinct responsibilities must give every player a share of the fun. Giving every player a physical control is this vehicle's candidate, not a rule for every vehicle.

The first playable comparison uses a tight reversing manoeuvre, a moving turn, and stopping to climb onto the roof. Rotate everyone through the controls. Check whether each player gets satisfying decisions and funny consequences, whether experienced players still need all three contributing, and whether moving/swapping adds fun without trivialising blind spots. Rear steering becoming optional and throttle/brake feeling dull are explicit reasons to revise the candidate.

Follow-up questions: [Does the freely swappable control split stay fun and require three players?](06-cooperation-playable-comparison.md), [How do players recover after leaving or overturning the truck?](07-movement-and-recovery.md), and [How does the monster truck connect to the waiting room without preassigned roles?](08-waiting-room-integration.md). No prototype or game implementation was built in this decision session. Glossary terms and the corrections log reflect the accepted design; existing game behaviour still needs reconciliation during specification and implementation.
