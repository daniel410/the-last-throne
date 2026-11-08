"""Run through Blender MCP. Author and export identical native head recipes.

Keeps the user's open scene intact; creates a separate scene and .blend copy.
Roblox Y-up positions are converted to Blender Z-up only for review.
"""
import bpy, json, math
from mathutils import Vector

ROOT = '/Users/daniel/Workspace/project/roblox/the-last-throne'
OUT = ROOT+'/assets/npcs/faces-v2'
# Catalog is injected by the MCP caller as CATALOG; no filesystem reads in safe mode.
catalog = CATALOG
scene = bpy.data.scenes.new('TLT_NPC_Faces_v2')
# TLT concept-color contract: explicit settings for every authoring/review scene.
scene.display_settings.display_device = 'sRGB'
scene.view_settings.view_transform = 'Standard'
scene.view_settings.look = 'None'
scene.view_settings.exposure = 0; scene.view_settings.gamma = 1
scene.view_settings.use_curve_mapping = False
bpy.context.window.scene = scene
atlas = bpy.data.images.load(OUT+'/face-atlas.png', check_existing=True)
atlas.pack()
materials = {}
recipes = {}
def material(tint_hex):
    if tint_hex in materials: return materials[tint_hex]
    m=bpy.data.materials.new('NPC_'+tint_hex);m.use_nodes=True
    rgb=[int(tint_hex[i:i+2],16)/255 for i in (0,2,4)]
    rgba=tuple(v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in rgb)+(1,)
    m.diffuse_color=rgba
    node=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
    node.inputs['Base Color'].default_value=rgba;node.inputs['Roughness'].default_value=.72
    materials[tint_hex]=m;return m

for index,c in enumerate(c for c in catalog if c['id']!='selene'):
    ident=c['id'];parts=[];recipes[ident]={'tile':index,'parts':parts}
    base=Vector(((index%5)*4.3,(index//5)*4.8,0))
    group=bpy.data.objects.new(ident,None);scene.collection.objects.link(group)
    def shape(name,size,pos,tint,roll=0,kind='sphere',export=True):
        if export: parts.append(dict(name=name,size=size,position=pos,color=tint,roll=roll,kind=kind))
        point=base+Vector((pos[0],pos[2],pos[1]))
        if kind=='sphere': bpy.ops.mesh.primitive_uv_sphere_add(segments=24,ring_count=16,location=point)
        else: bpy.ops.mesh.primitive_cube_add(size=1,location=point)
        ob=bpy.context.object;ob.name=ident+'_'+name;ob.parent=group
        ob.scale=Vector((size[0],size[2],size[1]))*(.5 if kind=='sphere' else 1)
        ob.rotation_euler[1]=-roll
        ob.data.materials.append(material(tint))
        if kind=='sphere':
            for p in ob.data.polygons:p.use_smooth=True
        return ob
    skin,hair=c['skin'],c['hair'];style=c['hairstyle']
    shape('Head',[1.72,1.93,1.30],[0,5.18,0],skin)
    for side in (-1,1):
        pointed=c['race'] in ('elf','goblin','spirit')
        shape('Ear',[.62 if pointed else .25,.30 if pointed else .40,.27],[side*(.95 if pointed else .83),5.18,.03],skin,side*.35)
        if pointed:shape('InnerEar',[.39,.15,.08],[side*.99,5.18,-.13],c['accent'],side*.35)
    if style=='bald':
        for side in (-1,1):shape('TempleHair',[.20,.57,.73],[side*.79,5.55,.12],hair)
    else:
        shape('HairBack',[1.82,1.48,1.29],[0,5.52,.24],hair)
        shape('HairCrown',[1.83,.63,1.34],[0,5.99,.06],hair,-.09)
        # Swept tapered locks follow the crown rather than covering the eyes.
        for i in range(3):
            shape('SweptLock',[.88,.32,.48],[-.51+i*.48,6.0-i*.055,-.49],hair,-.30+i*.06)
        if style in ('bob','curly','tousled','swept','short','goggles','crown'):
            length=1.22 if style in ('bob','crown') else .66
            for side in (-1,1):
                shape('TempleLock',[.30,length,.74],[side*.79,5.59-length*.24,.05],hair,side*.13)
            if style in ('curly','tousled','goggles'):
                for i in range(7):
                    a=i*math.tau/7;shape('Curl',[.48,.38,.48],[math.cos(a)*.68,6.10+math.sin(a)*.10,math.sin(a)*.40],hair,i*.18)
        if style in ('braid','ponytail'):
            if style=='ponytail':shape('Ponytail',[.65,1.55,.60],[.65,5.45,.55],hair,-.32)
            else:
                for i in range(6):
                    shape('Braid',[.32-i*.023,.38,.35],[.76+(.06 if i%2 else -.06),5.50-i*.25,.16],hair,(-1 if i%2 else 1)*.32)
                shape('BraidTie',[.29,.12,.33],[.76,4.18,.16],c['accent'])
    if style=='beard' or ident in ('oren','fen','garrick','orik','rowan'):
        for i in range(5):
            x=(i-2)*.23
            shape('BeardLock',[.35,.72-.16*abs(i-2),.31],[x,4.60+.04*abs(i-2),-.48],hair,x*.4)
        for side in (-1,1):shape('Mustache',[.44,.16,.13],[side*.26,4.94,-.74],hair,side*-.16)
    if style in ('hat','hardhat'):
        shape('HatCrown',[1.96,.64,1.50],[0,6.16,.05],c['accent'] if style=='hardhat' else c['coat'])
        shape('HatBrim',[2.35,.13,1.85],[0,5.94,-.06],c['accent'] if style=='hardhat' else c['coat'],kind='block')
    if style=='goggles':
        for side in (-1,1):
            shape('GoggleRim',[.59,.47,.17],[side*.36,6.09,-.63],c['accent'])
            shape('GoggleLens',[.40,.29,.09],[side*.36,6.09,-.73],'69A9B0')
    if style=='crown':
        for side in (-1,1):
            shape('Branch',[.12,1.1,.12],[side*.78,6.16,.18],c['accent'],side*.35,kind='block')
            for i in range(3):shape('Leaf',[.22,.32,.10],[side*(.76+i*.07),6.1+i*.22,.09],'B8E4C7',side*.55)
    # Block body review; runtime preserves its existing full outfit and props.
    shape('Torso',[2.05,2.05,1.12],[0,3.12,0],c['coat'],kind='block',export=False)
    for side in (-1,1):
        shape('Arm',[.75,1.94,.98],[side*1.43,3.13,0],c['coat'],kind='block',export=False)
        shape('Hand',[.65,.52,.72],[side*1.49,1.94,-.06],skin,kind='block',export=False)
        shape('Leg',[.92,1.72,1],[side*.55,1.4,0],'3E3C40',kind='block',export=False)
        shape('Boot',[1.02,.55,1.22],[side*.55,.3,-.12],'423D3C',kind='block',export=False)
    # Front plane, regular atlas UV, straight alpha. Same dimensions as SurfaceGui.
    verts=[(-.86,-.673,4.25),(.86,-.673,4.25),(.86,-.673,6.11),(-.86,-.673,6.11)]
    mesh=bpy.data.meshes.new(ident+'_Decal');mesh.from_pydata([base+Vector(v) for v in verts],[],[(0,1,2,3)])
    uv=mesh.uv_layers.new();col=index%5;row=index//5
    for loop,coord in zip(uv.data,[(0,0),(1,0),(1,1),(0,1)]):loop.uv=((col+coord[0])/5,1-(row+1-coord[1])/6)
    ob=bpy.data.objects.new(ident+'_FaceDecal',mesh);scene.collection.objects.link(ob);ob.parent=group
    mat=bpy.data.materials.new(ident+'_Face');mat.use_nodes=True
    nodes=mat.node_tree.nodes;nodes.clear();tex=nodes.new('ShaderNodeTexImage');tex.image=atlas;tex.interpolation='Linear'
    bsdf=nodes.new('ShaderNodeBsdfPrincipled');bsdf.inputs['Roughness'].default_value=.85
    mat.node_tree.links.new(tex.outputs['Color'],bsdf.inputs['Base Color']);mat.node_tree.links.new(tex.outputs['Alpha'],bsdf.inputs['Alpha'])
    output=nodes.new('ShaderNodeOutputMaterial');mat.node_tree.links.new(bsdf.outputs[0],output.inputs[0]);ob.data.materials.append(mat)
    mat.surface_render_method='DITHERED'

data={'version':2,'atlas':'rbxassetid://119430151832611','atlasSize':[1145,1374],'tileSize':229,'characters':recipes}
scene['head_recipes_json']=json.dumps(data)
scene.world=bpy.data.worlds.new('NPC_Review_World');scene.world.color=(.35,.35,.35)
def light(name,loc,power,size):
    d=bpy.data.lights.new(name,'AREA');d.energy=power;d.shape='DISK';d.size=size
    ob=bpy.data.objects.new(name,d);scene.collection.objects.link(ob);ob.location=loc;ob.rotation_euler=(Vector((8,0,4))-ob.location).to_track_quat('-Z','Y').to_euler()
light('Key',(1,-8,12),1800,12);light('Fill',(14,-5,8),1300,10)
camdata=bpy.data.cameras.new('NPC_Review');cam=bpy.data.objects.new('NPC_Review',camdata);scene.collection.objects.link(cam)
cam.location=(8.6,-23,9);cam.rotation_euler=(Vector((8.6,0,3.3))-cam.location).to_track_quat('-Z','Y').to_euler();camdata.type='ORTHO';camdata.ortho_scale=22;scene.camera=cam
scene.render.engine='BLENDER_EEVEE';scene.render.resolution_x=1600;scene.render.resolution_y=700;scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG';scene.render.filepath=ROOT+'/docs/evidence/npc-faces-v2/blender-lineup.png'
scene.view_settings.view_transform='Standard'
bpy.ops.wm.save_as_mainfile(filepath=OUT+'/npc-heads-v2.blend',copy=True,compress=True)
print('Authored',len(recipes),'heads; exported recipes and packed atlas; previous scene preserved')
