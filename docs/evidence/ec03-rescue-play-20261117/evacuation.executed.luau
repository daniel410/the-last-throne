task.spawn(function()
 local C=require(game.ReplicatedStorage.Shared.CampaignContent)
 _G.ECRescue.evacuation={}
 local report=_G.ECRescue.evacuation
 local ok,err=xpcall(function()
  assert(_G.ECRescue.state.journal.flags['EC-03:worm'],'worm must be complete')
  for _,s in ipairs(C.byId['EC-03'].goals[4].activity.steps)do
   local walk=_G.ECWalk(Vector3.new(table.unpack(s.position)),'exp_1-'..s.id);assert(walk.arrived,'walk timeout')
   task.wait(.6)
   local prompt
   for _,p in workspace.DeepwoodCampaign:GetDescendants()do
    if p:IsA('ProximityPrompt')and p.Enabled and p.Parent:IsA('BasePart')and(p.Parent.Position-Vector3.new(table.unpack(s.position))).Magnitude<3 then prompt=p;break end
   end
   assert(prompt,'active step prompt missing '..s.id)
   prompt:InputHoldBegin();task.wait(1);prompt:InputHoldEnd();task.wait(1)
  end
  report.prepared=_G.ECRescue.state.journal.flags['EC-03:exp_1']
  assert(report.prepared,'exp_1 not complete')
  local g=C.byId['EC-03'].goals[5]
  _G.ECWalk(Vector3.new(table.unpack(g.position)),'Orik')
  for _,s in ipairs(g.activity.steps)do
   local walk=_G.ECWalk(Vector3.new(table.unpack(s.position)),'escort-'..s.id);assert(walk.arrived,'escort walk timeout');task.wait(3)
  end
  report.miners=_G.ECRescue.state.journal.flags['EC-03:miners']
 end,debug.traceback)
 report.ok=ok;report.error=not ok and tostring(err)or nil;report.done=true
end);return 'evacuation walk and prompt interaction running'
