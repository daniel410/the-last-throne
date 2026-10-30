-- Native, bounded geometry derived from the Dawnspire concept. No remote assets.
local A={}
A.color={stone=Color3.fromRGB(187,183,165),pale=Color3.fromRGB(226,220,197),dark=Color3.fromRGB(61,76,101),
 gold=Color3.fromRGB(229,181,70),blue=Color3.fromRGB(27,65,136),wood=Color3.fromRGB(98,62,36),iron=Color3.fromRGB(66,72,83),
 purple=Color3.fromRGB(172,86,255),cream=Color3.fromRGB(255,240,199),fire=Color3.fromRGB(255,151,54)}
function A.builder(model,origin)
 return function(name,size,offset,color,material,solid,rotation)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=CFrame.new(origin+offset)*(rotation or CFrame.identity)
  p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=solid==true;p.CanQuery=solid==true;p.CanTouch=false
  p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.CastShadow=material~=Enum.Material.Neon
  p:SetAttribute('TLTDecorative',solid~=true);p.Parent=model;return p
 end
end
function A.sign(part,spec)
 local gui=Instance.new('SurfaceGui');gui.Name='FacilitySign';gui.Face=Enum.NormalId.Back;gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=40;gui.LightInfluence=0;gui.AutoLocalize=false;gui.Parent=part
 for i,s in ipairs({{spec.title,.08,.47,A.color.gold},{spec.subtitle,.57,.3,A.color.cream}}) do
  local t=Instance.new('TextLabel');t.Name=i==1 and 'Title' or 'Subtitle';t.Position=UDim2.fromScale(.04,s[2]);t.Size=UDim2.fromScale(.92,s[3]);t.BackgroundTransparency=1
  t.Text=s[1];t.TextColor3=s[4];t.TextScaled=true;t.Font=Enum.Font.GothamBold;t.AutoLocalize=false;t:SetAttribute('TextKey',spec.key..(i==1 and '.title' or '.subtitle'));t.Parent=gui
 end
end
function A.prompt(part,spec)
 local p=Instance.new('ProximityPrompt');p.Name=spec.id..'Interaction';p.Style=Enum.ProximityPromptStyle.Custom;p.ObjectText=spec.title;p.ActionText=spec.action
 p.KeyboardKeyCode=Enum.KeyCode.F;p.GamepadKeyCode=Enum.KeyCode.ButtonX;p.MaxActivationDistance=11;p.HoldDuration=0;p.RequiresLineOfSight=false
 p:SetAttribute('LobbyFacility',spec.id);p:SetAttribute('TextKey',spec.key..'.action');p.Parent=part;return p
end
function A.light(part,color,range,brightness)
 local l=Instance.new('PointLight');l.Color=color;l.Range=range;l.Brightness=brightness;l.Shadows=false;l:SetAttribute('TLTDecorative',true);l.Parent=part;return l
end
function A.crown(make,offset,scale)
 make('CrownBand',Vector3.new(3*scale,.45*scale,.35),offset,A.color.gold,Enum.Material.Metal)
 for _,x in ipairs({-1,0,1}) do
  make('CrownPoint',Vector3.new(.65*scale,1.4*scale,.35),offset+Vector3.new(x*scale,.65*scale,0),A.color.gold,Enum.Material.Metal,false,CFrame.Angles(0,0,math.rad(x*18)))
 end
end
return A
