local State={current=nil,target=nil,revision=0}
local partySnapshot,partyAt=nil,-math.huge
function State.set(current,target,targetTitle)
 local previous=State.current
 if not current or current.training or not previous or current.heroId~=previous.heroId
  or (current.expedition and current.expedition.runId)~=(previous.expedition and previous.expedition.runId) then
  State.waypoint=nil
 end
 State.targetTitle=targetTitle
 State.current=current;State.target=target;State.revision+=1
end
function State.setParty(value)
 partySnapshot=value;partyAt=os.clock()
end
function State.party()
 local current=State.current
 if not current or current.training or current.mode and current.mode~='Tutorial' or not partySnapshot or partySnapshot.heroId~=current.heroId or os.clock()-partyAt>2 then return {}end
 return partySnapshot.members or {}
end
return State
