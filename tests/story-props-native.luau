-- Isolated, native story art acceptance; no account/save/publish calls.
local Run=game:GetService('RunService');local Server=game.ServerScriptService.Server
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place required')
local report={kind='STORY_PROPS_NATIVE',checks=0,failures={},models={},regions={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local ok,err=xpcall(function()
 local kit=require(Server.World.StoryProps);local specs=require(Server.World.StoryPropGeometry)
 local fixture=Instance.new('Folder');fixture.Name='StoryPropAcceptance';fixture.Parent=workspace
 for key,spec in pairs(specs) do
  local m=kit.build(fixture,key,Vector3.new(100,20,50));local count=0
  check(m:GetAttribute('StoryPurpose')==spec.purpose,key..' story purpose retained')
  check(m.ModelStreamingMode==Enum.ModelStreamingMode.Atomic,key..' streams as a complete model')
  for _,p in ipairs(m:GetDescendants())do if p:IsA('BasePart')then
   count+=1;check(p.Anchored and not p.CanCollide and not p.CanTouch and not p.CanQuery,key..' decorative physics')
   check(p.Size.X>0 and p.Size.Y>0 and p.Size.Z>0,key..' positive geometry')
   check(not p:IsA('Part') or p.Shape~=Enum.PartType.Ball,key..' no stand-in spheres')
  end end
  check(count==#spec.parts and count<=130,key..' bounded reproducible part count');report.models[key]=count
 end
 check(kit.forStep('EC-04','west_valve',{kind='lever',title='Open the western coolant valve'})=='CoolantValve','coolant uses pipe/handwheel, not generic lever')
 check(kit.forStep('DW-02','testimony',{kind='ledger',title="Find the convoy captain's badge"})=='ConvoyBadge','badge differs from a book')
 check(kit.forStep('DW-01','supplies',{kind='bindings',title='Find the loose travel ropes'})=='TravelBindings','ropes do not become machinery')
 fixture:Destroy()
 Run:Run();task.wait(3)
 local world=require(Server.World.CampaignWorld).create();local content=require(game.ReplicatedStorage.Shared.CampaignContent)
 local artCount,parts=0,0
 for _,d in ipairs(world.folder:GetDescendants())do if d:IsA('Model') and d:GetAttribute('StoryPropKey')then
  artCount+=1
  for _,p in ipairs(d:GetDescendants())do if p:IsA('BasePart')then
   parts+=1;check(not p.CanCollide and not p.CanTouch and not p.CanQuery,'placed art preserves navigation and raycasts')
  end end
 end end
 for _,c in ipairs(content.chapters)do if not c.side then for _,g in ipairs(c.goals)do
  local node=world.nodes[c.id..':'..g.id];check(node~=nil,c.id..':'..g.id..' objective preserved')
  check((node.part.Position-(Vector3.new(table.unpack(g.position))+Vector3.new(0,1,0))).Magnitude<.01,'objective position unchanged')
  for _,s in ipairs(g.activity and g.activity.steps or {})do
   local entry=world.activityNodes[c.id..':'..g.id..':'..s.id]
   check(entry and entry.step==s,'stable step identity retained')
   check((entry.part.Position-(Vector3.new(table.unpack(s.position))+Vector3.new(0,1,0))).Magnitude<.01,'step interaction location unchanged')
   local expected=kit.forStep(c.id,g.id,s)
   local mode=g.activity.mode
   if expected and mode~='dialogue' and mode~='escort' then
    local art=world.folder.AdventureActivities:FindFirstChild(c.id..'_'..g.id..'_'..s.id..'_Art')
    check(art and art:GetAttribute('StoryPropKey')==expected,'story-specific step model exists')
    report.regions[c.epic or 1]=true
   end
  end
 end end end
 local before=#world.folder.AdventureActivities:GetChildren();require(Server.World.DeepwoodActivityWorld).create(world)
 check(#world.folder.AdventureActivities:GetChildren()==before,'repeated world acquisition does not duplicate art')
 check(artCount>80 and parts<18000,'bounded full campaign dressing')
 local valve=world.folder.AdventureActivities:FindFirstChild('EC-04_west_valve_operate_Art')
 check(valve and valve:GetAttribute('StoryVisualKey')=='EC-04:west_valve','valve keeps personal saved-state key')
 local presentation=require(game.StarterPlayer.StarterPlayerScripts.Client.EmberCalderaPresentation)
 presentation.update({flags={['EC-04:west_valve']=true}})
 check(valve:FindFirstChild('ValveHandwheel').Color==Color3.fromRGB(85,202,196),'completed valve handle shows saved state')
 presentation.update({flags={}})
 check(valve:FindFirstChild('ValveHandwheel').Color==Color3.fromRGB(163,125,63),'incomplete valve handle restores authored color')
 report.placedModels=artCount;report.placedParts=parts
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
if Run:IsRunning()then Run:Stop()end
report.pass=#report.failures==0;print('STORY_PROPS_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'story prop acceptance failed')
