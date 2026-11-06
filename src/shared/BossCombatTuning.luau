-- Server-selected story boss modifiers. Saved rules 1-7 retain their original power and tempo.
local T={previousBoost={damage=1.1,attackSpeed=1.1,moveSpeed=1.1},
 boost={damage=1.32,attackSpeed=1.265,moveSpeed=1.265},neutral={damage=1,attackSpeed=1,moveSpeed=1}}
function T.forRun(boss,version)
 if not boss or version~=nil and version<7 then return T.neutral end
 return version==7 and T.previousBoost or T.boost
end
-- Called only on the private encounter config and its cloned attack definitions.
-- Shorten recovery to raise the full base cycle rate, preserving warning/hit windows.
function T.apply(config,attackSpeed,moveSpeed)
 config.walkSpeed=config.walkSpeed*(moveSpeed or 1)
 if not attackSpeed or attackSpeed==1 then return end
 for _,attack in ipairs(config.attacks)do
  local fixed=attack.windup+attack.active
  attack.recovery=math.max(0,(fixed+attack.recovery)/(attackSpeed or 1)-fixed)
 end
end
return T
