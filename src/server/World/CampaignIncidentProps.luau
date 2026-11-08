-- Compact authored incident objects; original core quest art is untouched.
local M={}
local V=Vector3.new
function M.create(parent,chapter,goal,step,at)
 local m=Instance.new('Model');m.Name=chapter..'_'..goal..'_'..step.id..'_Art';m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 local wood=Color3.fromRGB(105,78,47);local iron=Color3.fromRGB(101,111,112);local gold=Color3.fromRGB(220,185,103);local ink=Color3.fromRGB(68,77,91)
 local function part(name,size,offset,color,material)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=CFrame.new(at+offset);p.Color=color;p.Material=material or Enum.Material.Wood;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=m;return p
 end
 local kind=step.kind
 if kind=='ledger'then
  part('Desk',V(4,.4,3),V(0,2,0),wood);for _,x in ipairs({-1.5,1.5})do part('DeskLeg',V(.3,2,.3),V(x,1,0),iron)end
  part('OpenRecord',V(2,.08,1.5),V(0,2.25,0),Color3.fromRGB(232,218,177));for i=1,3 do part('RecordLine',V(1.4,.03,.05),V(0,2.31,-.5+i*.25),ink)end
 elseif kind=='lever'then
  part('MechanismBase',V(3,1.2,2.5),V(0,.6,0),iron,Enum.Material.Metal)
  part('ControlPost',V(.45,2.4,.45),V(0,1.7,0),gold,Enum.Material.Metal)
  for _,x in ipairs({-1,1})do part('ControlGrip',V(1.8,.25,.25),V(x*.5,2.8,0),wood)end
  part('FlowIndicator',V(.4,.4,.5),V(0,1,-1.3),gold,Enum.Material.Neon)
 elseif kind=='lantern'then
  part('LanternPost',V(.45,3.8,.45),V(0,1.9,0),wood);part('LanternHood',V(1.5,.3,1.5),V(0,4,0),iron,Enum.Material.Metal)
  part('LanternGlass',V(.8,1,.8),V(0,3.35,0),gold,Enum.Material.Neon);part('LanternBase',V(1.3,.25,1.3),V(0,2.7,0),iron,Enum.Material.Metal)
 elseif kind=='rune'then
  part('CarvedStone',V(2.8,3,1),V(0,1.5,0),iron,Enum.Material.Slate)
  part('SignalMark',V(.3,1.8,.12),V(0,1.5,-.6),gold,Enum.Material.Neon);part('SignalMark',V(1.2,.3,.12),V(0,1.8,-.6),gold,Enum.Material.Neon)
 elseif kind=='bindings'then
  part('Anchor',V(2,1.3,2),V(0,.65,0),wood);for _,x in ipairs({-.6,.6})do part('RopeLoop',V(.18,.25,2.3),V(x,1.25,0),gold,Enum.Material.Fabric)end
 elseif kind=='tracks'then
  for i=1,3 do part('TrailMark',V(1,.06,1.5),V(i%2==0 and .7 or -.7,.05,(i-2)*2),gold,Enum.Material.Ground)end
 else
  part('RecoveredCase',V(3,1.6,2.2),V(0,.8,0),wood);for _,x in ipairs({-.9,.9})do part('CaseBand',V(.18,1.7,2.3),V(x,.8,0),iron,Enum.Material.Metal)end
 end
 m:SetAttribute('ExpansionStepEvent',chapter..':'..goal);m:SetAttribute('ExpansionStepChapter',chapter);m:SetAttribute('ExpansionStepIndex',tonumber(step.id:match('%d+')))
 for _,p in ipairs(m:GetChildren())do if p:IsA('BasePart')then p:SetAttribute('ExpansionOriginalColor',p.Color)end end
 m.Parent=parent;return m
end
return M
