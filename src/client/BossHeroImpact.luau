-- Brief, target-bound boss contact motifs. Cosmetic only: no slow, burn or stun.
local Tween=game:GetService('TweenService')
local Debris=game:GetService('Debris')
local Impact={}
local active={}
local function piece(holder,root,name,offset,size,color,shape)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.Color=color;p.Material=Enum.Material.Neon
 p.Shape=shape or Enum.PartType.Block;p.Transparency=.24;p.Anchored=false;p.Massless=true
 p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
 p.CFrame=root.CFrame*offset
 local weld=Instance.new('WeldConstraint');weld.Part0=root;weld.Part1=p;weld.Parent=p
 p.Parent=holder
 Tween:Create(p,TweenInfo.new(.48,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Transparency=1}):Play()
 return p
end
function Impact.play(target,element,color)
 local root=target:FindFirstChild('HumanoidRootPart');if not root then return end
 for i=#active,1,-1 do if not active[i].Parent then table.remove(active,i)end end
 local old=target:FindFirstChild('BossHeroImpact');if old then old:Destroy()end
 if #active>=12 then active[1]:Destroy();table.remove(active,1)end
 local holder=Instance.new('Folder');holder.Name='BossHeroImpact';holder.Parent=target
 table.insert(active,holder);Debris:AddItem(holder,.55)
 if element=='web'then
  for i=1,4 do
   local side=i<=2 and -1 or 1
   piece(holder,root,'SilkStrand',CFrame.new(0,(i%2-.5)*.5,side*.65)*CFrame.Angles(0,0,math.rad(i%2==0 and 32 or -32)),Vector3.new(2.5,.055,.055),color)
  end
 elseif element=='frost'then
  for i=1,5 do
   local yaw=i*math.pi*2/5
   piece(holder,root,'FrostCrystal',CFrame.new(math.cos(yaw)*1.05,-.5,math.sin(yaw)*.8)*CFrame.Angles(0,yaw,.3),Vector3.new(.18,.8,.22),color)
  end
 elseif element=='fire' or element=='venom'then
  for i=1,5 do
   local yaw=i*math.pi*2/5
   local flame=element=='fire'
   piece(holder,root,flame and 'Ember' or 'VenomDroplet',CFrame.new(math.cos(yaw)*.85,(i%3-1)*.55,math.sin(yaw)*.85),flame and Vector3.new(.15,.65,.15)or Vector3.one*.25,color,flame and Enum.PartType.Block or Enum.PartType.Ball)
  end
 elseif element=='physical'then
  for i=1,4 do
   local side=i<=2 and -1 or 1
   piece(holder,root,'ImpactSlash',CFrame.new(0,(i%2)*.4,side*.7)*CFrame.Angles(0,0,math.rad(i%2==1 and 42 or -42)),Vector3.new(2.3,.09,.06),color)
  end
 else
  for i=1,4 do
   local yaw=i*math.pi*.5
   piece(holder,root,element=='soul' and 'SoulMote' or 'ArcaneSigil',CFrame.new(math.cos(yaw),.2,math.sin(yaw)) * CFrame.Angles(0,yaw,math.pi*.25),Vector3.new(.28,.28,.08),color)
  end
 end
end
return Impact
