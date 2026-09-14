# 29: Board and drive with shared visibility

Status: done
Blocked by: 08b
Parent: [Active spec amendment](../../monster-truck/spec.md)

Approved 2026-09-14: user authorized the four-ticket revision breakdown (“I trust you.”).

## What to build

Board and drive with shared visibility in the retained monster-truck implementation, following the active 2026-09-14 amendment.

## Acceptance criteria

- [x] Revise the modeled truck to a recognisable monster-truck silhouette without the rear staircase; retain useful asset sources and materials.
- [x] Hold Space while moving against the truck to climb; targeting a seat highlights it and shows E to sit. Exclusive occupancy and deliberate exit work for host and guests.
- [x] All seated players use the shared elevated camera and stay seated through bumps and rollovers. On-foot movement remains available.
- [x] Preserve front-steering feel. Speed uses W forward, S braking then reverse after stopping, and gentle slowing on release, with no ordinary direction-selector or parking-brake management.
- [x] Contextual hints agree with controls, stale held input cannot transfer to a new occupant, and the truck remains safely parked before departure.
- [x] Verify boarding, real input-to-motion behavior, seated camera readability and host/guest consistency through existing scene/network harnesses and integrated visual inspection.

## Verification guidance

Reuse the previously confirmed public attempt/occupancy/lifecycle boundaries and existing Godot scene/network harnesses. Assert player-visible behavior, not private structure. Preserve exactly three humans and Steam-only shipping. Record evidence and update superseded assertions; human fun/feel is judged in checkpoint 06.

## Comments

- 2026-09-14: Gameplay code is implemented and tested. Astra must finish the truck silhouette/staircase GLB replacement and verify art/collision integration before this ticket is done. User requested code first, then Astra. See ../astra-handoff.md and ../revision-verification.md.

- 2026-09-14 completion: integrated the user’s smaller, high-clearance body and oversized-wheel revision. Asset/collision checks, actual three-peer course completion, corrected high-body boarding/recovery, dual-platform local packages and extracted Mac boot verified. See [final art/package evidence](../art-verification.md). Packages identify exact uncommitted source; no publishing or human acceptance claimed.
