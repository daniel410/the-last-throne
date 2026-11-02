-- Native player appearance lifecycle with CharacterAdded/Removing identity fixtures.
local Players=game:GetService('Players');local SS=game:GetService('ServerStorage')
local modules=game.ServerScriptService.Server.Cosmetics;local A=require(modules.WeaponAppearance)
local V=require(game.StarterPlayer.StarterPlayerScripts.Client.K0SwordVisual)
local expected={knight={'SwordBlade','136222429214301','td:v2:AzureOathblade'},dwarf={'Weapon','137793778150208','td:v2:Embercleaver:edge1'},mage={'WoodenShaft',nil,'authored:WoodenStaff'},elf={'Bow','83795343518288','td:ElfBow'}}
local report={kind='REFINED_PLAYER_WEAPONS_NATIVE',checks=0,failures={},assetLoads={},coverage='Native R6/R15 new PBR meshes, production appearance observers, re-equip/repair/respawn with Player identity fixtures; no real account or published client'}
local function check(v,m)report.checks+=1;assert(v,m)end
local function waitFor(fn)local t=os.clock();repeat local v=fn();if v then return v end;task.wait(.03)until os.clock()-t>4 end
local copy=modules.KnightAppearance:Clone();copy.Name='RefinedLifecycleQA';copy.Source=copy.Source:gsub('\nreturn KnightAppearance%s*$','\nreturn {bind=bindPlayer,unbind=unbindPlayer,sync=syncAppearance}\n');copy.Parent=modules
local lifecycle=require(copy);local all,players,events,preload={},{},{},{}
local function appearance(c)for _,m in ipairs(c:GetChildren())do if m:IsA('Model') and m:GetAttribute('TLT_K0_KnightAppearance')then return m end end end
local ok,err=xpcall(function()
 for _,rig in ipairs({Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15})do
  local desc=Instance.new('HumanoidDescription');local template=Players:CreateHumanoidModelFromDescriptionAsync(desc,rig);desc:Destroy()
  for class,spec in pairs(expected)do
   local first=template:Clone();first.Parent=workspace;table.insert(all,first);first:SetAttribute('K0ClassId',class)
   local added,removing=Instance.new('BindableEvent'),Instance.new('BindableEvent');table.insert(events,added);table.insert(events,removing)
   local player={Character=first,CharacterAdded=added.Event,CharacterRemoving=removing.Event};table.insert(players,player)
   lifecycle.bind(player);lifecycle.bind(player)
   local model=assert(waitFor(function()return appearance(first)end),'appearance attaches')
   check(model:GetAttribute('WeaponVisualVersion')==2 and model:GetAttribute('WeaponSourceKey')==spec[3],'actual player appearance selects reviewed v2 source')
   local part=assert(model:FindFirstChild(spec[1]))
   if class=='mage' then
    check(part:IsA('Part') and part.Material==Enum.Material.Wood,'base Mage uses apprentice wooden shaft')
    check(not model:FindFirstChild('Weapon') and model:FindFirstChild('LeftFork')~=nil,'Pyro mesh is absent from default Mage')
   else
    check(part:IsA('MeshPart') and part.MeshId=='rbxassetid://'..spec[2],'live class uses replacement mesh')
    check(part:FindFirstChildOfClass('SurfaceAppearance')~=nil,'replacement PBR is attached')
   end
   check(A.isAttached(model,first,class),'replacement validates complete rig/socket ownership')
   table.insert(preload,part)
   local total=0;for _,p in ipairs(model:GetChildren())do if p:IsA('BasePart') and p:GetAttribute('TLTPlayerWeaponPart')then total+=1;check(p.Massless and not p.Anchored and not p.CanCollide and not p.CanTouch and not p.CanQuery,'new weapon parts cannot change collision/hit authority')end end
   first:SetAttribute('K0State','Attack');first:SetAttribute('K0AttackKind','Basic');first:SetAttribute('K0AttackStartedAt',100);first:SetAttribute('K0AttackPhase','Active')
   V.renderArms(first,1/60,100.16);check(V.renderCharacter(first,1/60,100.16)==1,'new weapon uses production motion renderer')
   local tip=model:FindFirstChild('WeaponTip',true);check(tip and tip.Position.Y>0,'new mesh retains valid projectile/trail tip')
   first:SetAttribute('TLTEquippedWeapon','');task.wait(.06)
   check(part.Transparency==1,'unequipped replacement is hidden through real equipment observer')
   first:SetAttribute('TLTEquippedWeapon',class..'_weapon_fine');task.wait(.06)
   check(part.Transparency<1,'re-equipping restores replacement')
   -- A version-1 appearance is replaced rather than reused after an upgrade.
   model:SetAttribute('WeaponVisualVersion',1);lifecycle.sync(first)
   local replacement=assert(waitFor(function()local m=appearance(first);return m and m~=model and m end))
   check(replacement:GetAttribute('WeaponVisualVersion')==2,'stale old visual is rebuilt with new source')
   local grip=replacement:FindFirstChild(class=='knight' and 'SwordGrip' or 'WeaponGrip');local joint=grip:FindFirstChild(class=='knight' and 'K0SwordJoint' or 'PlayerWeaponJoint');joint:Destroy()
   check(waitFor(function()local m=appearance(first);return m and A.isAttached(m,first,class)end),'missing socket repairs to the refined model')
   removing:Fire(first);player.Character=nil
   local second=template:Clone();second.Parent=workspace;table.insert(all,second);player.Character=second;added:Fire(second)
   task.wait(.06);check(not appearance(second),'respawn waits for server-owned class')
   second:SetAttribute('K0ClassId',class)
   local respawn=assert(waitFor(function()return appearance(second)end))
   check(respawn:GetAttribute('WeaponSourceKey')==spec[3] and A.isAttached(respawn,second,class),'respawn uses replacement with the correct class')
   lifecycle.unbind(player)
  end
  template:Destroy()
 end
 local done=false;task.spawn(function()
  report.preload_ok,report.preload_error=pcall(function()game.ContentProvider:PreloadAsync(preload,function(id,status)report.assetLoads[id]=tostring(status)end)end);done=true
 end)
 local t=os.clock();repeat task.wait(.1)until done or os.clock()-t>15
 report.preload_finished=done;report.asset_permission_scope='Studio asset fetch; published RPG client permission and device render remain separate'
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
for _,p in ipairs(players)do lifecycle.unbind(p)end
for _,e in ipairs(events)do e:Destroy()end
for _,m in ipairs(all)do m:Destroy()end;copy:Destroy()
report.pass=#report.failures==0
print('REFINED_PLAYER_WEAPONS_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'Refined weapon integration failed')
