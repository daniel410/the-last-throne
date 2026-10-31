-- Client-local daylight profiles. Restore the original environment outside the
-- lobby and Deepwood, including when entering the separate training route.
local Lighting=game:GetService('Lighting')
local Mood={fogStart=180,fogEnd=340}
local profiles={
 Lobby={FogStart=10000,FogEnd=100000,FogColor=Color3.fromRGB(188,221,250),
  Brightness=3.2,Ambient=Color3.fromRGB(157,169,177),OutdoorAmbient=Color3.fromRGB(189,208,218),
  ClockTime=13,ExposureCompensation=.16,ColorShift_Top=Color3.fromRGB(20,33,48)},
 Deepwood={FogStart=Mood.fogStart,FogEnd=Mood.fogEnd,FogColor=Color3.fromRGB(192,225,246),
  Brightness=3.1,Ambient=Color3.fromRGB(159,169,150),OutdoorAmbient=Color3.fromRGB(191,210,180),
  ClockTime=13.5,ExposureCompensation=.14,ColorShift_Top=Color3.fromRGB(15,27,40)},
}
local saved,environment,sky,correction,current
local function clearOwned()
 if sky then sky:Destroy();sky=nil end
 if correction then correction:Destroy();correction=nil end
end
function Mood.update(mode)
 -- Preserve the previous boolean API used by scenery tests and other callers.
 if mode==true then mode='Deepwood' elseif mode==false then mode=nil end
 if mode~=nil and not profiles[mode] then mode=nil end
 if mode==current then return end
 if not mode then
  if saved then
   clearOwned()
   for key,value in pairs(saved) do Lighting[key]=value end
   for _,v in ipairs(environment) do v.Parent=Lighting end
   saved=nil;environment=nil
  end
  current=nil;return
 end
 if not saved then
  saved={};for key in pairs(profiles[mode]) do saved[key]=Lighting[key] end
  environment={}
  for _,v in ipairs(Lighting:GetChildren()) do
   if v:IsA('Atmosphere') or v:IsA('Sky') then table.insert(environment,v);v.Parent=nil end
  end
 end
 clearOwned()
 for key,value in pairs(profiles[mode]) do Lighting[key]=value end
 -- The built-in daylight sky needs no externally hosted or permissioned assets.
 -- Atmosphere overrides distance fog, so retain FogStart/FogEnd for Deepwood.
 sky=Instance.new('Sky');sky.Name='TLTClearDaySky';sky.CelestialBodiesShown=true;sky.StarCount=0;sky.Parent=Lighting
 correction=Instance.new('ColorCorrectionEffect');correction.Name='TLTVividDaylight'
 correction.Brightness=.025;correction.Contrast=.025;correction.Saturation=.24
 correction.TintColor=Color3.fromRGB(244,250,255);correction.Parent=Lighting
 current=mode
end
function Mood.start()
 local p=game:GetService('Players').LocalPlayer
 local function apply()
  local phase=p:GetAttribute('K0SessionPhase')
  local lobby=workspace:GetAttribute('TLTServerRole')~='Battle' and (phase=='Lobby' or phase=='LoadingLobby' or phase=='ReturningLobby')
  Mood.update(lobby and 'Lobby' or phase=='Tutorial' and p:GetAttribute('TLTRoute')~='Training' and 'Deepwood' or nil)
 end
 p:GetAttributeChangedSignal('K0SessionPhase'):Connect(apply);p:GetAttributeChangedSignal('TLTRoute'):Connect(apply)
 workspace:GetAttributeChangedSignal('TLTServerRole'):Connect(apply);apply()
end
return Mood
