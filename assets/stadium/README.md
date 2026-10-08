# Monster arena

Original Blender geometry, built with `source/build_stadium.py`. `source/stadium.blend` retains the assembled bowl, crowd, jump lanes and stunt rings; `source/crush_car.blend` contains the editable wreck. Godot loads the exported GLBs, so Blender is only needed to revise assets.

```powershell
& 'C:\Program Files\Blender Foundation\Blender 5.2\blender.exe' --background --python assets/stadium/source/build_stadium.py
```

The enclosed oval stadium has tiered grandstands, modeled spectators with varied clothes and poses, roof supports, exterior bands, floodlights, scoreboards, perimeter fencing, safety edges and sculpted dirt mounds. Runtime adds spotlights, glowing flickering pyro and spark particles. `dirt.gdshader` supplies world-space soil variation, grain, ruts and roughness; the dirt's bumps and ramps also exist in the collision mesh.

The supporting-art pass is authored in `source/stadium_detail.py`: 2,537 spectators face the infield, with tapered jerseys, collars, trousers, shoes, faces, ears, noses, hair, baseball caps, hearing protection, phones and foam fingers. Six standing/seated pose types vary the silhouette. Molded colored seats remain stationary; each fan's exported UVs encode an individual sway phase and height above the feet. Crowd and seat geometry is batched by material, with Godot's imported mesh LODs available at distance.

Wrecks are an oxblood sedan, faded petrol estate and checker-liveried taxi. They have wheel-arch cutouts, bowed hoods, caved roofs, door seams/handles, metal scrapes, rust, bent bumpers, radiator grilles, damaged lamps, open cabins, torn seats, steering wheels, jagged glass remnants and detailed steel wheels. `wreck_paint.gdshader` adds faded paint, chips and irregular roughness. Each has a separate folded mesh that preserves the wheels while compressing and creasing the body. Placement fits the bank and slope and clears the curved dirt beneath the chassis. All six editable models are under `source/crush_car*.blend`; GLB exports join parts by material to reduce draw calls. Regenerate only the cars with `-- --wrecks-only` appended to the Blender command above.

Three stunt choices retain the existing host-selected route layout and checkpoint contract:

1. **Car Crunch**: paired wrecks on the live ramp. Host proximity under the moving truck irreversibly crushes them for the current attempt; a bitmask in the complete attempt snapshot selects intact/folded models and synchronizes support shapes. Retry restores them. The cars use two authored damage states, not soft-body simulation.
2. **Ring Run**: align through modeled rings surrounded by show flames. Pyro is cosmetic; the book says so. The alternate lane has no centre deck.
3. **Big Air**: the live dirt jump has a real 6 m gap. Build speed straight, land, then merge to the red finish banner. The truck's pitch and roll follow averaged axle/side contacts, with independently presented wheel suspension.

Terrain/support collision uses layers 1+8. Solid barriers and rings use 1+4. Deep stunt pits preserve lethal falls and shared loss; ordinary barrier impacts allow reversal. Visible dirt support replaces the former flat road boxes. The `BRIDGE_X` internal constant remains only as the original course-coordinate contract.

The navigator's private modeled book has manually selected pages for each stunt and the chosen live lane. All three roles, six-minute timer, host authority, stopped consensual role swaps, retry and departure behavior remain.

See `.scratch/monster-truck-build/stadium-evidence/` for real Godot captures and verification. The previous quarry assets remain historical editable source and are no longer instantiated by the course.
