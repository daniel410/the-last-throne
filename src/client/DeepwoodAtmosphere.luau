-- Client-local biome lighting. Restore the authored environment outside the
-- campaign/lobby, including when entering the separate training route.
local Lighting=game:GetService('Lighting')
local Mood={fogStart=180,fogEnd=620}
local profiles={
 Lobby={FogStart=10000,FogEnd=100000,FogColor=Color3.fromRGB(188,221,250),
  Brightness=3.2,Ambient=Color3.fromRGB(157,169,177),OutdoorAmbient=Color3.fromRGB(189,208,218),
  ClockTime=13,ExposureCompensation=.16,ColorShift_Top=Color3.fromRGB(20,33,48)},
 Deepwood={FogStart=Mood.fogStart,FogEnd=Mood.fogEnd,FogColor=Color3.fromRGB(192,225,246),
  Brightness=2.7,Ambient=Color3.fromRGB(107,126,95),OutdoorAmbient=Color3.fromRGB(149,171,127),
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
profiles.FrozenVale={FogStart=180,FogEnd=700,FogColor=Color3.fromRGB(180,208,227),Brightness=2.4,Ambient=Color3.fromRGB(130,154,178),OutdoorAmbient=Color3.fromRGB(157,183,207),ClockTime=10.2,ExposureCompensation=0,ColorShift_Top=Color3.fromRGB(12,26,43)}
profiles.EmberCaldera={FogStart=165,FogEnd=650,FogColor=Color3.fromRGB(177,132,109),Brightness=2.5,Ambient=Color3.fromRGB(145,116,109),OutdoorAmbient=Color3.fromRGB(176,139,116),ClockTime=16.4,ExposureCompensation=.12,ColorShift_Top=Color3.fromRGB(30,15,8)}
profiles.Gloamwood={FogStart=120,FogEnd=600,FogColor=Color3.fromRGB(112,139,157),Brightness=2.4,Ambient=Color3.fromRGB(114,138,124),OutdoorAmbient=Color3.fromRGB(138,158,143),ClockTime=0,ExposureCompensation=.38,ColorShift_Top=Color3.fromRGB(14,24,30)}
profiles.HauntedGraveyard={FogStart=140,FogEnd=660,FogColor=Color3.fromRGB(104,124,155),Brightness=2.3,Ambient=Color3.fromRGB(112,128,155),OutdoorAmbient=Color3.fromRGB(137,152,178),ClockTime=.1,ExposureCompensation=.3,ColorShift_Top=Color3.fromRGB(21,22,35)}
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
 correction=Instance.new('ColorCorrectionEffect');correction.Name='TLTVividDaylight'
 correction.Brightness=.015;correction.Contrast=mode=='Lobby' and .025 or .09;correction.Saturation=mode=='Lobby' and .24 or mode=='Deepwood' and .10 or .04
 correction.TintColor=mode=='Gloamwood' and Color3.fromRGB(219,237,225) or mode=='HauntedGraveyard' and Color3.fromRGB(216,228,246) or Color3.fromRGB(244,250,255);correction.Parent=Lighting
 if mode~='Lobby' then
  -- Atmosphere blends sky and terrain; a short white fog curtain hid the authored skyline.
  atmosphere=Instance.new('Atmosphere');atmosphere.Name='TLTRegionalAtmosphere'
  atmosphere.Color=profiles[mode].FogColor;atmosphere.Decay=profiles[mode].Ambient
  atmosphere.Density=(mode=='Gloamwood' or mode=='HauntedGraveyard') and .22 or .24
  atmosphere.Offset=.1;atmosphere.Haze=mode=='EmberCaldera' and .9 or .45;atmosphere.Glare=.03;atmosphere.Parent=Lighting
  bloom=Instance.new('BloomEffect');bloom.Name='TLTLocalGlow';bloom.Intensity=.14;bloom.Size=14;bloom.Threshold=1.2;bloom.Parent=Lighting
 end
 current=mode
end
function Mood.restoration(s)
 valleyRestored=s and s.clears and s.clears['FV-07']==true or false
 if current=='FrozenVale'and atmosphere then
  atmosphere.Density=valleyRestored and .12 or .24
  atmosphere.Haze=valleyRestored and .25 or .45
  Lighting.FogStart=valleyRestored and 400 or profiles.FrozenVale.FogStart
  Lighting.FogEnd=valleyRestored and 1200 or profiles.FrozenVale.FogEnd
 end
end
function Mood.start()
 local p=game:GetService('Players').LocalPlayer
 local function apply()
  local phase=p:GetAttribute('K0SessionPhase')
  local lobby=workspace:GetAttribute('TLTServerRole')~='Battle' and (phase=='Lobby' or phase=='LoadingLobby' or phase=='ReturningLobby')
  local root=p.Character and p.Character:FindFirstChild('HumanoidRootPart')
  local region=root and root.Position.Z<-15000 and 'HauntedGraveyard' or root and root.Position.Z<-11200 and 'Gloamwood' or root and root.Position.Z<-7600 and 'EmberCaldera' or root and root.Position.Z<-3800 and 'FrozenVale' or 'Deepwood'
  Mood.update(lobby and 'Lobby' or phase=='Tutorial' and p:GetAttribute('TLTRoute')~='Training' and region or nil)
  if current=='FrozenVale'then Mood.restoration({clears={['FV-07']=valleyRestored}})end
 end
 p:GetAttributeChangedSignal('K0SessionPhase'):Connect(apply);p:GetAttributeChangedSignal('TLTRoute'):Connect(apply)
 workspace:GetAttributeChangedSignal('TLTServerRole'):Connect(apply)
 local elapsed=0;game:GetService('RunService').Heartbeat:Connect(function(dt)elapsed=elapsed+dt;if elapsed>.5 then elapsed=0;apply()end end);apply()
end
return Mood
