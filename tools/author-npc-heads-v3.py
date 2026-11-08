"""Blender MCP safe-mode source; caller injects CATALOG and FACE_IDS.

Review every NPC without overlapping rows. Decal UVs are projected onto the
head itself: no floating front plane. Scene property contains export data.
"""
import bpy, json, math
from mathutils import Vector

ROOT='/Users/daniel/Workspace/project/roblox/the-last-throne'
scene=bpy.data.scenes.new('TLT_NPC_Heads_v3');bpy.context.window.scene=scene
# TLT concept-color contract: explicit settings for every authoring/review scene.
scene.display_settings.display_device = 'sRGB'
scene.view_settings.view_transform = 'Standard'
scene.view_settings.look = 'None'
scene.view_settings.exposure = 0; scene.view_settings.gamma = 1
scene.view_settings.use_curve_mapping = False
materials={};recipes={}
def material(tint):
    if tint in materials:return materials[tint]
    m=bpy.data.materials.new('NPCv3_'+tint);m.use_nodes=True
    rgb=[int(tint[i:i+2],16)/255 for i in (0,2,4)]
    rgba=tuple(v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in rgb)+(1,)
    node=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
    node.inputs['Base Color'].default_value=rgba;node.inputs['Roughness'].default_value=.85;m.diffuse_color=rgba
    materials[tint]=m;return m

for index,c in enumerate(c for c in CATALOG if c['id']!='selene'):
    ident=c['id'];parts=[];recipes[ident]={'tile':index,'face':FACE_IDS[ident],'parts':parts}
    base=Vector(((index%5)*4.3,(index//5)*4.8,0))
    group=bpy.data.objects.new(ident+'_v3',None);scene.collection.objects.link(group)
    def shape(name,size,pos,tint,roll=0,kind='sphere'):
        # Shorter head restores a visible collar instead of a long bare chin.
        size=[size[0]*.95,size[1]*.86,size[2]]
        pos=[pos[0]*.95,4.98+(pos[1]-5.18)*.86,pos[2]]
        parts.append(dict(name=name,size=size,position=pos,color=tint,roll=roll,kind=kind))
        if kind=='sphere':bpy.ops.mesh.primitive_uv_sphere_add(segments=32,ring_count=24,location=base+Vector((pos[0],pos[2],pos[1])))
        else:bpy.ops.mesh.primitive_cube_add(size=1,location=base+Vector((pos[0],pos[2],pos[1])))
        ob=bpy.context.object;ob.name=ident+'_v3_'+name;ob.parent=group
        ob.scale=Vector((size[0],size[2],size[1]))*(.5 if kind=='sphere' else 1)
        ob.rotation_euler[1]=-roll;ob.data.materials.append(material(tint))
        if kind=='sphere':
            for poly in ob.data.polygons:poly.use_smooth=True
        return ob
    skin,hair,accent=c['skin'],c['hair'],c['accent'];style=c['hairstyle']
    skull=shape('Head',[1.72,1.93,1.38],[0,5.18,0],skin)
    # Reuse the uploaded individual face. Project onto curved front vertices;
    # mix transparent texels with skin instead of drawing an offset mask.
    image=bpy.data.images.load(ROOT+'/assets/npcs/faces-v3/'+ident+'.png',check_existing=True);image.pack()
    mat=material(skin).copy();mat.name=ident+'_CurvedFace'
    nodes=mat.node_tree.nodes;node=next(n for n in nodes if n.type=='BSDF_PRINCIPLED')
    tex=nodes.new('ShaderNodeTexImage');tex.image=image;tex.extension='CLIP'
    mix=nodes.new('ShaderNodeMixRGB');mix.inputs[1].default_value=node.inputs['Base Color'].default_value
    mat.node_tree.links.new(tex.outputs['Color'],mix.inputs[2]);mat.node_tree.links.new(tex.outputs['Alpha'],mix.inputs[0]);mat.node_tree.links.new(mix.outputs[0],node.inputs['Base Color'])
    skull.data.materials.append(mat)
    uv=skull.data.uv_layers.active
    for poly in skull.data.polygons:
        front=sum(skull.data.vertices[v].co.y for v in poly.vertices)<0
        poly.material_index=1 if front else 0
        for loop_id in poly.loop_indices:
            co=skull.data.vertices[skull.data.loops[loop_id].vertex_index].co
            uv.data[loop_id].uv=((co.x+1)/2,(co.z+1)/2)
    for side in (-1,1):
        pointed=c['race'] in ('elf','goblin','spirit')
        shape('Ear',[.58 if pointed else .23,.23 if pointed else .38,.29],[side*(.97 if pointed else .82),5.19,.05],skin,side*.48)
        if pointed:shape('InnerEar',[.35,.10,.08],[side*1.0,5.19,-.10],skin,side*.48)
    if style=='bald':
        # Follow the temples; no circular pads above the ears.
        for side in (-1,1):shape('TempleHair',[.13,.50,.22],[side*.79,5.47,.35],hair,side*.10)
    else:
        shape('HairBack',[1.80,1.42,1.26],[0,5.61,.30],hair)
        shape('HairCrown',[1.80,.59,1.39],[0,5.99,.12],hair,-.08)
        # One continuous sweep and a tapered end replace three sausage rolls.
        shape('SideSweep',[1.45,.30,.58],[-.14,5.99,-.42],hair,-.14)
        shape('SweepTip',[.68,.27,.46],[.53,5.89,-.47],hair,.22)
        if style in ('bob','swept','short','tousled','curly','goggles','crown'):
            bob=style=='bob' or ident in ('maeve','suri','ketta')
            for side in (-1,1):
                shape('SideLock',[.37,1.36 if bob else .65,.84],[side*.77,5.21 if bob else 5.62,.10],hair,side*-.09)
                if bob:shape('BobTip',[.48,.51,.66],[side*.72,4.76,.22],hair,side*-.30)
            if style in ('curly','tousled','goggles'):
                # Larger integrated waves, confined behind the fringe.
                for side in (-1,1):shape('CrownWave',[.75,.46,.83],[side*.46,6.12,.30],hair,side*.25)
                if ident=='dagna':shape('HairBun',[.94,.83,.83],[-.32,6.20,.60],hair)
        if style in ('braid','ponytail'):
            if style=='ponytail':
                shape('PonyTie',[.31,.23,.35],[.55,5.98,.60],accent)
                shape('Ponytail',[.64,1.57,.69],[.72,5.50,.68],hair,-.28)
                shape('PonyTip',[.39,.76,.43],[.94,4.66,.67],hair,-.26)
            else:
                # Overlapping braid lobes form a continuous rope.
                for i in range(6):
                    shape('Braid',[.29-i*.019,.46,.34],[.76+(.035 if i%2 else -.035),5.40-i*.24,-.02],hair,(-1 if i%2 else 1)*.24)
                shape('BraidTie',[.24,.12,.32],[.76,4.03,-.02],accent)
    if style=='beard' or ident in ('oren','fen','garrick','orik'):
        long=style=='beard'
        shape('BeardMass',[1.34,.85 if long else .48,.69],[0,4.43 if long else 4.56,-.22],hair)
        if long:shape('BeardTip',[.83,.74,.58],[0,4.03,-.17],hair)
        for side in (-1,1):
            shape('BeardSide',[.27,.72,.46],[side*.62,4.83,-.15],hair,side*.20)
            shape('Mustache',[.58,.14,.21],[side*.25,4.94,-.63],hair,side*-.12)
        if ident in ('aldric','brann','haldor'):
            for side in (-1,1):shape('BeardTie',[.24,.13,.33],[side*.30,4.11,-.40],accent)
    if ident=='rowan':
        # Short jaw beard; never the elderly/dwarf hanging beard.
        shape('JawBeard',[1.15,.27,.65],[0,4.42,-.10],hair)
        for side in (-1,1):shape('Sideburn',[.16,.61,.40],[side*.68,4.83,.03],hair,side*.24)
    if style in ('hat','hardhat'):
        shape('HatCrown',[1.98,.76,1.60],[0,6.12,.12],accent if style=='hardhat' else c['coat'])
        shape('HatBrim',[2.34,.11,1.92],[0,5.88,-.06],accent if style=='hardhat' else c['coat'])
        if style=='hardhat':shape('HelmetLamp',[.35,.38,.21],[0,6.12,-.72],'F6D18D')
    if style=='goggles':
        for side in (-1,1):
            shape('GoggleRim',[.59,.45,.19],[side*.36,6.08,-.58],accent)
            shape('GoggleLens',[.41,.29,.10],[side*.36,6.08,-.70],'527D83')
    if style=='crown':
        for side in (-1,1):
            shape('Branch',[.09,1.04,.09],[side*.75,6.16,.30],accent,side*.30,kind='block')
            for i in range(3):shape('Leaf',[.18,.28,.08],[side*(.74+i*.06),6.12+i*.19,.22],'B8E4C7',side*.60)
    # Plain shoulders locate the face relative to the unchanged block body.
    for name,size,pos,tint in [('Torso',[2.05,2.05,1.12],[0,3.12,0],c['coat']),('Collar',[1.2,.32,1.19],[0,4.07,-.02],accent)]:
        bpy.ops.mesh.primitive_cube_add(size=1,location=base+Vector((pos[0],pos[2],pos[1])));ob=bpy.context.object;ob.name=ident+'_v3_'+name;ob.parent=group;ob.scale=(size[0],size[2],size[1]);ob.data.materials.append(material(tint))
data={'version':3,'characters':recipes,'projection':'Decal on Head sphere; no SurfaceGui carrier'}
scene['head_recipes_json']=json.dumps(data)
scene.world=bpy.data.worlds.new('NPC_v3_World');scene.world.color=(.24,.24,.24)
scene.render.engine='BLENDER_EEVEE';scene.view_settings.view_transform='Standard'
bpy.ops.wm.save_as_mainfile(filepath=ROOT+'/assets/npcs/faces-v3/npc-heads-v3.blend',copy=True,compress=True)
print('Created v3 surface decals, shorter heads and continuous hair/beard masses')
