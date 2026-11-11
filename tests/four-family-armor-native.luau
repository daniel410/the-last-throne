-- Local engine acceptance; no real players, profiles, purchases or DataStores.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Use an isolated local build')
local Shared=game.ReplicatedStorage.Shared
local Catalog=require(Shared.ItemCatalog)
local Visuals=require(Shared.FourFamilyArmorVisuals)
local Armor=require(game.ServerScriptService.Server.Cosmetics.ArmorAppearance)
local Motion=require(game.StarterPlayer.StarterPlayerScripts.Client.K0SwordVisual)
local report={kind='FOUR_FAMILY_ARMOR_NATIVE',checks=0,loads={},rigs={},pass=false}
local function check(value,message)report.checks+=1;assert(value,message)end
local folder=game.ServerStorage[Visuals.folderName]
local slots={head='Head',body='Body',hands='Hands',feet='Feet'}
local families={'traveler','tempered','veteran','sentinel'}
local expected={};local parts={}
local ok,err=xpcall(function()
 check(#folder:GetChildren()==28,'exact 28 armor templates')
 for _,model in folder:GetChildren()do
  local n=0
  for _,p in model:GetDescendants()do
   check(not p:IsA('LuaSourceContainer')and not p:IsA('PackageLink'),'scriptless pinned template')
   if p:IsA('MeshPart')then
    n+=1;expected[p.MeshId]=true;expected[p.TextureID]=true;table.insert(parts,p)
    check(p.Color==Color3.new(1,1,1),'original color texture with white tint')
    check(p:GetAttribute('ArmorAnchor')==p.Name,'audited skeletal panel')
   end
  end
  check(n==model:GetAttribute('ArmorPartCount'),'complete template')
 end
 check(#parts==92,'all articulated panels')
 game.ContentProvider:PreloadAsync(parts,function(id,status)report.loads[id]=status.Name end)
 for id in expected do check(report.loads[id]=='Success','native mesh/texture loaded '..id)end
 local templateCount=0;for _ in expected do templateCount+=1 end;report.uniqueContent=templateCount
 for _,rigType in {Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15}do
  for _,classId in {'knight','elf','dwarf','mage'}do
   local d=Instance.new('HumanoidDescription')
   local character=game.Players:CreateHumanoidModelFromDescriptionAsync(d,rigType);d:Destroy()
   character.Parent=workspace;character:PivotTo(CFrame.new(0,600,0));character.HumanoidRootPart.Anchored=true
   character:SetAttribute('K0ClassId',classId)
   local root=character.HumanoidRootPart;local before=root.CFrame;local hp=character.Humanoid.Health
   local accessory=Instance.new('Accessory');accessory.Name='OriginalHairQA';accessory.AccessoryType=Enum.AccessoryType.Hair
   local handle=Instance.new('Part');handle.Name='Handle';handle.Transparency=.25;handle.Parent=accessory;accessory.Parent=character
   local marker=Instance.new('Model');marker.Name='ExistingWeaponAndShieldQA';marker:SetAttribute('Sentinel',true);marker.Parent=character
   local original={};for _,p in character:GetChildren()do if p:IsA('BasePart')then original[p]=p.Transparency end end
   for _,family in families do
    local prefix=family=='sentinel'and'sentinel_tier'or family
    local selected={head=classId=='mage'and'mage_'..family..'_hat'or prefix..'_hood',
     body=classId=='mage'and'mage_'..family..'_coat'or prefix..'_coat',hands=prefix..'_gloves',feet=prefix..'_boots'}
    for slot,suffix in slots do
     check(Catalog.items[selected[slot]].slot==slot,'existing catalog slot')
     character:SetAttribute('TLTEquipped'..suffix,selected[slot])
    end
    Armor.sync(character)
    for slot,suffix in slots do
     local visual=assert(character:FindFirstChild('TLTArmor_'..slot),'missing worn '..slot)
     check(visual:GetAttribute('ArmorVisualKey')==Visuals.models[selected[slot]][classId],'correct family/class selection')
     check(visual:GetAttribute('ArmorDefinitionId')==selected[slot],'confirmed equipment projection')
     check(character:GetAttribute('TLTArmor'..suffix..'Error')==nil,'no visual fallback')
     local count=0
     for _,p in visual:GetChildren()do
      if p:IsA('MeshPart')then
       count+=1;check(not p.Anchored and p.Massless and not p.CanCollide and not p.CanTouch and not p.CanQuery,'inert cosmetic physics')
       check(p.Transparency==0,'equipped panel visible')
       local weld=assert(p:FindFirstChild('ArmorWeld'))
       check(weld.Part1==p and weld.Part0.Parent==character,'attached to this life')
       local wanted=p:GetAttribute('ArmorAnchor')
       if rigType==Enum.HumanoidRigType.R15 then check(weld.Part0.Name==wanted,'R15 skeletal anchor')end
      end
     end
     check(count==visual:GetAttribute('ArmorPartCount'),'no missing or duplicate panels')
     Armor.sync(character);check(character['TLTArmor_'..slot]==visual,'idempotent sync')
    end
    check(handle.Transparency==(classId=='mage' and .25 or 1),'Mage Hat preserves hair; enclosing headwear masks it')
    local torso=character:FindFirstChild('UpperTorso')or character:FindFirstChild('Torso')
    check(torso.Transparency==1,'opaque body clothing masks original torso')
    -- Drive the existing production action renderer; weld anchors must follow
    -- its skeleton rather than root-locking the sleeves, cuffs and skirt.
    local localFrames={}
    for _,model in character:GetChildren()do if model:GetAttribute('TLTArmorAppearance')then
     for _,p in model:GetChildren()do if p:IsA('MeshPart')then localFrames[p]=p.ArmorWeld.Part0.CFrame:ToObjectSpace(p.CFrame)end end
    end end
    for _,state in {'Attack','Dodge','Idle'}do
     character:SetAttribute('K0State',state);character:SetAttribute('K0AttackKind','Basic')
     character:SetAttribute('K0AttackStartedAt',1000);character:SetAttribute('K0AttackPhase','Active')
     Motion.renderArms(character,1/60,1000.25);Motion.renderCharacter(character,1/60,1000.25)
     for part,offset in localFrames do
      local weld=part.ArmorWeld
      check(weld.Enabled and weld.Part0.Parent==character and weld.Part1==part,'motion keeps garment joint')
      check((weld.Part0.CFrame:ToObjectSpace(part.CFrame).Position-offset.Position).Magnitude<.001,'cosmetic rest socket stays fixed')
     end
    end
    check(root.CFrame==before and character.Humanoid.Health==hp,'no root/health changes')
    check(marker.Parent==character and marker:GetAttribute('Sentinel')==true,'existing weapon/shield preserved')
   end
   -- A missing next template preserves the last complete projection.
   local previous=character.TLTArmor_head
   local firstId=classId=='mage'and'mage_traveler_hat'or'traveler_hood'
   local key=Visuals.models[firstId][classId];local missing=folder[key];missing.Parent=nil
   character:SetAttribute('TLTEquippedHead',firstId);Armor.sync(character)
   check(character.TLTArmor_head==previous and character:GetAttribute('TLTArmorHeadError')=='MissingTemplate','failed replacement retains complete previous visual')
   missing.Parent=folder;Armor.sync(character)
   check(character.TLTArmor_head~=previous and previous.Parent==nil,'template recovery replaces once')
   local worn=character.TLTArmor_hands;local panel=worn:FindFirstChildWhichIsA('MeshPart');panel:Destroy();Armor.sync(character)
   check(character.TLTArmor_hands~=worn,'missing panel repaired from pinned source')
   local duplicate=character.TLTArmor_feet:Clone();duplicate.Parent=character;Armor.sync(character)
   local count=0;for _,child in character:GetChildren()do if child.Name=='TLTArmor_feet'then count+=1 end end
   check(count==1,'duplicate projection removed')
   for _,suffix in slots do character:SetAttribute('TLTEquipped'..suffix,'')end
   Armor.sync(character)
   for slot in slots do check(not character:FindFirstChild('TLTArmor_'..slot),'unequip removes only owned armor')end
   check(handle.Transparency==.25,'original hair transparency restored')
   for part,value in original do check(part.Transparency==value,'original body visibility restored')end
   character:SetAttribute('TLTEquippedHead','unknown-definition');Armor.sync(character)
   check(not character:FindFirstChild('TLTArmor_head'),'unmapped equipment has no fabricated armor')
   character:SetAttribute('TLTEquippedHead','mage_traveler_hat');character:SetAttribute('K0ClassId','elf');Armor.sync(character)
   check(not character:FindFirstChild('TLTArmor_head'),'class restricted visuals do not leak')
   table.insert(report.rigs,{rig=rigType.Name,classId=classId,families=4})
   character:Destroy()
  end
 end
end,debug.traceback)
report.pass=ok;report.error=err
print('ARMOR_QA_JSON '..game.HttpService:JSONEncode(report));assert(ok,err)
