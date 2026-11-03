-- Compares visible TD mesh bounds to default Roblox avatar rigs in an isolated place.
local Players=game:GetService('Players')
assert(game.PlaceId==0 and #Players:GetPlayers()==0,'isolated place only')
local visual=require(game.ServerScriptService.Server.World.SeleneVisual)
local report={kind='SELENE_SIZE_NATIVE',checks=0,failures={},heights={}}
local function check(v,label) report.checks+=1;assert(v,label) end
local folder=Instance.new('Folder');folder.Name='SeleneSizeQA';folder.Parent=workspace
local ok,err=xpcall(function()
 local ground=Vector3.new(100,500,200)
 for _,case in ipairs({{name='camp',options={}},{name='follower',options={}},{name='scaled',options={scale=.8,yaw=1.2}}}) do
  local model=visual.create(folder,ground,case.name,case.options)
  local root=model.PrimaryPart
  check((root.Position-ground).Magnitude<.001,'actor anchor preserved: '..case.name)
  check(not root.CanCollide and not root.CanQuery and not root.CanTouch,'root remains inert')
  local copy=model:Clone();copy.PrimaryPart=nil;copy.ActorRoot:Destroy();copy.VisualRoot:Destroy();copy.Parent=folder
  local cf,size=copy:GetBoundingBox();local scale=case.options.scale or 1
  check(math.abs(size.Y-4.8*scale)<.01,'visible mesh height: '..case.name)
  check(math.abs(cf.Position.Y-size.Y/2-ground.Y)<.01,'visible mesh rests on the ground')
  check(model.ActorRoot.NPCLabel.StudsOffset.Y>size.Y,'name label remains above mesh')
  if case.name=='camp' then report.heights.selene=size.Y end
  copy:Destroy()
 end
 for _,rig in ipairs({Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15}) do
  local description=Instance.new('HumanoidDescription');local character=Players:CreateHumanoidModelFromDescriptionAsync(description,rig);description:Destroy();character.Parent=folder
  local _,bounds=character:GetBoundingBox();report.heights[rig.Name]=bounds.Y
  local ratio=report.heights.selene/bounds.Y
  check(ratio>=.85 and ratio<1,'Selene slightly shorter than default '..rig.Name)
 end
end,debug.traceback)
folder:Destroy();if not ok then table.insert(report.failures,tostring(err)) end
report.pass=ok;workspace:SetAttribute('SeleneSizeQAReport',game.HttpService:JSONEncode(report));print('SELENE_SIZE_NATIVE '..game:GetService('HttpService'):JSONEncode(report));assert(ok,'Selene size fixture failed')
