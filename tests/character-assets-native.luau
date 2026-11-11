assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Isolated local engine fixture only')
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local W=require(Client.EquipmentWarmup)
local C=require(Client.CharacterAssetLoading)
assert(type(require(Client.InventoryGui).create)=='function','inventory UI compiles with warmup')
local manifest=require(game.ReplicatedStorage.Shared.EquipmentPreloadManifest)
local A=require(game.ServerScriptService.Server.Cosmetics.ArmorAppearance)
local report={kind='CHARACTER_ASSET_LOADING_NATIVE',keys=0,cases={},pass=false}
local ok,err=xpcall(function()
 for key in pairs(manifest) do assert(W.prepare(key,'elf'),'native download '..key);report.keys+=1;task.wait() end
 for _,class in ipairs({'elf','mage','knight','dwarf'}) do
  local d=Instance.new('HumanoidDescription');local c=game.Players:CreateHumanoidModelFromDescriptionAsync(d,Enum.HumanoidRigType.R15);d:Destroy();c.Parent=workspace;c:PivotTo(CFrame.new(0,800,0));c.HumanoidRootPart.Anchored=true
  c:SetAttribute('K0ClassId',class);c:SetAttribute('TLTEquippedWeapon','');c:SetAttribute('TLTEquippedOffhand','')
  local _,empty=C.snapshot(c);assert(empty,'empty weapon slots must not lock arrival')
  c:SetAttribute('TLTEquippedBody',class=='mage'and'mage_traveler_coat'or'traveler_coat')
  local _,missing=C.snapshot(c);assert(not missing,'equipment intent without replicated body must wait')
  A.sync(c);local key,complete=C.snapshot(c);assert(complete,'fully replicated body detected')
  local shell=c.TLTArmor_body;shell:GetChildren()[1]:Destroy()
  local changed,broken=C.snapshot(c);assert(not broken and changed~=key,'partial body must keep loading cover')
  table.insert(report.cases,{class=class,empty=empty,missingWait=not missing,complete=complete,brokenWait=not broken});c:Destroy();task.wait()
 end
 report.pass=true
end,debug.traceback)
report.error=err;print('CHARACTER_ASSETS_JSON '..game.HttpService:JSONEncode(report));assert(ok,err)
