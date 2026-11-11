local Visual=require(script.Parent.NPCVisual)
local Catalog=require(game:GetService('ReplicatedStorage').Shared.NPCCatalog)
local R={}
local Facilities=require(game.ReplicatedStorage.Shared.LobbyFacilities)
local Shop=Facilities.itemShop
local positions={mira=Shop.offset+Vector3.new(0,0,5*(Shop.scale or 1)),rowan=Facilities.training.offset+Vector3.new(10,0,11),tessa=require(game.ReplicatedStorage.Shared.DawnspireDesign).tessaOffset,oren=Vector3.new(18,0,25),selene=(Facilities.portal.offset+Facilities.defense.offset)/2,nia=Vector3.new(-18,0,25)}
function R.create(lobby,facilities,storagePrompt)
 local old=lobby.folder:FindFirstChild('DawnspireResidents');if old then old:Destroy() end
 local folder=Instance.new('Folder');folder.Name='DawnspireResidents';folder.Parent=lobby.folder
 local result={}
 for id,offset in pairs(positions) do
  local npc=Visual.create(folder,id,lobby.origin+offset,{yaw=math.pi})
  result[id]={model=npc}
  if id=='mira' or id=='selene' or id=='nia' or id=='tessa' then
   local p=Instance.new('ProximityPrompt');p.Name='NPCInteract';p.Style=Enum.ProximityPromptStyle.Custom
   p.ObjectText=Catalog.byId[id].name..' · '..Catalog.byId[id].role;p.ActionText=id=='mira' and 'Buy or sell supplies' or id=='selene' and require(game.ReplicatedStorage.Shared.SupporterText).view or id=='tessa' and 'View side quests' or 'Talk'
   p.KeyboardKeyCode=Enum.KeyCode.F;p.GamepadKeyCode=Enum.KeyCode.ButtonX;p.HoldDuration=0;p.MaxActivationDistance=10;p.RequiresLineOfSight=false;p.Parent=npc.PrimaryPart
   result[id].prompt=p
  end
 end
 -- Reunion scenes are personal cosmetics, unlocked by the existing final clear.
 local reunion=Instance.new('Model');reunion.Name='HomecomingReunion';reunion.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 reunion:SetAttribute('ExpansionEvent','HG-07:portal');reunion:SetAttribute('ExpansionChapter','HG-07');reunion:SetAttribute('ExpansionAfter',true)
 local greetings={
  {'Eryn',-20,38,'The convoy and the forest camp are safe. You brought our friends home, and now the Crownheart is home too!'},
  {'Tali',-10,42,'Every scout made it back. Finn is showing everyone the safe lantern trail. Thank you for finding us!'},
  {'Freya',10,42,'Our village roads are open again. The travelers asked me to bring you their thanks.'},
  {'Brann',20,38,'The workshops are running again. We kept your way home open, just as you kept our city safe.'},
  {'Lumi',0,34,'You found a friend even in the old crypt. I will keep a little light here for the next traveler.'},
 }
 for index,row in ipairs(greetings)do
  local npc=Visual.actor(reunion,row[1],lobby.origin+Vector3.new(row[2],0,row[3]),row[1]=='Lumi')
  local prompt=Instance.new('ProximityPrompt');prompt.Name='ReunionTalk';prompt.Style=Enum.ProximityPromptStyle.Custom;prompt.ObjectText=row[1]..' · Welcome Home';prompt.ActionText='Celebrate';prompt.KeyboardKeyCode=Enum.KeyCode.F;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX;prompt.RequiresLineOfSight=false;prompt.MaxActivationDistance=10;prompt.HoldDuration=0;prompt.Enabled=true;prompt.Parent=npc.PrimaryPart
  result['homecoming'..index]={model=npc,prompt=prompt,homecoming=true,name=row[1],text=row[4]}
 end
 for _,part in ipairs(reunion:GetDescendants())do if part:IsA('BasePart')then part:SetAttribute('ExpansionTransparency',part.Transparency);part.Transparency=1;part.CanCollide=false elseif part:IsA('Decal')or part:IsA('Texture')then part:SetAttribute('ExpansionTransparency',part.Transparency);part.Transparency=1 elseif part:IsA('BillboardGui')then part.Enabled=false end end
 reunion.Parent=lobby.folder
 require(script.Parent.CampaignReturnScenes).lobby(lobby)
 -- Existing server-authorized facilities retain their inputs and validation paths.
 facilities.training.prompt.ObjectText='Rowan · Hero Trainer'
 facilities.portal.prompt.ObjectText='Tessa · Expedition Guide'
 if storagePrompt then storagePrompt.ObjectText='Oren · Account Storage' end
 return result
end
return R
