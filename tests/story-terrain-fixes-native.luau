assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local QA only')
local Shared=game.ReplicatedStorage.Shared
local C=require(Shared.CampaignContent)
local B=require(Shared.CampaignBiome)
local mood=require(game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodAtmosphere)
local W=game.ServerScriptService.Server.World
local world=require(W.CampaignWorld).create()
local report={checks=0,zones=0,landmarks={},paths=0}
local function check(v,message)report.checks+=1;assert(v,message)end
local times={15.6,0,10.2,16.4,.1}
for id,z in pairs(C.zones)do
 local theme=B.at(z.center[1],z.center[3]);mood.update(theme)
 check(game.Lighting.ClockTime==times[z.epic],'actual engine regional lighting '..id);report.zones+=1
 if z.epic>1 then
  local site=world.folder.EpicWorldArt['EpicWorldArt_'..z.epic][id]
  for _,m in ipairs(site.RegionalConcept:GetChildren())do if m:GetAttribute('RegionalConceptRole')=='Signature'then
   report.landmarks[id]={scale=m:GetScale(),parts=#m:GetChildren(),details=m:GetAttribute('RuntimeDetailParts')}
   for _,p in ipairs(m:GetChildren())do if p.Name:match('^Silk')then check(math.min(p.Size.X,p.Size.Y)>=.26*m:GetScale()-.001,'silk visible thickness '..id)end end
  end end
 end
end
local z=C.zones['FV-07'];mood.update(B.at(z.center[1],z.center[3]));mood.restoration({clears={['FV-07']=true}})
check(game.Lighting.FogEnd==1200,'restored valley engine fog')
mood.restoration({clears={}});check(game.Lighting.FogEnd==700,'unrestored valley engine fog')
mood.update(nil)
local geometry={}
for _,p in ipairs(world.terrain:GetDescendants())do if p:IsA('BasePart')then geometry[p]={p.Size,p.CFrame,p.CanCollide,p.CanQuery}end end
local source={}
for _,p in ipairs(world.folder:GetDescendants())do if p:IsA('BasePart')and p:GetAttribute('CampaignSurfaceVersion')then source[p]={p.Size,p.CFrame,p.Color,p.Material,p.Transparency}end end
require(W.CampaignSurfaceFinish).apply(world)
for p,s in pairs(geometry)do check(p.Size==s[1]and p.CFrame==s[2]and p.CanCollide==s[3]and p.CanQuery==s[4],'retain physical surface '..p:GetFullName())end
for p,s in pairs(source)do
 check(p.Size==s[1]and p.CFrame==s[2]and p.Color==s[3]and p.Material==s[4]and p.Transparency==s[5],'surface finishing idempotence '..p.Name)
 if p.Name=='WornCurvedRoute'then check(p.Size.X<=9,'quiet secondary path width');report.paths+=1
 elseif p.Name=='JourneyWalkingTrail'then check(p.Size.X<=14,'main path width');report.paths+=1
 elseif p.Name=='RegionalReturnTrail'or p.Name=='ReturnLoop'then check(p.Size.X<=7,'return path width');report.paths+=1 end
end
check(report.landmarks['FV-07'].scale>1.5 and report.landmarks['EC-02'].scale>1.5,'palace and workshop scale')
check(report.landmarks['EC-07'].details==3,'furnace skyline')
print('STORY_TERRAIN_FIXES '..game.HttpService:JSONEncode(report))
return report
