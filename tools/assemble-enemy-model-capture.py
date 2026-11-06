from pathlib import Path
import subprocess,json
before=subprocess.check_output(['git','show','02309a66caff7cc593f3a7de0597beaf75a9c90a:src/server/World/GloamwoodAppearance.luau'],text=True)
code='local Before=assert(loadstring('+json.dumps(before,ensure_ascii=False)+'))()\n'
code+=r'''
assert(game.PlaceId==0,'Local capture only')
local Run=game:GetService('RunService');if not Run:IsRunning()then Run:Run();task.wait(.2)end
local After=require(game.ServerScriptService.Server.World.GloamwoodAppearance)
local Details=require(game.ServerScriptService.Server.World.EnemyModelDetails)
local Field=require(game.ServerScriptService.Server.World.TrainingField)
local folder=Instance.new('Folder');folder.Name='EnemyModelCapture';folder.Parent=workspace
local out={version=1,models={}}
local function capture(model,stage,kind)
 local visual=model.TdMonsterVisual;local row={kind=kind,stage=stage,height=model:GetAttribute('TdMonsterTargetHeight'),parts={}}
 for _,p in ipairs(visual:GetDescendants())do if p:IsA('BasePart')then
  local cf=model.HumanoidRootPart.CFrame:ToObjectSpace(p.CFrame)
  table.insert(row.parts,{name=p.Name,class=p.ClassName,shape=p:IsA('Part')and p.Shape.Name or nil,size={p.Size.X,p.Size.Y,p.Size.Z},cf={cf:GetComponents()},color={p.Color.R,p.Color.G,p.Color.B},transparency=p.Transparency,meshId=p:IsA('MeshPart')and p.MeshId or nil,detail=p:IsDescendantOf(visual:FindFirstChild('CombatDetails')or Instance.new('Folder'))})
 end end
 table.insert(out.models,row)
 print('ENEMY_MODEL_ROW '..game:GetService('HttpService'):JSONEncode(row))
end
for _,kind in ipairs({'Webling','Silkweaver','Barkstalker','Gloambat','VenomcoilCentipede','AncientHollowbark','VenomcoilKing','WidowQueen'})do
 for _,stage in ipairs({'before','after'})do
  local m=Instance.new('Model');m.Name=kind
  for _,name in ipairs({'HumanoidRootPart','Torso'})do local p=Instance.new('Part');p.Name=name;p.Anchored=true;p.CFrame=CFrame.new(0,3,0);p.Parent=m end
  m.Parent=folder
  local visual=(stage=='before'and Before or After).attach(m,kind,3,1)
  if stage=='after'then Details.attach(m,kind,visual,3,m:GetAttribute('TdMonsterTargetHeight'))end
  capture(m,stage,kind);m:Destroy()
 end
end
for _,kind in ipairs({'Warlord','KingOgre','Shaman','KingShaman'})do
 local m=Field.makeEnemy(folder,kind,0,0,1,1);m.HumanoidRootPart.Anchored=true;capture(m,'after',kind);m:Destroy()
end
folder:Destroy()
print('ENEMY_MODEL_CAPTURE_DONE '..#out.models)
'''
Path('/tmp/tlt-enemy-model-capture.luau').write_text(code)
