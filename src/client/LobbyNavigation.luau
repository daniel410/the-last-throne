-- Illustrated navigation tiles; Diamond Shop uses the original TD lobby artwork.
local RS=game:GetService('ReplicatedStorage')
local T=require(script.Parent.TDInventoryTheme)
local Progress=require(RS.Shared.DeepwoodProgress)
local Log=require(RS.Shared.DeepwoodQuestLog)
local Bridge=require(script.Parent.LobbyMenuBridge)
local LobbyArt=require(RS.Shared.TDUI.LobbyHomeArtAssets)
local M={}
function M.create(parent,actions)
 local rail=Instance.new('Frame');rail.Name='LobbyNavigation';rail.BackgroundTransparency=1;rail.Position=UDim2.new(0,10,.5,-204);rail.Size=UDim2.fromOffset(88,408);rail.Parent=parent
 local list=Instance.new('UIListLayout');list.Padding=UDim.new(0,4);list.Parent=rail
 local scale=Instance.new('UIScale');scale.Parent=rail
 local function resize() local camera=workspace.CurrentCamera;if camera then scale.Scale=math.min(1,math.max(.65,(camera.ViewportSize.Y-92)/408)) end end
 local camera=workspace.CurrentCamera;if camera then camera:GetPropertyChangedSignal('ViewportSize'):Connect(resize) end;resize()
 local panel=T.frame(parent,'LobbyGuide',UDim2.fromScale(.5,.5),UDim2.new(1,-32,1,-100));panel.AnchorPoint=Vector2.new(.5,.5);panel.Visible=false
 local cap=Instance.new('UISizeConstraint');cap.MaxSize=Vector2.new(1100,850);cap.Parent=panel
 require(script.Parent.LobbyPanelLayout).bind(panel)
 local title=T.label(panel,'Title','',UDim2.fromOffset(20,12),UDim2.new(1,-85,0,34),20,T.color.gold)
 local close=T.button(panel,'Close','X',UDim2.new(1,-60,0,10),UDim2.fromOffset(44,44));close.Activated:Connect(function() panel.Visible=false end)
 local body=T.label(panel,'Contents','',UDim2.fromOffset(24,60),UDim2.new(1,-48,1,-80),15,T.color.text);body.TextYAlignment=Enum.TextYAlignment.Top
 local atlas=require(script.Parent.LobbyAtlas).create(panel)
 local snapshot
 local function guide(kind)
  body.Visible=kind~='Maps';atlas.root.Visible=kind=='Maps'
  if kind=='Maps'then title.Text='ADVENTURE MAPS';atlas.show(snapshot);panel.Visible=true;return end
  title.Text=kind=='Quest' and 'QUEST JOURNAL' or 'ADVENTURE MAPS'
  local hero=snapshot and snapshot.heroId and snapshot.heroes and snapshot.heroes[snapshot.heroId]
  if not hero then body.Text='Select a hero to view their adventure progress.'
  else
   local journal=hero.deepwood or Progress.new()
   if kind=='Quest' then
    local chapter=Log.main(journal)
    body.Text=chapter and string.format('MAIN STORY · %s\n\n%s\n\nStories completed: %d / 21\n\nEnter an adventure to track objectives and view the full journal.',chapter.quest.title,chapter.quest.brief,journal.main) or 'The first three expeditions are complete.\n\nEnter an adventure to view your full journal.'

   end
  end
  panel.Visible=true
 end
 local function icon(button,id,index)
  local art
  if id=='DiamondShop' then
   art=T.sprite(button,'NavigationIcon','shop',UDim2.fromOffset(12,0),UDim2.fromOffset(64,48),LobbyArt)
  else
   art=Instance.new('ImageLabel');art.Name='NavigationIcon';art.BackgroundTransparency=1
   art.Image=id=='Blacksmith' and 'rbxassetid://97662984602605' or 'rbxassetid://137280207574223'
   -- Roblox renders the 2172x724 upload at 1024x341.
   art.ImageRectOffset=Vector2.new(math.round((index-1)*204.8),70)
   art.ImageRectSize=Vector2.new(math.round(index*204.8)-art.ImageRectOffset.X,190)
   art.Position=UDim2.fromOffset(12,0);art.Size=UDim2.fromOffset(64,48)
   art.ScaleType=Enum.ScaleType.Fit;art.Parent=button
  end
  art.ZIndex=3
 end
 for index,entry in ipairs({{'Heroes','HEROES'},{'ItemShop','ITEM SHOP'},{'Blacksmith','BLACKSMITH'},{'Quest','QUEST'},{'Maps','MAPS'},{'DiamondShop','DIAMOND SHOP'}}) do
  local b=T.button(rail,entry[1],entry[2],UDim2.new(),UDim2.fromOffset(88,64))
  -- Navigation artwork already includes its own frame. Keep the hit target, not a second shell.
  b.BackgroundTransparency=1;b.TDButtonArt.Visible=false
  b.Caption.Position=UDim2.new(0,2,.65,0);b.Caption.Size=UDim2.new(1,-4,.32,0);b.Caption.TextSize=10;b.Caption.TextScaled=entry[1]=='DiamondShop';b.Caption.ZIndex=4
  icon(b,entry[1],index);b.Activated:Connect(function()
   panel.Visible=false
   if entry[1]=='Heroes' then actions.close();Bridge:Fire('Heroes')
   elseif entry[1]=='Quest' or entry[1]=='Maps' then actions.close();guide(entry[1])
   else actions.open(entry[1]) end
  end)
 end
 return {rail=rail,panel=panel,update=function(s) snapshot=s;atlas.update(s) end}
end
return M
