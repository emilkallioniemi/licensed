"""Blender --background --python assets/waiting_room/source/build_waiting_room.py"""
from pathlib import Path
from math import pi
import bpy
from mathutils import Vector

SOURCE = Path(__file__).resolve().parent
OUT = SOURCE.parent
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
bpy.context.scene.unit_settings.system = 'METRIC'
palette = {
    'Plaster': '#e6dfca', 'Floor': '#bbc6b7', 'Tile': '#a7b9ad',
    'Teal': '#477c79', 'DarkTeal': '#29494c', 'Ochre': '#dbaa51',
    'Cream': '#f4ecd7', 'Ink': '#293a3d', 'Wood': '#a77550',
    'Steel': '#788b87', 'Screen': '#1d343a', 'ScreenInk': '#a8d9c4',
    'Paper': '#fcf1d7', 'Red': '#b96550', 'Green': '#718b55',
    'Soil': '#4c3b30', 'Glass': '#badbd8', 'Light': '#fff3cf',
}
materials = {}

def linear(v):
    return v/12.92 if v <= .04045 else ((v+.055)/1.055)**2.4

for name, hx in palette.items():
    m = bpy.data.materials.new(name)
    rgb = [linear(int(hx[i:i+2], 16)/255) for i in (1, 3, 5)]
    m.diffuse_color = (*rgb, 1)
    m.use_nodes = True
    bsdf = m.node_tree.nodes['Principled BSDF']
    bsdf.inputs['Base Color'].default_value = (*rgb, 1)
    bsdf.inputs['Roughness'].default_value = .78
    if name in ('Light', 'ScreenInk'):
        bsdf.inputs['Emission Color'].default_value = (*rgb, 1)
        bsdf.inputs['Emission Strength'].default_value = .45
    materials[name] = m

def group(name, loc=(0,0,0), parent=None):
    ob = bpy.data.objects.new(name, None)
    bpy.context.collection.objects.link(ob)
    ob.location = loc
    ob.parent = parent
    return ob

root = group('WaitingRoom')

def box(name, loc, size, mat, parent=root, bevel=.025):
    bpy.ops.mesh.primitive_cube_add(size=1)
    ob = bpy.context.object
    ob.name = name
    ob.parent = parent
    ob.location = loc
    ob.scale = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel:
        mod = ob.modifiers.new('Soft edges', 'BEVEL')
        mod.width = bevel
        mod.segments = 2
        bpy.ops.object.modifier_apply(modifier=mod.name)
    ob.data.materials.append(materials[mat])
    return ob

def cylinder(name, loc, radius, depth, mat, parent=root, vertices=16):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth)
    ob = bpy.context.object
    ob.name = name
    ob.parent = parent
    ob.location = loc
    ob.data.materials.append(materials[mat])
    mod = ob.modifiers.new('Rim', 'BEVEL')
    mod.width = .015
    mod.segments = 2
    bpy.ops.object.modifier_apply(modifier=mod.name)
    return ob

def text(name, body, loc, size, mat='Ink', parent=root):
    curve = bpy.data.curves.new(name, 'FONT')
    curve.body = body
    curve.size = size
    curve.align_x = 'CENTER'
    curve.align_y = 'CENTER'
    curve.extrude = .001
    ob = bpy.data.objects.new(name, curve)
    bpy.context.collection.objects.link(ob)
    ob.parent = parent
    ob.location = loc
    ob.rotation_euler.x = pi/2  # Face -Y.
    ob.data.materials.append(materials[mat])
    bpy.context.view_layer.objects.active = ob
    ob.select_set(True)
    bpy.ops.object.convert(target='MESH')
    ob.select_set(False)
    return ob

shell = group('Architecture', parent=root)
box('Floor slab', (0,0,-.12), (12,10,.24), 'Floor', shell)
for x in range(-6,6):
    for y in range(-5,5):
        box('Floor tile %d %d' % (x,y), (x+.5,y+.5,.007), (.986,.986,.014),
            'Tile' if (x+y)%2 == 0 else 'Floor', shell, .003)
back = group('BackWall', parent=shell)
left = group('LeftWall', parent=shell)
right = group('RightWall', parent=shell)
front = group('FrontWall', parent=shell)
ceiling = group('Ceiling', parent=shell)
for name, loc, size, parent in [
    ('Back', (0,5,1.8), (12.3,.22,3.6), back),
    ('Left', (-6,0,1.8), (.22,10,3.6), left),
    ('Right', (6,0,1.8), (.22,10,3.6), right),
]:
    box(name+' plaster', loc, size, 'Plaster', parent)
    lower = (loc[0],loc[1],.55)
    box(name+' wainscot', lower, (size[0]+.015,size[1]+.015,1.10), 'Teal', parent)
    box(name+' chair rail', (loc[0],loc[1],1.13), (size[0]+.055,size[1]+.055,.055), 'Ochre', parent)
    box(name+' skirting', (loc[0],loc[1],.08), (size[0]+.06,size[1]+.06,.16), 'DarkTeal', parent)
for x in [-3.55,3.55]:
    box('Entrance side wall', (x,-5,1.8), (4.9,.22,3.6), 'Plaster', front)
    box('Entrance side wainscot', (x,-4.97,.55), (4.9,.25,1.1), 'Teal', front)
box('Entrance lintel', (0,-5,3.15), (2.2,.22,.9), 'Plaster', front)
box('Ceiling panel', (0,0,3.67), (12.2,10.2,.14), 'Cream', ceiling)

entrance = group('Entrance', (0,-5,0), root)
for x in [-1.12,1.12]:
    box('Entrance jamb', (x,0,1.35), (.12,.3,2.7), 'DarkTeal', entrance)
box('Entrance header', (0,0,2.71), (2.36,.3,.14), 'DarkTeal', entrance)
box('Entrance threshold', (0,0,.03), (2.24,.38,.06), 'Steel', entrance)
box('Entrance mat', (0,-3.9,.035), (2.25,1.15,.04), 'DarkTeal')
for x in [-.9,-.6,-.3,0,.3,.6,.9]:
    box('Mat rib', (x,-3.9,.057), (.025,1.0,.007), 'Steel', bevel=.002)

reception = group('Reception', (-2.65,2.55,0), root)
box('Counter body', (0,0,.52), (3.75,.98,1.04), 'Teal', reception, .07)
box('Counter kickboard', (0,-.5,.12), (3.62,.025,.20), 'DarkTeal', reception)
box('Counter top', (0,-.025,1.1), (3.95,1.16,.14), 'Wood', reception, .05)
box('Counter face inset', (0,-.508,.63), (3.35,.025,.55), 'Cream', reception)
text('Reception label', 'RECEPTION', (0,-.53,.67), .22, parent=reception)
text('Reception sublabel', 'DRIVING TEST CENTRE', (0,-.53,.43), .075, 'Teal', reception)

terminal = group('FriendsTerminal', (.78,-.1,1.18), reception)
box('Terminal base', (0,0,.035), (.72,.44,.07), 'DarkTeal', terminal)
box('Terminal stem', (0,.06,.19), (.13,.13,.32), 'Steel', terminal)
box('Terminal bezel', (0,0,.49), (.86,.13,.60), 'DarkTeal', terminal)
box('FriendsScreenSurface', (0,-.073,.49), (.74,.012,.46), 'Screen', terminal, .004)
# Removable static placeholder; the screen itself is a clean 1.61:1 surface.
placeholder = group('FriendsScreenPlaceholder', parent=terminal)
text('Friends screen title', 'FRIENDS', (0,-.085,.61), .073, 'ScreenInk', placeholder)
text('Friends screen caption', 'RECEPTION TERMINAL', (0,-.085,.44), .036, 'ScreenInk', placeholder)
box('Screen underline', (0,-.085,.535), (.57,.006,.008), 'Teal', placeholder, .002)
box('Keyboard', (0,-.36,.055), (.65,.22,.065), 'Steel', terminal)
for x in range(9):
    for y in range(3):
        box('Key', (-.26+x*.065,-.42+y*.057,.093), (.048,.038,.015), 'Cream', terminal, .003)

box('Paper tray', (-1.03,.02,1.2), (.57,.39,.06), 'DarkTeal', reception)
for n in range(4):
    paper = box('Application form', (-1.03,.02,1.24+n*.008), (.49,.32,.007), 'Paper', reception, .001)
    paper.rotation_euler.z = n*.025
cylinder('Bell foot', (-.4,-.22,1.2), .11,.055,'Steel',reception)
cylinder('Bell dome', (-.4,-.22,1.25), .08,.06,'Ochre',reception)
cylinder('Bell button', (-.4,-.22,1.30), .025,.035,'Ink',reception)
box('Pen pot', (-1.5,.18,1.30), (.14,.14,.25), 'Ochre', reception)
for x in [-1.54,-1.5,-1.46]:
    box('Pen', (x,.18,1.48), (.013,.013,.28), 'Ink', reception, .003)

box('Main sign back', (-2.65,4.84,2.6), (4.3,.09,.67), 'DarkTeal')
text('Main sign title', 'DRIVING TEST CENTRE', (-2.65,4.778,2.7), .235, 'Cream')
text('Main sign subline', 'RECEPTION  /  BOOKINGS', (-2.65,4.777,2.43), .105, 'Ochre')
for x in [-4.0,-2.7,-1.4]:
    box('Back storage cupboard', (x,4.56,.66), (1.15,.48,1.3), 'Cream')
    box('Cupboard handle', (x+.38,4.3,.75), (.045,.035,.21), 'Steel')

door = group('TestDoor', (.55,4.82,0), root)
box('Door frame', (0,0,1.24), (1.40,.18,2.48), 'DarkTeal', door)
box('Door leaf', (0,-.11,1.22), (1.20,.07,2.31), 'Wood', door)
box('Door plaque', (0,-.158,1.78), (.92,.025,.30), 'Cream', door)
text('Door sign', 'TEST AREA', (0,-.175,1.78), .115, parent=door)
box('Door push plate', (.40,-.17,1.05), (.09,.035,.36), 'Steel', door)
box('Door kick plate', (0,-.16,.20), (1.08,.02,.24), 'Steel', door)

board = group('BookingBoard', (3.63,4.80,0), root)
box('Board frame', (0,0,1.91), (3.52,.17,2.72), 'Wood', board, .045)
box('Board backing', (0,-.10,1.91), (3.36,.025,2.56), 'DarkTeal', board)
text('Board heading', 'BOOK YOUR TEST', (0,-.126,3.01), .205, 'Cream', board)
text('Vehicle column heading', 'VEHICLE', (-.59,-.126,2.77), .12, 'Ochre', board)
text('Role column heading', 'YOUR ROLE', (1.08,-.126,2.77), .12, 'Ochre', board)
box('Board column divider', (.49,-.14,1.75), (.018,.02,1.97), 'Steel', board, .004)
slots = [('MonsterTruck', 'MONSTER TRUCK', 2.48), ('Car', 'CAR', 2.09),
         ('Moped', 'MOPED', 1.70), ('TruckTrailer', 'TRUCK + TRAILER', 1.31),
         ('Helicopter', 'HELICOPTER', .92)]
for i,(name,label,z) in enumerate(slots):
    row = group(name+'Slot', (-.59,-.15,z), board)
    box(name+'DisplaySurface', (0,0,0), (1.93,.035,.34), 'Ochre' if i==0 else 'Cream', row)
    text(name+'Label', label, (-.13,-.025,0), .098, 'Ink', row)
    if i:
        box(name+'LockBody', (.79,-.04,-.025), (.14,.045,.12), 'Steel', row, .015)
        for dx in [-.047,.047]:
            box(name+'LockUpright', (.79+dx,-.04,.055), (.022,.035,.09), 'Steel', row, .009)
        box(name+'LockTop', (.79,-.04,.10), (.11,.035,.022), 'Steel', row, .009)
    else:
        text('Available marker', '01', (.79,-.03,0), .13, 'Ink', row)

# Physical role controls only. Blank name strips and neutral lamps reserve space
# for the eventual exclusive-role state without pretending anybody is connected.
roles = group('RoleSelection', parent=board)
for name,z in [('Driver',2.36), ('Spotter',1.81), ('Navigator',1.26)]:
    choice = group(name+'Choice', (1.08,-.15,z), roles)
    box(name+'Card', (0,0,0), (1.0,.055,.49), 'Teal', choice)
    box(name+'Button', (0,-.045,.08), (.87,.055,.21), 'Cream', choice)
    text(name+'ButtonLabel', name.upper(), (0,-.077,.08), .095, 'Ink', choice)
    box(name+'OccupantSurface', (-.07,-.037,-.125), (.65,.014,.105), 'Screen', choice, .006)
    box(name+'StatusLamp', (.36,-.043,-.125), (.075,.025,.075), 'Steel', choice, .012)
random_choice = group('RandomChoice', (1.08,-.15,.82), roles)
box('RandomButton', (0,-.03,0), (1.0,.06,.26), 'Cream', random_choice)
text('RandomButtonLabel', 'RANDOM', (0,-.065,0), .105, 'Ink', random_choice)

seating = group('WaitingChairs', (-5.1,0,0), root)
seating.rotation_euler.z = pi/2
for i,x in enumerate([-1.15,0,1.15]):
    chair = group('Chair%02d'%(i+1), (x,0,0), seating)
    box('Seat', (0,0,.48), (.76,.67,.14), 'Ochre' if i==1 else 'Teal', chair, .065)
    box('Backrest', (0,.29,.94), (.76,.13,.73), 'Ochre' if i==1 else 'Teal', chair, .055)
    for dx in [-.28,.28]:
        for dy in [-.23,.23]:
            box('Chair leg', (dx,dy,.22), (.055,.055,.44), 'Steel', chair, .012)
    for dx in [-.42,.42]:
        box('Arm upright', (dx,.15,.65), (.045,.045,.50), 'Steel', chair, .01)
        box('Arm rest', (dx,-.03,.82), (.09,.52,.07), 'DarkTeal', chair)
    text('Seat number', '%02d'%(i+1), (0,.212,1.04), .14, 'Cream', chair)

# Two inset, opaque stylized window panels: no external scene or glass sorting.
windows = group('Windows', (-5.87,0,0), root)
windows.rotation_euler.z = pi/2
for x in [-1.45,1.45]:
    box('Window frame', (x,0,2.40), (2.30,.14,1.45), 'Cream', windows)
    box('Window pane', (x,-.083,2.40), (2.10,.022,1.25), 'Glass', windows)
    box('Window vertical mullion', (x,-.105,2.4), (.06,.035,1.25), 'Cream', windows)
    box('Window horizontal mullion', (x,-.105,2.4), (2.10,.035,.06), 'Cream', windows)
    box('Window sill', (x,-.17,1.66), (2.40,.40,.10), 'Cream', windows)

plant = group('Plant', (-4.95,-3.50,0), root)
cylinder('Plant pot', (0,0,.29), .29,.56,'Red',plant)
cylinder('Pot rim', (0,0,.55), .32,.08,'Red',plant)
cylinder('Soil', (0,0,.585), .28,.018,'Soil',plant)
cylinder('Stem', (0,0,1.12), .04,1.08,'Wood',plant)
for i in range(9):
    angle = i*2.4
    from math import sin, cos
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=1)
    leaf = bpy.context.object
    leaf.name = 'Plant leaf'
    leaf.parent = plant
    leaf.location = (sin(angle)*.27,cos(angle)*.27,.93+i*.075)
    leaf.scale = (.18,.40,.12)
    leaf.rotation_euler = (.35,sin(angle)*.4,-angle)
    leaf.data.materials.append(materials['Green'])

bin_group = group('WasteBin', (-4.95,3.65,0), root)
cylinder('Bin body', (0,0,.33), .23,.64,'Steel',bin_group)
cylinder('Bin lid', (0,0,.67), .25,.06,'DarkTeal',bin_group)
box('Bin opening', (0,0,.705), (.25,.12,.008), 'Ink', bin_group, .015)

clock = group('WallClock', (-.05,4.79,3.02), root)
face = cylinder('Clock rim', (0,0,0), .25,.06,'DarkTeal',clock,32)
face.rotation_euler.x = pi/2
face = cylinder('Clock face', (0,-.04,0), .22,.012,'Cream',clock,32)
face.rotation_euler.x = pi/2
box('Hour hand', (.047,-.058,.045), (.12,.015,.022), 'Ink', clock, .004).rotation_euler.y = -.6
box('Minute hand', (0,-.059,.085), (.018,.015,.17), 'Ink', clock, .004)

# A blank future display area; ready-up behavior remains separate.
future = group('FutureDisplay', (5.87,-.75,0), root)
future.rotation_euler.z = -pi/2
box('Notice frame', (0,0,1.95), (2.5,.12,1.5), 'Wood', future)
box('Notice backing', (0,-.075,1.95), (2.34,.03,1.34), 'Cream', future)
text('Notice title', 'NOTICES', (0,-.097,2.46), .17, 'Teal', future)
for x in [-.7,0,.7]:
    box('Blank notice', (x,-.10,1.94), (.54,.016,.66), 'Paper', future)
    cylinder_pin = box('Notice pin', (x,-.12,2.22), (.035,.018,.035), 'Ochre', future, .01)

fixtures = group('LightFixtures', parent=root)
for x in [-3,3]:
    for y in [-2,2]:
        box('Ceiling fixture', (x,y,3.52), (1.9,.56,.10), 'Steel', fixtures)
        box('Ceiling diffuser', (x,y,3.455), (1.74,.43,.035), 'Light', fixtures)

# Export visual geometry only. Cameras and actual lights are preview additions.
bpy.ops.object.select_all(action='DESELECT')
root.select_set(True)
for ob in root.children_recursive:
    ob.select_set(True)
bpy.ops.export_scene.gltf(filepath=str(OUT/'waiting_room.glb'), export_format='GLB', use_selection=True)

def area(name, loc, target, energy, size):
    bpy.ops.object.light_add(type='AREA', location=loc)
    ob = bpy.context.object
    ob.name = name
    ob.data.energy = energy
    ob.data.shape = 'DISK'
    ob.data.size = size
    ob.rotation_euler = (Vector(target)-ob.location).to_track_quat('-Z','Y').to_euler()
    return ob

for x in [-3,3]:
    for y in [-2,2]:
        area('Preview ceiling light', (x,y,3.38), (x,y,0), 220, 2.5)
area('Preview window fill', (-5.3,0,2.7), (0,0,1), 420, 4)
area('Preview front fill', (0,-5,4), (0,2,1), 600, 6)
bpy.ops.object.camera_add(location=(11,-14,11))
camera = bpy.context.object
camera.name = 'OverviewCamera'
camera.rotation_euler = (Vector((0,0,1))-camera.location).to_track_quat('-Z','Y').to_euler()
camera.data.type = 'ORTHO'
camera.data.ortho_scale = 18.8
scene = bpy.context.scene
scene.camera = camera
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32
scene.world.color = (.22,.22,.22)
scene.render.resolution_x = 1500
scene.render.resolution_y = 1100
scene.render.resolution_percentage = 100
scene.view_settings.view_transform = 'AgX'
# Saved source contains the complete room; cutaway hiding affects renders only.
bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'waiting_room.blend'))
for g in [front,right,ceiling,entrance,fixtures,future]:
    for ob in [g]+list(g.children_recursive):
        ob.hide_render = True
scene.render.filepath = str(OUT/'preview_overview.png')
bpy.ops.render.render(write_still=True)
for g in [front,right,ceiling,entrance,fixtures,future]:
    for ob in [g]+list(g.children_recursive):
        ob.hide_render = False
camera.location = (1.0,-4.55,1.80)
camera.rotation_euler = (Vector((-.25,3.6,1.65))-camera.location).to_track_quat('-Z','Y').to_euler()
camera.data.type = 'PERSP'
camera.data.lens = 20
scene.render.resolution_y = 900
scene.render.filepath = str(OUT/'preview_entrance.png')
bpy.ops.render.render(write_still=True)
camera.location = (3.63,1.65,2.0)
camera.rotation_euler = (Vector((3.63,4.8,1.91))-camera.location).to_track_quat('-Z','Y').to_euler()
camera.data.lens = 28
scene.render.resolution_x = 1200
scene.render.resolution_y = 1000
scene.render.filepath = str(OUT/'preview_booking.png')
bpy.ops.render.render(write_still=True)
print('Built complete visual room, GLB, Blender source, and three previews.')
