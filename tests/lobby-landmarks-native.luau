local RS=game.ReplicatedStorage;local SSS=game.ServerScriptService;local Run=game:GetService('RunService')
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Use an isolated local RPG artifact')
local report={kind='LOBBY_LANDMARKS_NATIVE',checks=0,failures={},coverage='Native world, raycast approaches, original prompt dispatch/access with Player doubles; no real client or teleport acceptance'}
local function check(v,m) report.checks+=1;assert(v,m) end
local ok,err=xpcall(function()
 Run:Run();task.wait(3)
 local lobby=workspace.DawnspireLobbyPrototype
 local facilities={portal=lobby.DawnspireExpeditionPortal,training=lobby.DawnspireTrainingGround,forge=lobby.DawnspireWeaponMerchant}
 for name,m in pairs(facilities) do
  local prompt=m:FindFirstChildWhichIsA('ProximityPrompt',true)
  check(prompt and prompt.Style==Enum.ProximityPromptStyle.Custom,name..' has cross-input entry')
  check(prompt.KeyboardKeyCode==Enum.KeyCode.F and prompt.GamepadKeyCode==Enum.KeyCode.ButtonX,name..' stable input')
  check(m:FindFirstChild('FacilitySign',true).Title.Text==({portal='EXPEDITIONS',training='TRAINING GROUNDS',forge='BLACKSMITH'})[name],name..' English sign')
  for _,v in ipairs(m:GetDescendants()) do
   if v:IsA('BasePart') then check(v.Anchored,name..' no loose physics') end
   if v:IsA('LuaSourceContainer') then error('Executable source in facility scenery') end
  end
  local p=prompt.Parent.Position;local start=p+Vector3.new(0,2,7)
  local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={lobby};params.RespectCanCollide=true
  check(workspace:Raycast(start,Vector3.new(0,-12,0),params)~=nil,name..' grounded walk-up')
  check(workspace:Raycast(start,Vector3.new(0,0,-6),params)==nil,name..' approach has no solid obstruction')
 end
 local veil=facilities.portal.PortalVeil
 check(math.abs(veil.CFrame.RightVector.Z)>.99,'portal disk stands vertically facing the courtyard')
 check(facilities.forge:FindFirstChild('TDWeaponDisplay1')~=nil,'shared TD weapons displayed at new forge')
 check(facilities.forge:FindFirstChild('AnvilTop') and facilities.forge:FindFirstChild('ForgeFire',true),'working forge silhouette and bounded fire')
 check(facilities.training:FindFirstChild('DummyBody') and facilities.training:FindFirstChild('ArcheryTarget'),'training visible before entering practice')
 local scratch=Instance.new('Folder');scratch.Name='FacilityAccessQA';scratch.Parent=workspace
 local function person(at,phase,attrs)
  local model=Instance.new('Model');local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Position=at;root.Parent=model
  local human=Instance.new('Humanoid');human.RequiresNeck=false;human.Parent=model;model:SetAttribute('K0SpawnReady',true);model.Parent=scratch
  local p={Character=model,attrs=attrs or {}};p.attrs.K0SessionPhase=phase or 'Lobby';function p:GetAttribute(k) return self.attrs[k] end
  return p
 end
 local Access=require(SSS.Server.Lobby.FacilityAccess);local prompt=facilities.portal:FindFirstChildWhichIsA('ProximityPrompt',true)
 check(Access.allowed(person(prompt.Parent.Position),prompt),'healthy lobby hero may interact')
 check(not Access.allowed(person(prompt.Parent.Position+Vector3.new(50,0,0)),prompt),'remote trigger is denied by server position')
 check(not Access.allowed(person(prompt.Parent.Position,'Tutorial'),prompt),'adventure cannot use lobby facility')
 check(not Access.allowed(person(prompt.Parent.Position,'Lobby',{TLTTravelLock=true}),prompt),'departing hero cannot enter facility')
 local dead=person(prompt.Parent.Position);dead.Character.Humanoid.Health=0;check(not Access.allowed(dead,prompt),'dead life denied')
 local unready=person(prompt.Parent.Position);unready.Character:SetAttribute('K0SpawnReady',false);check(not Access.allowed(unready,prompt),'unready spawn denied')
 local copy=SSS.Server.Lobby.FacilityService:Clone();copy.Name='FacilityServiceQA';copy.Source=copy.Source:gsub('remote:FireClient%(player,{error=errorCode}%)','player.notice=errorCode');copy.Parent=SSS.Server.Lobby
 local bindings={};local function proxy(original)
  local e=Instance.new('BindableEvent');e.Parent=scratch;table.insert(bindings,e)
  local p={Triggered=e.Event,Enabled=true,Parent=original.Parent,MaxActivationDistance=original.MaxActivationDistance}
  function p:IsDescendantOf(root) return original:IsDescendantOf(root) end
  return {prompt=p},e
 end
 local portal,pe=proxy(prompt);local training,te=proxy(facilities.training:FindFirstChildWhichIsA('ProximityPrompt',true));local opened,entered=0,0
 require(copy).start({facilities={portal=portal,training=training},expedition={openMenu=function() opened+=1 end},heroSession={startTraining=function() entered+=1;return 'SelectHeroFirst' end}})
 pe:Fire(person(prompt.Parent.Position));task.wait();check(opened==1,'portal dispatches adventure menu instead of auto launch')
 pe:Fire(person(prompt.Parent.Position+Vector3.new(50,0,0)));task.wait();check(opened==1,'spoofed prompt cannot dispatch')
 local trainee=person(training.prompt.Parent.Position);te:Fire(trainee);task.wait();check(entered==1 and trainee.notice=='SelectHeroFirst','training dispatch preserves actionable hero error')
 copy:Destroy();scratch:Destroy()
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err)) end
if Run:IsRunning() then Run:Stop() end
report.pass=#report.failures==0
print('LOBBY_LANDMARKS_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'Lobby landmark fixture failed')
