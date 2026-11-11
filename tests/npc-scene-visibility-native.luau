-- Isolated engine regression: hidden story actors must not leave floating faces.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local World=game.ServerScriptService.Server.World
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Content=require(game.ReplicatedStorage.Shared.CampaignContent)
local report={checks=0,actors=0,decals=0}
local function check(ok,message)report.checks+=1;assert(ok,message)end
local lobby={folder=Instance.new('Folder'),origin=Vector3.new(0,96,512)}
lobby.folder.Name='DawnspireLobbyPrototype';lobby.folder.Parent=workspace
local function prompt()
 local p=Instance.new('Part');p.Parent=lobby.folder
 local v=Instance.new('ProximityPrompt');v.Parent=p;return v
end
require(World.LobbyResidents).create(lobby,{training={prompt=prompt()},portal={prompt=prompt()}})
local scenes={lobby.folder.HomecomingReunion}
for _,m in ipairs(lobby.folder.SideStoryHomecomings:GetChildren())do table.insert(scenes,m)end
local function inspect(scene,visible)
 for _,v in ipairs(scene:GetDescendants())do
  if v:IsA('BasePart')or v:IsA('Decal')or v:IsA('Texture')then
   local original=v:GetAttribute('ExpansionTransparency')
   check(original~=nil,'original opacity saved: '..v:GetFullName())
   check(v.Transparency==(visible and original or 1),'whole scene opacity: '..v:GetFullName())
   if v:IsA('Decal')then report.decals+=1 end
  elseif v:IsA('BillboardGui')then check(v.Enabled==visible,'label follows scene')end
 end
end
-- Server defaults, before the first snapshot or client presentation exists.
for _,m in ipairs(scenes)do inspect(m,false)end
for _,m in ipairs(lobby.folder:GetDescendants())do if m:IsA('Model')and m:GetAttribute('TLTNPC')then report.actors+=1 end end
check(report.decals>11,'actual face and hair decals exercised')
local presentation=require(Client.CampaignExpansionPresentation)
presentation.update(nil)
for _,m in ipairs(scenes)do inspect(m,false)end
local completed={clears={['HG-07']=true,['DW-Q2']=true,['FV-Q1']=true,['EC-Q1']=true}}
presentation.update({journal=completed})
for _,m in ipairs(scenes)do inspect(m,true)end
local spirit=lobby.folder.HomecomingReunion.Lumi.FaceRig.Head.FaceDecal
check(spirit.Transparency==.12,'spirit face restores its original translucency')
-- A late decal/texture must immediately inherit the selected hero state.
presentation.update({journal={}})
local face=lobby.folder.HomecomingReunion.Lumi.FaceRig.Head
for _,class in ipairs({'Decal','Texture'})do
 local v=Instance.new(class);v.Name='LateSurface';v:SetAttribute('ExpansionTransparency',.37);v.Transparency=1;v.Parent=face
 task.wait()
 check(v.Transparency==1,'late surface hidden for unfinished hero')
 presentation.update({journal=completed});check(v.Transparency==.37,'late surface restored for completed hero')
 presentation.update({journal={}});check(v.Transparency==1,'hero switch hides late surface')
 v:Destroy()
end
-- A whole streamed scene must also inherit completion and hide on hero switch.
local clone=scenes[1]:Clone();clone.Name='RestreamedReunion';clone.Parent=lobby.folder;task.wait()
inspect(clone,false)
presentation.update({journal=completed});inspect(clone,true)
presentation.update({training=true,journal=completed});inspect(clone,false)
-- Normal residents remain visible throughout personal scene transitions.
check(lobby.folder.DawnspireResidents.Nia.FaceRig.Head.FaceDecal.Transparency==0,'normal Nia face remains visible')
check(lobby.folder.DawnspireResidents.Nia.Torso.Transparency==0,'normal Nia body remains visible')
-- Exercise the regional incident authoring path with actual actors as well.
local c=Content.byId['GW-06'];local g=c.expansionGoals[2];local area
for _,a in ipairs(Content.zones[c.zone].expansionAreas)do if a.id==g.area then area=a end end
local regional=Instance.new('Model');regional.Name='RegionalFixture';regional.Parent=workspace
require(World.CampaignIncidentScenes).create(regional,c,g,area)
local count=0
for _,m in ipairs(regional:GetChildren())do if m:GetAttribute('ExpansionEvent')then
 for _,v in ipairs(m:GetDescendants())do if v:IsA('Decal')or v:IsA('Texture')then
  count+=1;check(v:GetAttribute('ExpansionTransparency')~=nil,'regional face stores original opacity')
 end end
end end
check(count>0,'regional fixture includes actual NPC surfaces')
presentation.update({journal={clears={[c.id]=true}}})
for _,m in ipairs(regional:GetChildren())do if m:GetAttribute('ExpansionEvent')and m:GetAttribute('ExpansionMax')==3 then inspect(m,true)end end
lobby.folder:Destroy();regional:Destroy()
report.pass=true
print('NPC_SCENE_VISIBILITY '..game.HttpService:JSONEncode(report))
return report
