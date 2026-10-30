-- Finite encounter populations; no timer-based or unlimited add farming.
local B={}
local function unit(kind,level,count) return {kind=kind,level=level,count=count} end
B.profiles={
 ['DW-05:warlord']={
  guards={unit('Orc',9,2),unit('Shaman',9,1)},
  waves={{health=.5,enemies={unit('Orc',9,2),unit('Shaman',9,1)}}},
  intro='The Warlord has an escort. Clear the guards and watch for reinforcements at half health.',
 },
 ['DW-07:king_shaman']={
  guards={unit('Goblin',11,2),unit('Shaman',11,1)},
  waves={{health=.7,enemies={unit('Orc',11,2),unit('Shaman',11,1)}},{health=.35,enemies={unit('Goblin',11,2),unit('Shaman',11,1)}}},
  intro='The altar guard protects King Shaman. Expect reinforcements when his ritual changes phase.',
 },
 ['DW-Q2:goblin_king']={
  guards={unit('Goblin',9,4),unit('Shaman',9,1)},
  waves={{health=.5,enemies={unit('Goblin',9,2),unit('Shaman',9,1)}}},
  intro='The Goblin King commands a full warband. Keep an escape route open and watch the shamans.',
 },
 ['DW-Q3:king_ogre']={
  guards={unit('Orc',10,2),unit('Goblin',10,2)},
  waves={{health=.5,enemies={unit('Orc',10,2),unit('Shaman',10,1)}}},
  intro='Quarry guards surround King Ogre. Draw them away from his heavy swings.',
 },
 ['DW-Q4:enraged_warlord']={
  guards={unit('Orc',12,4),unit('Shaman',12,1)},
  waves={{health=.6,enemies={unit('Orc',12,2),unit('Shaman',12,1)}},{health=.3,enemies={unit('Goblin',12,2),unit('Orc',12,1)}}},
  intro='The remaining warband fights beside its commander. Two reinforcement groups will join as he weakens.',
 },
}
function B.install(content)
 for _,c in ipairs(content.chapters) do for _,g in ipairs(c.goals) do
  local profile=B.profiles[c.id..':'..g.id]
  if profile then
   local boss=g.enemies[1];g.enemies={boss}
   for _,spec in ipairs(profile.guards) do table.insert(g.enemies,spec) end
   g.bossEncounter=profile;g.activity=g.activity or {mode='battle',waves=1};g.activity.intro=profile.intro
  end
 end end
end
return B
