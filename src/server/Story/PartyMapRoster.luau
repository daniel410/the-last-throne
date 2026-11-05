-- Server-owned same-run membership. No run IDs/tickets are sent to clients.
local R={}
function R.create(o)
 return function(viewer)
  local hero=o.active(viewer);local result={heroId=hero and hero.heroId,members={}}
  if not hero or hero.training or not o.inAdventure(viewer)then return result end
  local run=o.run(viewer,hero.heroId);if not run or type(run.runId)~='string'or run.runId==''then return result end
  local roster={}
  for _,p in ipairs(o.players())do
   local h=o.active(p);local other=h and not h.training and o.inAdventure(p)and o.run(p,h.heroId)
   if other and other.runId==run.runId then table.insert(roster,{player=p,hero=h})end
  end
  table.sort(roster,function(a,b)return a.player.UserId<b.player.UserId end)
  for slot,row in ipairs(roster)do if slot<=4 and row.player~=viewer and #result.members<3 then
   local position,downed=o.position(row.player)
   table.insert(result.members,{userId=row.player.UserId,name=row.player.DisplayName,slot=slot,position=position,downed=downed==true})
  end end
  return result
 end
end
return R
