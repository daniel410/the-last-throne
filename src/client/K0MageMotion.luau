-- Original Blender MCP animation curves. Only accepted server action time is
-- sampled; this module never moves the root or authorizes hits/projectiles.
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local Clips=require(script.Parent.K0MageClips)
local Motion={}
local records=setmetatable({},{__mode="k"})
local function finite(v) return type(v)=="number" and v==v and math.abs(v)<math.huge end
local function axis(keys,t)
 local i=1
 for n=1,#keys-1 do if t>=keys[n][1] then i=n end end
 local a,b=keys[i],keys[i+1];local h=b[1]-a[1]
 local u=math.clamp((t-a[1])/h,0,1);local u2,u3=u*u,u*u*u
 return (2*u3-3*u2+1)*a[2]+(u3-2*u2+u)*h*a[3]+(-2*u3+3*u2)*b[2]+(u3-u2)*h*b[3]
end
function Motion.profile(d)
 if d.id=="mage.common.water_ball" or (d.element=="water" and d.form=="projectile") then return "water_orb" end
 if d.shield or d.form=="self" then return "ward" end
 if d.ultimate or (d.form=="ground" and d.windup>=.65) then return "elemental_heavy" end
 if d.id=="mage.common.gravity" or d.form=="ground" or d.form=="area" then return "ground_area" end
 return "arcane_bolt"
end
function Motion.definition(skillId,kind)
 if not skillId and kind~="Arcane" then return Config.BasicAttackProfiles.mage.attacks[1],"staff_strike" end
 for _,d in ipairs(Config.Skills.mage) do
  if d.id==skillId or not skillId and d.id=="mage.common.mana_bolt" then return d,Motion.profile(d) end
 end
end
function Motion.raw(profile,t)
 local clip=Clips.clips[profile];if not clip or not finite(t) then return nil end
 local pose={angles={},focus=math.clamp(axis(clip.curves.focus,t),0,1),profile=profile}
 for _,c in ipairs(Clips.channels) do
  local curves=clip.curves[c];local v=Vector3.new(axis(curves[1],t),axis(curves[2],t),axis(curves[3],t))
  pose.angles[c]=v;pose[c]=CFrame.Angles(math.rad(v.X),math.rad(v.Y),math.rad(v.Z))
 end
 return pose
end
local rest=Motion.raw("staff_strike",0)
function Motion.sample(d,profile,age,entry,entrySlope)
 if not d or not finite(age) then return nil end
 local w,a,r=d.windup,d.active,d.recovery
 local t=age<w and .65*math.clamp(age/w,0,1)
  or age<w+a and .65+.17*math.clamp((age-w)/a,0,1)
  or .82+.18*math.clamp((age-w-a)/r,0,1)
 local pose=Motion.raw(profile,t);if not pose then return nil end
 local opening=w*.3
 if entry and age<opening then
  local u=math.clamp(age/opening,0,1);local u2,u3=u*u,u*u*u
  for _,c in ipairs(Clips.channels) do
   local v=pose.angles[c]+(entry.angles[c]-rest.angles[c])*(2*u3-3*u2+1)
    +(entrySlope and entrySlope[c] or Vector3.zero)*opening*(u3-2*u2+u)
   pose.angles[c]=v;pose[c]=CFrame.Angles(math.rad(v.X),math.rad(v.Y),math.rad(v.Z))
  end
  pose.focus=math.clamp(pose.focus+entry.focus*(2*u3-3*u2+1),0,1)
 end
 pose.time=t;pose.element=d.element or (d.id=="mage.common.water_ball" and "water") or (d.id=="mage.common.gravity" and "gravity") or "arcane"
 pose.cutting=profile=="staff_strike" and age>=w*.55 and age<w+a
 return pose
end
local function presentation(record,now)
 return Motion.sample(record.d,record.profile,now-record.started,record.entry,record.entrySlope)
end
function Motion.forCharacter(character,now)
 local mode=character:GetAttribute("K0State")
 if character:GetAttribute("K0ClassId")~="mage" or (mode~="Attack" and mode~="Idle")
  or character:GetAttribute("TLTDeathFalling") or not finite(now) then records[character]=nil;return nil end
 local previous=records[character]
 if mode=="Attack" then
  local started=character:GetAttribute("K0AttackStartedAt")
  local d,profile=Motion.definition(character:GetAttribute("K0SkillId"),character:GetAttribute("K0AttackKind"))
  if not d or not finite(started) then records[character]=nil;return nil end
  if not previous or previous.started~=started or previous.d~=d then
   local entry,entrySlope
   if previous and started>=previous.started then
    entry=presentation(previous,started);entrySlope={}
    local before,after=presentation(previous,started-.0001),presentation(previous,started+.0001)
    for _,c in ipairs(Clips.channels) do entrySlope[c]=(after.angles[c]-before.angles[c])/.0002 end
   end
   previous={d=d,profile=profile,started=started,entry=entry,entrySlope=entrySlope};records[character]=previous
  end
 end
 if not previous then return Motion.raw("staff_strike",0) end
 if mode=="Idle" and now-previous.started>previous.d.windup+previous.d.active+previous.d.recovery then
  records[character]=nil;return Motion.raw("staff_strike",0)
 end
 return presentation(previous,now)
end
return Motion
