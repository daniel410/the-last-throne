-- Pure, bounded first-clear journal. Only trusted server events enter apply().
local Content=game and require(game:GetService('ReplicatedStorage').Shared.DeepwoodContent) or dofile('src/shared/DeepwoodContent.luau')
local P={}
function P.copy(v) if type(v)~='table' then return v end local r={} for k,x in pairs(v) do r[k]=P.copy(x) end return r end
function P.new() return {version=1,main=0,flags={},clears={},choice='',coins=0,killCoins=0} end
function P.goal(chapter,id) for _,g in ipairs(chapter.goals) do if g.id==id then return g end end end
function P.eligible(s,c)
 if c.side then return s.main>=c.minMain and not s.clears[c.id] end
 return s.main+1==c.number and not s.clears[c.id]
end
function P.available(s,c,g)
 if s.main<(g.minMain or 0) then return false end
 if not P.eligible(s,c) or s.flags[c.id..':'..g.id] then return false end
 for _,id in ipairs(g.requires) do if not s.flags[c.id..':'..id] then return false end end
 return true
end
function P.validate(s)
 if type(s)~='table' or s.version~=1 or type(s.flags)~='table' or type(s.clears)~='table'
 or type(s.main)~='number' or s.main%1~=0 or s.main<0 or s.main>7
 or type(s.coins)~='number' or s.coins%1~=0 or s.coins<0 or s.coins>2290
 or s.killCoins~=nil and (type(s.killCoins)~='number' or s.killCoins%1~=0 or s.killCoins<0 or s.killCoins>1e12)
 or (s.choice~='' and s.choice~='sanctuary' and s.choice~='shared') then return false end
 for key,v in pairs(s.flags) do
  local cid,gid
  if type(key)=='string' then cid,gid=key:match('^([^:]+):(.+)$') end
  local c=cid and Content.byId[cid];local g=c and P.goal(c,gid)
  if v~=true or not g then return false end
  if not c.side and c.number>s.main+1 or c.side and s.main<c.minMain then return false end
  for _,r in ipairs(g.requires) do if not s.flags[c.id..':'..r] then return false end end
 end
 local coins=0
 for _,c in ipairs(Content.chapters) do
  if s.clears[c.id] then
   if s.clears[c.id]~=true or not c.side and c.number>s.main or c.side and s.main<c.minMain then return false end
   for _,g in ipairs(c.goals) do if not g.optional and not s.flags[c.id..':'..g.id] then return false end end
   coins=coins+c.reward.coins
  elseif not c.side and c.number<=s.main then return false end
 end
 for id in pairs(s.clears) do if not Content.byId[id] then return false end end
 if coins~=s.coins or (s.flags['DW-07:restoration']==true)~=(s.choice~='') then return false end
 return true
end
function P.apply(s,chapterId,goalId,choice)
 if not P.validate(s) then return nil,'Incompatible' end
 local c=Content.byId[chapterId];local g=c and P.goal(c,goalId)
 if not g then return nil,'InvalidRequest' end
 if s.flags[chapterId..':'..goalId] then return P.copy(s),nil,{xp=0,coins=0,repeated=true} end
 if not P.available(s,c,g) then return nil,'StoryLocked' end
 if g.choice and choice~='sanctuary' and choice~='shared' then return nil,'ChooseRestoration' end
 local n=P.copy(s);n.flags[chapterId..':'..goalId]=true
 if g.choice then n.choice=choice end
 local reward={xp=0,coins=0}
 local complete=true for _,o in ipairs(c.goals) do if not o.optional and not n.flags[c.id..':'..o.id] then complete=false end end
 if complete then
  n.clears[c.id]=true;if not c.side then n.main=c.number end
  n.coins=n.coins+c.reward.coins;reward=P.copy(c.reward);reward.chapter=c.id
 end
 return n,nil,reward
end
return P
