-- Only a newly confirmed incident completion emits its authored outcome.
local M={}
function M.resolve(g,stepId,choice,before,after,chapterId)
 local text=g.text
 for _,step in ipairs(g.activity and g.activity.steps or {})do if step.id==stepId then
  text=step.text
  for _,answer in ipairs(step.choices or {})do if answer.id==choice then text=answer.text end end
 end end
 local key=chapterId..':'..g.id
 if g.expansion and after and after.flags[key] and not (before and before.flags[key])then return g.text end
 return text
end
return M
