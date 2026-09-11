"""Run with Blender --background --python build_player.py."""
from pathlib import Path
import bpy
from mathutils import Vector

SOURCE = Path(__file__).resolve().parent
OUT = SOURCE.parent
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)

COLORS = {
    'Shirt': (0.13, 0.43, 0.64, 1), 'Trousers': (0.09, 0.13, 0.19, 1),
    'Skin': (0.65, 0.39, 0.23, 1), 'Hair': (0.065, 0.035, 0.023, 1),
    'Shoes': (0.045, 0.055, 0.065, 1), 'Accent': (0.96, 0.68, 0.18, 1),
    'White': (0.9, 0.88, 0.8, 1), 'Ink': (0.025, 0.028, 0.035, 1),
}
mats = {}
for name, color in COLORS.items():
    m = bpy.data.materials.new(name)
    m.diffuse_color = color
    m.use_nodes = True
    m.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value = color
    m.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value = 0.82
    mats[name] = m

def pivot(name, location, parent=None):
    obj = bpy.data.objects.new(name, None)
    bpy.context.collection.objects.link(obj)
    obj.location = location
    obj.parent = parent
    return obj

def box(name, location, size, material, parent, bevel=0.04):
    bpy.ops.mesh.primitive_cube_add(size=1)
    obj = bpy.context.object
    obj.name = name
    obj.parent = parent
    obj.location = location
    obj.scale = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel:
        mod = obj.modifiers.new('Soft corners', 'BEVEL')
        mod.width = bevel
        mod.segments = 2
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.modifier_apply(modifier=mod.name)
    obj.data.materials.append(mats[material])
    return obj

# Blender Z up, face -Y. glTF export converts to Godot Y up, face +Z.
root = pivot('Learner', (0, 0, 0))
body = pivot('BodyPivot', (0, 0, 0.92), root)
box('Jacket', (0, 0, 0.22), (0.57, 0.32, 0.58), 'Shirt', body, 0.075)
box('Hem', (0, -0.005, -0.02), (0.57, 0.33, 0.07), 'Accent', body, 0.015)
box('Zip', (0, -0.166, 0.23), (0.018, 0.013, 0.42), 'Ink', body, 0.003)
box('Badge', (-0.145, -0.174, 0.29), (0.13, 0.018, 0.15), 'White', body, 0.008)
box('L vertical', (-0.17, -0.186, 0.30), (0.018, 0.008, 0.08), 'Accent', body, 0.001)
box('L foot', (-0.147, -0.187, 0.267), (0.06, 0.008, 0.018), 'Accent', body, 0.001)
box('Neck', (0, 0, 0.54), (0.19, 0.19, 0.14), 'Skin', body)
head = pivot('HeadPivot', (0, 0, 0.58), body)
box('Head', (0, -0.005, 0.22), (0.47, 0.40, 0.48), 'Skin', head, 0.085)
box('Hair cap', (0, 0.015, 0.43), (0.49, 0.40, 0.16), 'Hair', head, 0.05)
box('Fringe', (-0.08, -0.192, 0.37), (0.30, 0.055, 0.13), 'Hair', head, 0.016)
for side in [-1, 1]:
    box('Ear', (side * 0.244, 0, 0.23), (0.08, 0.14, 0.15), 'Skin', head, 0.03)
    box('Eye', (side * 0.105, -0.207, 0.245), (0.037, 0.018, 0.047), 'Ink', head, 0.009)
box('Nose', (0, -0.24, 0.19), (0.085, 0.09, 0.085), 'Skin', head, 0.02)
box('Mouth', (0, -0.211, 0.105), (0.085, 0.012, 0.015), 'Ink', head, 0.003)
for side, label in [(-1, 'Left'), (1, 'Right')]:
    shoulder = pivot(label + 'Shoulder', (side * 0.35, 0, 0.43), body)
    box(label + 'Sleeve', (side * 0.025, 0, -0.15), (0.20, 0.27, 0.36), 'Shirt', shoulder, 0.045)
    elbow = pivot(label + 'Elbow', (side * 0.025, 0, -0.31), shoulder)
    box(label + 'Forearm', (0, -0.012, -0.105), (0.18, 0.23, 0.25), 'Shirt', elbow)
    box(label + 'Cuff', (0, -0.012, -0.22), (0.19, 0.24, 0.065), 'Accent', elbow, 0.012)
    box(label + 'Hand', (0, -0.025, -0.30), (0.17, 0.19, 0.17), 'Skin', elbow, 0.045)
    hip = pivot(label + 'Hip', (side * 0.155, 0, -0.08), body)
    box(label + 'Thigh', (0, 0, -0.18), (0.245, 0.29, 0.38), 'Trousers', hip)
    knee = pivot(label + 'Knee', (0, 0, -0.36), hip)
    box(label + 'Shin', (0, 0, -0.16), (0.225, 0.26, 0.34), 'Trousers', knee)
    box(label + 'Shoe', (0, -0.075, -0.395), (0.26, 0.40, 0.17), 'Shoes', knee, 0.035)
    box(label + 'Sole', (0, -0.075, -0.457), (0.27, 0.41, 0.035), 'White', knee, 0.008)

bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE / 'learner.blend'))
bpy.ops.export_scene.gltf(filepath=str(OUT / 'learner.glb'), export_format='GLB')

# A separate contact sheet, never exported as part of the character.
for x, shirt, accent in [(-1.4, (0.78, 0.24, 0.14, 1), (0.98, 0.79, 0.27, 1)),
                         (1.4, (0.26, 0.55, 0.30, 1), (0.71, 0.81, 0.97, 1))]:
    copies = {}
    for original in [root] + list(root.children_recursive):
        clone = original.copy()
        if original.data:
            clone.data = original.data.copy()
            for slot in clone.material_slots:
                if slot.material.name in ['Shirt', 'Accent']:
                    name = slot.material.name
                    slot.material = slot.material.copy()
                    slot.material.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value = shirt if name == 'Shirt' else accent
        bpy.context.collection.objects.link(clone)
        copies[original] = clone
    for original, clone in copies.items():
        clone.parent = copies.get(original.parent)
    copies[root].location.x = x

bpy.ops.mesh.primitive_plane_add(size=200)
floor = bpy.context.object
floor.data.materials.append(mats['White'])
floor.location.z = -0.005
bpy.ops.object.camera_add(location=(4.4, -8.5, 3.6))
camera = bpy.context.object
camera.rotation_euler = (Vector((0, 0, 1.0)) - camera.location).to_track_quat('-Z', 'Y').to_euler()
camera.data.type = 'ORTHO'
camera.data.ortho_scale = 5.7
bpy.context.scene.camera = camera
for location, energy, size in [((0, -4, 6), 650, 5), ((-4, 0, 4), 400, 4)]:
    bpy.ops.object.light_add(type='AREA', location=location)
    light = bpy.context.object
    light.data.energy = energy
    light.data.shape = 'DISK'
    light.data.size = size
    light.rotation_euler = (Vector((0, 0, 1)) - light.location).to_track_quat('-Z', 'Y').to_euler()
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.samples = 32
scene.world.color = (0.35, 0.35, 0.35)
scene.render.resolution_x = 1200
scene.render.resolution_y = 700
scene.render.resolution_percentage = 100
scene.render.filepath = str(OUT / 'preview.png')
bpy.ops.render.render(write_still=True)
