local function color(r,g,b)return {r=r,g=g,b=b}end
Color3={fromRGB=color}
local originalSky={Parent=true,IsA=function(_,kind)return kind=='Sky'end}
local originalAtmosphere={Parent=true,IsA=function(_,kind)return kind=='Atmosphere'end}
local lighting={FogStart=10,FogEnd=900,FogColor=color(1,2,3),Brightness=1,Ambient=color(1,1,1),OutdoorAmbient=color(2,2,2),ClockTime=8,ExposureCompensation=0,ColorShift_Top=color(0,0,0)}
function lighting:GetChildren()return {originalSky,originalAtmosphere}end
game={GetService=function(_,name)assert(name=='Lighting');return lighting end}
local created={};local checks=0
local function check(v,msg)checks=checks+1;assert(v,msg)end
Instance={new=function(class)local o={class=class,Destroy=function(self)self.destroyed=true;self.Parent=nil end};created[#created+1]=o;return o end}
local mood=dofile('src/client/DeepwoodAtmosphere.luau')
mood.update('Lobby');check(lighting.Brightness==3.2,'existing lobby exposure');check(originalSky.Parent==nil and originalAtmosphere.Parent==nil,'original environment detached')
check(#created==2 and created[2].Saturation==.24,'lobby has unchanged correction and no regional atmosphere')
local prior={table.unpack(created)}
mood.update('Deepwood');check(lighting.ClockTime==13.5 and lighting.FogEnd==620,'forest remains daylight with a readable skyline')
for _,p in ipairs(prior)do check(p.destroyed,'old owned effects removed')end
check(created[5].class=='Atmosphere'and created[6].class=='BloomEffect','regional haze and restrained local glow')
for _,name in ipairs({'FrozenVale','EmberCaldera','Gloamwood','HauntedGraveyard','Lobby'})do
 prior={};for _,p in ipairs(created)do if not p.destroyed then prior[#prior+1]=p end end
 mood.update(name)
 for _,p in ipairs(prior)do check(p.destroyed,'switch destroys previous regional effects')end
 local active=0;for _,p in ipairs(created)do if not p.destroyed then active=active+1 end end
 check(active==(name=='Lobby'and 2 or 4),'no effect accumulation')
 if name=='Gloamwood'or name=='HauntedGraveyard'then check(lighting.ClockTime<1 and lighting.Ambient.r>=98,'moonlit region keeps readable ambient light')end
 local count=#created;mood.update(name);check(#created==count,'same mode is idempotent')
end
mood.update(false);check(lighting.Brightness==1 and lighting.ClockTime==8 and lighting.FogEnd==900,'training restores authored lighting')
check(originalSky.Parent==lighting and originalAtmosphere.Parent==lighting,'original sky/atmosphere restored')
for _,p in ipairs(created)do check(p.destroyed,'no owned effects leaked outside campaign')end
mood.update(true);check(lighting.FogEnd==620,'boolean compatibility');mood.update(nil);check(lighting.FogStart==10,'boolean cleanup')
print('Regional atmosphere '..checks..' checks passed')
