"""Blender --background --python assets/monster_truck/source/build_truck.py.
Dimensions are Godot metres (X right, Y up, -Z forward); export converts axes.
Animation empties have stable names used by TruckPresentation. Collision geometry
is deliberately authored separately in MonsterTruck: no tiny bolt collisions.
"""
from pathlib import Path
from math import pi, sin, cos, atan2, sqrt
import bpy
from mathutils import Vector
OUT = Path(__file__).resolve().parent.parent
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
bpy.context.scene.unit_settings.system='METRIC'
bpy.context.preferences.filepaths.save_version=0
colors={'Paint':'b96a35','Edge':'df9b4a','Cream':'eadcb9','Dark':'263537','Steel':'617779','Bright':'a3b1aa','Rubber':'20262a','Tread':'323b3c','Seat':'40666b','SeatInset':'537c7c','Red':'b44937','Lamp':'ffe2a2','Screen':'142d2d','Ink':'101b20','Rust':'714732'}
mats={}
for name,h in colors.items():
    rgb=[int(h[i:i+2],16)/255 for i in (0,2,4)]
    rgb=[v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in rgb]
    m=bpy.data.materials.new(name); m.diffuse_color=(*rgb,1); m.use_nodes=True
    bs=m.node_tree.nodes['Principled BSDF']; bs.inputs['Base Color'].default_value=(*rgb,1); bs.inputs['Roughness'].default_value=.74
    if name in ['Steel','Bright']: bs.inputs['Metallic'].default_value=.65
    if name=='Lamp': bs.inputs['Emission Color'].default_value=(*rgb,1); bs.inputs['Emission Strength'].default_value=.45
    mats[name]=m

def xyz(p): return (p[0],-p[2],p[1])
def group(name,at=(0,0,0),parent=None):
    ob=bpy.data.objects.new(name,None); bpy.context.collection.objects.link(ob); ob.parent=parent; ob.location=xyz(at); return ob
root=group('TruckModel')
def finish(ob,name,at,mat,parent,bevel=0):
    ob.name=name; ob.parent=parent; ob.location=xyz(at); ob.data.materials.append(mats[mat])
    if bevel:
        mod=ob.modifiers.new('Rounded manufactured edges','BEVEL'); mod.width=bevel; mod.segments=2
        bpy.context.view_layer.objects.active=ob; bpy.ops.object.modifier_apply(modifier=mod.name)
    return ob
def box(name,at,size,mat,parent=root,bevel=.025):
    bpy.ops.mesh.primitive_cube_add(size=1); ob=bpy.context.object; ob.scale=(size[0],size[2],size[1]); bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    return finish(ob,name,at,mat,parent,bevel)
def cylinder(name,at,radius,depth,mat,parent=root,axis='y',vertices=24):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices,radius=radius,depth=depth); ob=bpy.context.object
    if axis=='x': ob.rotation_euler.y=pi/2
    if axis=='z': ob.rotation_euler.x=pi/2
    return finish(ob,name,at,mat,parent,.015)
def rod(name,a,b,radius,mat,parent=root):
    a,b=Vector(xyz(a)),Vector(xyz(b)); d=b-a
    bpy.ops.mesh.primitive_cylinder_add(vertices=12,radius=radius,depth=d.length); ob=bpy.context.object
    ob.rotation_euler=d.to_track_quat('Z','Y').to_euler()
    return finish(ob,name,((a.x+b.x)/2,(a.z+b.z)/2,-(a.y+b.y)/2),mat,parent)
def torus(name,at,major,minor,mat,parent=root,axis='z'):
    bpy.ops.mesh.primitive_torus_add(major_segments=32,minor_segments=8,major_radius=major,minor_radius=minor); ob=bpy.context.object
    if axis=='x': ob.rotation_euler.y=pi/2
    elif axis=='z': ob.rotation_euler.x=pi/2
    return finish(ob,name,at,mat,parent)
def text(name,copy,at,size,mat='Cream',parent=root,rear=False):
    curve=bpy.data.curves.new(name,'FONT'); curve.body=copy; curve.size=size; curve.align_x='CENTER'; curve.align_y='CENTER'; curve.extrude=.001
    ob=bpy.data.objects.new(name,curve); bpy.context.collection.objects.link(ob); ob.parent=parent; ob.location=xyz(at)
    ob.rotation_euler=(pi/2,0,pi if not rear else 0); ob.data.materials.append(mats[mat])
    bpy.ops.object.select_all(action='DESELECT'); ob.select_set(True); bpy.context.view_layer.objects.active=ob; bpy.ops.object.convert(target='MESH'); return ob

# Open competition pickup: low body, exposed tyres and a sparse safety cage.
# No roof sheet or rear staircase obscures occupants in the shared camera.
box('Deck',(0,1.45,0),(4.8,.3,5),'Paint',bevel=.10)
box('CabFloor',(0,1.61,0),(4.65,.025,4.85),'Dark',bevel=.005)
for x in [-2.25,2.25]:
    box('Sill',(x,1.9,-.95),(.2,.65,2.7),'Paint',bevel=.07)
    box('CreamBelt',(x*1.047,2.14,-.95),(.025,.12,2.65),'Cream',bevel=.003)
    box('SillRubStrip',(x*1.05,1.7,-.95),(.09,.09,2.7),'Dark')
    # Short windshield frame and central roll hoop; rear balance deck is open.
    for z in [-2.3,0.1]:
        rod('CageUpright',(x,1.6,z),(x,3.55,z),.075,'Dark')
    rod('CageRoofSide',(x,3.55,-2.3),(x,3.55,.1),.075,'Dark')
    rod('RearCageBrace',(x,3.55,.1),(x,1.7,2.3),.06,'Steel')
    box('DoorNumberPlate',(x*1.052,1.93,-.65),(.025,.37,.60),'Cream',bevel=.025)
    # Broad shoulders above the wheels make the exposed tyre scale obvious.
    for z in [-1.8,1.8]:
        box('FenderShoulder',(x,2.34,z),(.60,.16,1.1),'Paint',bevel=.075)
        box('FenderLip',(x*1.105,2.27,z),(.08,.13,1.12),'Dark',bevel=.04)
for z in [-2.3,.1]:
    rod('CageCrossbar',(-2.25,3.55,z),(2.25,3.55,z),.075,'Dark')
# A racing bonnet and exposed intake distinguish the nose from the open bed.
box('Bonnet',(0,2.1,-2.6),(4.1,1,.9),'Paint',bevel=.12)
box('BonnetTop',(0,2.615,-2.6),(4.02,.03,.8),'Edge')
box('IntakeScoop',(0,2.77,-2.55),(.95,.28,.65),'Dark',bevel=.065)
box('IntakeOpening',(0,2.78,-2.89),(.76,.15,.025),'Ink')
for x in [-1.0,-.7,-.4,-.1,.2,.5,.8,1.1]:
    box('BonnetVent',(x,2.638,-2.6),(.11,.013,.45),'Dark',bevel=.01)
box('GrilleFrame',(0,2.02,-3.075),(2.35,.65,.08),'Cream')
box('Grille',(0,2.02,-3.125),(2.15,.49,.03),'Dark')
for x in [-.9,-.6,-.3,0,.3,.6,.9]: box('GrilleBar',(x,2.02,-3.15),(.035,.42,.03),'Steel')
for x in [-1.65,1.65]:
    cylinder('HeadlampBezel',(x,2.12,-3.075),.22,.12,'Dark',axis='z')
    cylinder('Headlamp',(x,2.12,-3.15),.17,.055,'Lamp',axis='z')
box('FrontBumper',(0,1.47,-3.12),(4.5,.25,.3),'Steel',bevel=.06)
for x in [-1.95,-1.6,1.6,1.95]: box('BumperRubber',(x,1.47,-3.29),(.18,.25,.045),'Dark')
text('FleetNumber','07',(0,2.44,-3.09),.16)
box('RearPanel',(-.9,2.05,2.35),(2,.8,.2),'Paint')
for x in [-2.1,2.1]:
    box('TailLampHousing',(x,1.8,2.49),(.25,.2,.08),'Dark')
    box('TailLamp',(x,1.8,2.54),(.18,.12,.035),'Red')
# High chassis rails leave the existing centre rescue gap intact.
for x in [-1.95,1.95]: box('ChassisRail',(x,1.23,0),(.18,.13,4.8),'Dark')
for axle,z in [('Front',-1.8),('Rear',1.8)]:
    axle_group=group(axle+'Axle',(0,1.1,z),root)
    cylinder('AxleTube',(0,0,0),.105,4.65,'Steel',axle_group,'x')
    cylinder('Differential',(0,0,0),.24,.4,'Dark',axle_group,'x')
    for side,x in [('L',-2.75),('R',2.75)]:
        suspension=group(axle+side+'Suspension',(x,1.1,z),root)
        steering=group(axle+side+'Steer',parent=suspension)
        wheel=group(axle+side+'Roll',parent=steering)
        cylinder('TyreCarcass',(0,0,0),1.04,.87,'Rubber',wheel,'x',32)
        for sx in [-.43,.43]:
            torus('TyreSidewall',(sx,0,0),.76,.23,'Rubber',wheel,'x')
            cylinder('Rim',(sx*1.07,0,0),.53,.07,'Steel',wheel,'x')
            cylinder('Hub',(sx*1.19,0,0),.22,.13,'Paint',wheel,'x')
            for i in range(8):
                a=i*pi/4
                cylinder('LugBolt',(sx*1.22,.32*cos(a),.32*sin(a)),.036,.05,'Bright',wheel,'x',8)
            for i in range(12):
                a=i*pi/6
                box('SidewallRib',(sx*1.04,.79*cos(a),.79*sin(a)),(.018,.06,.17),'Tread',wheel,.008).rotation_euler.x=-a
        for i in range(24):
            a=i*2*pi/24
            for sx in [-.23,.23]:
                ob=box('ChevronTread',(sx,1.025*cos(a),1.025*sin(a)),(.48,.145,.22),'Tread',wheel,.035)
                ob.rotation_euler.x=-a; ob.rotation_euler.z=(.24 if sx<0 else -.24)
        rod('SuspensionArm',(x*.67,1.3,z-.35),(x,1.1,z),.075,'Steel')
        cylinder('Damper',(x*.82,1.58,z),.075,.85,'Bright')
        # Spring is a continuous, editable beveled curve around the damper.
        curve=bpy.data.curves.new('CoilSpring','CURVE'); curve.dimensions='3D'; curve.bevel_depth=.035; curve.bevel_resolution=2
        spline=curve.splines.new('POLY'); spline.points.add(120)
        for i,pt in enumerate(spline.points):
            a=i/120*2*pi*7; pt.co=(*xyz((x*.82+.14*cos(a),1.18+i/120*.75,z+.14*sin(a))),1)
        ob=bpy.data.objects.new(axle+side+'Spring',curve); bpy.context.collection.objects.link(ob); ob.parent=root; ob.data.materials.append(mats['Edge'])
# Cab furnishing follows the already playable three-control coordinates.
for name,x,z,back in [('Front',-1.2,-1.3,1),('Pedals',1.2,-1.3,1),('Rear',-1.2,1.3,-1),('Examiner',1.2,1.4,1)]:
    seat=group(name+'Seat',(x,1.6,z),root)
    box('SeatPedestal',(0,.12,0),(.45,.24,.45),'Dark',seat)
    box('SeatCushion',(0,.34,0),(.68,.2,.68),'Seat',seat,.085)
    box('SeatInset',(0,.445,-back*.025),(.51,.025,.47),'SeatInset',seat,.04)
    box('SeatBack',(0,.76,back*.28),(.66,.7,.17),'Seat',seat,.08)
    box('BackInset',(0,.78,back*.18),(.5,.47,.045),'SeatInset',seat,.045)
    for sx in [-.28,.28]: box('SeatPipe',(sx,.6,back*.35),(.035,.75,.035),'Steel',seat,.012)
    for zz in [-.14,0,.14]: box('UpholsteryStitch',(0,.461,zz),(.45,.008,.008),'Cream',seat,.002)
    if name=='Examiner': continue
    if name=='Rear':
        # Legacy transform names remain for presentation compatibility, without
        # a steering wheel or console mesh. Weight shifting is the control.
        dash=group('RearConsole',(x,0,z),root)
        group('RearWheel',parent=dash)
        group('RearNeedle',parent=dash)
        for side in [-1,1]:
            rod('BalanceGrip',(side*.46,.48,-.1),(side*.46,.70,.2),.035,'Edge',seat)
        box('BalancePlatform',(0,.01,0),(1.65,.025,1.65),'Steel',seat,.02)
        continue
    dash=group(name+'Console',(x,0,z),root)
    box('ConsoleStand',(0,1.94,-back*.66),(.16,.64,.17),'Steel',dash)
    box('ConsoleHousing',(0,2.38,-back*.72),(1.02,.44,.16),'Dark',dash,.06)
    box('ConsoleFace',(0,2.38,-back*.625),(.91,.37,.025),'Cream',dash,.025)
    text(name+'ControlName',('STEERING' if name=='Front' else 'SPEED'),(.24,2.51,-back*.604),.068,'Dark',dash,rear=back==1)
    for sx in [-.4,.4]:
        for yy in [2.24,2.52]: cylinder('PanelScrew',(sx,yy,-back*.595),.013,.012,'Steel',dash,'z',8)
    if name!='Pedals':
        wheel=group(name+'Wheel',(.08,2.20,-back*.42),dash)
        torus('WheelRim',(0,0,0),.285,.033,'Tread',wheel)
        cylinder('WheelBoss',(0,0,0),.08,.10,'Paint',wheel,'z')
        for a in [pi/2,pi*7/6,pi*11/6]: rod('WheelSpoke',(0,0,0),(.265*cos(a),.265*sin(a),0),.022,'Bright',wheel)
        cylinder('AxleDial',(-.27,2.4,-back*.60),.125,.028,'Dark',dash,'z')
        for i in range(-3,4):
            a=i*.23
            box('DialTick',(-.27+sin(a)*.102,2.4+cos(a)*.102,-back*.574),(.012,.022,.009),'Cream',dash,.001)
        needle=group(name+'Needle',(-.27,2.4,-back*.561),dash)
        box('Needle',(0,.05,0),(.013,.10,.012),'Red',needle,.002)
    else:
        box('TimerGlass',(0,2.38,-.594),(.65,.16,.016),'Screen',dash,.008)
        for name2,xx in [('Throttle',.19),('Brake',-.19)]:
            pedal=group(name2+'Pedal',(xx,1.72,-.5),dash)
            box('PedalArm',(0,.13,0),(.04,.26,.035),'Bright',pedal)
            box('PedalPad',(0,.23,.03),(.22,.23,.075),'Rubber',pedal)
            for yy in [.16,.22,.28]: box('PedalGrip',(0,yy,.075),(.17,.022,.012),'Steel',pedal,.003)
        park=group('ParkingLever',(.45,2.15,-.32),dash)
        group('DirectionLever',(-.44,2.21,-.36),dash)
# Radio provision: a physical unpowered unit; interactions/music belong to 24.
box('RadioHousing',(.25,2.24,-2.26),(.65,.31,.29),'Steel',bevel=.04)
box('RadioFace',(.25,2.24,-2.10),(.58,.24,.025),'Dark')
for x in [.02,.055,.09,.125,.16,.195]: box('RadioGrille',(x,2.24,-2.08),(.013,.16,.012),'Bright',bevel=.003)
for x in [.34,.47]: cylinder('RadioKnob',(x,2.24,-2.06),.037,.055,'Cream',axis='z')
text('RadioOff','OFF',(.4,2.32,-2.078),.035,'Cream',rear=True)
# Scuffs, fasteners and modest hazard paint integrated into bodywork.
for x in [-2.15,-1.75,-.8,0,.8,1.75,2.15]:
    cylinder('DeckRivet',(x,1.45,-2.514),.026,.016,'Bright',axis='z',vertices=8)
for i in range(10):
    x=-1.8+i*.37
    ob=box('BumperHazard',(x,1.47,-3.282),(.16,.20,.012),'Edge',bevel=.001); ob.rotation_euler.y=.4
for x,y,z in [(-1.8,2.32,-3.063),(.7,1.9,-3.063),(1.35,2.4,-3.063),(-.4,2.22,-3.063)]:
    box('PaintChip',(x,y,z),(.14,.025,.009),'Rust',bevel=.003)

# Toy monster-truck proportions: compact shell lifted above oversized wheels.
# Seats/controls retain human-scale contact geometry; their spacing follows shell.
body_shell=group('RaisedBody',parent=root)
for ob in list(root.children):
    if ob == body_shell: continue
    if ob.name.endswith('Suspension'):
        ob.location.x = 2.4 if ob.location.x > 0 else -2.4
        ob.location.y = 2.1 if ob.location.y > 0 else -2.1
        ob.location.z = 1.6
        for child in ob.children_recursive:
            if child.name.endswith('Roll'): child.scale=(1.45,1.45,1.45)
    elif ob.name.endswith('Axle'):
        ob.location.y = 2.1 if ob.location.y > 0 else -2.1
        ob.location.z = 1.6
        ob.scale.x = 4.8/5.5
    elif ob.name.startswith(('SuspensionArm','Damper')) or ob.name.endswith('Spring'):
        bpy.data.objects.remove(ob,do_unlink=True)
    elif ob.type == 'EMPTY' and ob.name.endswith(('Seat','Console')):
        ob.location.x *= .72
        ob.location.y *= .8
        ob.location.z += 1.1
    else:
        ob.parent=body_shell
body_shell.scale=(.72,.8,1.0)
body_shell.location.z=1.1
# Long exposed suspension is the visual explanation for the lifted body.
for x in [-2.4,2.4]:
    for z in [-2.1,2.1]:
        rod('LongTravelArm',(x*.55,2.5,z*.72),(x,1.6,z),.10,'Steel')
        rod('LiftedDamper',(x*.70,2.8,z*.8),(x*.88,1.6,z),.085,'Bright')
        for ring in range(7):
            t=ring/6
            torus('LiftedSpring',(x*(.70+.18*t),2.75-1.08*t,z*(.8+.2*t)),.14,.035,'Edge',axis='y')

bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source'/'truck.blend'))
bpy.ops.export_scene.gltf(filepath=str(OUT/'truck.glb'),export_format='GLB',export_yup=True)
# Studio views live outside the GLB/source model; actual sight verified in Godot.
bpy.ops.mesh.primitive_plane_add(size=200); bpy.context.object.data.materials.append(mats['Cream']); bpy.context.object.location.z=-.015
scene=bpy.context.scene; scene.render.engine='CYCLES'; scene.cycles.samples=16
scene.render.resolution_x=960; scene.render.resolution_y=720; scene.render.resolution_percentage=100
scene.world.color=(.22,.22,.22)
for at,energy,size in [((3,-5,10),1700,7),((-6,2,7),1300,6),((0,7,9),1800,5)]:
    bpy.ops.object.light_add(type='AREA',location=at); bpy.context.object.data.energy=energy; bpy.context.object.data.shape='DISK'; bpy.context.object.data.size=size
bpy.ops.object.camera_add(); camera=bpy.context.object; camera.data.type='ORTHO'; camera.data.ortho_scale=10; scene.camera=camera
for title,at,target in [('front',(10,13,8),(0,-.5,2)),('rear',(10,-14,10),(0,-1.8,2)),('cabin',(5,7,7),(0,0,2.5))]:

    if title=='cabin':
        for ob in list(root.children_recursive):
            if ob.name.startswith(('Roof','Pillar')): ob.hide_render=True
        camera.data.ortho_scale=6.5
    camera.location=at; camera.rotation_euler=(Vector(target)-camera.location).to_track_quat('-Z','Y').to_euler()
    scene.render.filepath=str(OUT/('preview_'+title+'.png')); bpy.ops.render.render(write_still=True)

# Keep the .blend finely editable; batch only the portable export by material and
# mechanical parent to avoid hundreds of tread/bolt draw calls on every peer.
for ob in list(root.children_recursive):
    ob.hide_render=False
    if ob.type=='CURVE':
        bpy.ops.object.select_all(action='DESELECT'); ob.select_set(True); bpy.context.view_layer.objects.active=ob; bpy.ops.object.convert(target='MESH')
for parent in [root]+[ob for ob in root.children_recursive if ob.type=='EMPTY']:
    groups={}
    for ob in list(parent.children):
        if ob.type=='MESH': groups.setdefault(ob.data.materials[0].name,[]).append(ob)
    for material,objects in groups.items():
        bpy.ops.object.select_all(action='DESELECT')
        for ob in objects: ob.select_set(True)
        bpy.context.view_layer.objects.active=objects[0]
        if len(objects)>1: bpy.ops.object.join()
        bpy.context.object.name=parent.name+'_'+material
bpy.ops.object.select_all(action='DESELECT')
for ob in [root]+list(root.children_recursive): ob.select_set(True)
bpy.ops.export_scene.gltf(filepath=str(OUT/'truck.glb'),export_format='GLB',export_yup=True,use_selection=True)
