"""Original authored quarry map and field book. Run with Blender --background --python.

All dimensions below are Godot metres, Y up, forward -Z. GLB export converts
Blender's axes. The saved blend contains the assembled route with intact bridges;
runtime chooses the matching intact/broken mesh without changing collision rules.
"""
import bpy, math, random
from pathlib import Path
from mathutils import Vector
OUT = Path(__file__).resolve().parents[1]
random.seed(804)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)

def mat(name, hex):
    c = [int(hex[i:i+2],16)/255 for i in (0,2,4)]
    m=bpy.data.materials.new(name); m.diffuse_color=(*c,1); m.use_nodes=True
    m.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=(*[v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in c],1)
    m.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=.86
    return m
rock=[mat('Sandstone '+str(i),c) for i,c in enumerate(['A17F59','B8966B','C8AA7D','8B7054','D1B489'])]
asphalt=mat('Weathered asphalt','555B59'); steel=mat('Oxidised structural steel','704939')
teal=mat('Depot enamel','346768'); cream=mat('Warm painted lettering','EFE1B9')
yellow=mat('Safety ochre','E9AB43'); dark=mat('Dark iron','263D40')
concrete=mat('Precast concrete','AAA28A'); water=mat('Quarry water','436D70')
sage=mat('Dusty sage','758568'); grass=mat('Dry grass','A69960')
paper=mat('Ivory paper','EEE1BF'); leather=mat('Petrol cloth cover','244F52'); brass=mat('Brass corners','BDA060')

def xyz(p): return (p[0],-p[2],p[1])
def box(name,p,s,m,bevel=0):
    bpy.ops.mesh.primitive_cube_add(size=1,location=xyz(p)); o=bpy.context.object; o.name=name
    o.scale=(s[0],s[2],s[1]); bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    o.data.materials.append(m)
    if bevel:
        mod=o.modifiers.new('Soft manufactured edges','BEVEL'); mod.width=bevel; mod.segments=2
        bpy.ops.object.modifier_apply(modifier=mod.name)
    return o
def beam(name,a,b,width,m):
    va,vb=Vector(xyz(a)),Vector(xyz(b)); d=vb-va
    bpy.ops.mesh.primitive_cube_add(size=1,location=(va+vb)/2); o=bpy.context.object; o.name=name
    o.scale=(width,width,d.length); o.rotation_euler=d.to_track_quat('Z','Y').to_euler()
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True); o.data.materials.append(m); return o
def cylinder(name,p,r,h,m,vertices=16):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices,radius=r,depth=h,location=xyz(p)); o=bpy.context.object; o.name=name; o.data.materials.append(m); return o
def text(name,copy,p,size,m):
    bpy.ops.object.text_add(location=xyz(p),rotation=(math.pi/2,0,0)); o=bpy.context.object; o.name=name
    o.data.body=copy; o.data.align_x='CENTER'; o.data.size=size; o.data.extrude=.009; o.data.materials.append(m)
    bpy.ops.object.convert(target='MESH'); return bpy.context.object
def cliff(name,cx,cz,rx,rz,top,bottom=-24,n=15):
    verts=[]; jitter=[random.uniform(.79,1.16) for _ in range(n)]
    rings=[(bottom,1.12), (bottom+(top-bottom)*.24,1.2), (bottom+(top-bottom)*.29,1.08), (bottom+(top-bottom)*.55,1.03), (bottom+(top-bottom)*.61,.94), (bottom+(top-bottom)*.84,.93), (top,.77)]
    for level,(y,scale) in enumerate(rings):
        for i in range(n):
            a=2*math.pi*i/n
            variance=random.uniform(-1.8,1.8) if top>5 else 0
            verts.append(xyz((cx+math.cos(a)*rx*jitter[i]*scale+math.sin(level*1.8)*1.3,y+variance,cz+math.sin(a)*rz*jitter[i]*scale)))
    faces=[tuple(range(6*n,7*n))]
    for k in range(6):
        for i in range(n):
            a=k*n+i; b=k*n+(i+1)%n; c=(k+1)*n+(i+1)%n; d=(k+1)*n+i
            faces.extend([(a,b,c),(a,c,d)])
    mesh=bpy.data.meshes.new(name); mesh.from_pydata(verts,[],[tuple(reversed(f)) for f in faces]); mesh.update()
    o=bpy.data.objects.new(name,mesh); bpy.context.collection.objects.link(o)
    for m in rock: mesh.materials.append(m)
    for f in mesh.polygons:f.material_index=[1,0,1,2,1,4,2][min(6,f.index//(n*2))] if random.random()>.12 else random.randrange(len(rock))
    return o
def rounded_slab(name,p,width,depth,height,radius,m):
    # Horizontal arc corners, kept inside the original tested deck bounds.
    pts=[]
    for cx,cz,start in [(width/2-radius,depth/2-radius,0),(-width/2+radius,depth/2-radius,90),(-width/2+radius,-depth/2+radius,180),(width/2-radius,-depth/2+radius,270)]:
        for j in range(7):
            angle=math.radians(start+j*15)
            pts.append((cx+radius*math.cos(angle),cz+radius*math.sin(angle)))
    verts=[xyz((p[0]+x,p[1]+y,p[2]+z)) for y in [-height/2,height/2] for x,z in pts]
    n=len(pts); faces=[tuple(range(n,2*n)),tuple(reversed(range(n)))]
    faces += [(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
    mesh=bpy.data.meshes.new(name); mesh.from_pydata(verts,[],[tuple(reversed(f)) for f in faces]); mesh.materials.append(m); mesh.update()
    o=bpy.data.objects.new(name,mesh); bpy.context.collection.objects.link(o); return o
def boulder(p,s,m):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1,radius=1,location=xyz(p)); o=bpy.context.object; o.name='Weathered rock'
    o.scale=(s[0],s[2],s[1]); o.rotation_euler=(random.random(),random.random(),random.random()*6); o.data.materials.append(m)
def export(name,objects):
    bpy.ops.object.select_all(action='DESELECT')
    for o in objects:o.select_set(True)
    bpy.context.view_layer.objects.active=objects[0]
    bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',use_selection=True,export_yup=True)

# Four quarry shelves connected across excavated channels. The large cliff walls
# fold around the route; distinct industrial landmarks give each crossing a place.
box('Deep quarry basin',(0,-24.2,-112),(390,1,440),rock[3])
box('Flooded cut',(0,-23.58,-112),(135,.08,300),water)
for side in [-1,1]:
    for i,z in enumerate(range(32,-290,-28)):
        cliff('Outer quarry escarpment',side*random.uniform(69,86),z,random.uniform(21,31),23,random.uniform(13,33))
        cliff('Distant rim',side*random.uniform(110,138),z,35,34,random.uniform(30,58))
for z,depth in [(-17,50),(-90,24),(-150,24),(-218,40)]:
    # Exact shelf edge at bridge abutments, irregular vertical rock faces below.
    rounded_slab('Quarry shelf bed',(0,-12.2,z),52,depth,23.6,4,rock[1])
    for side in [-1,1]:
        cliff('Shelf rock buttress',side*25,z,8,depth*.46,-.4)
    rounded_slab('Road foundation',(0,-.6,z),52,depth,1.1,4,concrete)
    rounded_slab('Road surface',(0,-.075,z),51.8,depth-.1,.15,4,asphalt)
    for x in [-25.4,25.4]:
        for dz in range(-int(depth/2)+2,int(depth/2)-1,3):
            box('Curb edge',(x,.08,z+dz),(.5,.16,2.7),concrete,.04)
    # Road wear: discrete patches and tyre-darkened lanes, all flush.
    for i in range(9):
        x=random.uniform(-23,23); zz=z+random.uniform(-depth/2+1,depth/2-1)
        rounded_slab('Asphalt repair',(x,.009,zz),random.uniform(.4,1.4),random.uniform(.6,2),.008,.16,asphalt)
    for x in [-18,18]:
        for dz in range(-int(depth/2)+3,int(depth/2)-2,6):
            box('Lane dash',(x,.015,z+dz),(.18,.02,2.7),cream)
    for side in [-1,1]:
        for i in range(16):
            x=side*random.uniform(27,30); zz=z+random.uniform(-depth*.36,depth*.36)
            boulder((x,-.3,zz),(random.uniform(.3,.9),random.uniform(.3,.7),random.uniform(.3,.9)),random.choice(rock))
            for j in range(3):
                a=random.uniform(-.4,.4)
                beam('Scrub grass',(x,-.1,zz),(x+a,random.uniform(.25,.8),zz+random.uniform(-.4,.4)),.07,grass)
        for dz in [-7,0,7]:
            box('Concrete road barrier',(side*25.5,.75,z+dz),(.8,1.5,4),concrete,.12)
            box('Barrier warning panel',(side*25.05,.95,z+dz),(.03,.28,2.8),yellow)
    # Floodlights stand behind the collision barrier, away from the wheel path.
    for side in [-1,1]:
        x=side*28
        cylinder('Lamp mast',(x,5,z),.15,10,dark)
        beam('Lamp outreach',(x,9.8,z),(side*23,9.8,z),.18,dark)
        box('Lamp housing',(side*23,9.6,z),(1.8,.35,.75),teal,.1)
        box('Lamp glass',(side*23,9.39,z),(1.5,.04,.55),cream)

for i,(z,title) in enumerate([(-35,'01 / THE CUT'),(-95,'02 / PUMP WORKS'),(-155,'03 / HIGH QUARRY')]):
    # Signs sit on a physical overhead gantry, facing the approaching truck.
    for x in [-25,25]:beam('Route gantry leg',(x,0,z),(x,10,z),.4,teal)
    beam('Route gantry lintel',(-25,10,z),(25,10,z),.45,teal)
    box('Route sign',(0,9.6,z+.2),(18,2.6,.25),teal,.1)
    text('Route sign lettering',title,(0,9.1,z+.35),1.2,cream)
    for x,copy in [(-18,'LEFT'),(18,'RIGHT')]:
        box('Bridge direction sign',(x,8.9,z+.2),(7,1.5,.22),yellow,.07)
        text('Direction lettering',copy,(x,8.5,z+.34),.9,dark)

# Depot structures, locally made rather than downloaded scenery.
def shed(x,z,w,d,h):
    box('Maintenance building',(x,h/2,z),(w,h,d),teal,.15)
    box('Overhanging roof',(x,h+.15,z),(w+1,.3,d+1),dark,.05)
    for xx in [x-w*.27,x+w*.27]:
        box('Roller shutter',(xx,h*.35,z+d/2+.04),(w*.36,h*.66,.1),concrete)
        for y in range(1,int(h*.65)):box('Shutter slat',(xx,y,z+d/2+.12),(w*.36,.055,.035),dark)
    for xx in [x-w/2+.3,x+w/2-.3]:box('Building trim',(xx,h/2,z+d/2+.1),(.24,h,.18),cream)
    for j in range(int(w)):
        box('Roof rib',(x-w/2+j,h+.35,z),(.08,.1,d),concrete)
    cylinder('Vent',(x+w*.3,h+1,z),.55,1.5,dark)
shed(-38,2,18,12,8)
cliff('Depot ledge',-37,2,18,15,-.2)
text('Depot wall sign','RIFT / SALVAGE',(-38,6.9,8.15),1.1,cream)
cliff('Pump works ledge',38,-90,18,14,-.2)
shed(39,-95,17,12,6)
for x in [34,43]:
    cylinder('Pump tank',(x,7,-86),3,14,teal,24)
    for y in [1,5,9,13]:cylinder('Tank belt',(x,y,-86),3.08,.18,cream,24)
    beam('Tank outlet',(x,2,-83),(x,2,-76),.9,steel)
    beam('Down pipe',(x,2,-76),(x,-19,-76),.9,steel)
cliff('Crane ledge',-40,-150,18,14,-.2)
for x in [-44,-36]:
    for z in [-154,-146]:beam('Crane lattice leg',(x,0,z),(-40,24,-150),.55,steel)
for y in [5,10,15,20]:
    beam('Crane cross brace',(-44,y,-150),(-36,y+4,-150),.3,yellow)
beam('Crane jib',(-51,24,-150),(-5,24,-150),.65,yellow)
beam('Crane upper tie',(-40,29,-150),(-5,24,-150),.18,dark)
beam('Crane rear tie',(-40,29,-150),(-51,24,-150),.18,dark)
beam('Crane hoist',(-8,24,-150),(-8,12,-150),.07,dark)
box('Hanging crane hook',(-8,11.5,-150),(1,1.3,.3),steel,.2)
cliff('Exit works',0,-248,36,19,-.2)
shed(0,-250,36,15,12)
text('Exit building signage','SALVAGE / DISPATCH',(0,9,-242.35),1.6,cream)
for x in range(-11,12,2):box('Finish chequer',(x,.022,-214),(1,.025,1.2),cream)
for x in [-12,12]:
    cylinder('Finish pole',(x,5,-215),.13,10,teal)
box('Finish arch',(0,9.8,-215),(25,1.5,.3),teal)
text('Finish text','DISPATCH / EXIT',(0,9.35,-214.8),.95,cream)
environment=list(bpy.context.scene.objects)
export('environment',environment)

def bridge(broken):
    before=set(bpy.context.scene.objects)
    ranges=[(-18,-8),(8,18)] if broken else [(-18,18)]
    for a,b in ranges:
        box('Bridge wearing course',(0,-.15,(a+b)/2),(14,.3,b-a),asphalt)
        for x in [-6.75,6.75]:
            box('Bridge yellow edge',(x,.018,(a+b)/2),(.25,.03,b-a),yellow)
            box('Deep edge girder',(x,-1.1,(a+b)/2),(.4,1.8,b-a),steel)
        for z in range(a+1,b,3):
            box('Cross bearer',(0,-.65,z),(14.8,.5,.3),steel)
            box('Deck expansion seam',(0,.019,z),(13,.025,.07),dark)
            for x in [-6.7,6.7]:cylinder('Deck rivet',(x,.047,z),.09,.04,cream,8)
        for x in [-7.2,7.2]:
            for z in range(a,b,6):
                zz=min(z+6,b)
                beam('Underdeck truss diagonal',(x,-.4,z),(x,-4,zz),.24,steel)
                beam('Underdeck truss lower chord',(x,-4,z),(x,-4,zz),.28,steel)
                beam('Underdeck truss upright',(x,-.4,z),(x,-4,z),.22,steel)
    for z in [-17,17]:
        box('Concrete bridge abutment',(0,-2.3,z),(15,4,2),concrete,.15)
        for x in [-5,5]:box('Bridge pier',(x,-12,z),(1.7,21,2.2),concrete,.15)
    if broken:
        for x in [-6.5,6.5]:beam('Torn girder',(x,-1,-8),(x,-4,-4),.28,steel)
    return list(set(bpy.context.scene.objects)-before)
intact=bridge(False); export('bridge_intact',intact)
broken=bridge(True); export('bridge_broken',broken)
for o in broken:bpy.data.objects.remove(o,do_unlink=True)
# Assemble six instances in the editable source scene.
for side in [-1,1]:
    for z in [-60,-120,-180]:
        for src in intact:
            obj=src.copy(); obj.data=src.data; bpy.context.collection.objects.link(obj)
            obj.location+=Vector(xyz((side*18,0,z)))
for o in intact:bpy.data.objects.remove(o,do_unlink=True)
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source'/'quarry.blend'))

# Separate physical field manual, two bound page blocks and rounded cloth covers.
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
for side in [-1,1]:
    box('Cloth hard cover',(side*1.48,-.14,0),(2.94,.16,4.05),leather,.065)
    box('Bound paper block',(side*1.45,-.015,0),(2.78,.13,3.88),paper,.035)
    for y in [-.065,-.04,-.018]:
        box('Visible page edges',(side*1.45,y,1.945),(2.72,.007,.012),brass)
    for z in [-1.86,1.86]:box('Brass cover corner',(side*2.79,-.045,z),(.29,.04,.23),brass,.025)
cylinder('Rounded cloth spine',(0,-.12,0),.14,3.96,leather).rotation_euler[0]=math.pi/2
box('Binding crease',(0,.057,0),(.085,.016,3.87),brass,.012)
box('Ribbon bookmark',(.35,.065,1.95),(.15,.018,.72),teal)
export('field_book',list(bpy.context.scene.objects))
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'source'/'field_book.blend'))
