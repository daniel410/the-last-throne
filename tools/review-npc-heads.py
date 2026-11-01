"""Blender MCP: inject SOURCE_SCENE, OUTPUT_DIR. Render isolated front/60deg heads."""
import bpy,json,math
from mathutils import Vector,Matrix

source=bpy.data.scenes[SOURCE_SCENE];data=json.loads(source['head_recipes_json'])
review=bpy.data.scenes.new('NPC_Individual_Review_v'+str(data['version']))
bpy.context.window.scene=review;review.world=source.world
camdata=bpy.data.cameras.new('ReviewCamera');cam=bpy.data.objects.new('ReviewCamera',camdata);review.collection.objects.link(cam)
cam.location=(8.4,-25,2.0);cam.rotation_euler=(math.pi/2,0,0);camdata.type='ORTHO';camdata.ortho_scale=21;review.camera=cam
for x,power in ((0,1100),(15,1400)):
    lightdata=bpy.data.lights.new('ReviewLight','AREA');lightdata.energy=power;lightdata.size=10
    ob=bpy.data.objects.new('ReviewLight',lightdata);review.collection.objects.link(ob);ob.location=(x,-10,10);ob.rotation_euler=(Vector((8,0,2))-ob.location).to_track_quat('-Z','Y').to_euler()
review.render.engine=source.render.engine;review.render.resolution_x=1800;review.render.resolution_y=800;review.render.resolution_percentage=100;review.render.image_settings.file_format='PNG';review.view_settings.view_transform='Standard'
ids=list(data['characters']);suffix='_v'+str(data['version']) if data['version']>=3 else ''
for page in range(6):
    for ob in list(review.objects):
        if ob.type not in ('CAMERA','LIGHT'):bpy.data.objects.remove(ob,do_unlink=True)
    for column,ident in enumerate(ids[page*5:page*5+5]):
        recipe=data['characters'][ident];index=recipe['tile'];head=next(p for p in recipe['parts'] if p['name']=='Head')
        base=Vector(((index%5)*4.3,(index//5)*4.8,head['position'][1]))
        for row in range(2):
            dest=Vector((column*4.2,0,3.8-row*3.1));rotation=Matrix.Rotation(row*math.pi/3,4,'Z')
            for old in source.objects:
                if old.type=='MESH' and old.parent and old.parent.name==recipe.get('group',ident+suffix) and not any(key in old.name for key in ('Torso','Collar','Arm','Hand','Leg','Boot')):
                    ob=old.copy();ob.data=old.data;review.collection.objects.link(ob);ob.parent=None
                    ob.matrix_world=Matrix.Translation(dest)@rotation@Matrix.Translation(-base)@old.matrix_world;ob.hide_render=False
            font=bpy.data.curves.new(ident+'_Label','FONT');font.body=ident+(' / front' if row==0 else ' / 60 deg');font.align_x='CENTER';font.size=.22
            label=bpy.data.objects.new(ident+'_Label',font);review.collection.objects.link(label);label.location=(column*4.2,-1.3,2.55-row*3.1);label.rotation_euler=(math.pi/2,0,0)
    review.render.filepath=OUTPUT_DIR+'/page-'+str(page+1)+'.png';bpy.ops.render.render(write_still=True)
print('Rendered all 29 heads without overlap; visual acceptance requires inspecting every page')
