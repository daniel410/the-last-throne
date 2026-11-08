"""Blender MCP: SOURCE_SCENE, OUTPUT_DIR and REVIEW_IDS injected. One NPC per image."""
import bpy,math,json
from mathutils import Vector,Matrix
source=bpy.data.scenes[SOURCE_SCENE];data=json.loads(source['head_recipes_json'])
review=bpy.data.scenes.new('NPC_Concept_Portraits_v4');bpy.context.window.scene=review;review.world=source.world
# TLT concept-color contract: explicit settings for every authoring/review scene.
review.display_settings.display_device = 'sRGB'
review.view_settings.view_transform = 'Standard'
review.view_settings.look = 'None'
review.view_settings.exposure = 0; review.view_settings.gamma = 1
review.view_settings.use_curve_mapping = False
camera_data=bpy.data.cameras.new('PortraitCamera');camera=bpy.data.objects.new('PortraitCamera',camera_data);review.collection.objects.link(camera)
camera.location=(0,-25,4.95);camera.rotation_euler=(math.pi/2,0,0);camera_data.type='ORTHO';camera_data.ortho_scale=7.3;review.camera=camera
for x,power in ((-4,850),(4,1100)):
    light_data=bpy.data.lights.new('PortraitLight','AREA');light_data.energy=power;light_data.size=7
    light=bpy.data.objects.new('PortraitLight',light_data);review.collection.objects.link(light);light.location=(x,-7,9);light.rotation_euler=(Vector((0,0,4.8))-light.location).to_track_quat('-Z','Y').to_euler()
review.render.engine=source.render.engine;review.render.resolution_x=1280;review.render.resolution_y=800;review.render.resolution_percentage=100
review.render.image_settings.file_format='PNG';review.view_settings.view_transform='Standard'
for ident,recipe in data['characters'].items():
    if ident not in REVIEW_IDS:continue
    for ob in list(review.objects):
        if ob.type not in ('CAMERA','LIGHT'):bpy.data.objects.remove(ob,do_unlink=True)
    index=recipe['tile'];head=next(p for p in recipe['parts'] if p['name']=='Head');base=Vector(((index%5)*4.3,(index//5)*4.8,head['position'][1]))
    group=bpy.data.objects[recipe['group']]
    for view in range(2):
        dest=Vector((-1.8+view*3.6,0,head['position'][1]));rotation=Matrix.Rotation(view*math.pi/3,4,'Z')
        for old in group.children:
            if old.type=='MESH':
                ob=old.copy();ob.data=old.data;review.collection.objects.link(ob);ob.parent=None
                ob.matrix_world=Matrix.Translation(dest)@rotation@Matrix.Translation(-base)@old.matrix_world;ob.hide_render=False
        font=bpy.data.curves.new('Label','FONT');font.body=ident+(' / front' if view==0 else ' / 60 deg');font.align_x='CENTER';font.size=.19
        label=bpy.data.objects.new('Label',font);review.collection.objects.link(label);label.location=(-1.8+view*3.6,-1.2,2.93);label.rotation_euler=(math.pi/2,0,0)
    review.render.filepath=OUTPUT_DIR+'/'+ident+'.png';bpy.ops.render.render(write_still=True)
print('Rendered',len(REVIEW_IDS),'individual front/side portraits with collar and full hair length')
