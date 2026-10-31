import bpy,json,math
from mathutils import Vector
s=bpy.context.scene;actions=json.loads(s['v2_actions']);out={}
for k in ['Goblin','Orc','Ogre','Shaman','Warlord','GoblinKing','KingOgre','KingShaman']:
 for c in ['body','weapon','off','rightLeg','leftLeg']:
  o=bpy.data.objects[k+('_Body' if c=='body' else '_'+c)];o.animation_data.action=None;o.rotation_euler=(0,0,0)
  if c=='body':o.location=(0,0,0)
bpy.context.view_layer.update()
for k in ['Goblin','Orc','Ogre','Shaman','Warlord','GoblinKing','KingOgre','KingShaman']:
 mesh=bpy.data.objects[k+'_ArmR'];root=bpy.data.objects[k+'_Root'];pts=[(v,root.matrix_world.inverted()@mesh.matrix_world@v.co) for v in mesh.data.vertices]
 axis=1 if k=='Goblin' else 2
 def score(p):return p[1][axis]
 pts=sorted(pts,key=score,reverse=True);selected=pts[:max(8,len(pts)//40)]
 tip=sum((p[0].co for p in selected),Vector())/len(selected)
 mins=Vector([min(v.co[i] for v in mesh.data.vertices) for i in range(3)]);maxs=Vector([max(v.co[i] for v in mesh.data.vertices) for i in range(3)]);extent=maxs-mins;center=(maxs+mins)*.5
 # Native Roblox mesh import bakes Y180 into vertex coordinates.
 local=(tip-center);normal=Vector((-local.x/extent.x,local.z/extent.z,local.y/extent.y))
 base=normal.copy()
 if k=='Goblin':base.z+=.22
 else:base.y-=.16
 out[k]={'tip':[round(v,7) for v in normal],'base':[round(v,7) for v in base],'caster':k in ['Shaman','KingShaman']}
 marker=bpy.data.objects.new(k+'_WeaponTipSocket',None);s.collection.objects.link(marker);marker.parent=mesh;marker.location=tip;marker.empty_display_size=.025;marker.empty_display_type='SPHERE'
for k in ['Goblin','Orc','Ogre','Shaman','Warlord','GoblinKing','KingOgre','KingShaman']:
 for c,a in actions[k+'|Attack'].items():bpy.data.objects[k+('_Body' if c=='body' else '_'+c)].animation_data.action=bpy.data.actions[a]
s.frame_set(0)
print('SOCKETS:'+json.dumps(out,separators=(',',':')))
