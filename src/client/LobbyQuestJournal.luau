-- Read-only account snapshot view. Accepting quests remains an adventure interaction.
local RS=game:GetService('ReplicatedStorage')
local Content=require(RS.Shared.CampaignContent)
local Progress=require(RS.Shared.DeepwoodProgress)
local Log=require(RS.Shared.DeepwoodQuestLog)
local Text=require(RS.Shared.LobbyQuestText)
local T=require(script.Parent.TDInventoryTheme)
local Journal={}
local epics={{'Deepwood','DW-'},{'Frozen Vale','FV-'},{'Ember Caldera','EC-'},{'Gloamwood',false},{'Haunted Graveyard',false}}
function Journal.create(panel)
 local root=Instance.new('Frame');root.Name='LobbyQuestJournal';root.Position=UDim2.fromOffset(16,60);root.Size=UDim2.new(1,-32,1,-72);root.BackgroundTransparency=1;root.Visible=false;root.Parent=panel
 local tabs=Instance.new('ScrollingFrame');tabs.Name='EpicCategories';tabs.Size=UDim2.new(1,0,0,48);tabs.BackgroundTransparency=1;tabs.BorderSizePixel=0;tabs.ScrollBarThickness=0;tabs.ScrollingDirection=Enum.ScrollingDirection.X;tabs.CanvasSize=UDim2.new();tabs.Parent=root
 local summary=T.label(root,'Summary','',UDim2.fromOffset(4,50),UDim2.new(1,-8,0,24),12,T.color.gold)
 local list=Instance.new('ScrollingFrame');list.Name='Quests';list.Position=UDim2.fromOffset(0,78);list.Size=UDim2.new(1,0,1,-78);list.BackgroundTransparency=1;list.BorderSizePixel=0;list.ScrollBarThickness=5;list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.CanvasSize=UDim2.new();list.Parent=root
 local layout=Instance.new('UIListLayout');layout.Padding=UDim.new(0,8);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=list
 local snapshot,epic=nil,1;local buttons={}
 local function hero()return snapshot and snapshot.heroId and snapshot.heroes and snapshot.heroes[snapshot.heroId]end
 local function status(s,c)
  if not s then return Text.Locked,Text.SelectHero end
  if s.clears[c.id]then return Text.Completed,c.quest.outcome or Text.Enter end
  if c.side and not Progress.accepted(s,c)then
   if s.main<c.minMain then
    local prior=Content.mainChapters[c.minMain];return Text.Locked,prior and string.format(Text.Prerequisite,prior.quest and prior.quest.title or prior.title)or Text.Discover
   end
   if c.quest.discoveryOnly then return Text.Locked,Text.Discover end
   return Text.Locked,c.quest.giver and string.format(Text.AcceptFrom,c.quest.giver)or Text.Discover
  end
  if not c.side and c.number~=s.main+1 then
   local prior=Content.mainChapters[c.number-1];return Text.Locked,prior and string.format(Text.Prerequisite,prior.quest and prior.quest.title or prior.title)or Text.Enter
  end
  local current=Log.status(s,c)
  if current=='Ready to report'then return Text.Ready,c.quest.brief or Text.Enter end
  local waiting=current:match('^Waiting for story (%d+)$')
  if waiting then local prior=Content.mainChapters[tonumber(waiting)];return Text.Active,prior and string.format(Text.ReportAfter,prior.quest and prior.quest.title or prior.title)or Text.Enter end
  return Text.Active,c.quest.brief or Text.Enter
 end
 local function render(reset)
  local previous=list.CanvasPosition
  for _,child in ipairs(list:GetChildren())do if child:IsA('GuiObject')then child:Destroy()end end
  for i,b in ipairs(buttons)do b.Caption.Text=(i==epic and '> 'or '')..epics[i][1]:upper()..(epics[i][2]and ''or '\n'..Text.Future)end
  local spec=epics[epic];if not spec[2]then summary.Text=Text.Future;list.CanvasPosition=Vector2.zero;return end
  local h=hero();local journal=h and (h.deepwood or Progress.new())or nil
  local chapters={};for _,c in ipairs(Content.chapters)do if c.id:sub(1,3)==spec[2]then table.insert(chapters,c)end end
  table.sort(chapters,function(a,b)if a.side~=b.side then return not a.side end;if not a.side then return a.number<b.number end;return a.id<b.id end)
  summary.Text=h and (spec[1]:upper()..' · '..#chapters..' QUESTS')or Text.SelectHero
  for i,c in ipairs(chapters)do
   local current,hint=status(journal,c)
   local row=T.frame(list,'Quest_'..c.id,UDim2.new(),UDim2.new(1,-8,0,88));row.LayoutOrder=i;row:SetAttribute('QuestStatus',current)
   local title=T.label(row,'Title',(c.side and Text.Side or Text.Main)..' · '..(c.quest.title or c.title),UDim2.fromOffset(12,5),UDim2.new(1,-24,0,24),13,T.color.gold)
   title.TextTruncate=Enum.TextTruncate.AtEnd
   local state=T.label(row,'Status',current,UDim2.fromOffset(12,29),UDim2.new(1,-24,0,20),11,current==Text.Locked and T.color.muted or current==Text.Completed and T.color.green or T.color.gold)
   local detail=T.label(row,'Hint',hint,UDim2.fromOffset(12,49),UDim2.new(1,-24,0,32),11,T.color.text);detail.TextYAlignment=Enum.TextYAlignment.Top
  end
  list.CanvasPosition=reset and Vector2.zero or previous
 end
 for i,spec in ipairs(epics)do
  local b=T.button(tabs,'Epic'..i,spec[1]:upper(),UDim2.new(),UDim2.fromOffset(44,44));b.Caption.TextSize=10;b.Caption.TextWrapped=true
  b.Caption.Position,b.Caption.Size=UDim2.fromOffset(3,2),UDim2.new(1,-6,1,-4);buttons[i]=b
  b.Activated:Connect(function()epic=i;render(true)end)
 end
 local function resizeTabs()
  local width=root.AbsoluteSize.X
  if width<=0 then return end
  local columns=if width<520 then 3 else 5
  local gap=6
  local buttonWidth=math.max(44,math.floor((width-gap*(columns-1))/columns))
  local rows=math.ceil(#buttons/columns)
  local tabHeight=rows*44+(rows-1)*gap
  tabs.Size=UDim2.new(1,0,0,tabHeight)
  tabs.CanvasSize=UDim2.fromOffset(math.max(width,buttonWidth*columns+gap*(columns-1)),0)
  for i,b in ipairs(buttons)do
   local index=i-1
   b.Position=UDim2.fromOffset((index%columns)*(buttonWidth+gap),math.floor(index/columns)*(44+gap))
   b.Size=UDim2.fromOffset(buttonWidth,44)
  end
  summary.Position=UDim2.fromOffset(4,tabHeight+2)
  local listTop=tabHeight+30
  list.Position,list.Size=UDim2.fromOffset(0,listTop),UDim2.new(1,0,1,-listTop)
 end
 root:GetPropertyChangedSignal('AbsoluteSize'):Connect(resizeTabs);resizeTabs()
 return {root=root,show=function(s)snapshot=s;root.Visible=true;render(true)end,update=function(s)snapshot=s;if root.Visible then render(false)end end,
  selectEpic=function(i)if epics[i]then epic=i;render(true)end end}
end
return Journal
