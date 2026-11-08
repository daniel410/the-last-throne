-- Added completion awards. Original nonzero story budgets and journal earnings
-- remain immutable; the account commits these awards with durable clear receipts.
local Q={version=1,awards={
 ['DW-Q1']={xp=60,coins=100,ore=2},
 ['DW-Q2']={xp=100,coins=150,ore=3},
 ['DW-Q3']={xp=120,coins=180,ore=3},
 ['DW-Q4']={xp=160,coins=220,gems=1},
 ['FV-Q1']={xp=100,coins=150,ore=2},
 ['FV-Q2']={xp=180,coins=240,ore=3},
 ['FV-Q3']={xp=200,coins=260,gems=1},
 ['FV-Q4']={xp=280,coins=360,gems=2},
 ['EC-Q1']={xp=140,coins=200,ore=3},
 ['EC-Q2']={xp=260,coins=340,gems=1},
 ['EC-Q3']={xp=320,coins=400,gems=2},
 ['EC-Q4']={xp=400,coins=500,gems=3},
 ['GW-01']={xp=180,coins=250},
 ['GW-02']={xp=80,coins=120},
 ['GW-03']={xp=200,coins=300},
 ['GW-04']={xp=260,coins=380},
 ['GW-05']={xp=280,coins=420},
 ['GW-06']={xp=320,coins=480},
 ['GW-07']={xp=400,coins=650},
}}
function Q.install(content)
 for id,award in pairs(Q.awards)do
  local c=assert(content.byId[id],id)
  assert(c.reward.xp==0 and c.reward.coins==0,'Never overwrite an existing story budget')
  -- Existing version 1/2 journals use the historic Gold checksum. New awards
  -- live in the account wallet; changing that checksum would reject old saves.
  c.journalCoins=c.reward.coins
  c.reward={};for key,value in pairs(award)do c.reward[key]=value end
 end
end
function Q.valid(hero)
 local claims=hero.completionRewardClaims
 if claims==nil then return true end
 if type(claims)~='table'then return false end
 for id,version in pairs(claims)do
  if not Q.awards[id]or version~=Q.version or not(hero.deepwood and hero.deepwood.clears[id])then return false end
 end
 return true
end
return Q
