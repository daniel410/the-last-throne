local State={current=nil,target=nil,revision=0}
function State.set(current,target)
 State.current=current;State.target=target;State.revision+=1
end
return State
