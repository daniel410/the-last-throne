-- Isolated local Studio visual review. Native rigs and the shipping renderers,
-- with manual joint FK in Edit mode. Does not grant a player skills or save data.
assert(game.PlaceId==0,"Local review file only")
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local Visual=require(Client.K0SwordVisual)
local Bow=require(Client.K0BowMotion)
local Appearance=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local P=require(game.ReplicatedStorage.Shared.SkillPresentation)
local H={templates={},rows={},report={}}
local palettes={knight={Color3.fromRGB(175,180,190),Color3.fromRGB(55,110,215)},dwarf={Color3.fromRGB(130,90,55),Color3.fromRGB(200,120,50)},elf={Color3.fromRGB(70,140,70),Color3.fromRGB(70,140,70)},mage={Color3.fromRGB(90,50,140),Color3.fromRGB(70,40,110)}}
local folder=Instance.new("Folder");folder.Name="HeroSkillReview";folder.Parent=workspace;H.folder=folder
local camera=workspace.CurrentCamera
camera.FieldOfView=36
local light=game.Lighting
light.ClockTime=12;light.Brightness=2;light.Ambient=Color3.fromRGB(170,170,180);light.OutdoorAmbient=Color3.fromRGB(180,180,190)
light.GlobalShadows=false
local function label(parent,text,position,size)
 local anchor=Instance.new("Part");anchor.Name="ReviewLabel";anchor.Anchored=true;anchor.CanCollide=false;anchor.Transparency=1;anchor.Size=Vector3.one*.1;anchor.CFrame=CFrame.new(position);anchor.Parent=parent
 local gui=Instance.new("BillboardGui");gui.Size=UDim2.fromOffset(size or 300,30);gui.AlwaysOnTop=true;gui.Parent=anchor
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=.2;t.BackgroundColor3=Color3.fromRGB(24,31,43);t.TextColor3=Color3.fromRGB(240,240,245);t.TextSize=14;t.Font=Enum.Font.GothamMedium;t.Text=text;t.Parent=gui
end
function H.template(classId)
 if H.templates[classId] then return H.templates[classId] end
 local desc=Instance.new("HumanoidDescription")
 desc.HeadColor=Color3.fromRGB(226,194,161);desc.LeftLegColor=Color3.fromRGB(65,72,87);desc.RightLegColor=desc.LeftLegColor
 desc.TorsoColor=palettes[classId][1];desc.LeftArmColor=palettes[classId][2];desc.RightArmColor=desc.LeftArmColor
 local c=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,Enum.HumanoidRigType.R15);desc:Destroy()
 c.Name=classId;c.Parent=folder;c:PivotTo(CFrame.new(0,500,0))
 local m=Instance.new("Model");m.Name="ReviewAppearance";m.Parent=c
 assert(Appearance.attachInto(m,c,classId));if classId=="knight" then assert(Appearance.attachShieldInto(m,c)) end
 c:SetAttribute("K0ClassId",classId);c.Humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
 for _,part in ipairs(c:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=false end end
 pcall(function() game.ContentProvider:PreloadAsync(c:GetDescendants()) end)
 H.templates[classId]=c;c.Parent=nil
 return c
end
local function bake(c)
 local joints,offsets={},{}
 for _,j in ipairs(c:GetDescendants()) do
  if (j:IsA("Motor6D") or j:IsA("AnimationConstraint")) and j.Part0 and j.Part1 then joints[j.Part1]=j
  elseif j:IsA("WeldConstraint") and j.Part0 and j.Part1 then offsets[j.Part1]={part=j.Part0,cf=j.Part0.CFrame:ToObjectSpace(j.Part1.CFrame)} end
 end
 local memo={}
 local function frame(p)
  if memo[p] then return memo[p] end
  local j,o=joints[p],offsets[p]
  local cf=j and frame(j.Part0)*j.C0*j.Transform*j.C1:Inverse() or o and frame(o.part)*o.cf or p.CFrame
  memo[p]=cf;return cf
 end
 for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then frame(p) end end
 for p,cf in pairs(memo) do p.Anchored=true;p.CFrame=cf end
 return memo
end
function H.sheet(classId,first,count)
 for _,c in ipairs(folder:GetChildren()) do c:Destroy() end
 H.rows={}
 local template=H.template(classId)
 for row=0,(count or 8)-1 do
  local index=first+row;local d=Config.Skills[classId][index];if not d then break end
  local y=500+(7-row)*8
  local times={d.windup*.65,d.windup+(d.hitDelay or 0)+.015,d.windup+d.active+d.recovery*.6}
  local stats={skill=d.id,name=d.name,profile=P.get(d),frames={}}
  for col,age in ipairs(times) do
   local c=template:Clone();c.Name=string.format("%02d_%d_%s",index,col,d.id);c.Parent=folder
   local x=(col-2)*11;c:PivotTo(CFrame.new(x,y,0)*CFrame.Angles(0,math.rad(-20),0))
   c:SetAttribute("K0State","Attack");c:SetAttribute("K0SkillId",d.id);c:SetAttribute("K0Combo",1)
   c:SetAttribute("K0AttackKind",classId=="mage" and "Arcane" or "Basic")
   c:SetAttribute("K0AttackStartedAt",100);c:SetAttribute("K0SkillStartedAt",100);c:SetAttribute("K0AttackSeq",index)
   c:SetAttribute("K0AttackPhase",age<d.windup and "Windup" or age<d.windup+d.active and "Active" or "Recovery")
   if classId=="elf" then
    c:SetAttribute("K0RapidShotCount",1);c:SetAttribute("K0RapidShotAt",100+d.windup)
    if d.advanced and d.pulses>1 and col>1 then Bow.confirmPulse(c,d.id,1,index,100+d.windup,100,100+age) end
   end
   if d.branch=="gunner" then require(Client.AdvancedSkillVisual).play(c,d.id,c.HumanoidRootPart.Position,c.HumanoidRootPart.Position+Vector3.new(0,0,-20),0,nil,index) end
   Visual.renderArms(c,1/60,100+age);bake(c);Visual.renderCharacter(c,1/60,100+age)
   local frames=bake(c);local root=c.HumanoidRootPart
   local weapon=c:FindFirstChild("Weapon",true) or c:FindFirstChild("Staff",true) or c:FindFirstChild("Bow",true)
   local tip=c:FindFirstChild("WeaponTip",true)
   stats.frames[col]={age=age,tip=tip and {root.CFrame:PointToObjectSpace(tip.WorldPosition).X,root.CFrame:PointToObjectSpace(tip.WorldPosition).Y,root.CFrame:PointToObjectSpace(tip.WorldPosition).Z}}
   label(c,string.format("%02d %s | %s",index,d.name,({"READY","CONTACT","RECOVER"})[col]),Vector3.new(x,y-3.7,-.5),330)
  end
  table.insert(H.rows,stats);task.wait()
 end
 camera.CFrame=CFrame.lookAt(Vector3.new(9,528,105),Vector3.new(0,528,0))
 H.report[classId.."_"..first]=H.rows
 return {classId=classId,first=first,count=#H.rows,camera={9,528,105},target={0,528,0},rows=H.rows}
end
return H
