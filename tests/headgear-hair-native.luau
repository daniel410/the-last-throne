assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Use an isolated local build')
local A=require(game.ServerScriptService.Server.Cosmetics.ArmorAppearance)
local V=require(game.ReplicatedStorage.Shared.FourFamilyArmorVisuals)
local f=game.ServerStorage[V.hair.folderName]
local report={kind='HEADGEAR_HAIR_NATIVE',checks=0,loads={},cases=0,pass=false}
local function check(v,m)report.checks+=1;assert(v,m)end
local ok,err=xpcall(function()
 check(#f:GetChildren()==3,'three pinned hairstyle meshes')
 local expected={}
 for _,p in f:GetChildren()do
  check(p:IsA('MeshPart') and p:GetAttribute('HeadgearHair')==true,'hair-only template')
  check(p.TextureID=='' and p.Color==Color3.new(1,1,1),'intentional tintable untextured source')
  expected[p.MeshId]=true
  for _,d in p:GetDescendants()do check(not d:IsA('LuaSourceContainer')and not d:IsA('PackageLink'),'unlinked scriptless hair')end
 end
 game.ContentProvider:PreloadAsync(f:GetChildren(),function(id,status)report.loads[id]=status.Name end)
 for id in expected do check(report.loads[id]=='Success','hair mesh loaded '..id)end
 for _,rig in {Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15}do
  local d=Instance.new('HumanoidDescription');local c=game.Players:CreateHumanoidModelFromDescriptionAsync(d,rig);d:Destroy()
  c.Parent=workspace;c:PivotTo(CFrame.new(0,700,0));c.HumanoidRootPart.Anchored=true
  local accessory=Instance.new('Accessory');accessory.Name='OriginalHairQA';accessory.AccessoryType=Enum.AccessoryType.Hair
  local h=Instance.new('Part');h.Name='Handle';h.Transparency=.3;h.Parent=accessory;accessory.Parent=c
  local before=c.HumanoidRootPart.CFrame;local health=c.Humanoid.Health
  for _,class in {'mage','elf','knight','dwarf'}do for _,family in {'traveler','tempered','veteran','sentinel'}do
   local prefix=family=='sentinel'and'sentinel_tier'or family
   c:SetAttribute('K0ClassId',class);c:SetAttribute('TLTEquippedHead',class=='mage'and'mage_'..family..'_hat'or prefix..'_hood')
   A.sync(c)
   local model=assert(c:FindFirstChild('TLTArmor_head'));local hair=assert(model:FindFirstChild('Hair'))
   local style=class=='mage'and'MageHair'or class=='elf'and'ShortHair'or'HelmetHair'
   local color=(class=='mage'and V.hair.colors or V.hair.shortColors)[family]
   check(hair.MeshId==f[style].MeshId,'class-specific TD hair '..class..'/'..family)
   check(hair.Color==Color3.fromRGB(color[1],color[2],color[3]),'family hair color')
   check(hair:GetAttribute('HeadgearHair')and hair.ArmorWeld.Part0==c.Head,'hair follows actual head')
   check(model:GetAttribute('ArmorPartCount')==2,'hat or enclosing headwear plus exactly one hair mesh')
   check(not hair.Anchored and hair.Massless and not hair.CanCollide and not hair.CanQuery and not hair.CanTouch,'cosmetic-only physics')
   check(h.Transparency==1,'original avatar hair suppressed while owned hair worn')
   A.sync(c);check(c.TLTArmor_head==model,'idempotent headwear')
   hair:Destroy();A.sync(c);check(c.TLTArmor_head~=model and c.TLTArmor_head.Hair.MeshId==f[style].MeshId,'missing hair repaired atomically')
   report.cases+=1
  end end
  c:SetAttribute('K0ClassId','mage');c:SetAttribute('TLTEquippedHead','mage_sentinel_hat');A.sync(c)
  local previous=c.TLTArmor_head;local template=f.MageHair;template.Parent=nil
  c:SetAttribute('TLTEquippedHead','mage_traveler_hat');A.sync(c)
  check(c.TLTArmor_head==previous and c:GetAttribute('TLTArmorHeadError')=='MissingHeadgearHair','missing hair preserves complete prior headwear')
  template.Parent=f;A.sync(c);check(c.TLTArmor_head~=previous,'complete hairstyle recovered')
  c:SetAttribute('TLTEquippedHead','');A.sync(c)
  check(not c:FindFirstChild('TLTArmor_head')and math.abs(h.Transparency-.3)<.00001,'unequip removes owned hair and restores original')
  check(c.HumanoidRootPart.CFrame==before and c.Humanoid.Health==health,'root and health unchanged')
  c:Destroy()
 end
end,debug.traceback)
report.pass=ok;report.error=err
print('HEADGEAR_HAIR_JSON '..game.HttpService:JSONEncode(report));assert(ok,err)
