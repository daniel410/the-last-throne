-- Isolated native GUI/geometry fixture; no server combat or saved preferences.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Use an isolated local place')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local Settings=require(client.GameSettings)
local report={kind='DISPLAY_GUIDES_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local scratch=Instance.new('Folder');scratch.Name='DisplayGuidesQA';scratch.Parent=workspace
local player=Instance.new('Folder');player.Name='Player';player.Parent=scratch
local playerGui=Instance.new('Folder');playerGui.Name='PlayerGui';playerGui.Parent=player
local function rig(parent,name,position)
 local m=Instance.new('Model');m.Name=name;m.Parent=parent
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.CanCollide=false;root.Position=position;root.Parent=m
 local human=Instance.new('Humanoid');human.Parent=m
 return m,root
end
local character,root=rig(player,'Character',Vector3.new(200,21,0))
local world=Instance.new('Folder');world.Name='DeepwoodK0';world.Parent=workspace
local enemies=Instance.new('Folder');enemies.Name='Enemies';enemies.Parent=world
local training=Instance.new('Folder');training.Name='TerrainBlockout';training.Parent=world
local field=Instance.new('Folder');field.Name='DeepwoodCampaign';field.Parent=workspace
local terrain=Instance.new('Folder');terrain.Name='TerrainBlockout';terrain.Parent=field
local function ground(parent,position)
 local p=Instance.new('Part');p.Name='ForestGround';p.Size=Vector3.new(80,2,80);p.Position=position;p.Anchored=true;p.Parent=parent;return p
end
ground(training,Vector3.new(0,-1,0));local floor=ground(terrain,Vector3.new(200,17,0))
local enemy,enemyRoot=rig(enemies,'EpicMonster',Vector3.new(200,21,0))
enemy:SetAttribute('K0EnemyState','Windup');enemy:SetAttribute('K0Telegraph','Melee')
enemy:SetAttribute('K0AttackOrigin',enemyRoot.Position);enemy:SetAttribute('K0AttackDirection',Vector3.new(0,0,-1))
enemy:SetAttribute('K0AttackRange',10);enemy:SetAttribute('K0AttackAngle',90)
player:SetAttribute('K0SessionPhase','Tutorial')
local view,telegraphs
local Prompts=game:GetService('ProximityPromptService')
local originalPrompts=Prompts.Enabled
local ok,err=xpcall(function()
 for _,option in ipairs(Settings.options)do check(Settings.enabled(player,option.id),'guides default ON')end
 view=require(client.SettingsGui).create(player)
 check(not view.isOpen(),'settings initially closed')
 view.open();check(view.isOpen() and player:GetAttribute('TLTSettingsOpen') and not Prompts.Enabled,'settings modal blocks gameplay prompts')
 for _,option in ipairs(Settings.options)do
  local button=view.toggles[option.id]
  check(button.Caption.Text=='ON' and button.Selectable and button.Size.Y.Offset>=44,'readable selectable ON toggle')
  Settings.toggle(player,option.id);task.wait()
  check(button.Caption.Text=='OFF' and not button:GetAttribute('Enabled'),'external/map changes update settings control')
  Settings.toggle(player,option.id);task.wait()
 end
 Settings.set(player,'navigation',false)
 check(Settings.enabled(player,'attacks') and Settings.enabled(player,'waypoints'),'navigation toggle does not hide other guides')
 view.close();check(not view.isOpen() and Prompts.Enabled==originalPrompts,'close restores prompt state')
 view=require(client.SettingsGui).create(player)
 check(not Settings.enabled(player,'navigation') and view.toggles.navigation.Caption.Text=='OFF','rebuilding menu preserves session preferences')
 view.open();player:SetAttribute('TLTInventoryOpen',true);task.wait()
 check(not view.isOpen(),'opening bag closes settings')
 player:SetAttribute('TLTInventoryOpen',false);view.open();player:SetAttribute('K0SessionPhase','Respawning');task.wait()
 check(not view.isOpen(),'respawn closes settings')
 player:SetAttribute('K0SessionPhase','Tutorial')
 telegraphs=require(client.K0Telegraphs).create(enemies,player);telegraphs.update()
 local function visible()
  local parts={};for _,p in ipairs(workspace.K0LocalTelegraphs:GetDescendants())do if p:IsA('BasePart') and p.Transparency<1 then table.insert(parts,p)end end;return parts
 end
 check(#visible()==18,'epic melee arc and radial boundaries shown')
 for _,p in ipairs(visible())do check(math.abs(p.Position.Y-18.16)<.01,'epic guide lies above actual raised ground')end
 floor.CFrame=CFrame.new(200,17,0)*CFrame.Angles(0,0,math.rad(8));telegraphs.update()
 local minY,maxY=math.huge,-math.huge
 for _,p in ipairs(visible())do minY=math.min(minY,p.Position.Y);maxY=math.max(maxY,p.Position.Y)end
 check(maxY-minY>.5,'warning projects onto a slope instead of one fixed height')
 Settings.set(player,'attacks',false);task.wait();check(#visible()==0,'OFF removes ground outlines immediately')
 local hazard=Instance.new('Part');hazard.Name='CorruptionWarning';hazard.Transparency=.5;hazard.Anchored=true;hazard.Parent=field;task.wait()
 check(hazard.LocalTransparencyModifier==1 and hazard.Transparency==.5,'OFF also hides late boss warnings locally without changing server transparency')
 check(enemy:GetAttribute('K0EnemyState')=='Windup' and enemy:GetAttribute('K0AttackRange')==10,'toggle cannot change attack state or range')
 Settings.set(player,'attacks',true);task.wait();check(#visible()==18,'ON restores ongoing attack')
 check(hazard.LocalTransparencyModifier==0,'ON restores boss warning')
 enemy:SetAttribute('K0Telegraph','Unblockable');enemy:SetAttribute('K0AttackAngle',360);telegraphs.update()
 check(#visible()==16 and visible()[1].Color==Color3.fromRGB(255,73,58),'unblockable full circle remains red')
 enemy:SetAttribute('K0EnemyState','Idle');telegraphs.update();check(#visible()==0,'idle attack does not leave stale guide')
 enemy:SetAttribute('K0EnemyState','Active');root.Position=Vector3.new(0,3,0);telegraphs.update()
 check(#workspace.K0LocalTelegraphs:GetChildren()==0,'distant enemies release guide parts')
 enemyRoot.Position=Vector3.new(0,3,0);enemy:SetAttribute('K0AttackOrigin',enemyRoot.Position);telegraphs.update()
 check(#visible()==16 and math.abs(visible()[1].Position.Y-.16)<.01,'training floor remains correct')
 enemyRoot.Parent=nil;telegraphs.update();check(#visible()==0,'partial streamed rig hides warning')
 enemyRoot.Parent=enemy;telegraphs.update();check(#visible()==16,'late streamed root restores warning')
 enemy.Parent=scratch;check(#workspace.K0LocalTelegraphs:GetChildren()==0,'stream-out destroys guide immediately')
 enemy.Parent=enemies;telegraphs.update();check(#visible()==16,'stream-in restores active warning')
 player:SetAttribute('K0SessionPhase','Lobby');telegraphs.update();check(#visible()==0,'lobby hides training/adventure warnings')
end,debug.traceback)
if telegraphs then telegraphs.destroy()end
if view then view.gui:Destroy()end
scratch:Destroy();world:Destroy();field:Destroy();Prompts.Enabled=originalPrompts
if not ok then table.insert(report.failures,tostring(err))end
report.pass=#report.failures==0
print('DISPLAY_GUIDES_NATIVE '..game.HttpService:JSONEncode(report))
assert(report.pass,'Display guide verification failed')
