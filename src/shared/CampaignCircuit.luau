-- Safe circuit choices: no damage, currency cost or progress on a wrong answer.
local M={}
local rows={
 {{'inlet','OPEN THE INLET','Coolant enters the model.'},{'drain','OPEN THE DRAIN','The model loses its inlet flow.'}},
 {{'return','CONNECT THE RETURN','Coolant circulates back to the tank.'},{'vent','CLOSE THE RETURN','Pressure cannot circulate safely.'}},
 {{'protect','ENABLE CITY PROTECTION','The protection circuit is ready.'},{'bypass','BYPASS PROTECTION','The protection relay is disconnected.'}},
}
function M.install(chapter,index,steps)
 if chapter~='EC-05'or index~=2 then return end
 for n,step in ipairs(steps)do
  step.choices={}
  for _,a in ipairs(rows[n])do table.insert(step.choices,{id=a[1],title=a[2],text=a[3]})end
  step.solution=rows[n][1][1]
  step.failure='The model stays safe and your progress is unchanged. Follow the blue inlet, connect the return, then enable city protection.'
 end
end
return M
