-- Pure, bounded first-clear journal. Only trusted server events enter apply().
local Content=game and require(game:GetService('ReplicatedStorage').Shared.DeepwoodContent) or dofile('src/shared/DeepwoodContent.luau')
local P={}
function P.copy(v) if type(v)~='table' then return v end local r={} for k,x in pairs(v) do r[k]=P.copy(x) end return r end
function P.hasCell(cells,index) return cells and (cells[tostring(index)]==true or cells[index]==true) or false end
function P.new() return {version=1,main=0,flags={},clears={},choice='',coins=0,killCoins=0,activities={},decisions={},explored={},accepted={},clues={}} end
-- Recruitment is derived from the existing personal rescue report, including old saves.
function P.seleneUnlocked(s) return s and s.flags and s.flags['DW-03:report']==true or false end
function P.selectSelene(s,following)
 if not P.validate(s) then return nil,'Incompatible' end
 if type(following)~='boolean' then return nil,'InvalidRequest' end
 if not P.seleneUnlocked(s) then return nil,'StoryLocked' end
 local n=P.copy(s)
 if (s.seleneFollowing==true)==following then return n,nil,true end
 n.seleneFollowing=following;return n
end
function P.goal(chapter,id) for _,g in ipairs(chapter.goals) do if g.id==id then return g end end end
function P.accepted(s,c)
 if not c.side then return true end
 if (s.accepted or {})[c.id] or s.clears[c.id] then return true end
 -- Pre-contract saves already in progress must never lose their quest.
 for _,g in ipairs(c.goals) do if s.flags[c.id..':'..g.id] then return true end end
 return false
end
function P.canAccept(s,c) return c and c.side and s.main>=c.minMain and not P.accepted(s,c) end
function P.accept(s,id,discovery)
 if not P.validate(s) then return nil,'Incompatible' end
 local c=Content.byId[id]
 if not c or not c.side then return nil,'InvalidRequest' end
 if P.accepted(s,c) then return P.copy(s),nil,true end
 if not P.canAccept(s,c) then return nil,'StoryLocked' end
 local n=P.copy(s);n.accepted=n.accepted or {};n.accepted[id]=true
 if discovery then local result,reason=P.apply(n,id,c.goals[1].id);return result,reason,false end
 return n
end
function P.eligible(s,c)
 if c.side then return s.main>=c.minMain and P.accepted(s,c) and not s.clears[c.id] end
 return s.main+1==c.number and not s.clears[c.id]
end
function P.available(s,c,g)
 if s.main<(g.minMain or 0) then return false end
 if not P.eligible(s,c) or s.flags[c.id..':'..g.id] then return false end
 for _,id in ipairs(g.requires) do if not s.flags[c.id..':'..id] then return false end end
 return true
end
function P.collected(s,c,g,index)
 local key=c.id..':'..g.id
 local clues=(s.clues or {})[key]
 if g.activity and g.activity.mode=='investigate' and clues then return clues[g.activity.steps[index].id]==true end
 return index<=((s.activities or {})[key] or 0)
end
function P.nextStep(s,c,g)
 if not P.available(s,c,g) or not g.activity or not g.activity.steps then return nil end
 for index,step in ipairs(g.activity.steps) do if not P.collected(s,c,g,index) then return step end end
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
 if s.seleneFollowing~=nil and type(s.seleneFollowing)~='boolean' or s.seleneFollowing==true and not P.seleneUnlocked(s) then return false end
 if s.activities~=nil and type(s.activities)~='table' or s.decisions~=nil and type(s.decisions)~='table' then return false end
 for key,count in pairs(s.activities or {}) do
  local cid,gid
  if type(key)=='string' then cid,gid=key:match('^([^:]+):(.+)$') end
  local c=cid and Content.byId[cid];local g=c and P.goal(c,gid)
  if not g or not g.activity or not g.activity.steps or type(count)~='number' or count%1~=0 or count<1 or count>#g.activity.steps then return false end
  if not c.side and c.number>s.main+1 then return false end
  for _,r in ipairs(g.requires) do if not s.flags[cid..':'..r] then return false end end
  if count==#g.activity.steps and not s.flags[key] then return false end
 end
 for key,value in pairs(s.decisions or {}) do
  local cid,gid,sid
  if type(key)=='string' then cid,gid,sid=key:match('^([^:]+):([^:]+):(.+)$') end
  local c=cid and Content.byId[cid];local g=c and P.goal(c,gid);local found=false
  for index,step in ipairs(g and g.activity and g.activity.steps or {}) do if step.id==sid and index<=((s.activities or {})[cid..':'..gid] or 0) then
   for _,answer in ipairs(step.choices or {}) do if answer.id==value then found=true end end
  end end
  if not found then return false end
 end
 if s.accepted~=nil and type(s.accepted)~='table' or s.clues~=nil and type(s.clues)~='table' then return false end
 for id,value in pairs(s.accepted or {}) do
  local c=Content.byId[id];if not c or not c.side or value~=true or s.main<c.minMain then return false end
 end
 for key,values in pairs(s.clues or {}) do
  local cid,gid;if type(key)=='string' then cid,gid=key:match('^([^:]+):(.+)$') end
  local c=cid and Content.byId[cid];local g=c and P.goal(c,gid)
  if not g or not g.activity or g.activity.mode~='investigate' or type(values)~='table' then return false end
  local count=0
  for sid,value in pairs(values) do
   local found=false;for _,step in ipairs(g.activity.steps) do if step.id==sid then found=true end end
   if not found or value~=true then return false end;count=count+1
  end
  if count<1 or count~=((s.activities or {})[key] or 0) then return false end
 end
 if s.explored~=nil and type(s.explored)~='table' then return false end
 for id,cells in pairs(s.explored or {}) do
  local zone=Content.zones[id]
  if not zone or zone.requiresMain>s.main or type(cells)~='table' then return false end
  for cell,value in pairs(cells) do
   local index=tonumber(cell)
   if (type(cell)~='number' and type(cell)~='string') or not index or index%1~=0 or index<1 or index>144 or type(cell)=='string' and tostring(index)~=cell or type(cell)=='number' and cells[tostring(cell)]~=nil or value~=true then return false end
  end
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
function P.apply(s,chapterId,goalId,choice,stepId)
 if not P.validate(s) then return nil,'Incompatible' end
 local c=Content.byId[chapterId];local g=c and P.goal(c,goalId)
 if not g then return nil,'InvalidRequest' end
 if s.flags[chapterId..':'..goalId] then return P.copy(s),nil,{xp=0,coins=0,repeated=true} end
 if not P.available(s,c,g) then return nil,'StoryLocked' end
 local n=P.copy(s)
 if g.activity and g.activity.steps then
  n.activities=n.activities or {};n.decisions=n.decisions or {}
  local key=chapterId..':'..goalId;local count=n.activities[key] or 0
  local expected=g.activity.steps[count+1]
  local index
  for i,step in ipairs(g.activity.steps) do if step.id==stepId then index=i end end
  if index and P.collected(s,c,g,index) then return n,nil,{xp=0,coins=0,repeated=true} end
  if not expected or not index or g.activity.mode~='investigate' and expected.id~=stepId then return nil,'ActivityIncomplete' end
  if g.activity.mode=='investigate' then
   n.clues=n.clues or {};n.clues[key]=n.clues[key] or {}
   if not (s.clues or {})[key] then for i=1,count do n.clues[key][g.activity.steps[i].id]=true end end
   n.clues[key][stepId]=true
  end
  if expected.choices then
   local valid=false;for _,answer in ipairs(expected.choices) do if answer.id==choice then valid=true end end
   if not valid then return nil,'ChooseAnswer' end
   n.decisions[key..':'..stepId]=choice
  end
  n.activities[key]=count+1
  if count+1<#g.activity.steps then return n,nil,{xp=0,coins=0,step=stepId} end
 elseif stepId~=nil then return nil,'InvalidRequest' end
 if g.choice and choice~='sanctuary' and choice~='shared' then return nil,'ChooseRestoration' end
 n.flags[chapterId..':'..goalId]=true
 if g.choice then n.choice=choice end
 local reward={xp=0,coins=0}
 local complete=true for _,o in ipairs(c.goals) do if not o.optional and not n.flags[c.id..':'..o.id] then complete=false end end
 if complete then
  n.clears[c.id]=true;if not c.side then n.main=c.number end
  n.coins=n.coins+c.reward.coins;reward=P.copy(c.reward);reward.chapter=c.id
 end
 return n,nil,reward
end
function P.reveal(s,id,x,z)
 if not P.validate(s) or not Content.zones[id] or Content.zones[id].requiresMain>s.main or type(x)~='number' or type(z)~='number' or x%1~=0 or z%1~=0 or x<1 or x>12 or z<1 or z>12 then return nil,'InvalidRequest' end
 local n=P.copy(s);n.explored=n.explored or {}
 -- String keys survive Roblox JSON/DataStore serialization of sparse discovery.
 for zone,values in pairs(n.explored) do local normalized={} for key in pairs(values) do normalized[tostring(key)]=true end;n.explored[zone]=normalized end
 n.explored[id]=n.explored[id] or {};local changed=false
 for dx=-1,1 do for dz=-1,1 do local a,b=x+dx,z+dz;if a>=1 and a<=12 and b>=1 and b<=12 then local key=tostring((b-1)*12+a);if not n.explored[id][key] then n.explored[id][key]=true;changed=true end end end end
 return n,nil,not changed
end
return P
