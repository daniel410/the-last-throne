-- Local unpublished Studio native world/rig/contract fixture; no real Player.
local RS=game:GetService('ReplicatedStorage')
local SSS=game:GetService('ServerScriptService')
local Run=game:GetService('RunService')
local Http=game:GetService('HttpService')
local report={kind='DEEPWOOD_NATIVE',checks=0,failures={},coverage='Actual geometry and TD rigs, server-authoritative story contracts; no real Player/device/published save acceptance'}
local function check(v,m) report.checks+=1;if not v then table.insert(report.failures,m) end end
local function waitFor(f,seconds) local untilAt=os.clock()+seconds repeat local v=f();if v then return v end;task.wait(.1) until os.clock()>untilAt end
local ok,err=xpcall(function()
 for _,root in ipairs({RS.Shared,SSS.Server,game:GetService('StarterPlayer').StarterPlayerScripts}) do
  for _,m in ipairs(root:GetDescendants()) do if m:IsA('ModuleScript') then local success,result=pcall(require,m);check(success,m:GetFullName()..' '..tostring(result)) end end
 end
 Run:Run()
 local field=assert(waitFor(function() local m=workspace:FindFirstChild('DeepwoodCampaign');return m and m:GetAttribute('DeepwoodReady') and m end,25),'campaign bootstrap did not complete')
 local world=require(SSS.Server.World.DeepwoodWorld).create()
 local Content=require(RS.Shared.DeepwoodContent)
 local nav=require(game:GetService('StarterPlayer').StarterPlayerScripts.Client.DeepwoodNavigation)
 local function pos(id) return Vector3.new(table.unpack(Content.zones[id].center)) end
 local journal=require(game:GetService('StarterPlayer').StarterPlayerScripts.Client.DeepwoodJournal)
 for _,c in ipairs(Content.chapters) do if not c.side then for _,g in ipairs(c.goals) do
  local state={main=c.number-1,flags={},clears={}}
  for _,id in ipairs(g.requires) do state.flags[c.id..':'..id]=true end
  local current={journal=state,training=false};local target={chapter=c,goal=g}
  local guide=journal.guidance(current,target)
  check(guide and guide.position==Vector3.new(table.unpack(g.activity and g.activity.steps and g.activity.mode~='dialogue' and g.activity.mode~='escort' and g.activity.steps[1].position or g.position)),c.id..':'..g.id..' remains guided throughout Epic1')
  local path=nav.route(pos('DW-01'),guide.position)
  check(path[#path]==guide.position,g.id..' guide reaches actual objective')
  if #g.enemies>0 then
   check(guide.note:find(g.activity and 'Approach' or 'Hold F',1,true)~=nil,g.id..' explains encounter start')
   current.encounters={[c.id..':'..g.id]={remaining=2,pillars=0}}
   check(journal.guidance(current,target).note:find('2 left',1,true)~=nil,g.id..' explains remaining enemies')
   current.encounters[c.id..':'..g.id]={remaining=2,pillars=2}
   check(journal.guidance(current,target).note:find('seal pillars',1,true)~=nil,g.id..' explains shield blocker')
   current.encounters[c.id..':'..g.id]={remaining=0,pillars=0}
   check(journal.guidance(current,target).note:find('Saving',1,true)~=nil,g.id..' explains pending save')
  end
  current.training=true;check(journal.guidance(current,target)==nil,'training has no story guide')
  current.training=false;state.flags[c.id..':'..g.id]=true
  check(journal.guidance(current,target)==nil,'completed objective has no stale guide')
 end end end
 local route=nav.route(pos('DW-01')+Vector3.new(-30,3,45),pos('DW-03'))
 check(#route==5 and route[3]==pos('DW-02'),'guide uses the middle region instead of cutting across cliffs')
 local midpoint=pos('DW-01'):Lerp(pos('DW-02'),.4)
 route=nav.route(midpoint,pos('DW-03'))
 check(route[2]==pos('DW-02'),'guide continues forward while crossing the bridge')
 route=nav.route(pos('DW-03'),pos('DW-01'))
 check(route[3]==pos('DW-02'),'guide supports returning through connected regions')
 for id,z in pairs(Content.zones) do
  local ground=field.TerrainBlockout[id]:FindFirstChild('ForestGround')
  check(ground and ground.Position.X==z.center[1] and ground.Position.Z==z.center[3],id..' layout anchor')
  local spawn=world.spawns[id];check(spawn and spawn.Enabled and spawn.Neutral,id..' safe checkpoint')
 end
 check(workspace.StreamingEnabled and workspace.StreamingTargetRadius==384,'streaming configuration applied')
 check(game:GetService('StarterPlayer').CameraMaxZoomDistance==18,'bounded camera configured')
 check(Content.runtimeScale==2.2,'world lengths expanded 2.2 times')
 local count=0
 for _,c in ipairs(Content.chapters) do for _,g in ipairs(c.goals) do
  count+=1;local node=world.nodes[c.id..':'..g.id]
  check(node and node.prompt.MaxActivationDistance==12,c.id..g.id..' common interaction')
  check(node.part.Position==Vector3.new(table.unpack(g.position))+Vector3.new(0,1,0),g.id..' geometry anchor')
 end end
 report.objectives=count
 local activityCount=0
 for _,node in pairs(world.activityNodes) do
  activityCount+=1;local p=node.part.Position;local ground=field.TerrainBlockout[node.chapter.zone].ForestGround
  check(math.abs(p.X-ground.Position.X)<=ground.Size.X/2 and math.abs(p.Z-ground.Position.Z)<=ground.Size.Z/2,'activity stays on authored ground')
 end
 report.activitySteps=activityCount
 local appearance=require(SSS.Server.World.TdMonsterAppearance)
 local rig=require(SSS.Server.World.TrainingField)
 local combat=require(SSS.Server.Combat.CombatService)
 local enemies=workspace.DeepwoodK0.Enemies
 for index,kind in ipairs({'Goblin','Slime','Orc','Ogre','Shaman','Warlord','GoblinKing','KingOgre','EnragedWarlord','KingShaman'}) do
  local info=appearance.describe(kind);check(info.targetHeight>0,kind..' pinned template')
  local model=rig.makeEnemy(enemies,kind,1000+index*20,0,1,1)
  model:SetAttribute('DeepwoodEncounter','qa:'..kind);model:SetAttribute('StoryHealth',777);model:SetAttribute('StoryDamage',12)
  local enemy=combat.addStoryEnemy(model)
  check(enemy and enemy.humanoid.MaxHealth==777,kind..' server combat registration')
  check(model.TdMonsterVisual and #model.TdMonsterVisual:GetChildren()==#info.parts,kind..' actual TD parts')
  for _,part in ipairs(model.TdMonsterVisual:GetChildren()) do check(part:IsA('MeshPart') and part.MeshId~='',kind..' actual serialized mesh') end
  model:Destroy()
 end
 check(field.TerrainBlockout:FindFirstChild('ConnectedPath_DW-01_DW-02')~=nil,'continuous story path')
 check(field.TerrainBlockout:FindFirstChild('ConnectedPath_DW-05_DW-S3')~=nil,'optional battlefield route')
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err)) end
if Run:IsRunning() then Run:Stop() end
report.pass=#report.failures==0
print('DEEPWOOD_NATIVE '..Http:JSONEncode(report))
assert(report.pass,'Deepwood native failed')
