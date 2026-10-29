local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local UIS=game:GetService('UserInputService')
local RunService=game:GetService('RunService')
local Content=require(RS.Shared.DeepwoodContent)
local Progress=require(RS.Shared.DeepwoodProgress)
local Theme=require(script.Parent.TDInventoryTheme)
local Journal={}
function Journal.start(hud)
 local player=Players.LocalPlayer
 local remotes=RS:WaitForChild('Remotes');local request=remotes:WaitForChild('DeepwoodRequest');local response=remotes:WaitForChild('DeepwoodState')
 local gui=Instance.new('ScreenGui');gui.Name='DeepwoodJournal';gui.ResetOnSpawn=false;gui.DisplayOrder=42;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=player:WaitForChild('PlayerGui')
 local panel=Theme.frame(gui,'Journal',UDim2.fromScale(.5,.5),UDim2.fromOffset(620,480));panel.AnchorPoint=Vector2.new(.5,.5);panel.Visible=false
 Theme.label(panel,'Title','DEEPWOOD · THE BLACK ROOTS',UDim2.fromOffset(18,12),UDim2.new(1,-80,0,30),18,Theme.color.gold)
 local close=Theme.button(panel,'Close','X',UDim2.new(1,-52,0,12),UDim2.fromOffset(40,40))
 local list=Instance.new('ScrollingFrame');list.Name='Chapters';list.Position=UDim2.fromOffset(14,64);list.Size=UDim2.new(1,-28,1,-124);list.BackgroundTransparency=1;list.BorderSizePixel=0;list.ScrollBarThickness=6;list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.CanvasSize=UDim2.new();list.Parent=panel
 local layout=Instance.new('UIListLayout');layout.Padding=UDim.new(0,8);layout.Parent=list
 local retry=Theme.button(panel,'Retry','RETRY CHECKPOINT',UDim2.new(0,14,1,-52),UDim2.fromOffset(200,40))
 local coins=Theme.label(panel,'Coins','',UDim2.new(0,225,1,-52),UDim2.new(1,-240,0,40),12)
 local dialog=Theme.frame(gui,'StoryMessage',UDim2.new(.5,0,1,-195),UDim2.fromOffset(620,128));dialog.AnchorPoint=Vector2.new(.5,1);dialog.Visible=false
 local prose=Theme.label(dialog,'Dialogue','',UDim2.fromOffset(16,8),UDim2.new(1,-32,0,65),13)
 local dismiss=Theme.button(dialog,'Continue','CONTINUE',UDim2.new(1,-150,1,-46),UDim2.fromOffset(136,36))
 local sanctuary=Theme.button(dialog,'Sanctuary','ELVEN SANCTUARY',UDim2.new(0,12,1,-46),UDim2.fromOffset(260,36));sanctuary.Visible=false
 local shared=Theme.button(dialog,'Share','SHARE WITH REFUGEES',UDim2.new(1,-282,1,-46),UDim2.fromOffset(270,36));shared.Visible=false
 local current,target,lastMessage,selectedChapter
 local marker=Instance.new('BillboardGui');marker.Name='DeepwoodWaypoint';marker.Size=UDim2.fromOffset(190,55);marker.AlwaysOnTop=true;marker.StudsOffset=Vector3.new(0,6,0);marker.MaxDistance=2400;marker.Parent=gui
 local waypoint=Theme.label(marker,'Waypoint','',UDim2.new(),UDim2.fromScale(1,1),12,Theme.color.gold);waypoint.TextXAlignment=Enum.TextXAlignment.Center;waypoint.TextStrokeTransparency=.15
 local function setOpen(open)
  panel.Visible=open;player:SetAttribute('TLTStoryOpen',open or dialog.Visible)
 end
 local function choose(v) request:FireServer('Choose',v);dialog.Visible=false;setOpen(false) end
 sanctuary.Activated:Connect(function() choose('sanctuary') end);shared.Activated:Connect(function() choose('shared') end)
 if hud.journalMenu then hud.journalMenu.Activated:Connect(function() setOpen(true) end) end
 close.Activated:Connect(function() setOpen(false) end)
 dismiss.Activated:Connect(function() dialog.Visible=false;setOpen(panel.Visible) end)
 retry.Activated:Connect(function() request:FireServer('Retry');setOpen(false) end)
 UIS.InputBegan:Connect(function(input,processed)
  if not processed and input.KeyCode==Enum.KeyCode.J and current and player:GetAttribute('K0SessionPhase')=='Tutorial' then setOpen(not panel.Visible) end
 end)
 local function ready(c,g) return current and Progress.available(current.journal,c,g) end
 local function point(c,g)
  target={chapter=c,goal=g};local field=workspace:FindFirstChild('DeepwoodCampaign');local nodes=field and field:FindFirstChild('Objectives')
  marker.Adornee=nodes and nodes:FindFirstChild(c.id..'_'..g.id)
 end
 local function render()
  if not current then return end
  local s=current.journal;coins.Text=string.format('RPG Coins: %d  ·  Story + combat',s.coins+(s.killCoins or 0))
  for _,child in ipairs(list:GetChildren()) do if child:IsA('GuiObject') then child:Destroy() end end
  local first
  for _,c in ipairs(Content.chapters) do
   local discovered=not c.side
   for _,g in ipairs(c.goals) do if s.flags[c.id..':'..g.id] then discovered=true end end
   if discovered then
    local completed=s.clears[c.id];local active=Progress.eligible(s,c)
    local row=Theme.frame(list,c.id,UDim2.new(),UDim2.new(1,-10,0,completed and 54 or active and 136 or 54))
    Theme.label(row,'Chapter',c.id..'  '..c.title..(completed and '  ✓' or not active and '  ·  LOCKED' or ''),UDim2.fromOffset(12,5),UDim2.new(1,-24,0,30),14,completed and Theme.color.green or Theme.color.gold)
    if active then
     local nextGoal
     local done=0;for _,g in ipairs(c.goals) do if s.flags[c.id..':'..g.id] then done=done+1 end;if ready(c,g) and not nextGoal then nextGoal=g end end
     if nextGoal then
      first=first or {chapter=c,goal=nextGoal}
      local action=Theme.button(row,'Track',nextGoal.title,UDim2.fromOffset(12,40),UDim2.new(1,-24,0,44))
      action.Activated:Connect(function() selectedChapter=c.id;point(c,nextGoal);setOpen(false) end)
      Theme.label(row,'Progress',string.format('%d / %d objectives  ·  %d XP / %d Coins',done,#c.goals,c.reward.xp,c.reward.coins),UDim2.fromOffset(12,90),UDim2.new(1,-24,0,30),11)
     end
    end
   end
  end
  if target and not ready(target.chapter,target.goal) then target=nil end
  if not target and first then point(first.chapter,first.goal) end
  if not first then marker.Adornee=nil;target=nil end
  if hud.setStory then
   hud.setStory({title='DEEPWOOD · '..(s.main==7 and 'EPIC COMPLETE' or tostring(s.main+1)..' / 7'),objective=target and target.goal.title or 'The forest is safe. Discover hidden quests or return to Hub.',note='[J] Journal · [F / X / Tap] Interact'})
  end
  local field=workspace:FindFirstChild('DeepwoodCampaign');local nodes=field and field:FindFirstChild('Objectives')
  if nodes then for _,p in ipairs(nodes:GetChildren()) do
   local c=Content.byId[p:GetAttribute('ChapterId')];local g=c and Progress.goal(c,p:GetAttribute('GoalId'));local prompt=p:FindFirstChildOfClass('ProximityPrompt')
   if prompt and g then prompt.Enabled=ready(c,g) end
  end end
 end
 response.OnClientEvent:Connect(function(value)
  current=value;render()
  if value.message and value.message~=lastMessage then
   lastMessage=value.message;prose.Text=value.message;dialog.Visible=true;dismiss.Visible=true;sanctuary.Visible=false;shared.Visible=false;setOpen(panel.Visible)
  end
 end)
 local elapsed=0
 RunService.Heartbeat:Connect(function(dt)
  elapsed=elapsed+dt;if elapsed<.2 then return end;elapsed=0
  local phase=player:GetAttribute('K0SessionPhase');local alive=phase=='Tutorial'
  gui.Enabled=alive
  if not alive then panel.Visible=false;dialog.Visible=false;player:SetAttribute('TLTStoryOpen',false);return end
  local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
  if target and root then waypoint.Text='◆ '..target.goal.title..'\n'..math.floor((root.Position-Vector3.new(table.unpack(target.goal.position))).Magnitude)..' studs' end
  if current and root then
   local c=Content.byId['DW-07'];local g=Progress.goal(c,'restoration')
   local near=ready(c,g) and (root.Position-Vector3.new(table.unpack(g.position))).Magnitude<14
   if near then prose.Text=g.text;dialog.Visible=true;dismiss.Visible=false;sanctuary.Visible=true;shared.Visible=true;setOpen(panel.Visible) end
  end
 end)
 local function resize()
  local camera=workspace.CurrentCamera;if not camera then return end
  panel.Size=UDim2.fromOffset(math.min(620,camera.ViewportSize.X-20),math.min(480,camera.ViewportSize.Y-40))
  dialog.Size=UDim2.fromOffset(math.min(620,camera.ViewportSize.X-20),160)
  sanctuary.Size=UDim2.new(.5,-18,0,44);shared.Size=UDim2.new(.5,-18,0,44);shared.Position=UDim2.new(.5,6,1,-52);sanctuary.Position=UDim2.new(0,12,1,-52)
 end
 if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(resize) end;resize()
 task.spawn(function() for _=1,3 do request:FireServer('GetState');task.wait(2) end end)
 return {open=function() setOpen(true) end}
end
return Journal
