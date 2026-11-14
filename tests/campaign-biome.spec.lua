local C=dofile('src/shared/CampaignContent.luau')
local B=dofile('src/shared/CampaignBiome.luau')
local checks=0
local function check(v,message)checks=checks+1;assert(v,message)end
local expected={'Deepwood','Gloamwood','FrozenVale','EmberCaldera','HauntedGraveyard'}
for id,z in pairs(C.zones)do
 local function area(a)
  for _,offset in ipairs({{0,0},{-.49,-.49},{.49,.49},{-.49,.49},{.49,-.49}})do
   check(B.at(a.center[1]+a.size[1]*offset[1],a.center[3]+a.size[2]*offset[2])==expected[z.epic],'region/incident footprint '..id)
  end
 end
 area(z);for _,a in ipairs(z.expansionAreas or {})do area(a);area(a.connector)end
end
check(B.at(0/0,0)==nil and B.at(0,math.huge)==nil and B.at(nil,0)==nil,'invalid positions')
-- Exercise the real client startup and Heartbeat path, not just the selector.
local root={Position={X=0,Z=0}}
local signal={Connect=function()end}
local player={Character={FindFirstChild=function()return root end},GetAttribute=function(_,name)return name=='K0SessionPhase'and 'Tutorial'or nil end,GetAttributeChangedSignal=function()return signal end}
Color3={fromRGB=function(r,g,b)return {r=r,g=g,b=b}end}
local lighting={FogStart=0,FogEnd=0,Brightness=1,ClockTime=8,GetChildren=function()return {}end}
local token={};local beat
local originalRequire=require
require=function(m)if m==token then return B else return originalRequire(m)end end
game={GetService=function(_,name)
 if name=='Lighting'then return lighting
 elseif name=='Players'then return {LocalPlayer=player}
 elseif name=='ReplicatedStorage'then return {Shared={CampaignBiome=token}}
 elseif name=='RunService'then return {Heartbeat={Connect=function(_,fn)beat=fn end}}
 else error(name)end
end}
workspace={GetAttribute=function()return 'Battle'end,GetAttributeChangedSignal=function()return signal end}
Instance={new=function()return {Destroy=function()end}end}
local mood=dofile('src/client/DeepwoodAtmosphere.luau');mood.start()
local times={15.6,0,10.2,16.4,.1}
for id,z in pairs(C.zones)do
 root.Position={X=z.center[1],Z=z.center[3]};beat(.6)
 check(lighting.ClockTime==times[z.epic],'actual client startup mood '..id)
end
for _,link in ipairs(C.overlandLinks)do
 local a,b=C.zones[link[1]],C.zones[link[2]]
 for _,z in ipairs({a,b,a})do root.Position={X=z.center[1],Z=z.center[3]};beat(.6);check(lighting.ClockTime==times[z.epic],'round-trip transition '..link[1])end
end
local fv=C.zones['FV-07'];root.Position={X=fv.center[1],Z=fv.center[3]};beat(.6)
mood.restoration({clears={['FV-07']=true}});check(lighting.FogEnd==1200,'restored valley uses actual FV profile')
mood.restoration({clears={}});check(lighting.FogEnd==700,'unrestored valley fog')
mood.update(nil);check(lighting.ClockTime==8,'original environment restored')
require=originalRequire
print('Campaign biome/client '..checks..' checks passed')
