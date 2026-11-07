-- Native geometry/state fixture; use a local Edit document without players.
assert(game.PlaceId==0 and #game:GetService('Players'):GetPlayers()==0,'Use an isolated local build')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local folder=Instance.new('Folder');folder.Parent=workspace
local player=Instance.new('Folder');player.Parent=folder
local world=Instance.new('Folder');world.Parent=folder
local gui=Instance.new('ScreenGui');gui.Parent=folder
local report={kind='LOBBY_HERO_DOCK_NATIVE',checks=0}
local function check(value,message) report.checks+=1;assert(value,message) end
local ok,err=xpcall(function()
 local view=require(client.LobbyHeroDock).create(gui,player,function() error('Unexpected hero intention') end,function() error('Unexpected play intention') end,world)
 local state={phase='Lobby',canManage=true,canStart=true,selectedHeroId='h1',heroes={{heroId='h1',classId='knight',level=1},{heroId='h2',classId='mage',level=5}}}
 view.update(state,false)
 view.layout(Vector2.new(1920,1080))
 check(view.root.Visible and view.play.Active,'lobby dock is interactive')
 local count=0;for _ in pairs(view.cards) do count+=1 end
 check(count==4 and view.cards.priestess==nil,'four player classes, no priestess')
 check(view.cards.knight.HeroSelectedMarker.Visible and not view.cards.mage.HeroSelectedMarker.Visible,'selected hero only marked')
 check(view.cards.knight.HeroSelectionBorder.Thickness==5,'strong selected gold border')
 check(view.cards.knight.HeroSelectedTag.Visible and not view.cards.mage.HeroSelectedTag.Visible,'selection has explicit text beyond color/check')
 local mage=view.cards.mage.HeroPortrait
 check(mage.Image=='rbxassetid://115948760578578' and mage.ImageRectOffset==Vector2.new(341,341) and mage.ImageRectSize==Vector2.new(341,341),'original TD Arcanist atlas crop')
 check(view.play.CitadelButtonArt:GetAttribute('CitadelAtlasKey')=='play','original TD PLAY atlas')
 view.inventory({revision=2,ready=true,heroId='h1',heroes={h1={progression={level=1,xp=25}}}})
 local dock=view.root.HomeDock
 -- Saving/loading snapshots use ready=false even when the selected ID is known.
 view.inventory({revision=3,ready=false,heroId='h1',heroes={}})
 check(not dock.HomeXPTrack.Visible and dock.HomeHeroProgress.Text=='Loading Hero Progress...','unready inventory waits without boolean growth error')
 view.update(state,false);view.suppress(true);view.suppress(false)
 view.inventory({revision=4,ready=true,heroId='h1',heroes={h1={progression={level=1,xp=25}}}})
 check(dock.HomeHeroProgress.Text=='Knight Hero Lv.1' and dock.HomeXPAmount.Text=='25 / 100 XP','actual RPG growth labels')
 check(dock.HomeXPTrack.HomeXPFill.Size==UDim2.fromScale(.25,1),'actual RPG XP fraction')
 view.inventory({revision=1,ready=true,heroId='h1',heroes={h1={progression={level=1,xp=0}}}})
 check(dock.HomeXPAmount.Text=='25 / 100 XP','stale inventory snapshot ignored')
 for _,size in ipairs({Vector2.new(1920,1080),Vector2.new(1280,720),Vector2.new(844,390),Vector2.new(390,844)}) do
  view.layout(size)
  local p,s=dock.Position,dock.Size
  check(p.X.Offset>=0 and p.Y.Offset>=0 and p.X.Offset+s.X.Offset<=size.X and p.Y.Offset+s.Y.Offset==size.Y-12,'dock fits viewport '..tostring(size))
  check(dock.Hero_knight.Position.X.Offset==0 and dock.Hero_knight.Position.Y.Offset>view.play.Size.Y.Offset,'cards below PLAY')
  check(dock.Hero_mage.Position.X.Offset+dock.Hero_mage.Size.X.Offset==s.X.Offset,'four cards fill TD row')
  local compact=size.Y<500 or size.X<600;local selected=view.cards.knight
  check(selected.HeroSelectedTag.Visible==not compact,'selection label adapts without covering mobile portrait')
  check(selected.HeroSelectionBorder.Thickness==(compact and 2 or 5),'mobile selection uses a thin border; desktop unchanged')
  check(selected.HeroSelectedMarker.Size==UDim2.fromOffset(compact and 12 or 20,compact and 12 or 20),'selection check stays in a small corner')
  check(selected.HeroName.BackgroundColor3==(compact and Color3.fromRGB(12,27,54) or Color3.fromRGB(255,215,90)),'mobile nameplate does not fill with Gold')
 end
 view.layout(Vector2.new(1920,1080))
 check(view.cards.knight.HeroSelectedTag.Visible and view.cards.knight.HeroSelectionBorder.Thickness==5,'resizing back restores desktop selection')
 for _,key in ipairs({'TLTHeroSelectionOpen','TLTInventoryOpen','TLTProgressionOpen','TLTSettingsOpen','TLTLobbyPanelOpen','TLTLobbyTopMenuOpen','TLTTravelLock'}) do
  player:SetAttribute(key,true);task.wait();check(not view.root.Visible and not view.play.Active,key..' blocks dock')
  player:SetAttribute(key,false);task.wait();check(view.root.Visible,key..' restores dock')
 end
 view.update(state,true);check(not view.cards.knight.Active and not view.play.Active,'pending selection prevents duplicate inputs')
 state.selectedHeroId='h2';view.update(state,false)
 check(view.cards.mage.HeroSelectedMarker.Visible and not view.cards.knight.HeroSelectedMarker.Visible,'server-selected Mage marked')
 check(not dock.HomeXPTrack.Visible,'previous hero XP never shown for new selection')
 view.error('Try again.');check(dock.HomeHeroProgress.Text=='Try again.','errors remain visible without modal')
 view.suppress(true);check(not view.root.Visible,'modal suppression')
 view.suppress(false);world:SetAttribute('TLTServerRole','Battle');task.wait();check(not view.root.Visible,'Battle role hides dock')
 world:SetAttribute('TLTServerRole','Lobby');task.wait()
 for _,phase in ipairs({'LoadingLobby','LoadingTutorial','Tutorial','Respawning','ReturningLobby','SpawnFailed'}) do
  state.phase=phase;view.update(state,false);check(not view.root.Visible and not view.play.Active,'no dock interaction in '..phase)
 end
 report.status='passed'
end,debug.traceback)
folder:Destroy()
assert(ok,err)
return game:GetService('HttpService'):JSONEncode(report)
