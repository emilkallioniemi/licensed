# Navigation and survival revision

Status: ready-for-human
Date: 2026-10-08

User authorized implementation after consolidating all existing branches onto main. That consolidation is committed and pushed as `6493781`.

## Direction

Steering and speed stay approachable. Remove balance and the examiner entirely. The third player reads instructions and navigation information unavailable to the other roles. The group must get through a physical track; ordinary crashes permit stopping, reversing and continuing. Falling off or another lethal accident loses the attempt for everyone.

## Playable experiment

The stadium revision supersedes the quarry presentation below: [Monster arena assets and mechanics](../../assets/stadium/README.md). Three live-lane decisions now cover Car Crunch, Ring Run and Big Air, with a private paged stunt book, authored bumpy dirt, replicated crushable wrecks and an actual jump gap. The enclosed competition truck follows the user's oversized-tire / exposed-chassis reference. Quarry details below document the preceding iteration only.

Three junctions each offer left and right bridges. One has a real, visible missing span. The host selects the intact bridges for each attempt and replicates that layout. The navigation seat alone sees a modeled field book: contents and three inspection entries, found by manually turning pages. All players see numbered junction and branch signs, actual road geometry, shared crossing progress, time and results. There is no universal destination marker or spoken examiner guidance. Navigating without the book remains physically possible by cautiously inspecting the road: usefulness must come from timely information and coordination, never an artificial button gate.

The modeled quarry pass adds irregular sandstone formations, rounded road aprons, supported bridges, floodwater, a depot, pump works, crane and dispatch building. Original Blender source and the generator are retained in `assets/survival_map/source/`. Local page selection does not follow progress, and retry opens the contents. See `modeled-map-evidence/` for screenshots and technical verification.

Bridge width 14 m, truck hull about 6.8 m; wide turning decks support corrections. Yellow edge stripes mark exposed edges. Side barriers on merging decks stop the truck and allow reversal. Three ordered bridge crossings followed by the finish award a shared pass. The existing six-minute timer is retained as provisional tuning. Lethal truck falls below 8 m or learner falls/crushing fail; ordinary rollovers on supporting road can be righted in place. Recovery never moves the group across a missing span or rescues a fall.

Retry selects a fresh inspection report and restores intact world geometry. Host authority, occupancy generations, stopped consensual swaps, shared results and departure semantics stay in place. The internal `rear` seat identifier now means navigation; it accepts no driving commands.

## Solo development

A separate debug-only scene rehearses the production state, truck, track and learner simulation with three synthetic seats. Switch role views, record/replay driving inputs, disable a contribution, restart the same layout, and save/load recordings. It is excluded from exports and never fills a shipping seat. It can establish mechanics and expose dispensable contributions; it cannot establish three-human fun or Steam feel.

## Acceptance

- Navigation report follows exclusive occupancy, including swaps; steering/speed never see its directions in their guidance.
- Report and visible intact bridges agree on every layout and every peer.
- Physical wall contact can be reversed out of; no collision-based automatic loss.
- Lethal falls, including occupied truck falls, produce one shared failure with physical aftermath.
- A lethal observation wins simultaneous finish; an already awarded pass remains immutable.
- Ordered crossings, finish, retry and departure work over the existing three-peer harness.
- Human playtesting rotates all roles and evaluates regular navigator participation and whether recoverable accidents versus lethal falls feel fair and exciting.

## Evidence

Implementation and agent checks complete; see [verification](navigation-evidence/README.md) and [ticket 33](issues/33-navigation-survival.md). Human enjoyment and Steam acceptance remain pending.
