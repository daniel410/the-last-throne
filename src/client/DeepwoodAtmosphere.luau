-- Client-local biome lighting. Restore the authored environment outside the
-- campaign/lobby, including when entering the separate training route.
local Lighting=game:GetService('Lighting')
local Mood={fogStart=180,fogEnd=620}
local profiles={
 Lobby={FogStart=10000,FogEnd=100000,FogColor=Color3.fromRGB(188,221,250),
  Brightness=3.35,Ambient=Color3.fromRGB(170,181,190),OutdoorAmbient=Color3.fromRGB(198,215,226),
  ClockTime=13,ExposureCompensation=.16,ColorShift_Top=Color3.fromRGB(20,33,48)},
 Deepwood={FogStart=Mood.fogStart,FogEnd=Mood.fogEnd,FogColor=Color3.fromRGB(192,225,246),
  Brightness=3,Ambient=Color3.fromRGB(135,151,123),OutdoorAmbient=Color3.fromRGB(170,190,149),
  ClockTime=15.6,ExposureCompensation=.14,ColorShift_Top=Color3.fromRGB(15,27,40)},
}
local saved,environment,sky,correction,current,atmosphere,bloom
local valleyRestored=false
local function clearOwned()
 if sky then sky:Destroy();sky=nil end
 if correction then correction:Destroy();correction=nil end
 if atmosphere then atmosphere:Destroy();atmosphere=nil end
 if bloom then bloom:Destroy();bloom=nil end
end
profiles.FrozenVale={FogStart=180,FogEnd=700,FogColor=Color3.fromRGB(173,219,245),Brightness=2.65,Ambient=Color3.fromRGB(141,167,190),OutdoorAmbient=Color3.fromRGB(173,200,221),ClockTime=10.2,ExposureCompensation=.05,ColorShift_Top=Color3.fromRGB(12,26,43)}
profiles.EmberCaldera={FogStart=165,FogEnd=650,FogColor=Color3.fromRGB(171,118,104),Brightness=2.75,Ambient=Color3.fromRGB(153,129,136),OutdoorAmbient=Color3.fromRGB(187,152,141),ClockTime=16.4,ExposureCompensation=.12,ColorShift_Top=Color3.fromRGB(30,15,8)}
profiles.Gloamwood={FogStart=145,FogEnd=680,FogColor=Color3.fromRGB(88,110,147),Brightness=2.4,Ambient=Color3.fromRGB(122,138,162),OutdoorAmbient=Color3.fromRGB(131,148,177),ClockTime=0,ExposureCompensation=.25,ColorShift_Top=Color3.fromRGB(12,19,35)}
profiles.HauntedGraveyard={FogStart=140,FogEnd=660,FogColor=Color3.fromRGB(104,124,155),Brightness=2.3,Ambient=Color3.fromRGB(122,137,160),OutdoorAmbient=Color3.fromRGB(148,161,183),ClockTime=.1,ExposureCompensation=.3,ColorShift_Top=Color3.fromRGB(21,22,35)}
local grades={
 Lobby={tint=Color3.fromRGB(255,254,247),contrast=.025,saturation=.24},
 Deepwood={tint=Color3.fromRGB(255,252,245),contrast=.06,saturation=.17,density=.09,haze=.11},
 Gloamwood={tint=Color3.fromRGB(227,247,255),contrast=.075,saturation=.14,density=.16,haze=.28},
 FrozenVale={tint=Color3.fromRGB(239,251,255),contrast=.07,saturation=.12,density=.21,haze=.39},
 EmberCaldera={tint=Color3.fromRGB(255,244,238),contrast=.09,saturation=.17,density=.17,haze=.52},
 HauntedGraveyard={tint=Color3.fromRGB(232,239,255),contrast=.08,saturation=.14,density=.17,haze=.32},
}
function Mood.currentMode() return current end
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
 sky=Instance.new('Sky');sky.Name='TLTClearDaySky';sky.CelestialBodiesShown=true;sky.StarCount=(mode=='Gloamwood' or mode=='HauntedGraveyard') and 900 or 0;sky.MoonAngularSize=11;sky.Parent=Lighting
 local grade=grades[mode]
 correction=Instance.new('ColorCorrectionEffect');correction.Name='TLTVividDaylight'
 correction.Brightness=.015;correction.Contrast=grade.contrast
 correction.Saturation=grade.saturation;correction.TintColor=grade.tint;correction.Parent=Lighting
 if grade.density then
  -- Atmosphere blends sky and terrain; a short white fog curtain hid the authored skyline.
  atmosphere=Instance.new('Atmosphere');atmosphere.Name='TLTRegionalAtmosphere'
  atmosphere.Color=profiles[mode].FogColor;atmosphere.Decay=profiles[mode].Ambient
  atmosphere.Density=grade.density
  atmosphere.Offset=.1;atmosphere.Haze=grade.haze;atmosphere.Glare=.03;atmosphere.Parent=Lighting
  bloom=Instance.new('BloomEffect');bloom.Name='TLTLocalGlow';bloom.Intensity=.14;bloom.Size=14;bloom.Threshold=1.2;bloom.Parent=Lighting
 end
 current=mode
end
function Mood.restoration(s)
 valleyRestored=s and s.clears and s.clears['FV-07']==true or false
 if current=='FrozenVale'and atmosphere then
  atmosphere.Density=valleyRestored and .10 or grades.FrozenVale.density
  atmosphere.Haze=valleyRestored and .21 or grades.FrozenVale.haze
  Lighting.FogStart=valleyRestored and 400 or profiles.FrozenVale.FogStart
  Lighting.FogEnd=valleyRestored and 1200 or profiles.FrozenVale.FogEnd
 end
end
function Mood.start()
 local p=game:GetService('Players').LocalPlayer
 local Biome=require(game:GetService('ReplicatedStorage').Shared.CampaignBiome)
 local function apply()
  local phase=p:GetAttribute('K0SessionPhase')
  local lobby=workspace:GetAttribute('TLTServerRole')~='Battle' and (phase=='Lobby' or phase=='LoadingLobby' or phase=='ReturningLobby')
  local root=p.Character and p.Character:FindFirstChild('HumanoidRootPart')
  local region=root and Biome.at(root.Position.X,root.Position.Z)or 'Deepwood'
  Mood.update(lobby and 'Lobby' or phase=='Tutorial' and p:GetAttribute('TLTRoute')~='Training' and region or nil)
  if current=='FrozenVale'then Mood.restoration({clears={['FV-07']=valleyRestored}})end
 end
 p:GetAttributeChangedSignal('K0SessionPhase'):Connect(apply);p:GetAttributeChangedSignal('TLTRoute'):Connect(apply)
 workspace:GetAttributeChangedSignal('TLTServerRole'):Connect(apply)
 local elapsed=0;game:GetService('RunService').Heartbeat:Connect(function(dt)elapsed=elapsed+dt;if elapsed>.5 then elapsed=0;apply()end end);apply()
end
return Mood
