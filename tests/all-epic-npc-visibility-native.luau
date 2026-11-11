-- Actual five-epic map generation, personal scene surfaces and NPC/budget interaction.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
for _,s in ipairs(game.ServerScriptService:GetDescendants())do if s:IsA('Script')then s.Disabled=true end end
game.StarterPlayer.StarterPlayerScripts.Client.Disabled=true
local World=game.ServerScriptService.Server.World
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Tags=game:GetService('CollectionService')
local report={checks=0,epics={},scenes=0,surfaces=0}
local function check(v,m)report.checks+=1;assert(v,m)end
local function near(a,b)return math.abs(a-b)<.00001 end
local Visual=require(World.NPCVisual)
local Presentation=require(Client.NPCPresentation)
local character=Instance.new('Model');character.Name='VisibilityTestHero'
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Parent=character;character.Parent=workspace
local viewer={UserId=91,Character=character}
local world
for epic=1,5 do
 world=require(World.CampaignWorld).create(epic,world)
 local site=world.folder.CampaignExpansion['Epic'..epic]
 local row={epic=epic,scenes=0,npcs=0,surfaces=0}
 for _,m in ipairs(site:GetDescendants())do
  if m:IsA('Model')and m:GetAttribute('TLTNPC')then row.npcs+=1 end
  if m:IsA('Model')and m:GetAttribute('ExpansionEvent')then
   row.scenes+=1;report.scenes+=1
   -- Before any client snapshot, delayed scenes must be fully hidden.
   local first=m:GetAttribute('ExpansionMin')
   for _,v in ipairs(m:GetDescendants())do
    if v:IsA('Decal')or v:IsA('Texture')then
     row.surfaces+=1;report.surfaces+=1
     check(v:GetAttribute('ExpansionTransparency')~=nil,'authored surface opacity '..v:GetFullName())
     if first and first>0 then check(v.Transparency==1,'server hidden scene leaves no face '..v:GetFullName())end
    end
   end
  end
 end
 check(row.scenes>0 and row.npcs>0 and row.surfaces>0,'epic has real story actors and surfaces '..epic)
 table.insert(report.epics,row)
 print('ALL_EPIC_NPC_GENERATED '..game.HttpService:JSONEncode(row));task.wait()
end
local Expansion=require(Client.CampaignExpansionPresentation)
local completed={clears={}}
local Content=require(game.ReplicatedStorage.Shared.CampaignContent)
for _,c in ipairs(Content.chapters)do completed.clears[c.id]=true end
local scenes={}
for _,m in ipairs(world.folder.CampaignExpansion:GetDescendants())do
 if m:IsA('Model')and m:GetAttribute('ExpansionEvent')then table.insert(scenes,m)end
end
-- Explicit stage range fixtures exercise every real scene, independent of quest requirements.
local saved={}
for _,m in ipairs(scenes)do
 saved[m]={min=m:GetAttribute('ExpansionMin'),max=m:GetAttribute('ExpansionMax'),after=m:GetAttribute('ExpansionAfter'),requires=m:GetAttribute('ExpansionRequires')}
 m:SetAttribute('ExpansionMin',3);m:SetAttribute('ExpansionMax',3);m:SetAttribute('ExpansionRequires',nil)
end
local function inspect(visible)
 for _,m in ipairs(scenes)do for _,v in ipairs(m:GetDescendants())do
  if v:IsA('BasePart')or v:IsA('Decal')or v:IsA('Texture')then
   check(near(v.Transparency,visible and (v:GetAttribute('ExpansionTransparency')or 0)or 1),'entire scene follows hero '..v:GetFullName())
  end
 end end
end
Expansion.update(nil);inspect(false)
Expansion.update({journal=completed});inspect(true)
Expansion.update({journal={}});inspect(false)
Expansion.update({journal=completed});inspect(true)
-- Stream a late face and a full scene while hidden; both must inherit the state.
Expansion.update({journal={}})
local sample
for _,m in ipairs(scenes)do local p=m:FindFirstChild('FaceDecal',true);if p then sample=p;break end end
check(sample~=nil,'real face available for stream-in regression')
local late=Instance.new('Decal');late:SetAttribute('ExpansionTransparency',.24);late.Parent=sample.Parent;task.wait()
check(late.Transparency==1,'late face hidden without waiting for another hero snapshot')
Expansion.update({journal=completed});check(near(late.Transparency,.24),'late face restores authored opacity');late:Destroy()
local streamed=scenes[1]:Clone();streamed.Parent=world.folder;task.wait()
Expansion.update({journal={}})
for _,v in ipairs(streamed:GetDescendants())do if v:IsA('Decal')or v:IsA('Texture')then check(v.Transparency==1,'restreamed scene face hidden')end end
streamed:Destroy()
for m,s in pairs(saved)do m:SetAttribute('ExpansionMin',s.min);m:SetAttribute('ExpansionMax',s.max);m:SetAttribute('ExpansionAfter',s.after);m:SetAttribute('ExpansionRequires',s.requires)end
-- Five map positions exercise duplicate/private NPC selection with actual face rigs.
local groups={};local scope=Instance.new('Folder');scope.Name='NPCVisibilityCases';scope.Parent=world.folder
for epic,chapter in ipairs({'DW-01','GW-01','FV-01','EC-01','HG-01'})do
 local at=Vector3.new(table.unpack(Content.zones[chapter].center))
 local group={at=at}
 for index,role in ipairs({'static','escort','private'})do
  local m=Visual.create(scope,epic==5 and 'lumi' or 'eryn',at+Vector3.new(index*4,0,0),{name=chapter..role})
  m:SetAttribute('NPCActorIdentity','visibility:'..epic)
  m:SetAttribute('NPCActorRole',role=='static'and 'static'or 'escort')
  if role=='private'then m:SetAttribute('NPCPrivateOwnerUserId',92)end
  Tags:AddTag(m,'TLTStoryNPC');group[role]=m
 end
 table.insert(groups,group)
end
local controller=Presentation.create(viewer,world.folder,function()return {journal={}}end)
local function mask(m,value)
 for _,v in ipairs(m:GetDescendants())do
  if v:IsA('BasePart')or v:IsA('Decal')or v:IsA('Texture')then
   check(v.LocalTransparencyModifier==value,'body and surfaces share personal mask '..v:GetFullName())
  end
 end
end
for _,g in ipairs(groups)do
 root.Position=g.at;controller.update();mask(g.static,1);mask(g.escort,0);mask(g.private,1)
 local f=g.private:FindFirstChild('FaceDecal',true)
 check(f~=nil and f.LocalTransparencyModifier==1,'private escort face cannot leak')
 -- Keep an original local opacity to verify restoration on losing/winning selection.
 local face=g.escort:FindFirstChild('FaceDecal',true)
 check(face~=nil,'chosen NPC has real face')
 Tags:RemoveTag(g.escort,'TLTStoryNPC');controller.update();mask(g.static,0)
 Tags:AddTag(g.escort,'TLTStoryNPC');controller.update();mask(g.static,1)
end
-- Late streamed masks and pre-existing local translucency survive selection/teardown.
local hiddenFace=groups[1].private:FindFirstChild('FaceDecal',true)
for _,class in ipairs({'Decal','Texture'})do
 local v=Instance.new(class);v.LocalTransparencyModifier=.31;v.Parent=hiddenFace.Parent;task.wait()
 check(v.LocalTransparencyModifier==1,'late personal surface is masked immediately')
 v.Parent=nil;controller.update();v:Destroy()
end
local authored=Instance.new('Texture');authored.LocalTransparencyModifier=.31
-- Add while temporarily untagged so its original modifier is captured accurately.
local tested=groups[1].escort
Tags:RemoveTag(tested,'TLTStoryNPC');authored.Parent=tested:FindFirstChild('FaceDecal',true).Parent
Tags:AddTag(tested,'TLTStoryNPC');controller.update()
check(near(authored.LocalTransparencyModifier,.31),'selected surface preserves original local translucency')
authored.Parent=nil;controller.update();authored:Destroy()
-- Drive the real distance budget heartbeat using an isolated viewer dependency.
local budget=Client.WorldPresentationBudget:Clone();budget.Name='NPCBudgetVisibilityTest'
budget.Source=budget.Source:gsub("local Players=game:GetService%('Players'%)","local Players={LocalPlayer={Character=script.Character.Value,GetAttribute=function()return 'Battle'end}}")
local object=Instance.new('ObjectValue');object.Name='Character';object.Value=character;object.Parent=budget;budget.Parent=Client
local nearScenery=Instance.new('Part');nearScenery.Anchored=true;nearScenery.CanCollide=false;nearScenery:SetAttribute('TLTDecorative',true);nearScenery.Position=root.Position+Vector3.new(4,0,0);nearScenery.Parent=workspace
require(budget).start()
game:GetService('RunService'):Run();task.wait(.7)
for _,g in ipairs(groups)do mask(g.static,1);mask(g.private,1);mask(g.escort,0)end
check(nearScenery.LocalTransparencyModifier==0,'near scenery still visible')
root.Position+=Vector3.new(2000,0,0);task.wait(.7)
for _,g in ipairs(groups)do mask(g.static,1);mask(g.private,1);mask(g.escort,0)end
check(nearScenery.LocalTransparencyModifier==1,'distant scenery still culled')
controller.destroy()
for _,g in ipairs(groups)do mask(g.static,0);mask(g.private,0);mask(g.escort,0)end
nearScenery:Destroy();scope:Destroy();character:Destroy();world.folder:Destroy()
report.pass=true
print('ALL_EPIC_NPC_VISIBILITY '..game.HttpService:JSONEncode(report))
return report
