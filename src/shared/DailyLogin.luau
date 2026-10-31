-- TD-compatible UTC calendar, with a separate RPG Gold reward schedule.
local D={rewards={20,20,20,50,50,50,100},forgivenessSeconds=48*60*60}
local function integer(v,min,max)return type(v)=='number' and v==v and v%1==0 and v>=min and v<=max end
function D.valid(record)
 return type(record)=='table' and integer(record.day,1,7) and integer(record.lastClaim,0,1e12)
  and integer(record.amount,1,1e12) and type(record.requestId)=='string' and #record.requestId<=64
  and #record.requestId>0 and record.requestId:match('^[%w_-]+$')~=nil
end
function D.compute(record,now)
 if not record then return 1,true end
 local today,last=math.floor(now/86400),math.floor(record.lastClaim/86400)
 if last>=today then return record.day,false end
 if now-record.lastClaim<=D.forgivenessSeconds then return record.day%7+1,true end
 return 1,true
end
return D
