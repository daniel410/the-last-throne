local State={current=nil,target=nil,revision=0}
local partySnapshot,partyAt=nil,-math.huge
function State.set(current,target)
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
