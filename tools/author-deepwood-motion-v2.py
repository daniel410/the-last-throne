"""Run this source through Blender MCP in the v1 monster source scene.

Native custom-property curves are the export authority. Preview transforms use
the same Rx*Ry*Rz order as Roblox CFrame.Angles, conjugated into Blender Z-up.
No TD geometry, textures, server timings or gameplay values are changed.
"""
import bpy
import math
import json
from mathutils import Matrix, Vector

scene = bpy.context.scene
assert scene.name in ['TLT_Monster_Motion_Authoring','TLT_Deepwood_Monsters_v2']
scene.frame_set(0)
channels = ['body', 'weapon', 'off', 'rightLeg', 'leftLeg']
kinds = ['Goblin', 'Orc', 'Ogre', 'Shaman', 'Warlord', 'GoblinKing', 'KingOgre', 'EnragedWarlord', 'KingShaman', 'Slime']
profiles = {
    # stride, breath, weight, idle guard, windup, contact, follow-through
    'Goblin': (.43, 1.8, .7, [12,-5,-9], [102,-24,-30], [12,30,26], [-30,40,35]),
    'Orc': (.48, 2.3, 1.0, [4,0,-5], [112,-16,-19], [-52,18,12], [-82,25,18]),
    'Ogre': (.54, 3.0, 1.6, [0,0,-3], [86,-9,-16], [-62,10,9], [-84,15,17]),
    'Shaman': (.39, 2.6, .65, [-3,0,-4], [16,-18,-10], [-22,9,4], [-30,12,6]),
    'Warlord': (.51, 2.5, 1.25, [8,-5,-8], [98,-26,-25], [-58,28,20], [-83,38,27]),
    'GoblinKing': (.42, 2.2, .9, [5,-4,-7], [76,-32,-22], [-56,31,18], [-78,40,23]),
    'KingOgre': (.56, 3.3, 1.85, [0,-2,-4], [88,-14,-19], [-63,14,14], [-88,21,21]),
    'EnragedWarlord': (.51, 1.9, 1.6, [0,0,0], [0,0,0], [0,0,0], [0,0,0]),
    'KingShaman': (.4, 2.9, .85, [-4,-3,-5], [20,-22,-14], [-28,13,7], [-38,17,9]),
    'Slime': (.37, 1.65, .5, [0,0,0], [0,0,0], [0,0,0], [0,0,0]),
}
B = Matrix(((1,0,0),(0,0,-1),(0,1,0)))
shoulders = {'Goblin':(.34,.15), 'Orc':(.34,.16), 'Ogre':(.39,.18), 'Shaman':(.36,.2), 'Warlord':(.4,.2), 'GoblinKing':(.35,.16), 'KingOgre':(.4,.18), 'KingShaman':(.38,.17)}
# A mesh bound includes the weapon head. It is not an anatomical shoulder.
# Reset existing animation before moving the pivot; preserve every mesh's rest
# world matrix so the source silhouette and grip cannot change.
for kind in kinds:
    for c in channels:
        obj=bpy.data.objects[kind+('_Body' if c=='body' else '_'+c)]
        obj.animation_data_clear();obj.rotation_euler=(0,0,0);obj.scale=(1,1,1)
        if c=='body':obj.location=(0,0,0)
bpy.context.view_layer.update()
for kind,(x,z) in shoulders.items():
    for c,side in [('weapon',-1),('off',1)]:
        obj=bpy.data.objects[kind+'_'+c]
        children=[(child,child.matrix_world.copy()) for child in obj.children]
        obj.location=(x*side,0,z)
        bpy.context.view_layer.update()
        for child,world in children:child.matrix_world=world
        bpy.context.view_layer.update()
rest_locations = {k: {c: bpy.data.objects[k + ('_Body' if c == 'body' else '_' + c)].location.copy() for c in channels} for k in kinds}
actions = {}
result = {'version':2, 'fps':120, 'impactPhase':.62, 'samples':201, 'channels':channels, 'models':{}}

def body(x=0,y=0,z=0,pitch=0,yaw=0,roll=0,sx=1,sy=1,sz=1):
    return [x,y,z,pitch,yaw,roll,sx,sy,sz]

def pose(b=None,w=None,o=None,r=None,l=None):
    return {'body': b or body(), 'weapon':w or [0,0,0], 'off':o or [0,0,0], 'rightLeg':r or [0,0,0], 'leftLeg':l or [0,0,0]}

def action_curves(action):
    return [f for layer in action.layers for strip in layer.strips for bag in strip.channelbags for f in bag.fcurves]

def author(kind, clip, keys):
    objects = {c:bpy.data.objects[kind + ('_Body' if c=='body' else '_'+c)] for c in channels}
    clip_actions = {}
    for c,obj in objects.items():
        obj.animation_data_create()
        action = bpy.data.actions.new(kind + '_v2_' + clip + '_' + c)
        action.use_fake_user = True
        obj.animation_data.action = action
        for phase,p in keys:
            for i,value in enumerate(p[c]):
                obj['native'+str(i)] = float(value)
                obj.keyframe_insert(data_path='["native'+str(i)+'"]', frame=phase*120, group='Runtime')
        curves = action_curves(action)
        for f in curves:
            for point in f.keyframe_points:
                point.interpolation = 'BEZIER'
                point.handle_left_type = 'AUTO_CLAMPED'
                point.handle_right_type = 'AUTO_CLAMPED'
        native = {int(f.data_path.split('native')[1].split('"')[0]): f for f in curves}
        values = [[round(native[i].evaluate(t*.6),7) for i in range(len(keys[0][1][c]))] for t in range(201)]
        result['models'][kind]['clips'].setdefault(clip,{})[c] = values
        # Preview rotations match runtime, including noncommuting axes.
        for t,v in enumerate(values):
            angles = v[3:6] if c=='body' else v
            R = Matrix.Rotation(math.radians(angles[0]),3,'X') @ Matrix.Rotation(math.radians(angles[1]),3,'Y') @ Matrix.Rotation(math.radians(angles[2]),3,'Z')
            obj.rotation_mode = 'XYZ'
            obj.rotation_euler = (B @ R @ B.transposed()).to_euler('XYZ')
            obj.keyframe_insert(data_path='rotation_euler', frame=t*.6, group='Preview')
            if c=='body':
                obj.location = B @ Vector(v[:3])
                obj.scale = (v[6],v[8],v[7])
                obj.keyframe_insert(data_path='location', frame=t*.6, group='Preview')
                obj.keyframe_insert(data_path='scale', frame=t*.6, group='Preview')
            else:
                obj.location = rest_locations[kind][c]
        # Linear baked preview: no second Bezier interpolation over samples.
        for f in action_curves(action):
            if not f.data_path.startswith('["native'):
                for point in f.keyframe_points: point.interpolation = 'LINEAR'
        clip_actions[c] = action.name
    actions[kind+'|'+clip] = clip_actions

for index,kind in enumerate(kinds):
    stride,breath,weight,guard,wind,contact,follow = profiles[kind]
    has_legs = kind in ['Goblin','Orc','Ogre','Warlord']
    caster = kind in ['Shaman','KingShaman']
    mono = kind == 'EnragedWarlord'
    m = {'stride':stride,'breathSeconds':breath,'hasLegs':has_legs,'clips':{},'controllers':{c:kind+('_Body' if c=='body' else '_'+c) for c in channels},'style':['skirmisher','axe_brute','club_colossus','ritual_caster','disciplined_crusher','royal_scepter','royal_colossus','armored_body_slam','royal_ritual','elastic_pounce'][index]}
    if kind in shoulders:
        x,z=shoulders[kind];m['shoulders']={'weapon':[x,.5+z,0],'off':[-x,.5+z,0]}
    result['models'][kind] = m
    idle=[];walk=[];stun=[]
    for j in range(17):
        t=j/16;sn=math.sin(t*math.tau);cs=math.cos(t*math.tau);double=math.cos(t*math.tau*2)
        idle.append((t,pose(body(y=.0025*sn,pitch=-1.5+sn*.6,yaw=sn*.7,roll=cs*.5),[guard[0]+sn*1.6,guard[1],guard[2]], [7-sn,1,5])))
        amp=17 if kind=='Goblin' else 12 if weight>1.2 else 14
        bob=.005*(1-double);sway=.005*sn*weight
        walk.append((t,pose(body(x=sway,y=bob,pitch=-3.5/weight,yaw=-sn*2.3,roll=sn*1.8*weight),[guard[0]-sn*amp*.32,guard[1],guard[2]+cs*1.5], [7+sn*amp*.65,0,6], [sn*amp,0,cs*.8],[-sn*amp,0,-cs*.8])))
        stun.append((t,pose(body(x=.004*sn,y=-.012,pitch=-7+sn*1.4,yaw=cs*1.5,roll=sn*2.2),[22+sn*3,4,-12],[18-sn*2,-3,12],[-3,0,0],[3,0,0])))
    if mono:
        # Entire armored body is one existing mesh: sell weight via recoil and yaw.
        walk=[(t,pose(body(x=.007*math.sin(t*math.tau),pitch=-2,yaw=math.sin(t*math.tau)*3.5,roll=math.sin(t*math.tau)*3))) for t,_ in walk]
    if kind=='Slime':
        idle=[];walk=[];stun=[]
        for j in range(17):
            t=j/16;sn=math.sin(t*math.tau);cs=math.cos(t*math.tau)
            sy=1+sn*.045;side=1/math.sqrt(sy)
            idle.append((t,pose(body(sx=side,sy=sy,sz=side))))
            sy=1+sn*.2;side=1/math.sqrt(sy)
            walk.append((t,pose(body(y=max(0,sn)*.06,pitch=-sn*4,sx=side,sy=sy,sz=side))))
            stun.append((t,pose(body(x=sn*.004,roll=sn*2,sx=1.1,sy=.82,sz=1.1))))
    author(kind,'Idle',idle);author(kind,'Walk',walk);author(kind,'Stunned',stun)
    for heavy in [False,True]:
        for alt in [False,True]:
            clip=('Heavy' if heavy else 'Attack')+('Alt' if alt else '')
            strength=1.22 if heavy else 1
            twist=(-1 if alt else 1)*(18 if kind=='Goblin' else 12 if caster else 10)*strength
            ready=pose(body(pitch=-1.5),guard,[7,1,5])
            w=list(wind);hit=list(contact);end=list(follow)
            if heavy:
                w=[min(132,w[0]+17),w[1]*.6,w[2]*.7]
                hit=[hit[0]-(12 if kind!='Goblin' else 18),hit[1]*.7,hit[2]*.7]
                end=[max(-108,end[0]-12),end[1]*.65,end[2]*.65]
            if alt:
                w[1]*=-.8;w[2]*=-.7;hit[1]*=-.85;hit[2]*=-.7;end[1]*=-.8;end[2]*=-.7
            anticipation=pose(body(x=.006,y=-.008*weight,pitch=5*strength,yaw=-twist,roll=-2.5),w,[32 if not caster else 62,-8,14],[-5,0,-1],[5,0,1])
            loaded=pose(body(x=.009,y=-.012*weight,z=.004,pitch=7*strength,yaw=-twist*1.1,roll=-3),[w[0]+3,w[1],w[2]],[39 if not caster else 72,-8,14],[-6,0,-1],[6,0,1])
            strike=pose(body(x=-.003,y=-.004*weight,z=-.018*strength,pitch=-9*strength,yaw=twist*.9,roll=3),hit,[25 if not caster else 94,7,9],[3,0,1],[-3,0,-1])
            finish=pose(body(x=-.006,y=-.01*weight,z=-.022*strength,pitch=-13*strength,yaw=twist*1.3,roll=5),end,[16 if not caster else 85,10,7],[5,0,2],[-5,0,-2])
            settle=pose(body(x=-.002,y=-.004,z=-.008,pitch=-6,yaw=twist*.4,roll=2),[v*.35+g*.65 for v,g in zip(end,guard)],[12,3,5],[2,0,0],[-2,0,0])
            if caster:
                anticipation['body'][3]=3;loaded['body'][3]=5
                strike['body'][3]=-5;finish['body'][3]=-7
            if mono:
                anticipation=pose(body(y=-.012,pitch=6,yaw=-twist*1.4,roll=-3))
                loaded=pose(body(y=-.02,pitch=9,yaw=-twist*1.6,roll=-4))
                strike=pose(body(y=-.008,z=-.035,pitch=-13*strength,yaw=twist,roll=3))
                finish=pose(body(y=-.018,z=-.045,pitch=-18*strength,yaw=twist*1.5,roll=5))
            keys=[(0,ready),(.18,pose(body(pitch=1,yaw=-twist*.25),[g+(v-g)*.22 for g,v in zip(guard,w)],[18,0,8])),(.4,anticipation),(.5,loaded),(.55,loaded),(.62,strike),(.69,finish),(.78,finish),(.9,settle),(1,ready)]
            if kind=='Slime':
                def slime_pose(sy,lift,pitch,z=0):
                    side=1/math.sqrt(sy)
                    return pose(body(y=lift,z=z,pitch=pitch,roll=(-1 if alt else 1)*pitch*.2,sx=side,sy=sy,sz=side))
                keys=[(0,slime_pose(1,0,0)),(.18,slime_pose(.93,0,-2)),(.4,slime_pose(.75 if heavy else .8,0,-5)),(.5,slime_pose(.7 if heavy else .76,0,-6)),(.55,slime_pose(.78,0,-3)),(.62,slime_pose(1.18,.075*strength,-12,-.03)),(.69,slime_pose(.8,0,-6,-.035)),(.78,slime_pose(.9,0,-3,-.015)),(.9,slime_pose(1.035,.008,1)),(1,slime_pose(1,0,0))]
            author(kind,clip,keys)

scene.frame_start=0;scene.frame_end=120;scene.render.fps=120
for kind in kinds:
    for c,a in actions[kind+'|Attack'].items():
        obj=bpy.data.objects[result['models'][kind]['controllers'][c]]
        obj.animation_data.action=bpy.data.actions[a]
scene['v2_actions']=json.dumps(actions)
scene['v2_export']=json.dumps(result,separators=(',',':'))
scene.frame_set(0)
for o in scene.objects:o.hide_set(not o.name.startswith('Goblin_'))
print(json.dumps({'authored':len(actions),'controllerActions':sum(len(a) for a in actions.values()),'samples':201,'species':len(kinds)}))
