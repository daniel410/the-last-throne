-- Isolated real-mesh/rig acceptance. No Player profiles, purchases or DataStores.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Use an isolated local build')
local S=game.ReplicatedStorage.Shared
local V=require(S.FourFamilyShieldVisuals)
local C=require(S.ItemCatalog)
local cosmetics=game.ServerScriptService.Server.Cosmetics
local A=require(cosmetics.WeaponAppearance)
local Visual=require(game.StarterPlayer.StarterPlayerScripts.Client.K0SwordVisual)
local copy=cosmetics.KnightAppearance:Clone();copy.Name='ShieldLifecycleQA';copy.Source=copy.Source:gsub('\nreturn KnightAppearance%s*$','\nreturn {sync=syncAppearance}');copy.Parent=cosmetics
local lifecycle=require(copy)
local report={kind='FOUR_FAMILY_SHIELDS_NATIVE',checks=0,loads={},rigs={},pass=false}
local function check(v,m)report.checks+=1;assert(v,m)end
local ids={'knight_shield','knight_shield_fine','veteran_tier_shield','sentinel_tier_shield'}
local folder=game.ServerStorage[V.folderName];local preload={};local expected={}
local ok,err=xpcall(function()
 check(#folder:GetChildren()==4,'exact four shields')
 for _,id in ipairs(ids)do
  local spec=V.models[id];local t=folder[id]
  check(C.items[id].slot=='offhand','existing offhand definition')
  check(t:GetAttribute('MeshyTaskId')==spec.taskId and t:GetAttribute('ShieldDefinitionId')==id,'exact Task ID and equipment mapping')
  check(math.abs(t.Shield.Size.Y-1.88)<.0001,'same reviewed height')
  check(t.Shield.Color==Color3.new(1,1,1),'original texture without color tint')
  for _,n in ipairs(t:GetDescendants())do check(not n:IsA('LuaSourceContainer')and not n:IsA('PackageLink'),'scriptless unlinked runtime copy')end
  expected[spec.meshId]=true;expected[spec.textureId]=true;table.insert(preload,t.Shield)
 end
 game.ContentProvider:PreloadAsync(preload,function(id,status)report.loads[id]=status.Name end)
 for id in pairs(expected)do check(report.loads[id]=='Success','mesh/texture load '..id)end
 for _,rig in ipairs({Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15})do
  local desc=Instance.new('HumanoidDescription');local character=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,rig);desc:Destroy();character.Parent=workspace;character:PivotTo(CFrame.new(0,500,0));character.HumanoidRootPart.Anchored=true
  local root=character.HumanoidRootPart;local before=root.CFrame;local health=character.Humanoid.Health
  character:SetAttribute('K0ClassId','knight');character:SetAttribute('TLTEquippedWeapon','knight_weapon_traveler')
  for _,id in ipairs(ids)do
   character:SetAttribute('TLTEquippedOffhand',id);lifecycle.sync(character)
   local model=assert(character:FindFirstChild('TLT_K0_KnightAppearance'));local result=assert(A.attachShieldInto(model,character))
   check((result.shield.Size-folder[id].Shield.Size*V.visualScale).Magnitude<.0001,'all dimensions use reviewed visual scale')
   check(math.abs(result.shield.Size.Y-2.444)<.0001,'visible height increased 30 percent')
   local rest=result.grip.CFrame:ToObjectSpace(result.shield.CFrame)
   check((rest.Position-folder[id].Shield.CFrame.Position*V.visualScale).Magnitude<.0001,'back socket stays fixed while visual center scales')
   check(model:GetAttribute('ShieldVisualScale')==V.visualScale,'projection records its visual scale')
   check(result.shield.MeshId==V.models[id].meshId and result.shield.TextureID==V.models[id].textureId,'selected equipment changes physical shield '..id)
   check(model:GetAttribute('ShieldDefinitionId')==id and model:GetAttribute('ShieldSourceKey')==V.models[id].sourceKey,'runtime provenance')
   check(model:GetAttribute('UsesFourFamilyShield')==true and model:GetAttribute('UsesTdPlayerShield')==false,'family source explicitly identified')
   check(A.isShieldAttached(model,character),'valid left hand and visual weld')
   check(A.isAttached(model,character,'knight'),'right-hand sword preserved')
   local same=assert(A.attachShieldInto(model,character));check(same.shield==result.shield,'idempotent attach')
   model:SetAttribute('ShieldVisualScale',1)
   check(not A.isShieldAttached(model,character),'older smaller projection is rejected')
   result=assert(A.attachShieldInto(model,character))
   check(result.shield~=same.shield and same.shield.Parent==nil,'older projection rebuilt once at the new scale')
   lifecycle.sync(character);check(character.TLT_K0_KnightAppearance==model,'lifecycle preserves correct attachment')
   local owned=0
   for _,p in ipairs(model:GetDescendants())do if p:IsA('BasePart')and p:GetAttribute('TLTPlayerShieldPart')then owned+=1;check(not p.Anchored and p.Massless and not p.CanCollide and not p.CanTouch and not p.CanQuery,'cosmetic inert physics')end end
   check(owned==2,'no duplicate shield or socket')
   check(result.shield.Transparency<1,'equipped shield visible')
   local hand=result.joint.Part0;local offset=hand.CFrame:ToObjectSpace(result.shield.CFrame)
   -- Native import rebases mesh axes by180 degrees; use the audited surface front rather than mesh -Z.
   local nativeFront=folder[id].Shield.CFrame:VectorToObjectSpace(Vector3.new(0,0,-1))
   local joints={};for _,j in ipairs(character:GetDescendants())do if (j:IsA('Motor6D')or j:IsA('AnimationConstraint'))and j.Part0 and j.Part1 then joints[j.Part1]=j end end
   local function frame(p)local j=joints[p];return j and frame(j.Part0)*j.C0*j.Transform*j.C1:Inverse()or p.CFrame end
   character:SetAttribute('K0State','Attack');character:SetAttribute('K0AttackKind','Basic');character:SetAttribute('K0SkillId','knight.common.bash');character:SetAttribute('K0AttackStartedAt',1000);character:SetAttribute('K0AttackPhase','Active')
   Visual.renderArms(character,1/60,1000.25);Visual.renderCharacter(character,1/60,1000.25)
   check((frame(hand)*offset):VectorToWorldSpace(nativeFront):Dot(root.CFrame.LookVector)>.9,'shield face points toward target during bash')
   check(root.CFrame==before and character.Humanoid.Health==health,'pose/swap preserve authoritative root and health')
   character:SetAttribute('K0State','Idle');character:SetAttribute('K0AttackPhase','None');for i=1,30 do Visual.renderArms(character,1/60,1001+i/60);Visual.renderCharacter(character,1/60,1001+i/60)end
  end
  -- Failed template load retains the currently owned shield until a valid replacement exists.
  local model=character.TLT_K0_KnightAppearance;local previous=model.Shield
  local template=folder[ids[1]];template.Name='ShieldTemporarilyUnavailable';character:SetAttribute('TLTEquippedOffhand',ids[1]);local missing=A.attachShieldInto(model,character);template.Name=ids[1]
  check(missing==nil and previous.Parent==model,'failed load is non-destructive')
  character:SetAttribute('TLTEquippedOffhand','legacy-unlisted-shield');lifecycle.sync(character);model=character.TLT_K0_KnightAppearance
  check(model:GetAttribute('ShieldSourceKey')=='td:SwordsmanShield'and model:GetAttribute('ShieldDefinitionId')==nil,'unlisted shield retains legacy source')
  character:SetAttribute('TLTEquippedOffhand','');lifecycle.sync(character);model=character.TLT_K0_KnightAppearance
  for _,p in ipairs(model:GetChildren())do if p:IsA('BasePart')and p:GetAttribute('TLTPlayerShieldPart')then check(p.Transparency==1,'unequipped shield hidden')end end
  character:SetAttribute('K0ClassId','mage');character:SetAttribute('TLTEquippedWeapon','mage_weapon_traveler');lifecycle.sync(character);model=character.TLT_K0_KnightAppearance
  check(not model:FindFirstChild('K0ShieldHandWeld',true),'other classes do not gain shield')
  report.rigs[rig.Name]='four family swaps, bash facing, idempotence, failure recovery, legacy, unequip, class switch passed';character:Destroy()
 end
end,debug.traceback)
copy:Destroy();report.pass=ok;report.error=err;print('SHIELD_QA_JSON '..game.HttpService:JSONEncode(report));assert(ok,err)
