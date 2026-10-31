-- Isolated native scene/navigation and UI acceptance; no live account or saves.
local Run=game:GetService('RunService');local SSS=game.ServerScriptService;local Shared=game.ReplicatedStorage.Shared
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local report={kind='DEEPWOOD_PLACES_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local function waitFor(f)for _=1,30 do if f()then return true end;task.wait(.1)end end
local ok,err=xpcall(function()
 Run:Run();task.wait(3)
 local world=require(SSS.Server.World.DeepwoodWorld).create();local content=require(Shared.DeepwoodContent)
 local places=world.terrain.DeepwoodPlaces;local terraces,groves=0,0;local themes={}
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={world.terrain,world.folder.GroundedForest};params.RespectCanCollide=true
 local clear=OverlapParams.new();clear.FilterType=Enum.RaycastFilterType.Include;clear.FilterDescendantsInstances={places};clear.RespectCanCollide=true
 for id,z in pairs(content.zones)do
  local place=places[id];check(place and place:GetAttribute('PlaceTheme'),id..' has its own readable place')
  check(not themes[place:GetAttribute('PlaceTheme')],'each place has a distinct theme');themes[place:GetAttribute('PlaceTheme')]=true
  groves+=place:GetAttribute('AddedGroves') or 0
  if not place:GetAttribute('TerraceSkipped') then
   terraces+=1;check(place:GetAttribute('Clearance')>=0,'new solids reserve authored interaction and travel lanes')
   local p=place:GetAttribute('TerraceCenter');local rise=place:GetAttribute('TerraceRise')
   local hit=workspace:Raycast(p+Vector3.new(0,20,0),Vector3.new(0,-40,0),params)
   check(hit and math.abs(hit.Position.Y-p.Y-rise)<.1,'terrace has actual supported height')
   local ramps=0
   for _,ramp in ipairs(place:GetChildren())do if ramp.Name=='WalkableRamp'then
    ramps+=1;check(ramp.CanCollide and ramp.CanQuery,'ramps have real collision')
    local ends={}
    for _,sign in ipairs({-1,1})do table.insert(ends,ramp.CFrame:PointToWorldSpace(Vector3.new(0,.5,sign*(ramp.Size.Z/2-.2))))end
    table.sort(ends,function(a,b)return a.Y<b.Y end)
    for n=0,12 do
     local q=ends[1]:Lerp(ends[2],n/12);local floor=workspace:Raycast(q+Vector3.new(0,10,0),Vector3.new(0,-20,0),params)
     check(floor and math.abs(floor.Position.Y-q.Y)<.2,'ramp surface '..id..' sample '..n..' at '..tostring(q)..' hit '..tostring(floor and floor.Position)..' part '..tostring(floor and floor.Instance:GetFullName()))
    end
    local path=game:GetService('PathfindingService'):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false})
    path:ComputeAsync(ends[1]+Vector3.new(0,2,0),p+Vector3.new(0,rise+2,0))
    check(path.Status==Enum.PathStatus.Success,id..' both ramps reach the overlook without jumping')
   end end
   check(ramps==2,'each raised place has two open approaches')
  end
  check(#workspace:GetPartBoundsInBox(world.spawns[id].CFrame+Vector3.new(0,3,0),Vector3.new(16,4,16),clear)==0,'new scenery keeps checkpoint clear')
 end
 report.terraces=terraces;report.groves=groves;check(terraces>=8,'most regions gain optional elevation loops');check(groves>=140 and groves<=180,'grove density stays within bounded art budget')
 for _,ch in ipairs(content.chapters)do for _,goal in ipairs(ch.goals)do
  local p=Vector3.new(table.unpack(goal.position));check(#workspace:GetPartBoundsInBox(CFrame.new(p+Vector3.new(0,3,0)),Vector3.new(24,4,24),clear)==0,'new solids keep '..ch.id..':'..goal.id..' combat/interaction clear')
 end end
 check(require(SSS.Server.World.DeepwoodPlaces).create(world)==places,'reusing world cannot duplicate places')
 local client=game.StarterPlayer.StarterPlayerScripts.Client
 local gui=Instance.new('ScreenGui');gui.Parent=workspace
 local wallet=require(client.WalletDisplay);local map=require(client.BattleMinimap).create(gui)
 wallet.update({ready=true,wallet={gold=1234567,diamonds=89}})
 local view=map.frame.Wallet
 check(view.BackgroundTransparency==1 and not view.Active and not view:FindFirstChildOfClass('UIStroke'),'wallet has no panel or input surface')
 check(view.Position.Y.Scale==1 and view.Position.Y.Offset>0,'wallet sits below minimap and inherits its responsive scale')
 check(view.Gold.Text=='Gold  1234567' and view.Diamonds.Text=='Diamonds  89','wallet renders authoritative balances')
 check(view.TDIcon_gold and view.TDIcon_diamonds,'wallet reuses original TD currency icons')
 check(map.menu.Position.Y.Offset>168+view.Position.Y.Offset+view.Size.Y.Offset,'open map menu leaves wallet readable')
 wallet.update({ready=false});check(view.Gold.Text=='Gold  —' and view.Diamonds.Text=='Diamonds  —','unavailable wallet never claims zero balance')
 local rig=Instance.new('Model');rig.Parent=workspace
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Parent=rig
 local human=Instance.new('Humanoid');human.RequiresNeck=false;human.Parent=rig
 local bar=require(SSS.Server.World.EnemyHealthBar).attach(rig,human)
 check(not bar.BossBadge.Visible,'ordinary enemies have no boss badge')
 check(bar.EnemyLevel.Text=='Lv.1','training enemy has default level1')
 rig:SetAttribute('StoryLevel',17);check(waitFor(function()return bar.EnemyLevel.Text=='Lv.17'end),'late server level updates displayed level')
 rig:SetAttribute('StoryBoss',true);check(waitFor(function()return bar.BossBadge.Visible end),'late replicated boss rank updates its badge')
 check(bar.BossBadge.Text==require(Shared.K0Text).EnemyBossBadge and bar.BossBadge.Position.Y.Offset==0,'English badge above name and health')
 check(bar.EnemyName.Position.Y.Offset>=bar.BossBadge.Size.Y.Offset,'boss name does not overlap badge')
 check(bar.HpBg.Position.Y.Offset>=bar.EnemyName.Position.Y.Offset+bar.EnemyName.Size.Y.Offset,'health does not overlap name')
 human.Health=25;check(waitFor(function()return bar.HpBg.HpValue.Text=='25 / 100'end),'boss badge preserves live health updates')
 rig:SetAttribute('StoryBoss',false);check(waitFor(function()return not bar.BossBadge.Visible end),'removing boss rank restores ordinary display')
 check(bar.Size==UDim2.fromOffset(140,30) and bar.HpBg.Size==UDim2.new(1,-44,0,14),'ordinary display adds level while preserving compact HP width')
 human.Health=0;check(waitFor(function()return not bar.Enabled end),'death hides the whole overhead display')
 rig:Destroy();gui:Destroy()
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
if Run:IsRunning()then Run:Stop()end
report.pass=#report.failures==0;print('DEEPWOOD_PLACES_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'places native failed')
