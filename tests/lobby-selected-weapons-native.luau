-- Native held-weapon projection; no real Player or published rendering claims.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Use an isolated local place')
local modules=game.ServerScriptService.Server.Cosmetics
local copy=Instance.new('ModuleScript');copy.Name='QaLobbyAppearance'
copy.Source=modules.KnightAppearance.Source:gsub('\nreturn KnightAppearance%s*$','\nreturn {sync=syncAppearance}')
copy.Parent=modules
local lifecycle=require(copy);local weapons=require(modules.WeaponAppearance)
local character=Instance.new('Model');character.Name='QaLobbyHeldWeapons'
local humanoid=Instance.new('Humanoid');humanoid.Parent=character
for _,name in ipairs({'HumanoidRootPart','Right Arm','Left Arm'}) do
 local part=Instance.new('Part');part.Name=name;part.Size=Vector3.new(1,2,1);part.Anchored=true;part.Parent=character
end
character.Parent=workspace
local checks=0
local function check(value,label) checks+=1;assert(value,label) end
local ok,err=xpcall(function()
 for _,classId in ipairs({'knight','elf','dwarf','mage'}) do
  character:SetAttribute('TLTEquippedWeapon',classId..'_weapon')
  character:SetAttribute('TLTEquippedOffhand',classId=='knight' and 'shield' or '')
  character:SetAttribute('K0ClassId',classId);lifecycle.sync(character)
  local model=assert(character:FindFirstChild('TLT_K0_KnightAppearance'))
  check(weapons.isAttached(model,character,classId),'held weapon matches selected '..classId)
  local visible=0
  for _,part in ipairs(model:GetDescendants()) do if part:IsA('BasePart') and part:GetAttribute('TLTPlayerWeaponPart') and part.Transparency<1 then visible+=1 end end
  check(visible>0,'selected class weapon is visible')
  character:SetAttribute('TLTEquippedWeapon','');lifecycle.sync(character)
  for _,part in ipairs(model:GetDescendants()) do if part:IsA('BasePart') and part:GetAttribute('TLTPlayerWeaponPart') then check(part.Transparency==1,'unequipped weapon remains hidden') end end
 end
end,debug.traceback)
character:Destroy();copy:Destroy();assert(ok,err)
print('LOBBY_SELECTED_WEAPONS_NATIVE '..game.HttpService:JSONEncode({status='passed',checks=checks}))
