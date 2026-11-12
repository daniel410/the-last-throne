-- Real engine checks of authored shapes and the screenshot's incorrect field desk.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place required')
local kit=require(game.ServerScriptService.Server.World.StoryProps)
local geometry=require(game.ServerScriptService.Server.World.StoryQuestGeometry)
local assignments=require(game.ServerScriptService.Server.World.StoryPropAssignments)
local content=require(game.ReplicatedStorage.Shared.CampaignContent)
local fixture=Instance.new('Folder');fixture.Name='StoryContextAcceptance';fixture.Parent=workspace
local report={kind='STORY_PROP_CONTEXT_NATIVE',checks=0,models=0,parts=0}
local function check(v,m)report.checks+=1;assert(v,m)end
for key,spec in pairs(geometry)do
 local m=kit.build(fixture,key,Vector3.new(100,20,50));report.models+=1
 check(m:GetAttribute('StoryPropKey')==key and m:GetAttribute('StoryPropVersion')==2,key..' versioned asset')
 check(m.ModelStreamingMode==Enum.ModelStreamingMode.Atomic,key..' streams intact')
 local parts=0
 for _,p in ipairs(m:GetDescendants())do if p:IsA('BasePart')then
  parts+=1;report.parts+=1
  check(p.Anchored and not p.CanCollide and not p.CanTouch and not p.CanQuery,key..' keeps quest movement, combat queries and interactions unchanged')
  check(p.Position.Y>19.9 and p.Position.Y<26,key..' grounded local coordinates')
 end end
 check(parts==#spec.parts,key..' authored geometry retained')
 m:Destroy()
end
for _,id in ipairs({'DW-07','GW-02','FV-04','EC-07','HG-07'})do
 local c=content.byId[id]
 for _,g in ipairs(c.goals)do for _,s in ipairs(g.activity and g.activity.steps or {})do
  if g.activity.mode~='dialogue'and g.activity.mode~='escort'and s.kind~='actor'and assignments.forStep(id,g.id,s)then
   local m=kit.activity(fixture,id,g.id,s,Vector3.new(table.unpack(s.position)))
   check(m and m:GetAttribute('StoryObjective')==id..':'..g.id..':'..s.id,'semantic identity survives placement')
   check(m:GetAttribute('StoryObjectTitle')==s.title,'physical object traces to actual objective')
   if g.id:match('^exp_')then
    check(m:GetAttribute('ExpansionStepEvent')==id..':'..g.id,'saved incident event retained')
    check(m:GetAttribute('ExpansionStepIndex')==tonumber(s.id:match('%d+')),'saved incident step retained')
    for _,p in ipairs(m:GetChildren())do if p:IsA('BasePart')then check(p:GetAttribute('ExpansionOriginalColor')==p.Color,'personal-state color restores authored material')end end
   end
   check(not m:FindFirstChild('Desk')and not m:FindFirstChild('InkWell')and not m:FindFirstChild('LeatherBookBinding'),'no field desk, ink or book')
   m:Destroy()
  end
 end end
end
check(assignments.actions['DW-07:stabilize']=='Shut down','portal shutdown is not labeled Activate rune')
check(kit.forStep('HG-07','crownheart',{id='confirmed',kind='relic'})==false,'personal Crownheart scene has no static duplicate')
fixture:Destroy()
print('STORY_PROP_CONTEXT_NATIVE '..game.HttpService:JSONEncode(report))
