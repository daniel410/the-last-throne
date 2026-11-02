local Visual=require(script.Parent.NPCVisual)
local Catalog=require(game:GetService('ReplicatedStorage').Shared.NPCCatalog)
local R={}
local Facilities=require(game.ReplicatedStorage.Shared.LobbyFacilities)
local Shop=Facilities.itemShop
local positions={mira=Shop.offset+Vector3.new(0,0,5*(Shop.scale or 1)),rowan=Facilities.training.offset+Vector3.new(10,0,11),tessa=Vector3.new(-29,0,-24),oren=Vector3.new(18,0,25),selene=(Facilities.portal.offset+Facilities.defense.offset)/2,nia=Vector3.new(-18,0,25)}
function R.create(lobby,facilities,storagePrompt)
 local old=lobby.folder:FindFirstChild('DawnspireResidents');if old then old:Destroy() end
 local folder=Instance.new('Folder');folder.Name='DawnspireResidents';folder.Parent=lobby.folder
 local result={}
 for id,offset in pairs(positions) do
  local npc=Visual.create(folder,id,lobby.origin+offset,{yaw=math.pi})
  result[id]={model=npc}
  if id=='mira' or id=='selene' or id=='nia' then
   local p=Instance.new('ProximityPrompt');p.Name='NPCInteract';p.Style=Enum.ProximityPromptStyle.Custom
   p.ObjectText=Catalog.byId[id].name..' · '..Catalog.byId[id].role;p.ActionText=id=='mira' and 'Buy or sell supplies' or id=='selene' and require(game.ReplicatedStorage.Shared.SupporterText).view or 'Talk'
   p.KeyboardKeyCode=Enum.KeyCode.F;p.GamepadKeyCode=Enum.KeyCode.ButtonX;p.HoldDuration=0;p.MaxActivationDistance=10;p.RequiresLineOfSight=false;p.Parent=npc.PrimaryPart
   result[id].prompt=p
  end
 end
 -- Existing server-authorized facilities retain their inputs and validation paths.
 facilities.training.prompt.ObjectText='Rowan · Hero Trainer'
 facilities.portal.prompt.ObjectText='Tessa · Expedition Guide'
 if storagePrompt then storagePrompt.ObjectText='Oren · Account Storage' end
 return result
end
return R
