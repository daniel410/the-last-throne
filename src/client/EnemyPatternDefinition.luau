-- One server snapshot drives animation, warning boundaries and spell travel.
local RS=game:GetService('ReplicatedStorage')
local Http=game:GetService('HttpService')
local Patterns=require(RS.Shared.EnemyPatterns)
local Snapshot={}
local cache=setmetatable({},{__mode='k'})
local authored={}
for _,profile in pairs(Patterns.profiles)do
 for _,d in ipairs(profile.attacks)do authored[d.id]=d end
end
function Snapshot.remember(model,sequence,d)
 if model and type(d)=='table' and authored[d.id]then
  cache[model]={sequence=sequence,id=d.id,definition=d,raw=model:GetAttribute('K0PatternDefinition')}
 end
end
function Snapshot.get(model,id,sequence)
 if not model then return id and authored[id]or nil end
 id=id or model:GetAttribute('K0PatternId')
 if not id then return nil end
 sequence=sequence or model:GetAttribute('K0AttackSeq')
 local raw=model:GetAttribute('K0PatternDefinition');local row=cache[model]
 if row and row.sequence==sequence and row.id==id and row.raw==raw then return row.definition end
 if type(raw)=='string'then
  local ok,d=pcall(Http.JSONDecode,Http,raw)
  if ok and type(d)=='table' and d.id==id and authored[id]then
   cache[model]={sequence=sequence,id=id,definition=d,raw=raw};return d
  end
 end
 -- An event can arrive before its replicated attribute snapshot.
 if row and row.sequence==sequence and row.id==id then row.raw=raw;return row.definition end
 return authored[id]
end
function Snapshot.message(message)
 local d=message.definition
 if type(d)=='table' and d.id==message.id and authored[d.id]then
  Snapshot.remember(message.model,message.sequence,d);return d
 end
 return Snapshot.get(message.model,message.id,message.sequence)
end
return Snapshot
