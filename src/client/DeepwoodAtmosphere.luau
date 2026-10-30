-- Bright daylight first. Trees and distant mounds frame the view; only the
-- far background fades to a pale sky color, beyond all normal combat ranges.
local Lighting=game:GetService('Lighting')
local Mood={fogStart=180,fogEnd=340}
local values={FogStart=Mood.fogStart,FogEnd=Mood.fogEnd,FogColor=Color3.fromRGB(207,225,232),
 Brightness=2.6,Ambient=Color3.fromRGB(143,150,133),OutdoorAmbient=Color3.fromRGB(177,189,160),
 ClockTime=14,ExposureCompensation=.06}
local saved,environment,sky
function Mood.update(enabled)
 if enabled and not saved then
  saved={};for key,value in pairs(values) do saved[key]=Lighting[key];Lighting[key]=value end
  environment={}
  for _,v in ipairs(Lighting:GetChildren()) do if v:IsA('Atmosphere') or v:IsA('Sky') then table.insert(environment,v);v.Parent=nil end end
  sky=Instance.new('Sky');sky.Name='DeepwoodDaylightSky';sky.CelestialBodiesShown=true;sky.StarCount=0;sky.Parent=Lighting
 elseif not enabled and saved then
  for key,value in pairs(saved) do Lighting[key]=value end
  for _,v in ipairs(environment) do v.Parent=Lighting end
  sky:Destroy();saved=nil;environment=nil;sky=nil
 end
end
function Mood.start()
 local p=game:GetService('Players').LocalPlayer
 local function apply() Mood.update(p:GetAttribute('K0SessionPhase')=='Tutorial' and p:GetAttribute('TLTRoute')~='Training') end
 p:GetAttributeChangedSignal('K0SessionPhase'):Connect(apply);p:GetAttributeChangedSignal('TLTRoute'):Connect(apply);apply()
end
return Mood
