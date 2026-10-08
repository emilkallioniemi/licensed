"""Original monster-truck stadium. Blender 5.2 --background --python this_file.
Authored in Godot metres: X right, Y up, -Z forward. No external assets.
"""
import bpy, math, random, sys, os
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from stadium_detail import CrowdBuilder, build_wreck
from mathutils import Vector
OUT=Path(__file__).resolve().parents[1]
random.seed(709)
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
bpy.context.preferences.filepaths.save_version=0
def mat(name,h,metal=0,emission=0):
    c=[int(h[i:i+2],16)/255 for i in (0,2,4)]; c=[v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in c]
    m=bpy.data.materials.new(name); m.diffuse_color=(*c,1); m.use_nodes=True
    bs=m.node_tree.nodes['Principled BSDF']; bs.inputs['Base Color'].default_value=(*c,1); bs.inputs['Roughness'].default_value=.64; bs.inputs['Metallic'].default_value=metal
    if emission:bs.inputs['Emission Color'].default_value=(*c,1); bs.inputs['Emission Strength'].default_value=emission
    return m
dirt=mat('Stadium dirt','986744'); concrete=mat('Concrete','727C85'); steel=mat('Truss steel','263444',.7)
red=mat('Racing vermilion','D94C39'); blue=mat('Arena blue','267894'); cream=mat('Warm white','EFE8D3'); black=mat('Rubber','202528')
gold=mat('Safety gold','F2B63F'); screen=mat('LED midnight','11253B',0,.4); light=mat('Floodlight','DBE9FF',0,5)
orange=mat('Pyro enamel','ED7538'); silver=mat('Bare alloy','AFBBC1',.8); glass=mat('Wreck glass','294E5A',.3)
crowd_mats=[mat('Crowd '+str(i),h) for i,h in enumerate(['D04E3D','3A8A97','D6AD54','554B82','CBC7B4','2F4657','6C874B'])]
skin=[mat('Skin '+str(i),h) for i,h in enumerate(['BD825D','E0B291','82573F','A67351'])]
def xyz(p):return (p[0],-p[2],p[1])
def box(name,p,s,m,bevel=0):
    bpy.ops.mesh.primitive_cube_add(size=1,location=xyz(p)); o=bpy.context.object; o.name=name; o.scale=(s[0],s[2],s[1]); bpy.ops.object.transform_apply(location=False,rotation=False,scale=True); o.data.materials.append(m)
    if bevel:
        mod=o.modifiers.new('Rounded edges','BEVEL'); mod.width=bevel; mod.segments=2; bpy.ops.object.modifier_apply(modifier=mod.name)
    return o
def beam(name,a,b,r,m):
    a,b=Vector(xyz(a)),Vector(xyz(b)); v=b-a
    bpy.ops.mesh.primitive_cylinder_add(vertices=8,radius=r,depth=v.length,location=(a+b)/2); o=bpy.context.object; o.name=name; o.rotation_euler=v.to_track_quat('Z','Y').to_euler(); o.data.materials.append(m); return o
def text(copy,p,size,m,angle=0):
    bpy.ops.object.text_add(location=xyz(p),rotation=(math.pi/2,0,angle)); o=bpy.context.object; o.name='Lettering '+copy; o.data.body=copy; o.data.align_x='CENTER'; o.data.size=size; o.data.extrude=.009; o.data.materials.append(m); bpy.ops.object.convert(target='MESH'); return bpy.context.object
def mesh(name,verts,faces,m):
    data=bpy.data.meshes.new(name); data.from_pydata([xyz(p) for p in verts],[],faces); data.materials.append(m); data.update(); o=bpy.data.objects.new(name,data); bpy.context.collection.objects.link(o); return o
def export(name,objects):
    bpy.ops.object.select_all(action='DESELECT')
    for o in objects:o.select_set(True)
    bpy.context.view_layer.objects.active=objects[0]
    # Publish a complete GLB atomically, including when Godot has imported it.
    target=OUT/(name+'.glb'); temporary=OUT/(name+'.pending.glb')
    bpy.ops.export_scene.gltf(filepath=str(temporary),export_format='GLB',use_selection=True)
    os.replace(temporary,target)
def save_source(name):
    target=OUT/'source'/(name+'.blend'); temporary=OUT/'source'/(name+'.pending.blend')
    bpy.ops.wm.save_as_mainfile(filepath=str(temporary))
    os.replace(temporary,target)
def batch(objects,name):
    bpy.ops.object.select_all(action='DESELECT')
    for o in objects:o.select_set(True)
    bpy.context.view_layer.objects.active=objects[0]; bpy.ops.object.join(); o=bpy.context.object; o.name=name; return o
fans=CrowdBuilder()
chairs=CrowdBuilder()
denim=mat('Crowd denim','39516A')
hair=[mat('Crowd hair '+str(i),h) for i,h in enumerate(['292321','6C422D','C49A59','6B6260'])]
fan_index=0
def bump(x,z):
    fade=min(1,math.hypot(x,z+9)/9)
    return fade*(.18+.18*math.sin(z*.8+x*.31)+.12*math.sin(x*.73-z*.37)+1.4*math.exp(-((z+25)/6)**2)*math.exp(-(x/23)**2))
def ramp_height(z):
    t=max(0,min(1,(z+18)/36))
    return 3.8*math.sin(math.pi*t)**2+.28*math.sin(t*math.pi*12)**2

def build_wrecks():
    for variant in range(3):
        for crushed in [False,True]:
            bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
            build_wreck(globals(),variant,crushed)
            title='crush_car'+('' if variant==0 else '_'+str(variant))+('_folded' if crushed else '')
            # Preserve individual editable parts in Blender; batch only the export.
            save_source(title)
            groups={}
            for obj in list(bpy.context.scene.objects):
                groups.setdefault(obj.data.materials[0],[]).append(obj)
            objects=[batch(group,'Wreck_'+material.name) for material,group in groups.items()]
            export(title,objects)

if '--wrecks-only' in sys.argv:
    build_wrecks()
    raise SystemExit(0)

# Continuous sculpted dirt infield, interrupted by three unmistakable stunt pits.
verts=[]; faces=[]; nx=97; nz=265
for iz in range(nz):
    z=20-iz
    for ix in range(nx):
        x=ix-48; verts.append((x,bump(x,z),z))
for iz in range(nz-1):
    z=19.5-iz
    for ix in range(nx-1):
        x=ix-47.5
        if abs(x)<29 and any(abs(z-c)<18 for c in [-60,-120,-180]):continue
        a=iz*nx+ix; faces.extend([(a,a+1,a+nx),(a+1,a+nx+1,a+nx)])
ground=mesh('Ride_Dirt',verts,faces,dirt)
for f in ground.data.polygons:f.use_smooth=True
for c in [-60,-120,-180]:
    box('Ride_PitFloor',(0,-24,c),(58,1,36),concrete)
    for z in [c-18,c+18]:box('Pit concrete retaining wall',(0,-12,z),(58,24,.45),concrete)
    for x in [-29,29]:box('Pit side lining',(x,-12,c),(.5,24,36),concrete)
    # Floodlit diagonal safety bands make the excavated drop read as a hazard.
    for x in range(-28,29,2):
        if abs(abs(x)-18)<8:continue
        for z in [c-18.2,c+18.2]:box('Hazard edge',(x,.18,z),(1.8,.32,.45),gold if x%4 else black)
for z in [-17,-90,-150,-218]:
    for x in [-25.5,25.5]:
        box('Solid_Barrier',(x,.75,z),(.8,1.5,18),concrete,.12)
        for zz in [-7,-3,1,5]:box('Barrier chevron',(x,.95,z+zz),(.83,.45,2),red)
for x in [-48.5,48.5]:
    box('Solid_ArenaWall',(x,1.5,-110),(1,3,270),concrete,.1)
    for z in range(-235,20,12):
        box('Perimeter blue banners',(x*.987,2,z),(.12,1.6,10.7),blue)
        beam('Catch fence',(x,3,z),(x,6,z),.055,steel)
        for yy in [3,4,5,6]:beam('Fence wire',(x,yy,z),(x,yy,z+12),.015,steel)

# An oval bowl: tiers, aisles, seats, crowd, concourse portals and a roof ring.
crowd_parts=[]; seat_parts=[]
for sector in range(48):
    angle=2*math.pi*sector/48
    dx,dz=math.cos(angle),math.sin(angle)
    for row in range(9):
        r=54+row*2.3; zz=139+row*2.3
        p=(dx*r,3.4+row*1.15,-110+dz*zz)
        width=.135*math.sqrt((r*dz)**2+(zz*dx)**2)
        seat=box('Grandstand tread',p,(width,.8,3),concrete); seat.rotation_euler.z=math.pi/2-angle
        seat_parts.append(seat)
        if sector%6==0:continue
        count=max(4,min(8,int(width/1.1)))
        for seat_index in range(count):
            j=(seat_index-(count-1)/2)*min(1.25,width/count)
            x=p[0]+math.sin(angle)*j; z=p[2]-math.cos(angle)*j; y=p[1]+.83
            seat_color=red if (sector//6)%2 else blue
            chairs.origin=(x,y,z); chairs.angle=math.atan2(-dx,-dz)
            chairs.oval((0,0,0),(.35,.08,.34),seat_color,3)
            chairs.oval((0,.31,-.29),(.35,.34,.065),seat_color,4)
            if random.random()<.12:continue
            forward=.42 if fan_index%6 in [0,1,4] else 0
            fans.fan((x-dx*forward,p[1]+.4,z-dz*forward),math.atan2(-dx,-dz),crowd_mats,skin,black,denim,hair,cream,gold if fan_index%2 else red,fan_index)
            fan_index+=1
    # Upper promenade, roof support and cantilevered canopy.
    p=(dx*78,15,-110+dz*163)
    beam('Roof support',(p[0],0,p[2]),(p[0],26,p[2]),.25,steel)
    roof=box('Roof panel',(dx*69,26,-110+dz*154),(20,.32,20),steel); roof.rotation_euler.z=math.pi/2-angle
    beam('Roof truss',(dx*56,24,-110+dz*141),(dx*80,26,-110+dz*165),.16,silver)
    beam('Roof truss tie',(dx*56,24,-110+dz*141),(dx*78,18,-110+dz*163),.12,steel)
    if sector%3==0:
        box('Floodlight bank',(dx*55,24,-110+dz*140),(6,.8,1.2),steel,.1)
        for k in [-2,-1,0,1,2]:box('Lamp lens',(dx*55+k,23.55,-110+dz*140),( .7,.12,.7),light)
fans.finish(mesh)
chairs.finish(mesh,'Seats_')
print('Detailed spectators:',fan_index)
batch(seat_parts,'Grandstands')
# Closed architectural bowl and continuous roof fascia, not floating bleachers.
def oval_band(name,rx,rz,y0,y1,m):
    vs=[]; fs=[]
    for i in range(129):
        a=i*2*math.pi/128
        for y in [y0,y1]:vs.append((rx*math.cos(a),y,-110+rz*math.sin(a)))
    for i in range(128):
        a=i*2;fs.append((a,a+1,a+3,a+2))
    return mesh(name,vs,fs,m)
oval_band('Stadium exterior',80,165,-1,25.8,concrete)
oval_band('Upper red fascia',80.1,165.1,22,24.5,red)
oval_band('Lower concourse band',80.1,165.1,8,10,blue)
oval_band('Roof inner fascia',56,141,23,25.5,blue)
oval_band('Floodlight trim',56,141,24.7,24.85,light)
for i in range(48):
    a=i*2*math.pi/48
    beam('Exterior column',(80*math.cos(a),0,-110+165*math.sin(a)),(80*math.cos(a),25,-110+165*math.sin(a)),.30,steel)
for z in [29,-253]:
    face=-1 if z>0 else 1
    angle=math.pi if face<0 else 0
    box('Scoreboard frame',(0,19,z),(34,13,1.5),steel,.4)
    box('Scoreboard LED',(0,19,z+face*.8),(32,11,.08),screen)
    text('LICENSED',(0,20.5,z+face*.9),3.5,cream,angle)
    text('MONSTER ARENA',(0,17.2,z+face*.9),1.65,gold,angle)
    text('THREE CREW. ONE TRUCK.',(0,14.7,z+face*.9),.85,cream,angle)
    for x in [-15,15]:beam('Scoreboard pillar',(x,0,z),(x,14,z),.35,steel)
box('Ride_EndApron',(0,-.3,31),(96,.6,22),dirt)
box('Ride_EndApron',(0,-.3,-254),(96,.6,20),dirt)
for z in [25,-245]:
    box('Solid_EndWall',(0,1.5,z),(96,3,1),concrete,.1)
    box('End blue banner',(0,2,z+(-.55 if z>0 else .55)),(94,1.6,.1),blue)
for i,c in enumerate([-60,-120,-180]):
    for x in [-36,36]:
        box('Obstacle tower',(x,5,c+17),(3,10,2),blue,.15)
        text(['01','02','03'][i],(x,6,c+18.1),1.5,cream)
        text(['CRUNCH','RING RUN','BIG AIR'][i],(x,4.5,c+18.1),.45,gold)
    for x in [-32,32]:box('Pyro launcher',(x,.4,c+23),(1.3,.8,1.3),steel,.12)
for x in [-12,12]:beam('Finish post',(x,0,-219),(x,9,-219),.18,steel)
box('Finish banner',(0,9,-219),(25,2,.18),red)
text('FINISH',(0,8.45,-218.85),1.6,cream)
# Non-blocking dirt freestyle mounds at the sidelines give the arena depth.
for side in [-1,1]:
    for z in [-35,-90,-148,-215]:
        vs=[]; fs=[]
        for iz in range(21):
            zz=z-10+iz
            for ix in range(13):
                x=side*38-6+ix; h=4.2*math.sin(math.pi*ix/12)*math.sin(math.pi*iz/20)
                vs.append((x,bump(x,zz)+h,zz))
        for iz in range(20):
            for ix in range(12):
                a=iz*13+ix; fs.extend([(a,a+13,a+1),(a+1,a+13,a+14)])
        o=mesh('Ride_FreestyleMound',vs,fs,dirt)
        for f in o.data.polygons:f.use_smooth=True
environment=list(bpy.context.scene.objects); export('stadium',environment)

def lane(broken,jump=False):
    objects=[]; vs=[]; fs=[]
    for iz in range(73):
        z=-18+iz*.5
        for ix in range(29):
            x=-7+ix*.5; h=ramp_height(z)+.15*math.sin(x*1.2)*math.sin(math.pi*iz/72)
            vs.append((x,h,z))
    for iz in range(72):
        z=-17.75+iz*.5
        if broken and abs(z)<8:continue
        if jump and abs(z)<3.25:continue
        for ix in range(28):
            a=iz*29+ix; fs.extend([(a,a+29,a+1),(a+1,a+29,a+30)])
    o=mesh('Ride_Ramp',vs,fs,dirt)
    for f in o.data.polygons:f.use_smooth=True
    objects.append(o)
    for x in [-7,7]:
        for z in range(-18,18,2):
            if broken and abs(z+1)<8:continue
            if jump and abs(z+1)<3.25:continue
            a=(x,ramp_height(z)-.15,z); b=(x,ramp_height(z+2)-.15,z+2)
            objects.append(beam('Ramp rim',a,b,.10,gold))
    for z in [-17,17]:
        objects.append(box('Ramp foundation',(0,-1,z),(14,2,2),concrete,.1))
    return objects
intact=lane(False); export('lane_live',intact)
broken=lane(True); export('lane_missing',broken)
jump=lane(False,True); export('lane_jump',jump)
for o in broken:bpy.data.objects.remove(o,do_unlink=True)
for side in [-1,1]:
    for z in [-60,-120,-180]:
        for src in jump if z==-180 else intact:
            o=src.copy(); o.data=src.data; bpy.context.collection.objects.link(o); o.location+=Vector(xyz((side*18,0,z)))
for o in intact:bpy.data.objects.remove(o,do_unlink=True)
for o in jump:bpy.data.objects.remove(o,do_unlink=True)
# A full 3D stunt ring: torus rim, bracing, feet and marker lamps.
before=set(bpy.context.scene.objects)
bpy.ops.mesh.primitive_torus_add(major_segments=72,minor_segments=10,major_radius=7.5,minor_radius=.25,location=xyz((0,6.5,0)),rotation=(math.pi/2,0,0)); o=bpy.context.object; o.name='Ring steel'; o.data.materials.append(gold)
for x in [-7.6,7.6]:
    box('Ring foot',(x,-.2,0),(2,.4,3),steel,.1)
    beam('Ring strut',(x,0,1.2),(x,5,0),.13,red)
ring=list(set(bpy.context.scene.objects)-before); export('ring',ring)
for src in ring:
    for x in [-18,18]:
        o=src.copy(); o.data=src.data; bpy.context.collection.objects.link(o); o.location+=Vector(xyz((x,1.8,-120)))
for o in ring:bpy.data.objects.remove(o,do_unlink=True)
save_source('stadium')

# Three salvage designs, each with a separately authored folded shell.
build_wrecks()
