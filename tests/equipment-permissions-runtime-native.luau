-- Run as a normal server Script, never accept plugin-level reads as evidence.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated fixture only')
local Run=game:GetService('RunService')
assert(not Run:IsRunning(),'fresh edit session required')
game.ServerScriptService.Server.Disabled=true
local fixture=Instance.new('Script');fixture.Name='EquipmentPermissionsRuntime'
fixture.Source=[[
local report={kind='EQUIPMENT_PERMISSIONS_RUNTIME',checks=0,bows=0,fetches=0,failures={}}
local function check(value,label)report.checks+=1;assert(value,label)end
local ok,err=xpcall(function()
 local Assets=require(game.StarterPlayer.StarterPlayerScripts.Client.EquipmentAssetLoading)
 local A=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
 local Q=require(game.ServerScriptService.Server.Cosmetics.ElfQuiverAppearance)
 local Palette=require(game.ServerScriptService.Server.Cosmetics.ElfQuiverPalette)
 local s=Instance.new('SurfaceAppearance')
 check(not pcall(function()return s.ColorMap end),'legacy ColorMap is denied in real Script')
 check(pcall(function()return s.ColorMapContent.Uri end),'ColorMapContent is readable in real Script');s:Destroy()
 for _,definition in ipairs({'legacy','elf_weapon_traveler','elf_weapon_fine','elf_weapon_veteran','elf_weapon_sentinel'})do
  local result,reason=A.build('elf',definition~='legacy'and definition or nil);check(result~=nil,tostring(reason))
  local model=result.model;local bow=model.Bow;local surface=bow:FindFirstChildOfClass('SurfaceAppearance')
  local uri=surface and surface.ColorMapContent.Uri or bow.TextureID
  check(Palette[uri]~=nil,'reviewed bow texture palette '..definition)
  local character=Instance.new('Model');character.Name='EquipmentPermissionsFixture'
  local torso=Instance.new('Part');torso.Name='UpperTorso';torso.Anchored=true;torso.Parent=character
  model.Parent=character;character.Parent=workspace
  local quiver=Q.ensure(model,character);check(Q.valid(model,character),'quiver builds without privileged property reads '..definition)
  local color=Palette[uri].body
  check(quiver.QuiverFront.Color==Color3.fromRGB(math.round(color.R*bow.Color.R*255),math.round(color.G*bow.Color.G*255),math.round(color.B*bow.Color.B*255)),'authored palette preserved '..definition)
  for _,part in ipairs(model:GetDescendants())do if part:IsA('MeshPart')then
   local count=0
   Assets.preload(part,function(id,status)
    count+=1;report.fetches+=1
    if status~=Enum.AssetFetchStatus.Success then table.insert(report.failures,{id=id,status=tostring(status)})end
   end)
   check(count>0,'actual geometry/texture fetch callbacks '..part.Name)
  end end
  character:Destroy();report.bows+=1
 end
 check(#report.failures==0,'all reviewed bow visual assets downloaded')
end,debug.traceback)
report.pass=ok;report.error=err
local encoded=game.HttpService:JSONEncode(report)
print('EQUIPMENT_PERMISSIONS_RUNTIME '..encoded)
workspace:SetAttribute('TLTEquipmentPermissionsReport',encoded)
]]
fixture.Parent=game.ServerScriptService
Run:Run()
local encoded
for _=1,120 do
 task.wait(.5);encoded=workspace:GetAttribute('TLTEquipmentPermissionsReport');if encoded then break end
end
local report=encoded and game.HttpService:JSONDecode(encoded)
Run:Stop()
assert(report,'normal Script permission fixture timed out')
assert(report.pass,report.error)
return report
