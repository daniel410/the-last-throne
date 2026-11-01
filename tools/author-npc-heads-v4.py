"""Blender MCP safe-mode authoring. Inject CATALOG, PROFILES and FACE_IDS.

Per-character tapered curve frames replace generic hair rolls. Accessory
triangles and the same smooth hair segments are reconstructed in Roblox.
Native part count and device performance retain separate acceptance gates.
"""
import bpy,math,json
from mathutils import Vector,Matrix

ROOT='/Users/daniel/Workspace/project/roblox/the-last-throne'
scene=bpy.data.scenes.new('TLT_NPC_Heads_v4');bpy.context.window.scene=scene
materials={};recipes={};loft_meshes={}
hair_image=bpy.data.images.load(ROOT+'/assets/npcs/heads-v4/hair-fibers.png',check_existing=True);hair_image.pack()
def shade(tint,amount):
    return ''.join(format(max(0,min(255,round(int(tint[i:i+2],16)*amount))),'02X') for i in (0,2,4))
def material(tint):
    if tint in materials:return materials[tint]
    m=bpy.data.materials.new('NPCv4_'+tint);m.use_nodes=True
    rgb=[int(tint[i:i+2],16)/255 for i in (0,2,4)]
    rgba=tuple(v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in rgb)+(1,)
    node=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
    node.inputs['Base Color'].default_value=rgba;node.inputs['Roughness'].default_value=.84;m.diffuse_color=rgba
    materials[tint]=m;return m

for index,c in enumerate(c for c in CATALOG if c['id']!='selene'):
    ident=c['id'];profile=PROFILES[ident];style=profile['style'];hair=c['hair'];skin=c['skin'];accent=c['accent']
    parts=[];meshes=[];recipe={'tile':index,'face':FACE_IDS[ident],'parts':parts,'meshes':meshes,'profile':profile};recipes[ident]=recipe
    base=Vector(((index%5)*4.3,(index//5)*4.8,0));group=bpy.data.objects.new(ident+'_v4',None);scene.collection.objects.link(group);recipe['group']=group.name
    width=profile['width'];height=profile['height'];cy=4.98;top=cy+height*.5
    def primitive(name,size,pos,tint,roll=0):
        parts.append(dict(name=name,size=size,position=pos,color=tint,roll=roll,kind='sphere'))
        bpy.ops.mesh.primitive_uv_sphere_add(segments=32,ring_count=24,location=base+Vector((pos[0],pos[2],pos[1])))
        ob=bpy.context.object;ob.name=ident+'_v4_'+name;ob.parent=group;ob.scale=(size[0]/2,size[2]/2,size[1]/2);ob.rotation_euler[1]=-roll;ob.data.materials.append(material(tint))
        for poly in ob.data.polygons:poly.use_smooth=True
        if name in ('HairFoundation','BeardFoundation','JawBeard'):
            parts[-1]['surface']='hair'
            mat=material(tint).copy();mat.name=ident+'_'+name+'_Fibers';nodes=mat.node_tree.nodes
            node=next(n for n in nodes if n.type=='BSDF_PRINCIPLED');tex=nodes.new('ShaderNodeTexImage');tex.image=hair_image
            mix=nodes.new('ShaderNodeMixRGB');mix.blend_type='MULTIPLY';mix.inputs[0].default_value=.45;mix.inputs[1].default_value=node.inputs['Base Color'].default_value
            mat.node_tree.links.new(tex.outputs['Color'],mix.inputs[2]);mat.node_tree.links.new(mix.outputs[0],node.inputs['Base Color'])
            ob.data.materials.append(mat)
            for poly in ob.data.polygons:
                if sum(ob.data.vertices[v].co.y for v in poly.vertices)<0:poly.material_index=1
        return ob
    def mesh(name,verts,faces,tint,tones=None):
        # All export coordinates are Roblox Y-up. Triangles are the authority.
        record={'name':name,'vertices':[[round(v,5) for v in p] for p in verts],'triangles':faces,'color':tint}
        if tones:record['tones']=tones
        meshes.append(record)
        data=bpy.data.meshes.new(ident+'_'+name);data.from_pydata([base+Vector((p[0],p[2],p[1])) for p in verts],[],faces)
        ob=bpy.data.objects.new(ident+'_v4_'+name,data);scene.collection.objects.link(ob);ob.parent=group
        data.materials.append(material(tint))
        # Flat faces match the native triangle export; no smoother-only preview.
        if tones:
            for tone in sorted(set(tones)):data.materials.append(material(shade(tint,tone)))
            ordered=sorted(set(tones))
            for poly,tone in zip(data.polygons,tones):poly.material_index=1+ordered.index(tone)
        return ob
    def loft(name,points,radius,tint,depth=.55,steps=3,sides=4,end=.025):
        # Overlapping tapered ellipsoids follow the authored cubic curve.
        # Their exact frames are exported; preview and native use the same skin.
        controls=[Vector(p) for p in points]
        count=max(4,steps+1)
        samples=[]
        for j in range(count+1):
            t=j/count;u=1-t
            p=controls[0]*(u*u*u)+controls[1]*(3*u*u*t)+controls[2]*(3*u*t*t)+controls[3]*(t*t*t)
            r=radius*(.75+.35*math.sin(math.pi*t))*(1-t)+end*t
            samples.append((p,r))
        for j in range(count):
            a,ra=samples[j];b,rb=samples[j+1];tangent=(b-a).normalized()
            ref=Vector((0,0,1)) if abs(tangent.z)<.90 else Vector((1,0,0))
            right=tangent.cross(ref).normalized();back=right.cross(tangent).normalized()
            center=(a+b)*.5;r=(ra+rb)*.5
            size=[r*2,(b-a).length+r*3.70,r*2*depth]
            basis=Matrix(((right.x,tangent.x,back.x),(right.y,tangent.y,back.y),(right.z,tangent.z,back.z)))
            frame=[round(v,7) for row in basis for v in row]
            parts.append(dict(name=name,size=[round(v,6) for v in size],position=[round(v,6) for v in center],color=tint,roll=0,kind='sphere',frame=frame))
            if tint not in loft_meshes:
                bpy.ops.mesh.primitive_uv_sphere_add(segments=16,ring_count=10)
                ob=bpy.context.object;ob.data.materials.append(material(tint));loft_meshes[tint]=ob.data
                for poly in ob.data.polygons:poly.use_smooth=True
            else:
                ob=bpy.data.objects.new(ident+'_v4_'+name,loft_meshes[tint]);scene.collection.objects.link(ob)
            ob.name=ident+'_v4_'+name;ob.parent=group
            conversion=Matrix(((1,0,0,0),(0,0,1,0),(0,1,0,0),(0,0,0,1)))
            native=Matrix.Translation(center)@basis.to_4x4()@Matrix.Diagonal(Vector((size[0]/2,size[1]/2,size[2]/2,1)))
            ob.matrix_world=Matrix.Translation(base)@conversion@native
    skull=primitive('Head',[width,height,1.40],[0,cy,0],skin)
    face_path=ROOT+'/assets/npcs/heads-v4/'+ident+'-face.png' if ident in ('rowan','rook') else ROOT+'/assets/npcs/faces-v3/'+ident+'.png'
    image=bpy.data.images.load(face_path,check_existing=True);image.pack()
    mat=material(skin).copy();mat.name=ident+'_v4_Face';nodes=mat.node_tree.nodes;node=next(n for n in nodes if n.type=='BSDF_PRINCIPLED')
    tex=nodes.new('ShaderNodeTexImage');tex.image=image;tex.extension='CLIP';mix=nodes.new('ShaderNodeMixRGB');mix.inputs[1].default_value=node.inputs['Base Color'].default_value
    mat.node_tree.links.new(tex.outputs['Color'],mix.inputs[2]);mat.node_tree.links.new(tex.outputs['Alpha'],mix.inputs[0]);mat.node_tree.links.new(mix.outputs[0],node.inputs['Base Color']);skull.data.materials.append(mat)
    uv=skull.data.uv_layers.active
    for poly in skull.data.polygons:
        poly.material_index=1 if sum(skull.data.vertices[v].co.y for v in poly.vertices)<0 else 0
        for loop_id in poly.loop_indices:
            co=skull.data.vertices[skull.data.loops[loop_id].vertex_index].co;uv.data[loop_id].uv=((co.x+1)/2,(co.z+1)/2)
    ear=profile.get('ear',0)
    for side in (-1,1):
        if ear:
            # Sculpted pointed ear: rounded root, raised tip and recessed inner face.
            x=side*(width*.45);tip=x+side*ear
            verts=[[x,5.29,-.03],[x,4.88,-.03],[tip,5.40,.08],[x+side*.19,5.10,-.18],[x,5.12,.20]]
            mesh('PointedEar',verts,[[0,1,3],[0,3,2],[3,1,2],[0,2,4],[2,1,4],[1,0,4]],skin)
            mesh('InnerEar',[[x+side*.05,5.22,-.12],[x+side*.10,4.98,-.12],[tip-side*.13,5.34,.035]],[[0,1,2]],shade(skin,.80))
        else:primitive('Ear',[.23,.35,.29],[side*width*.49,5.02,.06],skin,side*.12)
    # Scalp mesh follows an asymmetric hairline instead of a flat cap.
    if style not in ('bald','bare','receding','hat','hardhat'):
        primitive('HairFoundation',[width*1.03,1.30,1.22],[0,top-.40,.30],hair)
        sweep=profile.get('sweep',-1);part=profile.get('part',.2)*-sweep
        for i in range(3):
            start=part+i*.12*sweep
            lift=.09*i+(.12 if style in ('swept','messy','curly') else 0)
            endx=sweep*(width*.49+.035*i)
            loft('SweptForelock',[[start,top+.10,.02+i*.09],[start+sweep*.35,top+.36+lift,-.22],[endx,top+.04,-.63],[endx,5.38+i*.09,-.24]],.28-i*.025,hair,depth=.74)
        if style in ('messy','curly'):
            for i in range(4):
                x=-.65+i*.42;dx=(-1 if i%2 else 1)*.22
                loft('LooseCrownCurl',[[x,top+.04,.16],[x+dx,top+.48,.02],[x-dx,top+.34,-.42],[x+dx*.5,top-.12,-.55]],.20,hair,depth=.90)
    if style in ('bald','receding','hat','hardhat'):
        for side in (-1,1):
            for i in range(2 if style=='receding' else 1):
                loft('TempleWisps',[[side*width*.40,5.45,.31],[side*width*.55,5.58+i*.12,.21],[side*width*.56,5.20,.10],[side*width*.48,4.99,.21]],.12,hair,depth=.7)
    if style in ('bob','long','layered'):
        length=profile.get('length',1.2)
        for side in (-1,1):
            for j in range(3):
                z=-.02+j*.34;x=side*(width*.44+.03*j);endY=top-length-.14*j
                if style=='bob':
                    joint=[side*(width*.50+.06),top-.68,z+.03]
                    loft('WavyLayer',[[x*.65,top+.03,z],[side*(width*.58+.15),top-.10,z-.12],[side*(width*.62+.13),top-.49,z+.02],joint],.24,hair,depth=.82,end=.16)
                    loft('WavyLayer',[joint,[side*(width*.37+.04),top-.87,z+.03],[side*(width*.44+.08),endY-.12,z+.12],[side*(width*.60+.05),endY+.08,z+.08]],.21,hair,depth=.78,end=.025)
                else:
                    loft('WavyLayer',[[x*.65,top+.03,z],[x+side*.28,top-.22,z-.18],[x+side*.12,endY+.33,z+.16],[side*width*.57 if style=='long' and j<2 else x-side*.03,endY,-.48 if style=='long' and j<2 else z+.02]],.23 if style!='long' else .27,hair,depth=.78,end=.02)
        if style=='long':
            for j in range(3):
                x=(j-1)*.48;loft('LongBackWave',[[x,top,.54],[x+.22,top-.6,.98],[x-.2,3.8,.88],[x+.12,top-length,.63]],.33,hair,depth=.75)
    def braid(name,side,length,beard=False,offset=0):
        start=4.35 if beard else 5.10
        center=side*.33 if beard else side*(width*.40+.05)
        z=-.91 if beard else -.35
        for strand in range(3):
            points=[];steps=6
            for j in range(steps+1):
                t=j/steps;a=t*math.tau*1.50+strand*math.tau/3;radius=.105*(1-.50*t)
                depth=z if beard else -.35-.45*min(1,t*2)
                points.append(Vector((center+math.sin(a)*radius,start-length*t,depth+math.cos(a)*radius)))
            for j in range(steps):
                a=points[j];b=points[j+1];delta=b-a
                loft(name,[list(a),list(a+delta*.33),list(a+delta*.67),list(b)],.09*(1-.40*j/steps),hair,depth=.85,steps=1,end=.07*(1-.40*j/steps))
        primitive('BraidTie',[.25,.12,.30],[center,start-length+.04,z],'CBA45D')
    if style in ('braid','twin_braid'):
        braid('FrontBraid',-1,profile['length']-.4)
        if style=='twin_braid':braid('FrontBraid',1,profile['length']-.4)
    if style in ('pony','bun','curly_bun'):
        centerX=.36 if style=='pony' else -.18
        if style=='pony':
            loft('HighPonytail',[[centerX,top+.20,.56],[1.18,top+.38,.73],[1.02,4.7,.76],[.85,4.24,.69]],.34,hair,depth=.90,steps=4)
            primitive('PonyTie',[.30,.22,.31],[centerX,top+.18,.56],accent)
        else:
            for j in range(4):
                a=j*math.tau/4
                loft('BunCurl',[[centerX,top+.03,.43],[centerX+math.sin(a)*.48,top+.60,.44+math.cos(a)*.30],[centerX-math.sin(a)*.42,top+.65,.65-math.cos(a)*.30],[centerX,top+.20,.70]],.25,hair,depth=.85,steps=3)
        for side in (-1,1):
            loft('TempleCurl',[[side*width*.43,top-.06,-.25],[side*width*.64,5.4,-.39],[side*width*.43,5.05,-.30],[side*width*.53,4.77,-.12]],.10,hair,depth=.9,steps=3)
    beard=profile.get('beard',0)
    if beard:
        if beard>.25:
            primitive('BeardFoundation',[width*.82,beard*.78+.22,.86],[0,4.43-beard*.38,-.38],hair)
            if beard>.80:
                primitive('BeardFoundation',[width*.48,beard*.45,.65],[0,4.47-beard*.77,-.32],hair)
            for side in (-1,1):
                primitive('BeardFoundation',[.55,.85,.70],[side*width*.30,4.55,-.20],hair,side*-.14)
                primitive('Mustache',[.65,.13,.22],[side*.24,4.73,-.65],hair,side*-.10)
        else:
            tint=''.join(format(round(int(hair[i:i+2],16)*.38+int(skin[i:i+2],16)*.62),'02X') for i in (0,2,4))
            # Short beard is painted in the face decal, with no protruding jaw bar.
            pass
        if profile.get('braidedBeard'):
            for side in (-1,1):braid('BeardPlait',side,.70,True)
    if style in ('hat','hardhat'):
        verts=[];faces=[];segments=16
        if style=='hat':rings=[(1.34,.92,top+.02),(1.36,.94,top+.10),(.82,.66,top+.13),(.75,.61,top+.91),(.68,.57,top+1.0)]
        else:rings=[(1.03,.83,top-.05),(1.04,.84,top+.03),(.95,.77,top+.12),(.70,.57,top+.44),(.18,.18,top+.57)]
        for rx,rz,y in rings:
            for k in range(segments):
                a=k*math.tau/segments;verts.append([math.sin(a)*rx,y-.26+.035*math.cos(a*2),math.cos(a)*rz])
        for j in range(len(rings)-1):
            for k in range(segments):
                a=j*segments+k;b=j*segments+(k+1)%segments;d=a+segments;e=b+segments;faces.extend([[a,b,e],[a,e,d]])
        center=len(verts);verts.append([0,rings[-1][2]-.26,0])
        for k in range(segments):faces.append([center,(len(rings)-1)*segments+k,(len(rings)-1)*segments+(k+1)%segments])
        mesh('TallHat' if style=='hat' else 'SafetyHelmet',verts,faces,c['coat'] if style=='hat' else 'C48A32')
        if style=='hardhat':primitive('HelmetLamp',[.39,.43,.22],[0,top+.02,-.81],'F9DEA3')
    if profile.get('goggles'):
        for side in (-1,1):
            primitive('GoggleRim',[.61,.47,.21],[side*.37,top+.15,-.55],accent)
            primitive('GoggleLens',[.43,.29,.10],[side*.37,top+.15,-.68],'5D8790')
    if profile.get('earrings'):
        for side in (-1,1):
            verts=[];faces=[];segments=10
            for j in range(segments):
                a=j*math.tau/segments
                for radius in (.135,.095):verts.append([side*width*.54+math.cos(a)*radius,4.82+math.sin(a)*radius,-.10])
            for j in range(segments):
                a=j*2;b=((j+1)%segments)*2;faces.extend([[a,b,b+1],[a,b+1,a+1]])
            mesh('GoldHoop',verts,faces,'CBA45D')
    if profile.get('crown'):
        for side in (-1,1):
            loft('CrownBranch',[[side*.62,top-.03,.20],[side*.9,top+.25,.17],[side*.74,top+.59,.31],[side*1.03,top+.86,.28]],.055,'826950',depth=1,steps=3)
            loft('CrownFork',[[side*.83,top+.3,.22],[side*1.1,top+.40,.22],[side*1.20,top+.53,.19],[side*1.16,top+.66,.16]],.035,'826950',depth=1,steps=2)
            for j in range(3):primitive('CrownLeaf',[.14,.27,.07],[side*(.88+j*.10),top+.36+j*.20,.12],'BDE4CC',side*.5)
    if profile.get('circlet'):
        for side in (-1,1):
            loft('Circlet',[[0,top-.18,-.66],[side*.35,top-.14,-.64],[side*.65,top-.17,-.39],[side*.79,top-.26,-.12]],.025,'CBA45D',depth=1,steps=3)
            for j in range(3):primitive('CircletLeaf',[.10,.23,.05],[side*(.30+j*.15),top-.10+j*.02,-.58+j*.07],'CBA45D',side*.6)
    # Fixed block shoulders are review-only, excluded from head recipes.
    for name,size,pos,tint in [('Torso',[2.05,2.05,1.12],[0,3.12,0],c['coat']),('Collar',[1.2,.32,1.19],[0,4.07,-.02],accent)]:
        bpy.ops.mesh.primitive_cube_add(size=1,location=base+Vector((pos[0],pos[2],pos[1])));ob=bpy.context.object;ob.name=ident+'_v4_'+name;ob.parent=group;ob.scale=(size[0],size[2],size[1]);ob.data.materials.append(material(tint))
    recipe['triangles']=sum(len(m['triangles']) for m in meshes)
data={'version':4,'characters':recipes,'projection':'individual Decal on native round head','geometry':'authored tapered curve spheres and small accessory triangle surfaces','hairSurface':'rbxassetid://100424123930098'}
scene['head_recipes_json']=json.dumps(data)
scene.world=bpy.data.worlds.new('NPC_v4_World');scene.world.color=(.24,.24,.24);scene.render.engine='BLENDER_EEVEE';scene.view_settings.view_transform='Standard'
bpy.ops.wm.save_as_mainfile(filepath=ROOT+'/assets/npcs/heads-v4/npc-heads-v4.blend',copy=True,compress=True)
print('Authored',len(recipes),'concept profiles; triangles',sum(r['triangles'] for r in recipes.values()),'maximum',max(r['triangles'] for r in recipes.values()))
