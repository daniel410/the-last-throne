-- 실제 생성 경로와 개인 NPC 표시: 전체 Meshy NPC의 메시·이름표·프롬프트를 함께 검사한다.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Local edit fixture only')
local Visual=require(game.ServerScriptService.Server.World.NPCVisual)
local Motion=require(game.StarterPlayer.StarterPlayerScripts.Client.NPCMotionPresentation)
local Presentation=require(game.StarterPlayer.StarterPlayerScripts.Client.NPCPresentation)
local Catalog=require(game.ReplicatedStorage.Shared.NPCCatalog)
local Tags=game.CollectionService
local scope=Instance.new('Folder');scope.Name='NPCMeshVisibilityTest';scope.Parent=workspace
local hero=Instance.new('Model');hero.Parent=scope
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Position=Vector3.new(0,5,0);root.Parent=hero
local viewer={UserId=91,Character=hero}
local report={checks=0,models=0};local controller
local function check(v,m)report.checks+=1;assert(v,m)end
local ok,err=xpcall(function()
 for _,c in Catalog.characters do if c.id~='selene' then
  local actors={}
  for i,role in {'static','escort','private'}do
   local m=Visual.create(scope,c.id,Vector3.new(i*3,5,0),{})
   m:SetAttribute('NPCActorIdentity','mesh-qa:'..c.id)
   m:SetAttribute('NPCActorRole',role=='static' and 'static' or 'escort')
   if role=='private'then m:SetAttribute('NPCPrivateOwnerUserId',92)end
   local prompt=Instance.new('ProximityPrompt');prompt.Name='Talk';prompt.Parent=m.PrimaryPart
   Tags:AddTag(m,'TLTStoryNPC');actors[role]=m
   check(m:FindFirstChild('BodyMesh')~=nil and m:GetAttribute('NPCVisualVersion')==6,'factory chooses approved model')
   check(Motion.bind(m)~=nil,'motion dispatch chooses skin')
  end
  controller=Presentation.create(viewer,scope,function()return {journal={}}end);controller.update()
  for role,m in actors do
   local visible=role=='escort'
   check(m.BodyMesh.LocalTransparencyModifier==(visible and 0 or 1),'whole surface mask '..c.id..role)
   check(m.PrimaryPart.NPCLabel.Enabled==visible,'label mask')
   check(m.PrimaryPart.Talk.Enabled==visible,'prompt mask')
  end
  local privateClone=actors.private:Clone();privateClone.Parent=scope;controller.update()
  check(privateClone.BodyMesh.LocalTransparencyModifier==1,'restreamed private mesh stays hidden')
  controller.destroy();controller=nil
  for _,m in actors do check(m.BodyMesh.LocalTransparencyModifier==0,'cleanup restores authored mask');m:Destroy()end
  privateClone:Destroy();report.models+=1
 end end
 local selene=Visual.create(scope,'selene',Vector3.new(0,5,0),{})
 check(not selene:GetAttribute('NPCMeshySkinned') and not selene:FindFirstChild('BodyMesh'),'Selene retains existing path')
 selene:Destroy()
end,debug.traceback)
if controller then controller.destroy()end;scope:Destroy()
report.pass=ok;report.failure=not ok and tostring(err) or nil
assert(ok,err);return game.HttpService:JSONEncode(report)
