-- Server-selected story boss modifiers. Saved rules 1-6 retain their original tempo.
local T={boost={damage=1.1,attackSpeed=1.1,moveSpeed=1.1},neutral={damage=1,attackSpeed=1,moveSpeed=1}}
function T.forRun(boss,version)
 return boss and (version==nil or version>=7)and T.boost or T.neutral
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
