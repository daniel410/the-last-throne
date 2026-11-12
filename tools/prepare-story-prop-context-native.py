"""격리 Studio에서 스토리 물품 계약/전체 배치를 검사한다. --overlay는 후보용이다."""
from pathlib import Path
import argparse, hashlib, json
root = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser()
p.add_argument('--overlay', action='store_true')
p.add_argument('--review', action='store_true')
p.add_argument('--output', type=Path, default=Path('/tmp/tlt-story-prop-context-native.luau'))
a = p.parse_args()
paths = [
    'src/server/World/StoryQuestGeometry.luau',
    'src/server/World/StoryPropAssignments.luau',
    'src/server/World/StoryProps.luau',
    'src/server/World/CampaignIncidentProps.luau',
    'src/server/World/DeepwoodActivityWorld.luau',
    'src/client/EmberCalderaPresentation.luau',
    'src/shared/CampaignStoryText.luau',
]
code = "assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place required')\n"
for path in paths:
    parent = 'game.ReplicatedStorage.Shared' if '/shared/' in path else 'game.StarterPlayer.StarterPlayerScripts.Client' if '/client/' in path else 'game.ServerScriptService.Server.World'
    name = Path(path).stem
    source = json.dumps((root / path).read_text())
    if a.overlay:
        code += f'do local parent={parent};local m=parent:FindFirstChild("{name}")or Instance.new("ModuleScript");m.Name="{name}";m.Source={source};m.Parent=parent end\n'
    else:
        code += f'assert({parent}.{name}.Source=={source},"source mismatch {name}")\n'
for suite in ['tests/story-prop-context-native.luau', 'tests/story-props-native.luau']:
    code += 'do\n' + (root / suite).read_text() + '\nend\n'
    paths.append(suite)
if a.review:
    code += """
local root=Instance.new('Folder');root.Name='StoryPropContextReview';root.Parent=workspace
root:SetAttribute('ReviewSession','story-props-context-20261112')
local kit=require(game.ServerScriptService.Server.World.StoryProps)
local rows={
 {'RootSealRoots','FieldMap','SealedDispatch','MedicineSatchel'},
 {'ScoutLantern','WebBindings','ShedCarapace','TravelPack'},
 {'SnowSled','SnowBeacon','RelayInstrument','IceGateLock'},
 {'LiftGear','MineBrace','PressureGauge','EmptyKeyCarrier'},
 {'KeeperLantern','CryptLatch','ThroneConduit','BindingFrame'},
}
local themes={'Deepwood','Gloamwood','FrozenVale','EmberCaldera','HauntedGraveyard'}
for row,keys in ipairs(rows)do
 for col,key in ipairs(keys)do
  local at=Vector3.new((col-2.5)*8,100,(row-1)*12)
  local floor=Instance.new('Part');floor.Name='ReviewPlinth';floor.Anchored=true;floor.Size=Vector3.new(7,.4,9);floor.Position=at-Vector3.new(0,.2,0);floor.Color=Color3.fromRGB(100,113,102);floor.Parent=root
  local m=kit.build(root,key,at,{theme=themes[row]})
  local label=Instance.new('BillboardGui');label.Size=UDim2.fromOffset(200,24);label.StudsOffset=Vector3.new(0,4.8,0);label.AlwaysOnTop=true;label.Parent=m.PrimaryPart
  local text=Instance.new('TextLabel');text.Size=UDim2.fromScale(1,1);text.BackgroundColor3=Color3.fromRGB(28,35,39);text.BackgroundTransparency=.15;text.TextColor3=Color3.fromRGB(244,229,194);text.TextSize=12;text.Text=themes[row]..' / '..key;text.AutoLocalize=false;text.Parent=label
 end
 task.wait()
end
local lighting=game:GetService('Lighting');lighting.ClockTime=13;lighting.Brightness=2
workspace.CurrentCamera.CameraType=Enum.CameraType.Scriptable
workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(32,140,-25),Vector3.new(0,101,20))
print('STORY_PROP_CONTEXT_REVIEW_READY')
for i=1,600 do if _G.TLTStoryPropReviewDone then break end task.wait(1)end
root:Destroy()
"""
code += "print('STORY_PROP_CONTEXT_FINAL_PASS')\n"
a.output.write_text(code)
paths.append('tools/prepare-story-prop-context-native.py')
a.output.with_suffix('.inputs.json').write_text(json.dumps({path: hashlib.sha256((root / path).read_bytes()).hexdigest() for path in paths}, indent=2) + '\n')
print(a.output)
