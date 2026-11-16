-- Local Studio fixture. The driver installs review-hero-skills-studio as a ModuleScript.
assert(game.PlaceId==0 and game.GameId==0 and #game.Players:GetPlayers()==0)
local client=game.StarterPlayer.StarterPlayerScripts.Client
local rigs=require(game.ServerStorage.HeroReviewRigs)
local config=require(game.ReplicatedStorage.Shared.K0Config)
local catalog=require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local suffix=_G.HeroActionBefore and "Before" or ""
local function renderer(name) return require(client[name..suffix]) end
local pixel, controller, hero=renderer("PixelFX"),renderer("PixelFXController"),renderer("HeroVFX")
local visual, weapon, wind=renderer("AdvancedSkillVisual"),renderer("K0SwordVisual"),renderer("WindLanceVisual")
local armor=require(game.ServerScriptService.Server.Cosmetics.ArmorAppearance)
local rows={
 "knight.common.whirlwind","dwarf.common.overhead","elf.common.aimed","mage.common.water_ball",
 "mage.cryo.eternal_tempest","mage.pyro.caldera_s_judgment","knight","dwarf","elf","mage",
}
local ages={.015,.055,.095,.135,.175,.215,.255,.295}
if _G.HeroActionMotion then
 rows={}
 for _,id in {"knight.common.whirlwind","dwarf.common.overhead","elf.common.aimed","mage.common.water_ball"} do
  for _ in ages do table.insert(rows,id) end
 end
elseif _G.HeroActionCatalog then
 rows={}
 for _,class in {"knight","dwarf","elf","mage"} do
  for _,skill in config.Skills[class] do table.insert(rows,skill.id) end
 end
end
local floor=Instance.new("Part")
floor.Anchored=true;floor.Size=Vector3.new(240,1,240);floor.Position=Vector3.new(0,-.5,0)
floor.Material=Enum.Material.Slate;floor.Color=Color3.fromRGB(49,57,67);floor.Parent=workspace
game.Lighting.ClockTime=16;game.Lighting.Brightness=2
local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=43
if not game.RunService:IsRunning() then game.RunService:Run() end

local function capture(index,id,title)
 local done=false
 game.CaptureService:CaptureScreenshot(function(content)
  local img=game.AssetService:CreateEditableImageAsync(Content.fromUri(content))
  local src=img:ReadPixelsBuffer(Vector2.zero,img.Size)
  local width=_G.HeroActionCatalog and 320 or 480
  local height=math.floor(width*img.Size.Y/img.Size.X+.5)
  local pixels={}
  for y=0,height-1 do for x=0,width-1 do
   local offset=4*(math.floor(y*img.Size.Y/height)*img.Size.X+math.floor(x*img.Size.X/width))
   pixels[#pixels+1]=string.format("%02x%02x%02x",buffer.readu8(src,offset),buffer.readu8(src,offset+1),buffer.readu8(src,offset+2))
  end end
  local packed=table.concat(pixels)
  print("CURATED_META "..game.HttpService:JSONEncode({index=index,id=id,name=title,width=width,height=height}))
  for i=1,#packed,20000 do
   print("CURATED_RGB "..index.." "..packed:sub(i,i+19999))
   if (i-1)%120000==0 then task.wait(.08) end
  end
  img:Destroy();done=true
 end)
 local deadline=os.clock()+12
 repeat task.wait(.03) until done or os.clock()>deadline
 assert(done,"Screenshot timeout: "..id)
end

for index,id in rows do
 local row=catalog.byId[id]
 local class=row and row.classId or id
 local skill=row and row.definition
 local d=skill or config.BasicAttackProfiles[class].attacks[1]
 local actor=rigs.template(class):Clone();actor.Parent=workspace
 for suffixName,item in {Head="traveler_hood",Body="traveler_coat",Hands="traveler_gloves",Feet="traveler_boots"} do
  actor:SetAttribute("TLTEquipped"..suffixName,item)
 end
 armor.sync(actor)
 actor.HumanoidRootPart.Anchored=true
 game.ContentProvider:PreloadAsync(actor:GetDescendants())
 task.wait(.15)
 actor:PivotTo(CFrame.new(0,3,0));local root=actor.HumanoidRootPart;root.Anchored=true
 local origin=root.Position
 local at=workspace:GetServerTimeNow()
 local age=d.windup+(d.hitDelay or 0)+.005
 actor:SetAttribute("K0State","Attack");actor:SetAttribute("K0SkillId",skill and id)
 actor:SetAttribute("K0Combo",1);actor:SetAttribute("K0AttackKind",skill and skill.magic and "Arcane" or "Basic")
 actor:SetAttribute("K0AttackPhase","Active");actor:SetAttribute("K0AttackSeq",index)
 actor:SetAttribute("K0AttackStartedAt",at-age);actor:SetAttribute("K0SkillStartedAt",at-age)
 local center=origin+root.CFrame.LookVector*math.min(d.range or 7,10)
 if d.form=="area" or d.form=="self" or id=="knight.common.whirlwind" then center=origin end
 weapon.renderArms(actor,1/60,at);rigs.bake(actor)
 local before={};for _,obj in workspace:GetChildren() do before[obj]=true end
 weapon.renderCharacter(actor,1/60,at);rigs.bake(actor)
 local points={center,center+Vector3.new(2,0,-1)}
 if skill and d.advanced then visual.play(actor,id,origin,center,1,points,index,at,at-age)
 else
  assert(controller.renderCharacter(actor,at),"Missing release: "..id)
  -- Melee common skills are already rendered by the weapon entry point.
  if skill and hero.count()==0 then hero.skill(actor,id,origin,center,1,points) end
 end
 local sample=_G.HeroActionMotion and ages[(index-1)%#ages+1] or .085
 hero.step(at+sample);pixel.step(sample);wind.step(at+sample)
 local focus=(origin+center)*.5+Vector3.yAxis*(d.ultimate and 1.6 or .3)
 local distance=d.ultimate and 21 or 11
 camera.CFrame=CFrame.lookAt(focus+Vector3.new(.88,.52,.82)*distance,focus)
 local clones={}
 for _,obj in workspace:GetChildren() do
  if not before[obj] then table.insert(clones,obj:Clone());obj:Destroy() end
 end
 hero.clear();pixel.clear();wind.clear()
 local frozen=Instance.new("Folder");frozen.Parent=workspace
 for _,obj in clones do obj.Parent=frozen end
 game.ContentProvider:PreloadAsync(frozen:GetDescendants())
 for _,e in frozen:GetDescendants() do
  if e:IsA("ParticleEmitter") then e:Clear();e:Emit(e:GetAttribute("ReviewBurstCount") or 0) end
 end
 task.wait(.08)
 for _,e in frozen:GetDescendants() do if e:IsA("ParticleEmitter") then e.TimeScale=0 end end
 capture(index,id,d.name or class.." basic")
 frozen:Destroy();actor:Destroy()
end
print("CURATED_CAPTURE_COMPLETE")
