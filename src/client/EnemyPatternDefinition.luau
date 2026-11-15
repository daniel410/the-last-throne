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
function Snapshot.remember(model,sequence,d,frame)
 if model and type(d)=='table' and authored[d.id]then
  local old=cache[model]
  cache[model]={sequence=sequence,id=d.id,definition=d,raw=model:GetAttribute('K0PatternDefinition'),frame=frame or old and old.sequence==sequence and old.id==d.id and old.frame or nil}
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
   cache[model]={sequence=sequence,id=id,definition=d,raw=raw,frame=row and row.sequence==sequence and row.id==id and row.frame or nil};return d
  end
 end
 -- An event can arrive before its replicated attribute snapshot.
 if row and row.sequence==sequence and row.id==id then row.raw=raw;return row.definition end
 return authored[id]
end
function Snapshot.message(message)
 local d=message.definition
 if type(d)=='table' and d.id==message.id and authored[d.id]then
  local frame=message.kind=='begin'and {origin=message.origin,direction=message.direction,aim=message.aim,castOrigin=message.castOrigin}or nil
  Snapshot.remember(message.model,message.sequence,d,frame);return d
 end
 return Snapshot.get(message.model,message.id,message.sequence)
end
function Snapshot.frame(model)
 local row=cache[model]
 if row and row.sequence==model:GetAttribute('K0AttackSeq')and row.frame then return row.frame end
 return {origin=model:GetAttribute('K0PatternOrigin'),direction=model:GetAttribute('K0PatternDirection'),aim=model:GetAttribute('K0PatternAim'),castOrigin=model:GetAttribute('K0PatternCastOrigin')}
end
return Snapshot
