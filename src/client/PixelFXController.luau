-- Basic/common release accents, including misses and non-damaging skills.
-- Advanced pulses and confirmed hits are wired at their existing event consumers.
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local RS=game:GetService("ReplicatedStorage")
local Config=require(RS.Shared.K0Config)
local Catalog=require(RS.Shared.PixelFXCatalog)
local Assets=require(RS.Shared.PixelFXAssets)
local FX=require(script.Parent.PixelFX)
local Controller={}
local seen=setmetatable({},{__mode="k"})
local hurt=setmetatable({},{__mode="k"})
local started=false
function Controller.renderCharacter(character,now)
 if character:GetAttribute("K0State")~="Attack" or character:GetAttribute("TLTDeathFalling") then return false end
 local classId=character:GetAttribute("K0ClassId")
 local row=Catalog.get(classId,character:GetAttribute("K0SkillId"))
 if not row or row.definition and row.definition.advanced then return false end
 local profile=Config.BasicAttackProfiles[classId]
 local d=row.definition or profile and profile.attacks[character:GetAttribute("K0Combo") or 1]
 local at=character:GetAttribute("K0AttackStartedAt")
 local seq=character:GetAttribute("K0AttackSeq")
 local root=character:FindFirstChild("HumanoidRootPart")
 if not d or type(at)~="number" or type(seq)~="number" or not root then return false end
 local rate=not row.definition and (character:GetAttribute("K0BasicAttackRate") or 1) or 1
 local beat=Catalog.beat(d,(now-at)*rate)
 if beat==0 then return false end
 local old=seen[character]
 if old and old.seq==seq and old.at==at and old.beat>=beat then return false end
 seen[character]={seq=seq,at=at,beat=beat}
 -- Ranged releases sit near the weapon, not at a guessed target.
 local ranged=classId=="elf" or classId=="mage" and row.definition and row.definition.magic
 local position=root.Position+root.CFrame.LookVector*(ranged and 1.8 or 2.4)
 return FX.emit(row.key,position,row.definition and 2.5 or 1.6,.32,{character=character,seq=seq})
end
function Controller.renderHurt(character,now)
 local specific=character:GetAttribute('K0PatternHurtAt');if type(specific)=='number' and now-specific<.3 then return false end
 local at=character:GetAttribute("K0HurtAt")
 if type(at)~="number" or at~=at or hurt[character]==at or now-at<0 or now-at>.2 then return false end
 local damage=character:GetAttribute("K0HurtDamage")
 local root=character:FindFirstChild("HumanoidRootPart")
 if not root or type(damage)~="number" or damage<=0 then return false end
 hurt[character]=at
 return FX.emit("enemy",root.Position+Vector3.new(0,.4,0),1.6,.25)
end
function Controller.start()
 if started then return end;started=true
 -- Async preloading never blocks combat input; failed assets keep existing 3D fallbacks.
 task.spawn(function()
  local list={};for _,id in pairs(Assets) do table.insert(list,id) end
  pcall(function() game:GetService("ContentProvider"):PreloadAsync(list) end)
 end)
 Run.RenderStepped:Connect(function()
  local now=workspace:GetServerTimeNow()
  for _,player in ipairs(Players:GetPlayers()) do
   if player.Character then Controller.renderCharacter(player.Character,now);Controller.renderHurt(player.Character,now) end
  end
 end)
end
return Controller
