"""Original static modular scrapyard. Blender 5.2; no downloaded assets.
Run: Blender --background --python assets/scrapyard/source/build_scrapyard.py
Metres; Z up in source, exported to Godot Y up. Each module has ground-centred origin.
"""
import bpy, math, random
from pathlib import Path
from mathutils import Vector
OUT=Path(__file__).resolve().parents[1]
random.seed(804)
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
def mat(name, rgb):
 rgb=[v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in rgb]
 m=bpy.data.materials.new(name); m.diffuse_color=(*rgb,1); m.use_nodes=True
 p=m.node_tree.nodes.get('Principled BSDF'); p.inputs['Base Color'].default_value=(*rgb,1); p.inputs['Roughness'].default_value=.82
 return m
rust=mat('Oxidised ochre',(.39,.18,.095)); teal=mat('Faded depot teal',(.18,.34,.34)); cream=mat('Old enamel',(.72,.67,.48)); steel=mat('Dark cut steel',(.17,.21,.21)); rubber=mat('Old rubber',(.07,.085,.075)); glass=mat('Opaque dusty glass',(.23,.32,.32)); red=mat('Primer red',(.43,.20,.15)); concrete=mat('Weathered concrete',(.42,.43,.36)); yellow=mat('Safety ochre',(.82,.55,.16))
parts=[]
def box(name, p, s, m, bevel=.04, rot=(0,0,0)):
 bpy.ops.mesh.primitive_cube_add(size=1,location=p); o=bpy.context.object; o.name=name; o.dimensions=s; o.rotation_euler=rot
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True); o.data.materials.append(m)
 if bevel:
  mod=o.modifiers.new('Soft battered edges','BEVEL');mod.width=bevel;mod.segments=2;bpy.ops.object.modifier_apply(modifier=mod.name)
 parts.append(o);return o
def cyl(name,p,r,d,m,rot=(0,0,0),verts=12):
 bpy.ops.mesh.primitive_cylinder_add(vertices=verts,radius=r,depth=d,location=p,rotation=rot);o=bpy.context.object;o.name=name;o.data.materials.append(m);parts.append(o);return o
def beam(name,a,b,w,m):
 a,b=Vector(a),Vector(b);o=box(name,(a+b)/2,(w,w,(b-a).length),m,.01);o.rotation_euler=(b-a).to_track_quat('Z','Y').to_euler()
def car(offset=(0,0,0), paint=teal, crushed=False):
 x,y,z=offset; h=.65 if crushed else 1
 box('Buckled sill',(x,y,z+.42),(2.35,4.35,.55),rust)
 box('Battered body',(x,y,z+.7),(2.45,4.15,.65*h),paint,.12)
 box('Bonnet',(x,y-1.4,z+1.0*h),(2.3,1.35,.22),paint,.09,rot=(.08,0,.025))
 box('Crushed cabin',(x,y+.2,z+1.28*h),(1.95,1.8,.75*h),glass,.16)
 box('Folded roof',(x,y+.2,z+1.7*h),(2.06,1.95,.14),paint,.07,rot=(0,.07,.02))
 for sx in [-1,1]:
  for yy in [-1.35,1.35]:
   cyl('Tyre',(x+sx*1.12,y+yy,z+.43),.47,.30,rubber,(0,math.pi/2,0));cyl('Bare rim',(x+sx*1.29,y+yy,z+.43),.25,.025,steel,(0,math.pi/2,0))
  box('Door seam',(x+sx*1.235,y+.12,z+.78),( .025,1.45,.045),rust,.005)
  box('Door handle',(x+sx*1.26,y+.55,z+1.04*h),(.04,.22,.06),cream,.01)
 for yy in [-2.16,2.16]:
  box('Loose bumper',(x,y+yy,z+.5),(2.6,.16,.22),steel)
  for xx in [-.78,.78]:box('Broken lamp',(x+xx,y+yy,z+.83),( .4,.05,.20),cream)
 for i in range(10):
  box('Paint loss',(x+random.uniform(-1,1),y+random.uniform(-1.8,1.8),z+1.06*h),(.18,.30,.013),rust,.005)
def export(name,build):
 global parts
 parts=[];build();bpy.ops.object.select_all(action='DESELECT')
 for o in parts:o.select_set(True)
 bpy.context.view_layer.objects.active=parts[0];bpy.ops.object.join();o=bpy.context.object;o.name=name
 bpy.context.scene.cursor.location=(0,0,0);bpy.ops.object.origin_set(type='ORIGIN_CURSOR')
 bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',use_selection=True)
 o.hide_render=True;o.hide_set(True)
 return o
export('wreck',lambda:car())
def stack():
 car(paint=red,crushed=True);car((.14,.15,1.25),cream,True);car((-.15,-.15,2.5),teal,True)
export('wreck_stack',stack)
def container():
 box('Container shell',(0,0,1.5),(6,2.8,3),teal,.08)
 for x in [-2.95,2.95]:
  for y in [-1.36,1.36]:box('Corner casting',(x,y,1.5),(.15,.16,3.08),steel)
 for i in range(24):
  for y in [-1.43,1.43]:box('Corrugated steel',(-2.8+i*.24,y,1.5),(.085,.09,2.78),teal,.01)
 for x in [-3.04,3.04]:
  for y in [-.69,.69]:
   box('Cargo door',(x,y,1.5),(.07,1.31,2.72),teal,.01)
   box('Locking bar',(x*1.015,y,1.5),(.07,.07,2.55),cream,.01)
   for z in [.3,2.7]:box('Hinge',(x*1.02,y,z),(.12,.27,.12),rust,.01)
 for i in range(18):box('Rust streak',(-2.8+i*.32,-1.491,random.uniform(.3,2.7)),(.045,.015,random.uniform(.15,.55)),rust,.002)
export('container',container)
def fence():
 for x in [-3,0,3]:
  box('Fence post',(x,0,1.6),(.14,.18,3.2),steel,.02);box('Foot',(x,0,.15),(.42,.42,.3),concrete)
 for i in range(20):box('Uneven corrugated panel',(-2.85+i*.3,.02,1.25),(.29,.10,2.4+random.uniform(-.15,.15)),teal if i%4 else rust,.015)
 for z in [.4,2.25]:box('Rail',(0,-.08,z),(6,.12,.12),steel,.01)
export('fence',fence)
def scrap():
 box('Compacted scrap base',(0,0,.35),(4.6,3.2,.7),rust,.25)
 for i in range(26):
  box('Bent salvaged panel',(random.uniform(-1.7,1.7),random.uniform(-1,1),random.uniform(.6,1.2)),(random.uniform(.6,1.8),random.uniform(.3,.8),.12),[rust,teal,cream,steel][i%4],.03,(random.uniform(-.35,.35),random.uniform(-.3,.3),random.uniform(-2,2)))
 for x in [-1.5,0,1.5]:cyl('Cut pipe',(x,0,1.4),.25,2.3,steel,(math.pi/2,0,0))
export('scrap_pile',scrap)
def workshop():
 box('Workshop masonry',(0,0,3.4),(16,9,6.8),concrete,.12)
 box('Front steel fascia',(0,-4.56,5.8),(16.2,.18,1.6),teal)
 for x in [-4.1,4.1]:
  box('Shutter frame',(x,-4.65,2.4),(6.7,.24,4.8),steel)
  box('Closed roller shutter',(x,-4.80,2.4),(6.2,.10,4.45),teal)
  for i in range(19):box('Shutter slat',(x,-4.87,.3+i*.23),(6.12,.045,.055),steel,.007)
  box('Shutter bottom',(x,-4.92,.19),(6.3,.16,.18),yellow)
 for y in [-2.3,2.3]:box('Pitched steel roof',(0,y,7.0),(16.7,4.9,.18),steel,.02,(.12 if y<0 else -.12,0,0))
 for x in range(-8,9):
  for y in [-2.3,2.3]:box('Roof seam',(x,y,7.11),(.055,4.9,.07),teal,.008,(.12 if y<0 else -.12,0,0))
 for x in [-7.6,0,7.6]:box('Drain pipe',(x,-4.75,3.4),(.13,.14,6.6),rust,.02)
 for x in [-5,5]:
  box('Frosted clerestory',(x,-4.67,6.0),(4,.08,.70),glass)
  for dx in [-1.3,0,1.3]:box('Mullion',(x+dx,-4.74,6),(.065,.07,.8),cream,.005)
 for x in [-7.2,7.2]:box('Lamp hood',(x,-5.0,4.9),(.5,.5,.22),cream)
 box('Vent',(0,1,7.8),(2,2,1.4),teal)
 for i in range(7):box('Vent louvre',(0,-.04,7.3+i*.15),(1.8,.1,.06),steel,.01)
export('workshop',workshop)
def skyline():
 for x,h in [(-7,14),(-2,19),(3,12)]:
  cyl('Storage silo',(x,0,h/2),2.1,h,concrete,verts=16)
  for z in [1,h-1]:cyl('Silo band',(x,0,z),2.17,.18,steel,verts=16)
  cyl('Vent chimney',(x,0,h+2),.48,4,rust)
 for x in [-10,7]:box('Gantry column',(x,0,7),(.45,.5,14),steel)
 beam('Conveyor spine',(-10,0,14),(7,0,19),.5,steel)
 for x in range(-10,7,2):beam('Conveyor rib',(x,-.7,14+(x+10)*5/17),(x,.7,14+(x+10)*5/17),.18,rust)
export('industrial_skyline',skyline)
def parking():
 box('Compressed vehicle base',(0,0,.38),(2.96,2.96,.76),rust,.12)
 box('Flattened vehicle shell',(0,0,.94),(2.95,2.9,.88),teal,.16)
 for x in [-1.38,1.38]:
  for y in [-.85,.85]:cyl('Crushed wheel',(x,y,.45),.4,.16,rubber,(0,math.pi/2,0))
 box('Collapsed windscreen',(0,-.7,1.27),(2.1,.65,.15),glass,.05)
 for y in [-1.44,1.44]:box('Folded bumper',(0,y,.6),(2.95,.10,.18),steel)
 for x in [-.9,.9]:box('Lamp',(x,-1.46,.99),(.4,.06,.19),cream)
export('parking_wreck',parking)
def gate():
 box('Fixed post',(0,0,.6),(.48,.48,1.2),yellow,.06)
 for z in [.25,.65,1.05]:box('Black paint band',(0,-.245,z),(.48,.01,.17),steel,.005)
 for x in [-.15,.15]:cyl('Cap bolt',(x,0,1.2),.035,.02,steel)
export('gate_post',gate)
# Library has individually revisable named modules; not a flattened yard scene.
for o in bpy.context.scene.objects:o.hide_render=False;o.hide_set(False)
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source'/'scrapyard.blend'))
print('SCRAPYARD EXPORT PASS')
