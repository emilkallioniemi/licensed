"""Original articulated learner. Blender --background --python build_player.py.

Rigid segmented humanoid rig: every mesh is parented to its anatomical joint.
The named local transforms are the portable Godot rig contract; no physics or
occupancy is baked into the asset. Runtime poses/IK live in learner_pose.gd.
Blender Z up, forward -Y; exported Godot Y up, forward +Z.
"""
from pathlib import Path
from math import radians
import bpy
from mathutils import Vector
SOURCE = Path(__file__).resolve().parent
OUT = SOURCE.parent
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)

def rgba(hex):
    # Palettes.gd uses sRGB; Blender shader inputs are scene-linear.
    rgb=[int(hex[i:i+2],16)/255 for i in (0,2,4)]
    return tuple(c/12.92 if c<=.04045 else ((c+.055)/1.055)**2.4 for c in rgb)+(1,)
PALETTES=[dict(Shirt='477c79',Trousers='29494c',Accent='f4ecd7'),dict(Shirt='dbaa51',Trousers='555f73',Accent='477c79'),dict(Shirt='b96550',Trousers='29494c',Accent='facf76')]
COLORS=dict(PALETTES[0],Skin='d3a78c',Hair='493429',Shoes='3c4248',White='f4ecd7',Ink='292830',Lip='925c50',Metal='959c98')
mats={}
for name,color in COLORS.items():
    m=bpy.data.materials.new(name); m.diffuse_color=rgba(color); m.use_nodes=True
    shader=m.node_tree.nodes['Principled BSDF']; shader.inputs['Base Color'].default_value=rgba(color); shader.inputs['Roughness'].default_value=.72
    mats[name]=m

def pivot(name,location,parent=None):
    obj=bpy.data.objects.new(name,None); bpy.context.collection.objects.link(obj); obj.parent=parent; obj.location=location
    obj.empty_display_type='SPHERE'; obj.empty_display_size=.025
    return obj

def box(name,location,size,material,parent,bevel=.025):
    bpy.ops.mesh.primitive_cube_add(size=1)
    obj=bpy.context.object; obj.name=name; obj.parent=parent; obj.location=location; obj.scale=size
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    if bevel:
        mod=obj.modifiers.new('Tailored soft edges','BEVEL'); mod.width=bevel; mod.segments=3
        bpy.ops.object.modifier_apply(modifier=mod.name)
        mod=obj.modifiers.new('Weighted normals','WEIGHTED_NORMAL'); mod.keep_sharp=True
        bpy.ops.object.modifier_apply(modifier=mod.name)
    obj.data.materials.append(mats[material]); return obj

root=pivot('Learner',(0,0,0))
body=pivot('BodyPivot',(0,0,1.08),root)
box('TrouserSeat',(0,0,-.005),(.49,.30,.22),'Trousers',body,.055)
spine=pivot('Spine',(0,0,.04),body)
box('Jacket',(0,0,.235),(.55,.32,.48),'Shirt',spine,.075)
box('RibbedHem',(0,0,.015),(.55,.33,.06),'Accent',spine,.012)
box('Zip',(0,-.167,.23),(.014,.015,.38),'Metal',spine,.003)
box('ZipPull',(0,-.18,.38),(.035,.015,.045),'Metal',spine,.004)
for side in [-1,1]:
    ob=box('FoldedCollar',(side*.08,-.105,.465),(.15,.20,.065),'Accent',spine,.018); ob.rotation_euler.y=side*.22
    box('Pocket',(side*.17,-.17,.135),(.14,.022,.13),'Shirt',spine,.013)
    box('PocketSeam',(side*.17,-.185,.20),(.14,.009,.012),'Accent',spine,.002)
    box('ShoulderSeam',(side*.235,0,.405),(.018,.325,.028),'Accent',spine,.006)
box('LearnerBadge',(-.145,-.177,.335),(.115,.022,.13),'White',spine,.012)
box('BadgeLStem',(-.169,-.191,.345),(.018,.009,.074),'Lip',spine,.002)
box('BadgeLFoot',(-.146,-.192,.315),(.06,.009,.018),'Lip',spine,.002)
box('Neck',(0,0,.51),(.18,.18,.13),'Skin',spine)
head=pivot('HeadPivot',(0,0,.51),spine)
box('Face',(0,-.008,.17),(.445,.37,.43),'Skin',head,.09)
box('HairCap',(0,.008,.375),(.465,.375,.13),'Hair',head,.055)
for i in range(4):
    tuft=box('SweptFringe',(-.15+i*.085,-.165,.34+i*.009),(.125,.08,.105),'Hair',head,.021); tuft.rotation_euler.y=-.12
for side,label in [(-1,'Left'),(1,'Right')]:
    box(label+'Ear',(side*.228,0,.175),(.075,.13,.14),'Skin',head,.03)
    box(label+'EarInset',(side*.257,-.015,.18),(.012,.065,.075),'Lip',head,.012)
    eye=pivot(label+'Eye',(side*.098,-.186,.215),head)
    box('EyeWhite',(0,0,0),(.080,.023,.090),'White',eye,.023)
    box('Pupil',(side*.005,-.014,-.003),(.034,.014,.05),'Ink',eye,.011)
    box('Glint',(-.009,-.023,.012),(.01,.006,.012),'White',eye,.003)
    brow=pivot(label+'Brow',(side*.098,-.197,.285),head)
    ob=box('Brow',(0,0,0),(.092,.029,.025),'Hair',brow,.008); ob.rotation_euler.y=side*.12
box('Nose',(0,-.212,.16),(.091,.11,.085),'Skin',head,.029)
box('LowerLip',(0,-.184,.074),(.108,.025,.022),'Lip',head,.008)
box('Mouth',(0,-.201,.087),(.083,.008,.013),'Ink',head,.003)
for side,label in [(-1,'Left'),(1,'Right')]:
    shoulder=pivot(label+'Shoulder',(side*.335,0,.40),spine)
    box(label+'Sleeve',(0,0,-.135),(.205,.265,.31),'Shirt',shoulder,.045)
    elbow=pivot(label+'Elbow',(0,0,-.29),shoulder)
    box(label+'Forearm',(0,0,-.125),(.17,.22,.28),'Shirt',elbow,.037)
    box(label+'Cuff',(0,0,-.25),(.18,.23,.055),'Accent',elbow,.01)
    wrist=pivot(label+'Wrist',(0,0,-.28),elbow)
    box(label+'Palm',(0,0,-.063),(.145,.082,.135),'Skin',wrist,.025)
    # Each digit has independently bendable proximal and distal joints.
    for i,finger in enumerate(['Index','Middle','Ring','Little']):
        x=(i-1.5)*.036
        finger_root=pivot(label+finger,(x,0,-.117),wrist)
        length=[.061,.073,.066,.050][i]
        box(finger+'Proximal',(0,0,-length/2),(.030,.050,length),'Skin',finger_root,.012)
        tip=pivot(label+finger+'Tip',(0,0,-length),finger_root)
        box(finger+'Distal',(0,0,-.024),(.027,.046,.048),'Skin',tip,.012)
        box(finger+'Nail',(0,.024,-.026),(.018,.003,.023),'White',tip,.003)
    thumb=pivot(label+'Thumb',(-side*.083,-.005,-.036),wrist)
    thumb.rotation_euler.y=-side*.48
    box('ThumbProximal',(0,0,-.035),(.045,.06,.07),'Skin',thumb,.018)
    tip=pivot(label+'ThumbTip',(0,0,-.065),thumb)
    box('ThumbDistal',(0,0,-.026),(.041,.056,.052),'Skin',tip,.017)
    hip=pivot(label+'Hip',(side*.155,0,0),body)
    box(label+'Thigh',(0,0,-.23),(.245,.29,.46),'Trousers',hip,.045)
    knee=pivot(label+'Knee',(0,0,-.46),hip)
    box(label+'Shin',(0,0,-.22),(.22,.26,.44),'Trousers',knee,.039)
    box('KneePatch',(0,-.134,-.015),(.17,.021,.14),'Trousers',knee,.019)
    ankle=pivot(label+'Ankle',(0,0,-.46),knee)
    box(label+'Shoe',(0,-.075,-.06),(.26,.39,.17),'Shoes',ankle,.04)
    box(label+'Sole',(0,-.075,-.122),(.27,.40,.035),'White',ankle,.008)
    for j in range(3): box('Lace',(0,-.065-j*.048,.017),(.15,.019,.014),'White',ankle,.004)

# Tailor the short jacket/neck to the retained 1.75 m standing eye. This is the
# rest anatomy, shared by every pose; limbs/head retain their modeled dimensions.
for component in spine.children:
    component.location.z *= .8
    if component.type == 'MESH': component.scale.z *= .8

bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'learner.blend'))
bpy.ops.export_scene.gltf(filepath=str(OUT/'learner.glb'),export_format='GLB')
# Studio source view and matching license portraits, from the exported body.
bpy.ops.mesh.primitive_plane_add(size=200); floor=bpy.context.object; floor.data.materials.append(mats['White']); floor.location.z=.003
bpy.ops.object.camera_add(location=(3,-7,3)); camera=bpy.context.object; bpy.context.scene.camera=camera; camera.data.type='ORTHO'
for location,energy,size in [((0,-4,6),800,5),((-4,0,4),500,4),((2,3,4),650,3)]:
    bpy.ops.object.light_add(type='AREA',location=location); light=bpy.context.object; light.data.energy=energy; light.data.shape='DISK'; light.data.size=size
    light.rotation_euler=(Vector((0,0,1))-light.location).to_track_quat('-Z','Y').to_euler()
scene=bpy.context.scene; scene.render.engine='CYCLES'; scene.cycles.samples=32; scene.world.color=(.35,.35,.35)
scene.view_settings.view_transform='AgX'; scene.render.resolution_percentage=100
for i,palette in enumerate(PALETTES):
    for name,color in palette.items(): mats[name].node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=rgba(color)
    camera.location=(.20,-4,1.72); camera.rotation_euler=(Vector((0,0,1.59))-camera.location).to_track_quat('-Z','Y').to_euler(); camera.data.ortho_scale=.98
    scene.render.resolution_x=512; scene.render.resolution_y=512; scene.render.filepath=str(OUT/f'portrait_{i+1}.png'); bpy.ops.render.render(write_still=True)
for name,color in PALETTES[0].items(): mats[name].node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=rgba(color)
for x,index in [(-1.25,1),(1.25,2)]:
    copies={}
    for original in [root]+list(root.children_recursive):
        clone=original.copy()
        if original.data:
            clone.data=original.data.copy()
            for slot in clone.material_slots:
                if slot.material.name in PALETTES[index]:
                    color=PALETTES[index][slot.material.name]; slot.material=slot.material.copy(); slot.material.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=rgba(color)
        bpy.context.collection.objects.link(clone); copies[original]=clone
    for original,clone in copies.items(): clone.parent=copies.get(original.parent)
    copies[root].location.x=x
camera.location=(3.5,-8,3.1); camera.rotation_euler=(Vector((0,0,1))-camera.location).to_track_quat('-Z','Y').to_euler(); camera.data.ortho_scale=5.1
scene.render.resolution_x=1200; scene.render.resolution_y=800; scene.render.filepath=str(OUT/'preview.png'); bpy.ops.render.render(write_still=True)
