local function color(r,g,b) return {r=r,g=g,b=b} end
Color3={fromRGB=color}
local originalSky={Parent=true,IsA=function(_,kind) return kind=='Sky' end}
local originalAtmosphere={Parent=true,IsA=function(_,kind) return kind=='Atmosphere' end}
local lighting={FogStart=10,FogEnd=900,FogColor=color(1,2,3),Brightness=1,Ambient=color(1,1,1),OutdoorAmbient=color(2,2,2),ClockTime=8,ExposureCompensation=0,ColorShift_Top=color(0,0,0)}
function lighting:GetChildren() return {originalSky,originalAtmosphere} end
game={GetService=function(_,name) assert(name=='Lighting');return lighting end}
local created={}
Instance={new=function(class) local o={class=class,Destroy=function(self) self.destroyed=true;self.Parent=nil end};created[#created+1]=o;return o end}
local mood=dofile('src/client/DeepwoodAtmosphere.luau')
mood.update('Lobby');assert(lighting.Brightness==3.2 and originalSky.Parent==nil and originalAtmosphere.Parent==nil)
assert(created[1].class=='Sky' and created[2].Saturation==.24)
mood.update('Deepwood');assert(created[1].destroyed and created[2].destroyed and lighting.FogStart==180 and lighting.FogEnd==340)
assert(lighting.Brightness==3.1 and created[4].Saturation==.24)
mood.update(false);assert(lighting.Brightness==1 and lighting.FogStart==10 and lighting.FogEnd==900 and originalSky.Parent==lighting and originalAtmosphere.Parent==lighting)
assert(created[3].destroyed and created[4].destroyed)
mood.update(true);assert(lighting.FogEnd==340);mood.update(nil);assert(lighting.Brightness==1)
print('Daylight profile transitions: 8 checks passed')
