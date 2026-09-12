# How does the monster truck connect to the waiting room without preassigned roles?

Label: wayfinder:grilling
Type: grilling
Status: resolved
Parent: ../map.md
Blocked by: 01, 02

## Question

How should the existing booking board, role pickup, ready-up, and transition into the test accommodate a monster truck with no preassigned roles? Inspect the existing implementation, then decide what players see before departure, where they arrive relative to the truck, and how they first take up controls. Reconcile the existing role-hold prerequisite with the accepted physical-handover design.

Keep this to the existing waiting room's integration with this vehicle. Results, retry presentation, and return flow must be reconciled with their respective decisions; unrelated waiting-room improvements remain outside the map.

## Comments

- 2026-09-12: User delegated the release key. Decision: E takes an available control and E again releases it, standing beside it, including while moving. Existing one-operator and unattended-control rules remain in force.
- 2026-09-12: User chose contextual control guidance: subtly highlight visible physical controls such as a lever, and use a small UI hint for controls outside the learner's sight, such as pedals. Exact graphics and driving input bindings belong to subsequent control/presentation planning. No universal instrument display or additional sight is implied.

- 2026-09-12: User accepted hiding monster-truck role selection and showing "Choose your controls in the truck" instead. Three matching picks and three seated learners trigger the existing examiner call, door animation, and fade into the scrapyard.
- 2026-09-12: User rejected waiting for all three controls to be occupied before starting the timer. Start immediately on arrival so boarding itself creates time pressure.
- 2026-09-12: User proposed three physical interaction spots, used with E like the waiting room. Interacting seats the learner at that control and then shows their controls. This replaces the earlier approach-only control-discovery recommendation; departure from the seat and the precise control display remain to clarify.

- 2026-09-12: User accepted arrival beside the parked monster truck, with the parking brake engaged and examiner already seated. Keep the walk short; learners physically climb aboard and choose controls by approaching them. Timer start and initial instruction flow remain to decide.
- 2026-09-12: Implementation inspection found hard-coded Driver/Spotter/Navigator/Random pickup in `scripts/booking_board.gd`, role holds required for launch and notice-board progression in `scripts/room_state.gd`, and dealt-role presentation on test arrival in `scripts/waiting_room.gd`. Existing departure uses examiner audio, door theatre, and a fade into the test area. Arrival currently places learners in a stub car park; no truck or boarding exists. Nonempty `launched_roles` also indicates launch and drives replicated transition detection, so removing role assignment requires an explicit launch-state representation. These are implementation facts, not additional design decisions.

## Answer

Resolved with the user on 2026-09-12 after confirmation of the complete flow.

- Monster-truck booking hides role pickup and displays "Choose your controls in the truck". Three matching picks and three seated learners trigger the existing examiner call, door animation, and fade.
- Learners arrive a short walk beside the parked truck, parking brake engaged and examiner already seated. The timer begins immediately on arrival, putting boarding under time pressure.
- Learners physically board and approach one of three control positions. E seats them at an available control; E again releases it and lets them move, even while the truck is moving. Occupancy remains exclusive, and swaps require physical movement.
- Show contextual guidance for the occupied control: subtle highlighting for visible physical controls, small UI hints for controls such as pedals that cannot be seen. Preserve sight from the learner's physical position and existing unattended-control behavior.
- Implementation must reconcile booking, notice-board readiness, role presentation, and launch-state replication with the absence of preassigned monster-truck roles. Results, retries, and return agreement stay with their existing decision ticket; detailed control layout/bindings, timer visibility, and further teaching remain follow-up scope.
