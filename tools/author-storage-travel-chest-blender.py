import bpy,json,math
from pathlib import Path
from mathutils import Vector
root=str(Path(__file__).resolve().parents[1]/'assets/models/storage-travel-chest-v1')
data=json.loads((Path(root)/'geometry.json').read_text())
scene=bpy.data.scenes.new('TLT_TravelStorageChest_v1')
scene.world=bpy.data.worlds.new('TravelChestStudio');scene.world.use_nodes=True
bg=next(n for n in scene.world.node_tree.nodes if n.type=='BACKGROUND');bg.inputs['Color'].default_value=(.30,.34,.40,1);bg.inputs['Strength'].default_value=.4
parent=bpy.data.objects.new('TLT_TravelStorageChest_v1',None);scene.collection.objects.link(parent)
materials={}
def material(p):
 key=(p['material'],tuple(p['color']))
 if key in materials:return materials[key]
 m=bpy.data.materials.new('Chest_'+p['material']+'_'+'_'.join(map(str,p['color'])));m.use_nodes=True
 bs=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
 color=tuple((v/255)**1.6 for v in p['color']);bs.inputs['Base Color'].default_value=(*color,1)
 bs.inputs['Metallic'].default_value=.72 if p['material']=='Metal' else 0
 bs.inputs['Roughness'].default_value=.78 if p['material']=='Wood' else .65
 if p['material']=='Wood':
  ns=m.node_tree.nodes;links=m.node_tree.links
  coord=ns.new('ShaderNodeTexCoord');mapping=ns.new('ShaderNodeVectorMath');mapping.operation='MULTIPLY';mapping.inputs[1].default_value=(1,32,14);links.new(coord.outputs['Generated'],mapping.inputs[0])
  noise=ns.new('ShaderNodeTexNoise');noise.inputs['Scale'].default_value=4;noise.inputs['Detail'].default_value=2;links.new(mapping.outputs['Vector'],noise.inputs['Vector'])
  ramp=ns.new('ShaderNodeValToRGB');ramp.color_ramp.elements[0].color=(*(c*.55 for c in color),1);ramp.color_ramp.elements[1].color=(*(min(1,c*1.5) for c in color),1);links.new(noise.outputs['Fac'],ramp.inputs['Fac']);links.new(ramp.outputs['Color'],bs.inputs['Base Color'])
  bump=ns.new('ShaderNodeBump');bump.inputs['Strength'].default_value=.18;bump.inputs['Distance'].default_value=.025;links.new(noise.outputs['Fac'],bump.inputs['Height']);links.new(bump.outputs['Normal'],bs.inputs['Normal'])
 materials[key]=m;return m
for i,p in enumerate(data['parts']):
 if p['shape']=='Ball':
  verts=[];faces=[];rings=5;segments=8
  for j in range(rings+1):
   phi=math.pi*j/rings
   for k in range(segments):
    theta=math.tau*k/segments;verts.append((math.sin(phi)*math.cos(theta)/2,math.cos(phi)/2,math.sin(phi)*math.sin(theta)/2))
  for j in range(rings):
   for k in range(segments):a=j*segments+k;b=j*segments+(k+1)%segments;faces.append((a,b,b+segments,a+segments))
 else:
  verts=[(-.5,-.5,-.5),(.5,-.5,-.5),(.5,.5,-.5),(-.5,.5,-.5),(-.5,-.5,.5),(.5,-.5,.5),(.5,.5,.5),(-.5,.5,.5)]
  faces=[(0,3,2,1),(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)]
 points=[];a=p['angle'];c,s=math.cos(a),math.sin(a)
 for v in verts:
  x,y,z=[v[d]*p['size'][d] for d in range(3)];x,y=x*c-y*s,x*s+y*c
  x+=p['position'][0];y+=p['position'][1];z+=p['position'][2];points.append((x,-z,y))
 mesh=bpy.data.meshes.new(p['name']+'_Geometry');mesh.from_pydata(points,[],faces);mesh.update()
 obj=bpy.data.objects.new(f"{p['name']}_{i:03d}",mesh);scene.collection.objects.link(obj);obj.parent=parent;obj.data.materials.append(material(p))
 obj['RobloxMaterial']=p['material'];obj['RobloxCollision']=p['solid']
 # The source bevel is a render aid; native Roblox uses the preserved boxes.
 if p['shape']=='Block' and min(p['size'])>.09:
  mod=obj.modifiers.new('SmallWornEdges','BEVEL');mod.width=.022;mod.segments=1
camdata=bpy.data.cameras.new('TravelChestCamera');cam=bpy.data.objects.new('TravelChestCamera',camdata);scene.collection.objects.link(cam);cam.location=(8,-10,6.5);cam.rotation_euler=(Vector((0,0,1.55))-cam.location).to_track_quat('-Z','Y').to_euler();camdata.type='ORTHO';camdata.ortho_scale=8.8;scene.camera=cam
for name,at,power,size in [('ChestKey',(-4,-5,8),1100,5),('ChestFill',(5,-2,5),700,4),('ChestRim',(0,4,6),1000,3)]:
 d=bpy.data.lights.new(name,'AREA');o=bpy.data.objects.new(name,d);scene.collection.objects.link(o);o.location=at;o.rotation_euler=(Vector((0,0,1.5))-o.location).to_track_quat('-Z','Y').to_euler();d.energy=power;d.shape='DISK';d.size=size
scene.render.resolution_x=1200;scene.render.resolution_y=900;scene.render.resolution_percentage=100
try:scene.render.engine='BLENDER_EEVEE'
except TypeError:pass
scene.render.film_transparent=True;scene.render.image_settings.file_format='PNG';scene.render.filepath=root+'/preview.png'
previous_scene=bpy.context.window.scene
bpy.context.window.scene=scene
try:
 bpy.ops.export_scene.gltf(filepath=root+'/travel-storage-chest.glb',export_format='GLB',use_active_scene=True,export_cameras=False,export_lights=False,export_apply=True)
finally:
 bpy.context.window.scene=previous_scene
bpy.ops.render.render(write_still=True,scene=scene.name)
print(json.dumps({'scene':scene.name,'parts':len(data['parts']),'blend':root+'/travel-storage-chest.glb','preview':root+'/preview.png'}))

