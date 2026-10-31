-- Trial support budget; server service owns distance, identity, cooldown and line of sight.
local S={followSpeed=28,pathRefresh=.75,cooldown=12,range=18,healFraction=.12,shieldFraction=.10,shieldDuration=3}
function S.limit(players) return ({2,2,1,1})[players] or 0 end
function S.action(health,maxHealth,stunned,danger)
 if health<=0 or maxHealth<=0 then return nil end
 if stunned then return 'Cleanse' end
 if health<maxHealth*.65 then return 'Heal' end
 if danger then return 'Protect' end
end
return S
