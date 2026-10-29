-- Native UI symbols for action families; no concept image is sliced into runtime icons.
local Glyph={}
local function shape(p,n,x,y,w,h,color,rotation,round)
 local f=Instance.new('Frame');f.Name=n;f.Position=UDim2.fromOffset(x,y);f.Size=UDim2.fromOffset(w,h);f.BackgroundColor3=color;f.BorderSizePixel=0;f.Rotation=rotation or 0;f.Parent=p
 if round then local c=Instance.new('UICorner');c.CornerRadius=UDim.new(round,0);c.Parent=f end
 return f
end
local function ring(p,x,y,size,color)
 local f=shape(p,'Arc',x,y,size,size,color,0,1);f.BackgroundTransparency=1
 local s=Instance.new('UIStroke');s.Color=color;s.Thickness=3;s.Parent=f
 return f
end
function Glyph.draw(parent,classId,base,size,unlocked)
 local root=Instance.new('Frame');root.Name='SkillGlyph';root.Size=UDim2.fromOffset(64,64);root.Position=UDim2.new(.5,-size/2,.5,-size/2);root.BackgroundTransparency=1;root.Parent=parent
 local scale=Instance.new('UIScale');scale.Scale=size/64;scale.Parent=root
 local color=unlocked and (base.element=='fire' and Color3.fromRGB(255,190,72) or base.root==3 and classId=='knight' and Color3.fromRGB(255,211,93) or Color3.fromRGB(173,233,255)) or Color3.fromRGB(103,121,146)
 local white=unlocked and Color3.fromRGB(244,253,255) or color
 local family=base.root or base.index or 1
 if classId=='knight' and family==1 then
  shape(root,'ShieldPoint',21,32,24,24,color,45,.12);shape(root,'ShieldFace',14,9,36,32,color,0,.16)
  shape(root,'ShieldInset',20,13,24,27,Color3.fromRGB(26,111,213),0,.12);shape(root,'ShieldCrest',30,14,4,29,white)
 elseif classId=='knight' and family==3 then
  shape(root,'Head',25,9,15,15,color,0,1);shape(root,'Body',21,28,23,23,color,0,.2)
  shape(root,'LeftArm',7,27,12,27,color,-27,.3);shape(root,'RightArm',46,27,12,27,color,27,.3)
 elseif classId=='elf' then
  local count=family==1 and 1 or 3
  for i=1,count do
   local x=count==1 and 30 or 12+(i-1)*18
   shape(root,'Arrow',x,19,4,34,white,0,.1);shape(root,'ArrowHead',x-5,10,14,14,color,45,.08)
  end
 elseif classId=='dwarf' and family~=3 then
  shape(root,'AxeHandle',29,12,6,43,white,22,.2);shape(root,'AxeBlade',10,10,25,22,color,22,.15);shape(root,'AxeEdge',6,9,9,26,white,22,.15)
 elseif classId=='mage' and family==1 then
  shape(root,'BoltTop',28,6,12,30,color,28,.1);shape(root,'BoltLow',22,29,12,29,white,28,.1);shape(root,'BoltBridge',22,27,23,9,color)
 elseif classId=='mage' and family==2 then
  shape(root,'WaterTip',22,10,23,23,color,45,.2);shape(root,'WaterDrop',15,24,37,33,color,0,1);shape(root,'WaterShine',22,30,5,16,white,20,.5)
 else
  ring(root,9,11,45,color);ring(root,17,21,28,white);ring(root,26,30,11,color)
  shape(root,'SweepTip',41,9,12,12,white,45,.1)
 end
 return root
end
return Glyph
