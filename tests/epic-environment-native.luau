-- Local engine acceptance: authored geometry, grounded props, budgets and recovery.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated environment review only')
local W=game.ServerScriptService.Server.World
local world=require(W.CampaignWorld).create()
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local report={checks=0,zones={},parts=0,solid=0}
local function check(ok,message)report.checks+=1;assert(ok,message)end
local themes={Deepwood=true,Gloamwood=true,FrozenVale=true,EmberCaldera=true,HauntedGraveyard=true}
for id,z in pairs(C.zones)do
 local site=world.folder.EpicWorldArt['EpicWorldArt_'..z.epic][id]
 local root=site:FindFirstChild('BiomeDetails');check(root~=nil,'biome details '..id)
 local n,clusters=0,0
 for _,m in ipairs(root:GetChildren())do if m:IsA('Model')then
  clusters+=1;check(m:GetAttribute('BlenderEnvironmentSource')~=nil,'source attribution')
 end end
 for _,p in ipairs(root:GetDescendants())do if p:IsA('BasePart')then
  n+=1
  check(p.Anchored and not p.CanTouch,'anchored non-touch scenery')
  check(p.CanCollide==(p:GetAttribute('EpicDetailSolid')==true),'physical large geometry')
  check(p.CanQuery==p.CanCollide,'solid queries agree')
  check(p:GetAttribute('TLTSceneryDistance')~=nil,'distance budget')
  if p.CanCollide then report.solid+=1 end
 end end
 check(clusters>0,'at least one grounded cluster '..id)
 check(n<=500,'per-zone detail instance ceiling '..id)
 report.zones[id]={clusters=clusters,parts=n};report.parts+=n
end
local n=#world.folder:GetDescendants()
for i=1,5 do require(W.CampaignWorld).create(i,world)end
check(#world.folder:GetDescendants()==n,'cached create is idempotent')
local Lighting=game:GetService('Lighting')
local mood=require(game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodAtmosphere)
local original={ClockTime=Lighting.ClockTime,Ambient=Lighting.Ambient,FogEnd=Lighting.FogEnd}
for theme in pairs(themes)do
 mood.update(theme)
 check(Lighting:FindFirstChild('TLTRegionalAtmosphere')~=nil,'regional aerial perspective')
 check(Lighting.ExposureCompensation>=0,'readable exposure')
 mood.update(theme)
 local count=0;for _,p in ipairs(Lighting:GetChildren())do if p.Name=='TLTRegionalAtmosphere'then count+=1 end end
 check(count==1,'no stacked effects')
end
mood.update(nil)
for key,value in pairs(original)do check(Lighting[key]==value,'training/environment restore '..key)end
print('EPIC_ENVIRONMENT_QA '..game.HttpService:JSONEncode(report))
_G.TLTReviewWorld=world
return report
