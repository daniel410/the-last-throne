-- Safe circuit choices: no damage, currency cost or progress on a wrong answer.
local M={}
local rows={
 {{'inlet','TURN THE TRIANGLE VALVE','Coolant enters the model.'},{'drain','TURN THE RING VALVE','The model loses its inlet flow.'}},
 {{'return','CONNECT THE RING RETURN','Coolant circulates back to the tank.'},{'vent','CLOSE THE TRIANGLE RETURN','Pressure cannot circulate safely.'}},
 {{'protect','ENABLE CITY PROTECTION','The protection circuit is ready.'},{'bypass','BYPASS PROTECTION','The protection relay is disconnected.'}},
}
function M.install(chapter,index,steps)
 if chapter~='EC-05'or index~=2 then return end
 for n,step in ipairs(steps)do
  step.choices={}
  for i,a in ipairs(rows[n])do
   local symbols={{'triangle','ring'},{'ring','triangle'},{'shield','broken'}}
   table.insert(step.choices,{id=a[1],title=a[2],text=a[3],symbol=symbols[n][i]})
  end
  step.displayOrder=n==2 and {2,1}or {1,2}
  step.circuitControls=true
  step.solution=rows[n][1][1]
  step.failure=({
   'That ring line drains away from the tank. Follow the triangle arrow INTO the tank and try again. The model is safe; no progress was lost.',
   'That triangle gate closes the loop. Follow the ring arrow BACK to the tank and try again. The model is safe; no progress was lost.',
   'That broken relay bypasses the city. Connect the shield mark instead. The model is safe; no progress was lost.',
  })[n]
 end
end
function M.display(step)
 local result={}
 for _,i in ipairs(step.displayOrder or {1,2})do if step.choices and step.choices[i]then table.insert(result,step.choices[i])end end
 return result
end
return M
