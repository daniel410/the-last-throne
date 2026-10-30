local RS=game:GetService('ReplicatedStorage')
local TextService=game:GetService('TextService')
local Content=require(RS.Shared.DeepwoodContent)
local P=require(RS.Shared.DeepwoodProgress)
local Log=require(RS.Shared.DeepwoodQuestLog)
local Theme=require(script.Parent.TDInventoryTheme)
local Book={}
function Book.create(parent,track)
 local panel=Theme.frame(parent,'Journal',UDim2.fromScale(.5,.5),UDim2.fromOffset(680,540));panel.AnchorPoint=Vector2.new(.5,.5);panel.Visible=false
 Theme.label(panel,'Title','QUEST JOURNAL',UDim2.fromOffset(18,12),UDim2.new(1,-80,0,30),18,Theme.color.gold)
 local close=Theme.button(panel,'Close','X',UDim2.new(1,-52,0,12),UDim2.fromOffset(40,40))
 local tab='Main';local last
 local buttons={}
 for index,row in ipairs({{'Main','MAIN STORY'},{'Side','SIDE QUESTS'},{'Chronicle','CHRONICLE'}}) do
  local b=Theme.button(panel,row[1]..'Tab',row[2],UDim2.new((index-1)/3,10,0,58),UDim2.new(1/3,-20,0,38));b.Caption.TextSize=12;buttons[row[1]]=b
 end
 local list=Instance.new('ScrollingFrame');list.Name='Chapters';list.Position=UDim2.fromOffset(14,108);list.Size=UDim2.new(1,-28,1,-170);list.BackgroundTransparency=1;list.BorderSizePixel=0;list.ScrollBarThickness=6;list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.CanvasSize=UDim2.new();list.Parent=panel
 local layout=Instance.new('UIListLayout');layout.Padding=UDim.new(0,10);layout.Parent=list
 local retry=Theme.button(panel,'Retry','RETURN TO CHECKPOINT',UDim2.new(0,14,1,-50),UDim2.new(.5,-21,0,38));retry.Caption.TextSize=11
 local coins=Theme.label(panel,'Coins','',UDim2.new(.5,0,1,-50),UDim2.new(.5,-16,0,38),11)
 local render
 local function card(title,lines,action,caption)
  local width=math.max(200,panel.Size.X.Offset-52);local height=14
  local values={{text=title,size=15,color=Theme.color.gold}}
  for _,line in ipairs(lines) do table.insert(values,type(line)=='table' and line or {text=line,size=12}) end
  for _,line in ipairs(values) do line.height=math.max(line.size or 12,TextService:GetTextSize(line.text,line.size or 12,Enum.Font.GothamMedium,Vector2.new(width-24,2000)).Y)+8;height+=line.height end
  if action then height+=50 end
  local row=Theme.frame(list,'QuestCard',UDim2.new(),UDim2.new(1,-8,0,height));local y=8
  for _,line in ipairs(values) do
   Theme.label(row,'Line',line.text,UDim2.fromOffset(12,y),UDim2.new(1,-24,0,line.height),line.size or 12,line.color);y+=line.height
  end
  if action then local b=Theme.button(row,'Track',caption or 'TRACK',UDim2.fromOffset(12,y+2),UDim2.new(1,-24,0,38));b.Caption.TextSize=12;b.Activated:Connect(action) end
 end
 render=function(current)
  last=current;if not current then return end
  for _,v in ipairs(list:GetChildren()) do if v:IsA('GuiObject') then v:Destroy() end end
  for name,b in pairs(buttons) do b.Caption.TextColor3=name==tab and Theme.color.gold or Theme.color.text end
  local s=current.journal
  coins.Text=string.format('Gold earned: %d\nConfirmed progress is saved.',s.coins+(s.killCoins or 0))
  if tab=='Main' then
   local c=Log.main(s)
   card('EPIC 1 · THE BLACK ROOTS',{require(RS.Shared.DeepwoodQuestCatalog).epic.promise,string.format('%d / 7 stories completed · Side quests are optional.',s.main)})
   if c then
    local phase,index,total=Log.phase(s,c)
    card(string.format('MAIN STORY %d / 7 · %s',c.number,c.quest.title),{c.quest.brief,string.format('Phase %d / %d · %s',index,total,phase),Log.reward(c)},function() track(c.id) end,'TRACK MAIN STORY')
    local currentPhase=c.quest.phases[index];local lines={}
    for _,id in ipairs(currentPhase.goals) do local g=P.goal(c,id);table.insert(lines,(s.flags[c.id..':'..id] and '✓ ' or '□ ')..g.title) end
    card('CURRENT PHASE',lines)
    local target=Log.target(s,c);local g=target and target.goal
    if g and g.activity and g.activity.steps then
     local lines={g.activity.mode=='investigate' and 'Gather the evidence in any order.' or g.activity.mode=='sequence' and g.activity.clue or 'Each confirmed step is saved.'}
     for i,step in ipairs(g.activity.steps) do table.insert(lines,(P.collected(s,c,g,i) and '✓ ' or '□ ')..step.title) end
     card(g.title,lines)
    end
    for _,g in ipairs(c.goals) do if g.optional and P.available(s,c,g) then
     card('OPTIONAL · '..g.title,{'This does not block the main story.','Rescuing the altar captives creates an opening during King Shaman\'s final phase.'},function() track(c.id,g.id) end,'TRACK OPTIONAL RESCUE')
    end end
    card('NEXT STORY',{'Complete this story to open the next region. Combat alone may not finish an investigation, rescue, or report.'})
   else card('EPIC COMPLETE',{'Your restoration choice and completed quests are in the Chronicle. You can finish accepted side quests or return to the lobby.'}) end
  elseif tab=='Side' then
   card('OPTIONAL STORIES',{'Discover a field clue or speak to a resident. Read the request, then choose ACCEPT or LATER.','Accepted quests never block the seven main stories. Report to the named resident when the work is done.'})
   local count=0
   for _,c in ipairs(Content.chapters) do if c.side and s.main>=c.minMain and not s.clears[c.id] and (c.id~='DW-Q1' or P.accepted(s,c)) then
    count+=1;local status=Log.status(s,c)
    local lines={c.quest.brief,'Status: '..status,Log.reward(c)}
    if status=='Available' then table.insert(lines,'Quest giver: '..c.quest.giver..' · Elder Tree Outpost')
    else local t=Log.target(s,c);if t then table.insert(lines,'Next: '..t.goal.title) else table.insert(lines,'Continue the main story to reach '..c.quest.giver..'.') end end
    card(c.title,lines,function() track(c.id) end,status=='Available' and 'FIND QUEST GIVER' or status=='Ready to report' and 'TRACK REPORT' or status:find('Waiting',1,true) and 'CONTINUE MAIN STORY' or 'TRACK SIDE QUEST')
   end end
   if count==0 then card('NO OPEN REQUESTS',{'Explore for field clues and continue the main story. Hidden discoveries appear here after you accept them.'}) end
  else
   local count=0
   for _,c in ipairs(Content.chapters) do if s.clears[c.id] then
    count+=1;local lines={c.quest.outcome}
    for _,choice in ipairs(Log.choices(s,c)) do table.insert(lines,'Your response: '..choice) end
    card((c.side and 'SIDE QUEST · ' or 'MAIN STORY · ')..(c.quest.title or c.title),lines)
   end end
   if count==0 then card('YOUR CHRONICLE',{'Complete a story or report an optional quest to record its outcome here.'}) end
  end
 end
 for name,b in pairs(buttons) do b.Activated:Connect(function() tab=name;list.CanvasPosition=Vector2.zero;render(last) end) end
 return {panel=panel,close=close,retry=retry,render=render,setTab=function(value) tab=value;render(last) end}
end
return Book
