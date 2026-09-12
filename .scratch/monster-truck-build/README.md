# Monster truck implementation tickets

Published: 2026-09-13
Approval: user authorized the proposed 28-ticket breakdown (“I trust you.”).

[Authoritative specification](../monster-truck/spec.md) · [Tracker spec entry point](spec.md)

These are implementation tickets, distinct from the sixteen resolved wayfinder decisions. Every ticket starts ready-for-agent; blockers determine whether it may start. Statuses in individual files are authoritative. No implementation or human acceptance is claimed by publication.

| Ticket | Blocked by | Deliverable |
| --- | --- | --- |
| [01: Book and launch without preassigned roles](issues/01-book-and-launch.md) | None | Three friends book the monster truck, sit down, and arrive together without selecting roles. |
| [02: Board and occupy controls on a moving truck](issues/02-board-and-occupy.md) | 01 | Learners physically board a rough truck, walk on it, and exclusively take or leave its controls, including during movement. |
| [03: Drive with three shared controls](issues/03-three-shared-controls.md) | 02 | Three players steer both axles and operate throttle/brakes to negotiate a moving turn and tight reverse. |
| [04: Fall, reboard, and rescue physically](issues/04-falls-and-rescue.md) | 03 | Learners can ride the roof, fall harmlessly, reboard, and physically rescue a trapped friend while time continues. |
| [05: Fail, assess, concede, and retry together](issues/05-failure-and-retry.md) | 04 | An accident or timeout fails the trio after its aftermath; players can unanimously concede, retry or return. |
| [06: Validate three-player cooperation and online feel](issues/06-cooperation-checkpoint.md) | 05 | A retained playable checkpoint demonstrates whether all three controls are necessary, enjoyable and responsive online. |
| [07: Drive the modeled and animated truck](issues/07-modeled-truck.md) | 06 | The playable truck gains decent Blender models, animated controls and motion, without losing its validated driving and sight. |
| [08: Move as expressive, animated learners](issues/08-animated-learners.md) | 06 | Each player moves, boards and drives as an expressive learner visible consistently to friends. |
| [09: Complete the scrapyard gates and hill start](issues/09-gates-and-hill.md) | 07 | Players begin the modeled scrapyard test by clearing offset gates and completing a hill start under examiner direction. |
| [10: Cross the ravine bridge](issues/10-ravine-bridge.md) | 09 | Players align both axles and cross a narrow bridge, with recoverable scrapes and catastrophic falls. |
| [11: Reverse beside the working crusher](issues/11-crusher-reverse.md) | 10 | Players reverse through the crusher-side bend while a modeled crusher works beside the legal route. |
| [12: Descend, park, and pass the complete route](issues/12-park-and-pass.md) | 11 | Players finish the five-item route with reverse parallel parking and receive a shared passing rating. |
| [13: Encounter workers crossing with scrap](issues/13-worker-crossing.md) | 08, 09 | Players perceive and avoid a working learner-sized hazard: a worker crossing the lane with a rattling scrap trolley. |
| [14: Avoid the crane’s suspended wreck](issues/14-crane-crossing.md) | 10 | Players notice a suspended wreck sweep across the bridge entrance and wait safely or suffer a shared collision. |
| [15: Yield to the loaded forklift](issues/15-forklift-crossing.md) | 08, 11 | Players yield at the broad terrace junction to a forklift whose collision can shed its wreck or topple occupied machinery. |
| [16: Validate the complete test’s pacing and replay](issues/16-pacing-replay-checkpoint.md) | 12, 13, 14, 15 | Repeated human attempts establish whether the full modeled and sounded route sustains enjoyable cooperation and fair replay. |
| [17: Earn and retain personal licenses locally](issues/17-personal-local-licenses.md) | 12 | Each player immediately earns the shared pass on their own durable license and sees their retained best on results. |
| [18: Recover interrupted license awards](issues/18-recover-license-awards.md) | 17 | A player whose award delivery was interrupted can recover earned progress from a surviving original friend. |
| [19: Show personal licenses and booking-board stamps](issues/19-show-personal-license.md) | 08, 17 | Players show their personal license to friends and see current players’ stamps on the booking board. |
| [20: Back up licenses through Steam RemoteStorage](issues/20-steam-license-backup.md) | 18 | Personal licenses remain locally usable while valid surviving progress is backed up and reconciled through Steam storage. |
| [21: Verify owned-app Cloud restoration](issues/21-verify-cloud-restoration.md) | 20 | A license is demonstrably restored through the game’s owned Steam application on a clean computer or installation. |
| [22: Perform five shared emotes](issues/22-shared-emotes.md) | 19 | Players react with five animated gestures visible in their own hands and to friends. |
| [23: Ride with the physical examiner](issues/23-physical-examiner.md) | 07, 12 | A physical examiner reacts to driving and delivers the complete dry assessment repertoire. |
| [24: Operate the shared radio](issues/24-shared-radio.md) | 07 | Players physically operate a shared dashboard radio with three generated instrumental styles. |
| [25: Finish accident damage and aftermath](issues/25-accident-aftermath.md) | 12, 13, 14, 15 | Every agreed serious accident leaves a readable, shared physical aftermath that survives until retry. |
| [26: Finish results presentation and the return journey](issues/26-finished-results-return.md) | 19, 23, 25 | The complete marked assessment sits over the accident or successful finish and leads cleanly into retry or the waiting room. |
| [27: Validate the complete presentation online](issues/27-presentation-online-checkpoint.md) | 16, 22, 24, 26 | Three humans experience the finished assets, sound and complete test together, with recorded fixes for presentation and responsiveness. |
| [28: Verify the complete vehicle acceptance](issues/28-complete-vehicle-acceptance.md) | 21, 27 | The complete monster truck has traceable end-to-end evidence satisfying the specification. |

## Starting and progressing

Ticket 01 is the initial frontier. Work blockers first, with a fresh implementation context per ticket. Independent branches may proceed when their own blockers are done; this index does not authorize spawning agents or separate tasks by itself.

Cooperation checkpoint 06 gates route expansion. Full-test checkpoint 16 gates final presentation validation. Tickets 06, 16 and 27 require three-human evidence; 21 requires authorized owned-app configuration and real account/computer restoration evidence. Prepare all agent-owned work before a human handoff, and park ready-for-human only when the remaining dependency actually prevents completion.

## Coverage guide

- Waiting-room integration and shared truck/control behavior: 01–06.
- Early integrated truck/learner assets and full route/hazards: 07–16.
- Personal records, receipt recovery, physical license and owned-app Cloud: 17–21.
- Gestures, examiner, radio, destruction, finished results and presentation review: 22–27.
- Full specification acceptance, including both Cloud and human play evidence: 28.

The complete playable checkpoint includes decent models and generated audio. Later presentation tickets finish the full coverage; they do not defer all assets until after gameplay. Model, rig, audio and integration work remains agent-owned. Broader release operations are outside this effort.
