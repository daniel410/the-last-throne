-- Visual adapter only. Existing Part carriers and saved journal keys stay stable.
local Env=require(script.Parent.DeepwoodEnvironment)
local K=require(script.Parent.EpicEnvironmentKit)
local F={}
local V=Vector3.new
local function tag(model,key)
 model:SetAttribute('LateStoryHideKey',key)
 for _,p in ipairs(model:GetDescendants())do if p:IsA('BasePart')then p:SetAttribute('LateStoryHideKey',key)end end
end
function F.create(props,region,center)
 if props:FindFirstChild('InvasionPortalVisual')then return end
 local portal=Env.portal(props,center+V(0,0,-175));portal.Name='InvasionPortalVisual'
 portal:ScaleTo(portal:GetScale()*2.2)
 local cf,size=portal:GetBoundingBox()
 portal:PivotTo(CFrame.new(center+V(0,size.Y/2,-175))*cf:ToObjectSpace(portal:GetPivot()))
 tag(portal,'HG-07:portal')
 local heart=Instance.new('Model');heart.Name='CrownheartVisual';heart.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;heart.Parent=props
 local p=center+V(65,9,14);local w=4
 for i=0,3 do
  local yaw=CFrame.Angles(0,i*math.pi/2,0)
  local color=i%2==0 and Color3.fromRGB(116,220,246)or Color3.fromRGB(161,241,255)
  K.part(heart,'CrownheartFacet',V(w/2,4,w/2),CFrame.new(p+V(0,1,0))*yaw*CFrame.new(-w/4,0,w/4),color,Enum.Material.Neon,'Corner')
  K.part(heart,'CrownheartBaseFacet',V(w/2,3,w/2),CFrame.new(p-V(0,1,0))*CFrame.Angles(math.pi,0,0)*yaw*CFrame.new(-w/4,0,w/4),color,Enum.Material.Glass,'Corner')
 end
 tag(heart,'HG-07:crownheart')
 local throne=Instance.new('Model');throne.Name='CrownThroneTrim';throne.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;throne.Parent=region
 local stone=K.palette.HauntedGraveyard.rock;local gold=Color3.fromRGB(172,151,103)
 for _,side in ipairs({-1,1})do
  K.part(throne,'ThroneArm',V(3,9,16),center+V(65+side*10,5,16),stone,Enum.Material.Slate)
  K.part(throne,'ThroneUpright',V(2.5,28,3),center+V(65+side*10,14,24),gold,Enum.Material.Metal)
  K.part(throne,'ThroneFinial',V(5,8,5),CFrame.new(center+V(65+side*10,31,24))*CFrame.Angles(0,side*.3,0),stone,Enum.Material.Slate,'Corner')
 end
 for i=-2,2 do K.part(throne,'CrownCrest',V(3,5+math.abs(i)*2,3),center+V(65+i*4,27,24),gold,Enum.Material.Metal)end
end
return F
