local Content=game and require(game:GetService('ReplicatedStorage').Shared.DeepwoodContent) or dofile('src/shared/DeepwoodContent.luau')
local P=game and require(game:GetService('ReplicatedStorage').Shared.DeepwoodProgress) or dofile('src/shared/DeepwoodProgress.luau')
local Log={}
function Log.main(s) return s.main<7 and Content.chapters[s.main+1] or nil end
function Log.target(s,c,optionalId)
 if not c then return nil end
 if optionalId then local g=P.goal(c,optionalId);if g and g.optional and P.available(s,c,g) then return {chapter=c,goal=g} end end
 for _,g in ipairs(c.goals) do if not g.optional and P.available(s,c,g) then return {chapter=c,goal=g} end end
end
function Log.status(s,c)
 if s.clears[c.id] then return 'Completed' end
 if not c.side then return c.number==s.main+1 and 'In progress' or 'Locked' end
 if s.main<c.minMain then return 'Locked' end
 if not P.accepted(s,c) then return 'Available' end
 local report=P.goal(c,c.quest.turnIn)
 local ready=true;for _,g in ipairs(c.goals) do if not g.optional and g~=report and not s.flags[c.id..':'..g.id] then ready=false end end
 if ready and s.main<(report.minMain or 0) then return 'Waiting for story '..report.minMain end
 return P.available(s,c,report) and 'Ready to report' or 'In progress'
end
function Log.phase(s,c)
 if c.side then return Log.status(s,c) end
 for i,phase in ipairs(c.quest.phases) do
  for _,id in ipairs(phase.goals) do if not s.flags[c.id..':'..id] then return phase.title,i,#c.quest.phases end end
 end
 return 'Completed',#c.quest.phases,#c.quest.phases
end
function Log.reward(c)
 if c.reward.xp==0 and c.reward.coins==0 then return 'No fixed XP or Coins. Combat rewards are earned separately.' end
 return string.format('On story completion: %d XP · %d Coins. Items go to your bag or unclaimed rewards.',c.reward.xp,c.reward.coins)
end
function Log.choices(s,c)
 local rows={}
 for _,g in ipairs(c.goals) do for _,step in ipairs(g.activity and g.activity.steps or {}) do
  local picked=(s.decisions or {})[c.id..':'..g.id..':'..step.id]
  for _,answer in ipairs(step.choices or {}) do if answer.id==picked then table.insert(rows,answer.title) end end
 end end
 if c.id=='DW-07' and s.choice~='' then table.insert(rows,s.choice=='sanctuary' and 'Restore the Elven Sanctuary' or 'Share restoration with the refugees') end
 return rows
end
return Log
