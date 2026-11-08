"""After authoring and socket creation, assemble a seven-clip NLA review reel.

Run through Blender MCP; save the resulting .blend through MCP separately.
"""
import bpy
import json

scene=bpy.context.scene
# TLT concept-color contract: explicit settings for every authoring/review scene.
scene.display_settings.display_device = 'sRGB'
scene.view_settings.view_transform = 'Standard'
scene.view_settings.look = 'None'
scene.view_settings.exposure = 0; scene.view_settings.gamma = 1
scene.view_settings.use_curve_mapping = False
actions=json.loads(scene['v2_actions'])
clips=['Idle','Walk','Attack','AttackAlt','Heavy','HeavyAlt','Stunned']
for kind in ['Goblin','Orc','Ogre','Shaman','Warlord','GoblinKing','KingOgre','EnragedWarlord','KingShaman','Slime']:
    for channel in ['body','weapon','off','rightLeg','leftLeg']:
        obj=bpy.data.objects[kind+('_Body' if channel=='body' else '_'+channel)]
        obj.animation_data.action=None
        for track in list(obj.animation_data.nla_tracks):obj.animation_data.nla_tracks.remove(track)
        track=obj.animation_data.nla_tracks.new()
        track.name='Deepwood v2 Review'
        for index,clip in enumerate(clips):
            track.strips.new(clip,index*140,bpy.data.actions[actions[kind+'|'+clip][channel]])
for marker in list(scene.timeline_markers):scene.timeline_markers.remove(marker)
for index,clip in enumerate(clips):
    scene.timeline_markers.new(clip,frame=index*140)
    if clip in ['Attack','AttackAlt','Heavy','HeavyAlt']:
        scene.timeline_markers.new(clip+' CONTACT',frame=index*140+74)
scene.frame_start=0
scene.frame_end=960
scene.frame_set(354)
for obj in scene.objects:obj.hide_set(not obj.name.startswith('Goblin_'))
keep=set(name for group in actions.values() for name in group.values())
for action in list(bpy.data.actions):
    if action.name not in keep:action.use_fake_user=False
bpy.ops.outliner.orphans_purge(do_recursive=True)
print('Review reel prepared: Idle0 Walk140 Attack280 AttackAlt420 Heavy560 HeavyAlt700 Stunned840')
