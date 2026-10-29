-- Presentation only, driven by server-confirmed branch casts and pulses.
local RS=game:GetService("ReplicatedStorage")
local Tween=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local Config=require(RS.Shared.K0Config)
local Visual={}
local byId={};for _,list in pairs(Config.Skills) do for _,d in ipairs(list) do byId[d.id]=d end end
local colors={steel=Color3.fromRGB(255,215,133),holy=Color3.fromRGB(255,239,167),gun=Color3.fromRGB(255,210,80),bomb=Color3.fromRGB(255,133,57),shell=Color3.fromRGB(255,87,55),nature=Color3.fromRGB(104,238,157),fire=Color3.fromRGB(255,101,41),earth=Color3.fromRGB(235,173,91),water=Color3.fromRGB(73,178,255),frost=Color3.fromRGB(141,234,255),lightning=Color3.fromRGB(222,198,255)}
local active=0
local function part(name,color,shape,size,cf,life)
 if active>=64 then return nil end
 active=active+1
 local p=Instance.new("Part");p.Name=name;p.Shape=shape;p.Size=size;p.CFrame=cf;p.Material=Enum.Material.Neon;p.Color=color;p.Transparency=.25;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=workspace
 Debris:AddItem(p,life);task.delay(life,function() active=math.max(0,active-1) end)
 return p
end
local function disc(center,radius,color,life,warning)
 local p=part(warning and "SkillTelegraph" or "SkillImpact",color,Enum.PartType.Cylinder,Vector3.new(.08,radius*2,radius*2),CFrame.new(center-Vector3.new(0,2.5,0))*CFrame.Angles(0,0,math.pi/2),life)
 if p then p.Transparency=warning and .82 or .65;Tween:Create(p,TweenInfo.new(life),{Transparency=1,Size=p.Size*1.1}):Play() end
end
local function segment(first,last,color,life,width)
 local length=(last-first).Magnitude;if length<.05 then return end
 local p=part("SkillPath",color,Enum.PartType.Block,Vector3.new(width or .18,width or .18,length),CFrame.lookAt((first+last)/2,last),life)
 if p then Tween:Create(p,TweenInfo.new(life),{Transparency=1}):Play() end
end
local function firearm(character,d)
 if d.branch~="gunner" then return end
 local arm=character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
 if not arm then return end
 local existing=character:FindFirstChild("BranchSkillProp");if existing then existing:Destroy() end
 local model=Instance.new("Model");model.Name="BranchSkillProp";model.Parent=character
 local function piece(name,size,offset,color)
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.Color=color;p.Material=Enum.Material.Metal;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true;p.CFrame=arm.CFrame*offset;p.Parent=model
  local weld=Instance.new("WeldConstraint");weld.Part0=arm;weld.Part1=p;weld.Parent=p
 end
 if d.element=="bomb" then piece("Bomb",Vector3.new(.7,.7,.7),CFrame.new(0,-1,-.4),Color3.fromRGB(65,66,72))
 else
  local heavy=d.element=="shell"
  piece("Barrel",Vector3.new(heavy and .65 or .3,heavy and .65 or .3,heavy and 2.5 or 1.7),CFrame.new(0,-.7,-1.1),Color3.fromRGB(68,83,99))
  piece("Stock",Vector3.new(.55,.5,.8),CFrame.new(0,-.7,.1),Color3.fromRGB(111,68,39))
  piece("Muzzle",Vector3.new(.5,.5,.2),CFrame.new(0,-.7,heavy and -2.4 or -2),Color3.fromRGB(215,183,91))
 end
 Debris:AddItem(model,d.windup+d.active+d.recovery)
end
function Visual.start()
 RS:WaitForChild("Remotes"):WaitForChild("K0AdvancedEffect").OnClientEvent:Connect(function(character,id,origin,center,pulse,points)
  local d=byId[id];if not d or not d.advanced or typeof(origin)~="Vector3" or typeof(center)~="Vector3" then return end
  local color=colors[d.element] or colors.steel
  if pulse==0 then
   if character then firearm(character,d) end
   if d.form=="ground" then
    if d.scatter then for i=1,d.pulses do disc(center+Vector3.new((i%2==0 and 1 or -1)*3,0,(i-2)*2),d.radius,color,d.windup+(i-1)*d.interval,true) end
    else disc(center,d.radius,color,d.windup,true) end
   end
   return
  end
  if d.form=="chain" and type(points)=="table" then
   local from=origin;for i=1,math.min(#points,8) do segment(from,points[i],color,.35,.3);from=points[i] end
  elseif d.detonate then segment(origin,center,color,.25,.4);disc(center,d.radius,color,.5,false)
  elseif d.form=="ground" then
   disc(center,d.radius,color,.5,false)
   if d.element=="shell" then segment(center+Vector3.new(0,18,0),center,color,.25,.6)
   elseif d.element=="earth" then for i=-1,1 do local p=part("EarthSpike",color,Enum.PartType.Block,Vector3.new(1,4,1),CFrame.new(center+Vector3.new(i*2,0,0)),.5);if p then Tween:Create(p,TweenInfo.new(.5),{Transparency=1}):Play() end end end
  elseif d.form=="area" or d.form=="cone" then disc(origin,d.form=="area" and d.range or math.min(d.range,10),color,.35,false)
  else segment(d.returning and pulse==2 and center or origin,d.returning and pulse==2 and origin or center,color,.35,d.form=="line" and .4 or .2) end
  if d.shield and character and character:FindFirstChild("HumanoidRootPart") then disc(character.HumanoidRootPart.Position,3,color,.5,false) end
 end)
end
return Visual
