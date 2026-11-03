-- Personal post-campaign scenery. The server-confirmed hero snapshot is the only trigger.
local M={}
local scene
function M.update(snapshot)
 local hero=snapshot and snapshot.heroId and snapshot.heroes and snapshot.heroes[snapshot.heroId]
 local done=hero and hero.deepwood and hero.deepwood.clears['HG-07']==true
 local lobby=workspace:FindFirstChild('DawnspireLobbyPrototype')
 if not done or not lobby then if scene then scene:Destroy();scene=nil end;return end
 if scene and scene.Parent then return end
 scene=Instance.new('Model');scene.Name='DawnspireHomecoming';scene:SetAttribute('PersonalStoryVisual',true)
 local origin=Vector3.new(0,96,512)
 local function part(name,size,position,color,material)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.Position=origin+position;p.Color=color;p.Material=material or Enum.Material.Slate;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p:SetAttribute('TLTDecorative',true);p.Parent=scene;return p
 end
 part('RestoredCrystalThrone',Vector3.new(12,2,8),Vector3.new(0,1,47),Color3.fromRGB(166,187,207))
 part('CrystalThroneBack',Vector3.new(12,15,3),Vector3.new(0,8,51),Color3.fromRGB(153,211,236),Enum.Material.Glass)
 local heart=part('Crownheart',Vector3.new(3,5,3),Vector3.new(0,8,47),Color3.fromRGB(127,236,255),Enum.Material.Neon)
 local light=Instance.new('PointLight');light.Color=heart.Color;light.Range=28;light.Brightness=1.4;light.Parent=heart
 for i=-3,3 do if i~=0 then
  part('FestivalBanner',Vector3.new(3,7,.3),Vector3.new(i*7,11,54),i%2==0 and Color3.fromRGB(79,133,207) or Color3.fromRGB(222,183,81))
 end end
 local gui=Instance.new('BillboardGui');gui.Name='HomecomingGreeting';gui.Size=UDim2.fromOffset(340,70);gui.StudsOffset=Vector3.new(0,7,0);gui.MaxDistance=70;gui.Parent=heart
 local text=Instance.new('TextLabel');text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Font=Enum.Font.GothamBold;text.TextSize=17;text.TextColor3=Color3.fromRGB(255,235,174);text.TextStrokeTransparency=.15;text.Text='WELCOME HOME, HERO!\nTogether, we brought back the light.';text.AutoLocalize=false;text.Parent=gui
 scene.Parent=lobby
end
return M
