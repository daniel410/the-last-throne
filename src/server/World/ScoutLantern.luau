-- The same three-bar scout light is carried by Finn and reused by his allies.
local L={};local V=Vector3.new
function L.create(parent,cf)
 local m=Instance.new('Model');m.Name='ThreeBarScoutLantern';m:SetAttribute('StoryMotif','FinnThreeBarLight')
 local function part(name,size,offset,color,material)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf*CFrame.new(offset);p.Color=color;p.Material=material or Enum.Material.Metal
  p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=m;return p
 end
 local dark=Color3.fromRGB(82,86,81);local gold=Color3.fromRGB(239,200,98)
 part('LanternBase',V(1.3,.2,1),V(0,-.7,0),dark)
 part('LanternTop',V(1.3,.2,1),V(0,.7,0),dark)
 part('SafeScoutLight',V(.8,1,.6),V(0,0,0),gold,Enum.Material.Neon)
 for i=-1,1 do part('RecognizableGoldBar',V(.15,1.4,.15),V(i*.43,0,-.55),gold)end
 part('LanternHandle',V(1,.2,.15),V(0,1.15,0),dark)
 m.WorldPivot=cf;m.Parent=parent;return m
end
function L.attach(actor)
 if actor:FindFirstChild('ThreeBarScoutLantern')then return end
 return L.create(actor,actor.PrimaryPart.CFrame*CFrame.new(1.5,2,-.7))
end
return L
