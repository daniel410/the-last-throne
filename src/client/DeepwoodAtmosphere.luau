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
profiles.FrozenVale={FogStart=145,FogEnd=380,FogColor=Color3.fromRGB(207,229,243),Brightness=3.1,Ambient=Color3.fromRGB(150,173,194),OutdoorAmbient=Color3.fromRGB(185,209,228),ClockTime=12,ExposureCompensation=.12,ColorShift_Top=Color3.fromRGB(12,26,43)}
profiles.EmberCaldera={FogStart=170,FogEnd=420,FogColor=Color3.fromRGB(191,163,147),Brightness=3,Ambient=Color3.fromRGB(161,146,134),OutdoorAmbient=Color3.fromRGB(194,177,158),ClockTime=14,ExposureCompensation=.12,ColorShift_Top=Color3.fromRGB(30,15,8)}
profiles.Gloamwood={FogStart=160,FogEnd=420,FogColor=Color3.fromRGB(130,153,165),Brightness=2.6,Ambient=Color3.fromRGB(117,140,145),OutdoorAmbient=Color3.fromRGB(151,179,167),ClockTime=16,ExposureCompensation=.15,ColorShift_Top=Color3.fromRGB(14,24,30)}
profiles.HauntedGraveyard={FogStart=160,FogEnd=420,FogColor=Color3.fromRGB(158,169,191),Brightness=2.6,Ambient=Color3.fromRGB(130,144,167),OutdoorAmbient=Color3.fromRGB(170,186,202),ClockTime=16.5,ExposureCompensation=.15,ColorShift_Top=Color3.fromRGB(21,22,35)}
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
  local root=p.Character and p.Character:FindFirstChild('HumanoidRootPart')
  local region=root and root.Position.Z<-15000 and 'HauntedGraveyard' or root and root.Position.Z<-11200 and 'Gloamwood' or root and root.Position.Z<-7600 and 'EmberCaldera' or root and root.Position.Z<-3800 and 'FrozenVale' or 'Deepwood'
  Mood.update(lobby and 'Lobby' or phase=='Tutorial' and p:GetAttribute('TLTRoute')~='Training' and region or nil)
 end
 p:GetAttributeChangedSignal('K0SessionPhase'):Connect(apply);p:GetAttributeChangedSignal('TLTRoute'):Connect(apply)
 workspace:GetAttributeChangedSignal('TLTServerRole'):Connect(apply)
 local elapsed=0;game:GetService('RunService').Heartbeat:Connect(function(dt)elapsed=elapsed+dt;if elapsed>.5 then elapsed=0;apply()end end);apply()
end
return Mood
