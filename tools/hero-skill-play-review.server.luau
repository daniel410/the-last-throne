-- Test-only: install in an isolated Place with shipping bootstraps disabled.
local RS=game.ReplicatedStorage
local Config=require(RS.Shared.K0Config)
local templates=game.ServerStorage:WaitForChild("HeroSkillReviewTemplates")
local folder=Instance.new("Folder");folder.Name="LiveHeroSkillReview";folder.Parent=workspace
local control=Instance.new("Folder");control.Name="SkillReviewControl";control.Parent=RS
local remotes=Instance.new("Folder");remotes.Name="Remotes";remotes.Parent=RS
local effect=Instance.new("RemoteEvent");effect.Name="K0AdvancedEffect";effect.Parent=remotes
local stage=Instance.new("Part");stage.Name="ReviewFloor";stage.Size=Vector3.new(180,1,180);stage.Anchored=true;stage.CFrame=CFrame.new(0,497.4,-12);stage.Color=Color3.fromRGB(75,86,92);stage.Parent=folder
local classes={"knight","dwarf","elf","mage"};local heroes={}
for i,classId in ipairs(classes) do
 local c=templates[classId]:Clone();c.Parent=folder;c.Name=classId;c:PivotTo(CFrame.new((i-2.5)*12,501,0))
 c:SetAttribute("K0ClassId",classId);c:SetAttribute("K0Combo",1)
 for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.Anchored=p==c.HumanoidRootPart;p.CanCollide=false end end
 heroes[classId]=c
end

control:SetAttribute("Ready",true)
task.wait(2)
for index=1,32 do
 local longest=0
 for _,classId in ipairs(classes) do
  local c=heroes[classId];local d=Config.Skills[classId][index];local start=workspace:GetServerTimeNow()+.12
  local total=d.windup+d.active+d.recovery;longest=math.max(longest,total)
  c:SetAttribute("K0State","Attack");c:SetAttribute("K0SkillId",d.id);c:SetAttribute("K0AttackSeq",index)
  c:SetAttribute("K0AttackStartedAt",start);c:SetAttribute("K0SkillStartedAt",start)
  c:SetAttribute("K0AttackKind",classId=="mage" and "Arcane" or "Basic");c:SetAttribute("K0Shield",d.shield and 100 or 0)
  if d.advanced then
   task.delay(.12,function()
    local o=c.HumanoidRootPart.Position
    effect:FireAllClients(c,d.id,o,o+Vector3.new(0,0,-math.min(d.range,25)),0,nil,index)
   end)
  end
  for pulse=1,d.pulses or d.shotCount or 1 do
   local due=.12+d.windup+(d.hitDelay or 0)+(pulse-1)*(d.interval or d.shotInterval or .3)
   task.delay(due,function()
    if c:GetAttribute("K0AttackSeq")~=index then return end
    local o=c.HumanoidRootPart.Position;local target=o+Vector3.new(0,0,-math.min(d.range,25))
    if d.advanced then effect:FireAllClients(c,d.id,o,target,pulse,{target},index,workspace:GetServerTimeNow(),start)
    else
     local payload=string.format("%d|%f|%f|%f|%f|%f|%f",index*10+pulse,o.X,o.Y,o.Z,target.X,target.Y,target.Z)
     if classId=="mage" or classId=="dwarf" and d.ranged then c:SetAttribute("K0SpellVisual",payload)
     elseif classId=="elf" then c:SetAttribute("K0ArrowVisual",payload);c:SetAttribute("K0RapidShotAt",workspace:GetServerTimeNow());c:SetAttribute("K0RapidShotCount",pulse) end
    end
   end)
  end
 end
 control:SetAttribute("Index",index)
 task.wait(longest+.65)
end
for _,c in pairs(heroes) do c:SetAttribute("K0State","Idle") end
control:SetAttribute("Completed",128)
print("HERO_SKILL_PLAY_REVIEW completed 128 scripted skill casts; no real combat/data saving")
