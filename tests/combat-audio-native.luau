-- Run in an empty local Studio place with actual source factories in `deps`.
-- tools/assembly is intentionally external to avoid editing any open TD place.
assert(game.PlaceId == 0 and #game:GetService("Players"):GetPlayers() == 0, "Empty local place required")
local Audio, Catalog, Config = deps.Audio, deps.CombatAudioCatalog, deps.K0Config
local result = {checks=0,skills=0,pulses=0,assets={},kind="COMBAT_AUDIO_NATIVE",published=false}
local function check(v,label) result.checks+=1;assert(v,label) end
local function clean()
 for _,v in ipairs(workspace:GetChildren()) do if v.Name=="K0CombatAudioEmitter" then v:Destroy() end end
end
local c=Instance.new("Model");c.Name="QaAudioCharacter";c.Parent=workspace
local root=Instance.new("Part");root.Name="HumanoidRootPart";root.Anchored=true;root.Parent=c
local camera=Instance.new("Camera");camera.CFrame=CFrame.new(0,0,10);camera.Parent=workspace
local oldCamera=workspace.CurrentCamera;workspace.CurrentCamera=camera
local ok,err=xpcall(function()
 local index=0
 for classId,list in pairs(Config.Skills) do
  c:SetAttribute("K0ClassId",classId)
  for _,d in ipairs(list) do
   index+=1;result.skills+=1
   check(Catalog.get(classId,d.id,"release")~=nil,d.id.." release profile")
   check(Catalog.get(classId,d.id,"impact")~=nil,d.id.." impact profile")
   c:SetAttribute("K0State","Attack");c:SetAttribute("K0AttackSeq",index)
   c:SetAttribute("K0SkillId",d.id);c:SetAttribute("K0AttackStartedAt",100)
   check(not Audio.renderCharacter(c,100),d.id.." no windup release")
   for beat=1,d.shotCount or d.pulses or 1 do
    clean()
    local at=100+d.windup+(d.hitDelay or 0)+(beat-1)*(d.shotInterval or d.interval or .3)+.001
    check(Audio.renderCharacter(c,at),d.id.." pulse "..beat)
    check(not Audio.renderCharacter(c,at),d.id.." dedup "..beat)
    result.pulses+=1
   end
   clean()
  end
  c:SetAttribute("K0SkillId",nil);c:SetAttribute("K0Combo",1)
  c:SetAttribute("K0BasicAttackRate",2);c:SetAttribute("K0AttackSeq",1000+index)
  local d=Config.BasicAttackProfiles[classId].attacks[1]
  local at=100+(d.windup+(d.hitDelay or 0))/2+.001
  check(Audio.renderCharacter(c,at),classId.." scaled basic timing")
  check(not Audio.renderCharacter(c,at),classId.." basic dedup")
  clean()
 end
 c:SetAttribute("K0SkillId","elf.common.rapid");c:SetAttribute("K0ClassId","elf")
 c:SetAttribute("K0AttackSeq",2000);c:SetAttribute("K0State","Dodge")
 check(not Audio.renderCharacter(c,100.25),"cancelled attack silent")
 c:SetAttribute("K0State","Dead");check(not Audio.renderCharacter(c,100.25),"dead silent")
 c:SetAttribute("K0State","Attack");c:SetAttribute("TLTDeathFalling",true)
 check(not Audio.renderCharacter(c,100.25),"death falling silent")
 c:SetAttribute("TLTDeathFalling",nil);c:SetAttribute("K0AttackSeq",2001)
 check(not Audio.renderCharacter(c,103),"late stream in no backlog")
 check(not Audio.play("impact",Vector3.zero,"elf","mage.common.gravity"),"wrong class skill rejected")
 check(not Audio.play("impact",Vector3.new(0/0,0,0),"elf"),"NaN rejected")
 check(not Audio.play("release",Vector3.new(1000,0,0),"knight"),"distant sound rejected")
 check(not Audio.play("invalid",Vector3.zero,"knight"),"unknown layer rejected")
 clean()
 local played,holder=Audio.play("impact",Vector3.zero,"knight","knight.common.bash")
 check(played,"shield contact plays")
 check(not Audio.play("impact",Vector3.zero,"knight","knight.common.bash"),"AoE contact collapsed")
 local s=holder.K0HitSound
 check(s.RollOffMinDistance==8 and s.RollOffMaxDistance==80 and not s.Looped,"spatial one shot")
 check(s.SoundId=="rbxassetid://9119072660","shield store asset")
 check(holder.Anchored and not holder.CanCollide and not holder.CanQuery and not holder.CanTouch,"inert emitter")
 task.wait(.08);check(Audio.play("impact",Vector3.zero,"knight","knight.common.bash"),"next hit allowed")
 clean()
 for i=1,20 do Audio.play("release",Vector3.zero,"knight") end
 for i=1,20 do Audio.play("impact",Vector3.new(i*9,0,0),"mage") end
 local counts={release=0,impact=0}
 for _,h in ipairs(workspace:GetChildren()) do if h.Name=="K0CombatAudioEmitter" then
  local kind=h:FindFirstChild("K0HitSound") and "impact" or "release";counts[kind]+=1
 end end
 check(counts.release==8 and counts.impact<=8 and counts.impact>0,"separate voice caps")
 task.wait(1.6)
 local live=0;for _,h in ipairs(workspace:GetChildren())do if h.Name=="K0CombatAudioEmitter"then live+=1 end end
 check(live==0,"all emitters cleaned by lifetime")
 local cp=game:GetService("ContentProvider")
 local used={}
 for _,profile in pairs(Catalog.profiles)do for _,clip in pairs(profile)do if not used[clip.id]then
  used[clip.id]=true
  local sound=Instance.new("Sound");sound.SoundId=clip.id;sound.Volume=0;sound.Parent=root
  local status
  local loaded,why=pcall(function()cp:PreloadAsync({sound},function(_,st)status=st.Name end)end)
  task.wait(.05)
  table.insert(result.assets,{id=clip.id,status=status,loaded=sound.IsLoaded,length=sound.TimeLength,error=not loaded and tostring(why) or nil})
  check(loaded and status=="Success" and sound.IsLoaded and sound.TimeLength>0,"audio decode "..clip.id)
  sound:Destroy()
 end end end
end,debug.traceback)
clean();c:Destroy();workspace.CurrentCamera=oldCamera;camera:Destroy()
result.success=ok;result.error=not ok and err or nil
print(game:GetService("HttpService"):JSONEncode(result))
assert(ok,err)
