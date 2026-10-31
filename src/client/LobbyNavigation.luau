-- Compact, TD-inspired navigation tiles with original Roblox GUI icon shapes.
local RS=game:GetService('ReplicatedStorage')
local T=require(script.Parent.TDInventoryTheme)
local Content=require(RS.Shared.DeepwoodContent)
local Progress=require(RS.Shared.DeepwoodProgress)
local Log=require(RS.Shared.DeepwoodQuestLog)
local Access=require(RS.Shared.DeepwoodAccess)
local Bridge=require(script.Parent.LobbyMenuBridge)
local M={}
function M.create(parent,actions)
 local rail=Instance.new('Frame');rail.Name='LobbyNavigation';rail.BackgroundTransparency=1;rail.Position=UDim2.new(0,10,.5,-170);rail.Size=UDim2.fromOffset(88,340);rail.Parent=parent
 local list=Instance.new('UIListLayout');list.Padding=UDim.new(0,4);list.Parent=rail
 local scale=Instance.new('UIScale');scale.Parent=rail
 local function resize() local camera=workspace.CurrentCamera;if camera then scale.Scale=math.min(1,math.max(.65,(camera.ViewportSize.Y-92)/340)) end end
 local camera=workspace.CurrentCamera;if camera then camera:GetPropertyChangedSignal('ViewportSize'):Connect(resize) end;resize()
 local panel=T.frame(parent,'LobbyGuide',UDim2.fromScale(.5,.5),UDim2.new(1,-32,1,-100));panel.AnchorPoint=Vector2.new(.5,.5);panel.Visible=false
 local cap=Instance.new('UISizeConstraint');cap.MaxSize=Vector2.new(720,620);cap.Parent=panel
 local title=T.label(panel,'Title','',UDim2.fromOffset(20,12),UDim2.new(1,-85,0,34),20,T.color.gold)
 local close=T.button(panel,'Close','X',UDim2.new(1,-60,0,10),UDim2.fromOffset(44,44));close.Activated:Connect(function() panel.Visible=false end)
 local body=T.label(panel,'Contents','',UDim2.fromOffset(24,60),UDim2.new(1,-48,1,-80),15,T.color.text);body.TextYAlignment=Enum.TextYAlignment.Top
 local snapshot
 local function guide(kind)
  title.Text=kind=='Quest' and 'QUEST JOURNAL' or 'DEEPWOOD MAPS'
  local hero=snapshot and snapshot.heroId and snapshot.heroes and snapshot.heroes[snapshot.heroId]
  if not hero then body.Text='Select a hero to view their adventure progress.'
  else
   local journal=hero.deepwood or Progress.new()
   if kind=='Quest' then
    local chapter=Log.main(journal)
    body.Text=chapter and string.format('MAIN STORY · %s\n\n%s\n\nStories completed: %d / 7\n\nEnter an adventure to track objectives and view the full journal.',chapter.quest.title,chapter.quest.brief,journal.main) or 'Deepwood main stories complete.\n\nEnter an adventure to view your full journal.'
   else
    local lines={'DAWNSPIRE → DEEPWOOD','', 'Your progress opens new regions:', ''}
    for i=1,7 do local id=string.format('DW-%02d',i);local z=Content.zones[id];table.insert(lines,string.format('%s  %s',Access.allowed(journal,id) and 'OPEN' or 'LOCKED',z.name)) end
    table.insert(lines,'\nEnter an adventure to explore the full map.');body.Text=table.concat(lines,'\n')
   end
  end
  panel.Visible=true
 end
 local function shape(parent,name,x,y,w,h,color,rotation,round)
  local part=Instance.new('Frame');part.Name=name;part.Position=UDim2.fromScale(x,y);part.Size=UDim2.fromScale(w,h);part.BorderSizePixel=0;part.BackgroundColor3=color;part.Rotation=rotation or 0;part.ZIndex=3;part.Parent=parent
  if round then local c=Instance.new('UICorner');c.CornerRadius=UDim.new(1,0);c.Parent=part end
 end
 local gold=Color3.fromRGB(241,201,119);local pale=Color3.fromRGB(199,223,237);local red=Color3.fromRGB(230,106,93)
 local function icon(b,id)
  if id=='Heroes' then shape(b,'Head',.39,.08,.22,.24,pale,0,true);shape(b,'Armor',.31,.30,.38,.28,gold,0,true)
  elseif id=='ItemShop' then shape(b,'Bottle',.38,.22,.24,.33,red,0,true);shape(b,'Neck',.44,.12,.12,.14,pale);shape(b,'Cork',.43,.08,.14,.06,gold)
  elseif id=='Blacksmith' then shape(b,'Blade',.47,.06,.08,.40,pale,40);shape(b,'Guard',.34,.35,.31,.07,gold,40);shape(b,'Grip',.32,.43,.07,.18,gold,40)
  elseif id=='Quest' then shape(b,'Book',.31,.10,.38,.43,pale);shape(b,'Spine',.48,.10,.035,.43,gold);shape(b,'Line1',.34,.21,.11,.025,gold);shape(b,'Line2',.53,.28,.11,.025,gold)
  else shape(b,'Map',.29,.12,.42,.38,pale,-8);shape(b,'Route',.35,.29,.29,.025,gold,-25);shape(b,'Pin',.56,.16,.08,.10,red,0,true) end
 end
 for _,entry in ipairs({{'Heroes','HEROES'},{'ItemShop','ITEM SHOP'},{'Blacksmith','BLACKSMITH'},{'Quest','QUEST'},{'Maps','MAPS'}}) do
  local b=T.button(rail,entry[1],entry[2],UDim2.new(),UDim2.fromOffset(88,64));b.Caption.Position=UDim2.new(0,2,.65,0);b.Caption.Size=UDim2.new(1,-4,.32,0);b.Caption.TextSize=10;b.Caption.ZIndex=4
  icon(b,entry[1]);b.Activated:Connect(function()
   panel.Visible=false
   if entry[1]=='Heroes' then actions.close();Bridge:Fire('Heroes')
   elseif entry[1]=='Quest' or entry[1]=='Maps' then actions.close();guide(entry[1])
   else actions.open(entry[1]) end
  end)
 end
 return {rail=rail,panel=panel,update=function(s) snapshot=s end}
end
return M
