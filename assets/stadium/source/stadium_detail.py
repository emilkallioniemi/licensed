"""Original stadium supporting cast. Coordinates are Godot X/Y/-Z.

Crowd geometry is accumulated directly by material, avoiding thousands of
objects/draw calls. UV stores per-person animation phase and foot-anchored weight.
"""
import bpy
import math
import random
from mathutils import Vector


class CrowdBuilder:
    def __init__(self):
        self.geometry = {}
        self.origin = (0, 0, 0)
        self.angle = 0
        self.phase = 0
        self.size = 1

    def emit(self, verts, faces, material):
        vs, fs, uvs = self.geometry.setdefault(material, ([], [], []))
        start = len(vs)
        c, s = math.cos(self.angle), math.sin(self.angle)
        for x, y, z in verts:
            vs.append((self.origin[0] + self.size * (c*x+s*z),
                       self.origin[1] + self.size*y,
                       self.origin[2] + self.size * (-s*x+c*z)))
            uvs.append((self.phase, max(0, min(1, y/1.8))))
        fs.extend(tuple(start+i for i in f) for f in faces)

    def oval(self, p, scale, material, rings=4, sides=8):
        vs, fs = [], []
        for j in range(rings+1):
            v = math.pi*j/rings
            for i in range(sides):
                a = 2*math.pi*i/sides
                vs.append((p[0]+scale[0]*math.sin(v)*math.cos(a),
                           p[1]+scale[1]*math.cos(v),
                           p[2]+scale[2]*math.sin(v)*math.sin(a)))
        for j in range(rings):
            for i in range(sides):
                a=j*sides+i; b=j*sides+(i+1)%sides
                fs.append((a,b,b+sides,a+sides))
        self.emit(vs,fs,material)

    def limb(self, a, b, r1, r2, material, sides=8):
        a,b=Vector(a),Vector(b); direction=(b-a).normalized()
        u=direction.cross(Vector((0,0,1)))
        if u.length<.01: u=direction.cross(Vector((1,0,0)))
        u.normalize(); v=direction.cross(u)
        vs=[]
        for p,r in [(a,r1),(b,r2)]:
            for i in range(sides):
                t=i*2*math.pi/sides; vs.append(p+r*(u*math.cos(t)+v*math.sin(t)))
        fs=[tuple(range(sides-1,-1,-1)),tuple(range(sides,2*sides))]
        fs.extend((i,(i+1)%sides,(i+1)%sides+sides,i+sides) for i in range(sides))
        self.emit(vs,fs,material)

    def fan(self, p, angle, shirts, skins, dark, denim, hair, white, accent, index):
        self.origin=p; self.angle=angle; self.phase=random.random()*6.283
        self.size=random.uniform(.91,1.09)
        skin=random.choice(skins); shirt=random.choice(shirts); trousers=random.choice([dark,denim])
        coiffure=random.choice(hair); pose=index%6
        standing=pose in [0,1,4]; hip=.82 if standing else .43
        neck=hip+.57; head=neck+.23
        # Tapered jersey, rounded shoulders, collar and visible hem.
        self.limb((0,hip,0),(0,neck-.08,0),.20,.27,shirt)
        self.limb((0,hip-.025,0),(0,hip+.02,0),.205,.205,accent)
        self.limb((0,neck-.04,0),(0,neck+.06,0),.10,.10,skin)
        self.oval((0,head,0),(.16,.22,.155),skin)
        self.oval((0,head+.12,-.018),(.169,.12,.16),coiffure,3)
        for side in [-1,1]:
            self.oval((side*.156,head,0),(.036,.06,.039),skin,3,6)
            self.oval((side*.058,head+.025,.143),(.026,.023,.012),dark,3,6)
        self.oval((0,head-.025,.16),(.034,.047,.035),skin,3,6)
        self.limb((-.042,head-.09,.144),(.042,head-.09,.144),.009,.009,dark,6)
        # Baseball caps, long hair, and hearing protection make distinct silhouettes.
        if index%4==0:
            self.oval((0,head+.155,0),(.18,.105,.18),accent,3)
            self.oval((0,head+.13,.17),(.18,.018,.17),accent,2)
        elif index%4==1:
            self.oval((0,head-.07,-.12),(.18,.24,.095),coiffure)
        elif index%4==2:
            for side in [-1,1]:
                self.oval((side*.185,head,0),(.057,.105,.075),accent,3)
            self.limb((-.18,head+.14,0),(.18,head+.14,0),.025,.025,dark)
        for side in [-1,1]:
            knee=(side*.15,.40,.04) if standing else (side*.17,.41,.42)
            ankle=(side*.16,.10,.05) if standing else (side*.18,.10,.44)
            self.limb((side*.12,hip,0),knee,.115,.09,trousers)
            self.limb(knee,ankle,.09,.075,trousers)
            self.oval((ankle[0],.07,ankle[2]+.09),(.10,.075,.18),dark,3)
            self.limb((ankle[0]-.075,.035,ankle[2]+.19),(ankle[0]+.075,.035,ankle[2]+.19),.018,.018,white,6)
            shoulder=(side*.23,neck-.13,0)
            if pose==0: elbow=(side*.42,neck+.16,0); hand=(side*.39,neck+.49,.04)
            elif pose==1: elbow=(side*.40,neck,.04); hand=(side*.20,neck+.27,.23)
            elif pose==2: elbow=(side*.34,hip+.22,.18); hand=(side*.09,hip+.38,.38)
            elif pose==3: elbow=(side*.33,hip+.16,.13); hand=(side*.18,hip+.05,.44)
            elif pose==4 and side==1: elbow=(.42,neck+.05,0); hand=(.55,neck+.43,0)
            else: elbow=(side*.33,hip+.25,.04); hand=(side*.32,hip+.04,.10)
            self.oval(shoulder,(.13,.14,.13),shirt,3)
            self.limb(shoulder,elbow,.105,.075,shirt)
            self.limb(elbow,hand,.068,.049,skin)
            self.oval(hand,(.067,.08,.051),skin,3,6)
        # Jersey chest stripe, phone, or raised foam finger.
        self.limb((-.14,neck-.23,.215),(.14,neck-.23,.215),.028,.028,white,6)
        if pose==1:
            self.limb((-.10,neck+.26,.25),(.10,neck+.26,.25),.065,.065,dark,4)
        if pose==4:
            self.limb((.55,neck+.42,0),(.55,neck+.76,0),.09,.065,accent)

    def finish(self, mesh_function, prefix='Crowd_'):
        for material,(vs,fs,uvs) in self.geometry.items():
            o=mesh_function(prefix+material.name,vs,fs,material)
            uv=o.data.uv_layers.new(name='Fan motion')
            for polygon in o.data.polygons:
                polygon.use_smooth=True
                for loop in polygon.loop_indices: uv.data[loop].uv=uvs[o.data.loops[loop].vertex_index]


def build_wreck(api, variant=0, crushed=False):
    """Hand-shaped salvage sedan / estate / taxi, plus folded crush states."""
    box,beam,mesh,mat = [api[k] for k in ('box','beam','mesh','mat')]
    black,steel,silver,cream,glass = [api[k] for k in ('black','steel','silver','cream','glass')]
    paint=mat(['Salvage oxblood','Faded petrol estate','Taxi mustard'][variant],['A63E32','477D83','CD9E35'][variant],.25)
    rust=mat('Exposed rust','713F2B',.15); interior=mat('Torn charcoal upholstery','343C3D')
    primer=mat('Scraped primer','AAA897',.2); lens=mat('Cracked tail lens','9E3026',.1)
    rng=random.Random(135+variant)
    def wheel_cylinder(name,a,b,r,material):
        a=Vector((a[0],-a[2],a[1])); b=Vector((b[0],-b[2],b[1]))
        delta=b-a
        bpy.ops.mesh.primitive_cylinder_add(vertices=24,radius=r,depth=delta.length,location=(a+b)/2)
        o=bpy.context.object; o.name=name; o.rotation_euler=delta.to_track_quat('Z','Y').to_euler()
        o.data.materials.append(material)
        for polygon in o.data.polygons: polygon.use_smooth=len(polygon.vertices)==4
        bpy.context.view_layer.update()
        return o
    def panel(name,verts,faces,material=paint):
        if crushed:
            # Distinct folded shell: accordion hood/roof with displaced corners.
            verts=[(x*(1.03 if y>.5 else 1), .12+y*.22+(.035*math.sin(z*11+x*4) if y>.5 else 0), z) for x,y,z in verts]
        return mesh(name,verts,faces,material)
    def part(name,p,s,m,bevel=0):
        if crushed: p=(p[0],.12+p[1]*.22,p[2]); s=(s[0],max(.025,s[1]*.22),s[2])
        return box(name,p,s,m,bevel)
    def bar(name,a,b,r,m):
        if crushed: a=(a[0],.12+a[1]*.22,a[2]); b=(b[0],.12+b[1]*.22,b[2]); r*=.65
        return beam(name,a,b,r,m)
    part('Underbody chassis',(0,.23,0),(2.40,.18,4.48),steel,.06)
    # Side skins follow actual semicircular cut-outs around each wheel.
    for side in [-1,1]:
        outline=[(-2.36,.25)]
        for wheel_z in [-1.5,1.5]:
            for i in range(13):
                a=math.pi-i*math.pi/12
                outline.append((wheel_z+.53*math.cos(a),.34+.53*math.sin(a)))
        outline.append((2.36,.25))
        vs=[]
        for z,y in outline:
            dent=.09*math.sin(z*7+variant*2) if abs(z)<1 else 0
            vs.extend([(side*(1.29-dent),y,z),(side*(1.28-dent),.86-.045*math.cos(z*5),z)])
        panel('Dented wheel-arch quarter',vs,[(i,i+1,i+3,i+2) for i in range(0,len(vs)-2,2)])
        # Raised arch lip, panel seams, handles and scraped door sill.
        for wz in [-1.5,1.5]:
            for i in range(12):
                a=math.pi-i*math.pi/12; b=math.pi-(i+1)*math.pi/12
                bar('Scuffed arch lip',(side*1.30,.34+.53*math.sin(a),wz+.53*math.cos(a)),(side*1.30,.34+.53*math.sin(b),wz+.53*math.cos(b)),.025,primer)
        for z in [-.91,.16,.96]:bar('Door shut line',(side*1.295,.35,z),(side*1.28,.84,z),.012,black)
        for z in [-.10,.80]:part('Missing paint door handle',(side*1.305,.79,z),(.035,.045,.17),silver,.01)
        for i in range(7):
            z=rng.uniform(-.90,.88); y=rng.uniform(.38,.75)
            panel('Bare metal scrape',[(side*1.305,y,z),(side*1.309,y+.025,z+.28),(side*1.308,y+.05,z+.11)],[(0,1,2)],primer if i%2 else rust)
        bar('Rocker rail',(side*1.25,.29,-.93),(side*1.25,.29,.95),.055,rust)
    # Bowed hood and trunk: asymmetric rings produce creases in silhouette.
    for name,zs in [('Buckled bonnet',[-2.35,-1.91,-1.42,-1.05]),('Dented boot',[1.10,1.53,1.96,2.36])]:
        vs=[]
        for j,z in enumerate(zs):
            for i,x in enumerate([-1.27,-.65,0,.65,1.27]):
                y=.85+(.14 if j==1 else 0)*math.cos(x*2.3)+rng.uniform(-.055,.035)
                vs.append((x,y,z))
        panel(name,vs,[(j*5+i,j*5+i+1,(j+1)*5+i+1,(j+1)*5+i) for j in range(3) for i in range(4)])
    # Open cabin: sloped A/C pillars, no opaque window blocks hiding the seats.
    rear=1.58 if variant==1 else .91
    for side in [-1,1]:
        bar('A pillar',(side*1.18,.84,-1.10),(side*.98,1.46,-.57),.055,paint)
        bar('B pillar',(side*1.20,.84,.19),(side*1.00,1.48,.20),.045,paint)
        bar('C pillar',(side*1.20,.83,rear+.29),(side*.99,1.44,rear),.065,paint)
        bar('Window sill',(side*1.20,.86,-1.05),(side*1.20,.86,rear+.28),.033,silver)
        # Small jagged remnants of safety glass in otherwise open side windows.
        panel('Broken side glass',[(side*1.19,.89,-.99),(side*1.15,1.05,-.90),(side*1.19,.96,-.69),(side*1.19,.90,-.55)],[(0,1,2,3)],glass)
    roof=[]
    for j,z in enumerate([-.62,-.20,.34,rear]):
        for i,x in enumerate([-1.02,-.5,0,.5,1.02]):
            roof.append((x,1.47+.06*(1-abs(x))-(.19 if i==2 and j==2 else 0),z))
    panel('Caved roof',roof,[(j*5+i,j*5+i+1,(j+1)*5+i+1,(j+1)*5+i) for j in range(3) for i in range(4)])
    bar('Windshield header',(-.98,1.46,-.59),(.98,1.46,-.59),.04,paint)
    panel('Shattered windshield corner',[(-1.14,.87,-1.07),(-.97,1.41,-.61),(-.68,1.37,-.65),(-.78,1.12,-.88),(-.43,.93,-1.02)],[(0,1,2,3,4)],glass)
    for x in [-.58,.58]:
        part('Seat cushion',(x,.57,.07),(.68,.16,.65),interior,.07)
        seat=part('Torn seat back',(x,.90,.37),(.68,.57,.16),interior,.055)
        part('Headrest',(x,1.20,.39),(.35,.18,.13),interior,.04)
        part('Upholstery split',(x+.08,.95,.276),(.034,.22,.008),cream)
    part('Rear bench',(0,.70,.98),(1.8,.38,.38),interior,.07)
    part('Dashboard',(0,.90,-.81),(2.05,.16,.27),black,.03)
    for i in range(12):
        a=i*math.tau/12; b=(i+1)*math.tau/12
        bar('Steering wheel',(-.58+.20*math.cos(a),1.06+.18*math.sin(a),-.62),(-.58+.20*math.cos(b),1.06+.18*math.sin(b),-.62),.018,black)
    # Tires stay tires after crushing; the body folds around the running gear.
    for side in [-1,1]:
        for z in [-1.5,1.5]:
            cy=.34 if not crushed else .26
            wheel=wheel_cylinder('Flat salvage tire',(side*1.13,cy,z),(side*1.43,cy,z),.43,black)
            # Flatten lower sidewall and cant one damaged wheel.
            for v in wheel.data.vertices:
                world=wheel.matrix_world @ v.co
                if world.z<.04: world.z=.04; v.co=wheel.matrix_world.inverted() @ world
            wheel_cylinder('Steel wheel',(side*1.435,cy,z),(side*1.465,cy,z),.27,rust)
            wheel_cylinder('Rim dish',(side*1.468,cy,z),(side*1.48,cy,z),.19,silver)
            for i in range(6):
                a=i*math.tau/6
                beam('Rim ventilation',(side*1.482,cy+.20*math.sin(a),z+.20*math.cos(a)),(side*1.493,cy+.20*math.sin(a),z+.20*math.cos(a)),.04,black)
            for i in range(20):
                a=i*math.tau/20
                tread_y=max(.045,cy+.425*math.sin(a))
                beam('Tread notch',(side*1.17,tread_y,z+.425*math.cos(a)),(side*1.40,tread_y,z+.425*math.cos(a)),.014,steel)
    for z in [-2.38,2.38]:
        part('End fascia',(0,.57,z),(2.5,.43,.10),paint,.035)
        bar('Bent bumper',(-1.27,.36,z*1.025),(.2,.29,z*1.055),.085,silver)
        bar('Bent bumper',(.2,.29,z*1.055),(1.26,.43,z*1.02),.085,silver)
    part('Radiator opening',(0,.59,-2.44),(1.05,.23,.02),black)
    for x in [-.4,-.2,0,.2,.4]:part('Bent grille slat',(x,.59,-2.46),(.025,.18,.025),silver)
    for x in [-.93,.93]:
        part('Headlamp surround',(x,.65,-2.45),(.44,.25,.055),silver,.04)
        part('Cracked headlamp',(x,.65,-2.484),(.35,.18,.02),cream if x<0 else black,.025)
        part('Tail lamp',(x,.67,2.45),(.40,.18,.035),lens,.025)
    part('Empty rear plate',(0,.52,2.455),(.49,.15,.025),primer,.01)
    if variant==2:
        part('Taxi roof sign',(0,1.55,.18),(.58,.18,.25),cream,.025)
        for side in [-1,1]:
            for i in range(10):
                for row in range(2):
                    part('Checker livery',(side*1.30,.62+row*.07,-.76+i*.14),(.015,.065,.13),black if (row+i)%2 else cream)
