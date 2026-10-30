local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local UIS=game:GetService('UserInputService')
local RunService=game:GetService('RunService')
local Content=require(RS.Shared.DeepwoodContent)
local Progress=require(RS.Shared.DeepwoodProgress)
local Log=require(RS.Shared.DeepwoodQuestLog)
local Theme=require(script.Parent.TDInventoryTheme)
local Navigation=require(script.Parent.DeepwoodNavigation)
local Text=require(RS.Shared.K0Text)
local MapState=require(script.Parent.DeepwoodMapState)
local Gates=require(script.Parent.DeepwoodGates)
local Journal={}
function Journal.guidance(current,target,origin)
 if not current or current.training or not target then return nil end
 local goal=target.goal;local chapter=target.chapter
 if target.offer then
  if not Progress.canAccept(current.journal,chapter) then return nil end
  return {position=Vector3.new(table.unpack(chapter.quest.offerPosition)),objective='Speak with '..chapter.quest.giver,note='Optional request · Choose ACCEPT or LATER after hearing the request.'}
 end
 if not Progress.available(current.journal,chapter,goal) then return nil end
 local fight=current.encounters and current.encounters[chapter.id..':'..goal.id]
 local step=Progress.nextStep(current.journal,chapter,goal)
 local a=goal.activity
 local destination=Vector3.new(table.unpack(goal.position))
 local hint=#goal.enemies>0 and (a and a.mode=='battle' and 'Approach the ambush area. Stay alert for the raiders.' or Text.StoryBeginEncounter) or goal.id==chapter.quest.turnIn and 'Talk to '..chapter.quest.giver..' to report your findings.' or Text.StoryInteract
 if step then
  local count=(current.journal.activities or {})[chapter.id..':'..goal.id] or 0
  hint=string.format('%d / %d · %s',count+1,#a.steps,step.title)
  if a.mode=='investigate' then
   if origin then
    local nearest
    for index,candidate in ipairs(a.steps) do if not Progress.collected(current.journal,chapter,goal,index) then
     local distance=(origin-Vector3.new(table.unpack(candidate.position))).Magnitude
     if not nearest or distance<nearest then step=candidate;nearest=distance end
    end end
   end
   destination=Vector3.new(table.unpack(step.position));hint=string.format('Evidence %d / %d · Any order · %s',count,#a.steps,step.title)
  elseif a.mode=='sequence' then hint=a.clue;destination=Vector3.new(table.unpack(step.position))
  elseif a.mode=='escort' then
   local attempt=current.activities and current.activities[chapter.id..':'..goal.id]
   if attempt then destination=attempt.actorPosition;hint=attempt.status else hint='Speak to '..a.actor..' to begin the escort.' end
  elseif a.mode~='dialogue' then destination=Vector3.new(table.unpack(step.position)) end
 end
 if fight then
  hint=(fight.pillars or 0)>0 and string.format(Text.StoryPillarsLeft,fight.pillars)
   or fight.remaining>0 and string.format(Text.StoryEnemiesLeft,fight.remaining) or Text.StorySaving
  if fight.waves and fight.waves>1 then hint=string.format('Wave %d / %d · %s',fight.wave,fight.waves,hint) end
 end
 return {position=destination,objective=goal.title,note=hint}
end
function Journal.start(hud)
 local player=Players.LocalPlayer
 local remotes=RS:WaitForChild('Remotes');local request=remotes:WaitForChild('DeepwoodRequest');local response=remotes:WaitForChild('DeepwoodState')
 local gui=Instance.new('ScreenGui');gui.Name='DeepwoodJournal';gui.ResetOnSpawn=false;gui.DisplayOrder=42;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=player:WaitForChild('PlayerGui')
 local current,target,selectedChapter,selectedGoal,lastMessage,render,setOpen,track
 local book=require(script.Parent.DeepwoodQuestBook).create(gui,function(id,goal) track(id,goal) end)
 local panel=book.panel
 local dialog=Theme.frame(gui,'StoryMessage',UDim2.new(.5,0,1,-195),UDim2.fromOffset(620,160));dialog.AnchorPoint=Vector2.new(.5,1);dialog.Visible=false;dialog.BackgroundTransparency=.85
 dialog.TDPanelArt:Destroy();dialog:FindFirstChildOfClass('UIStroke').Transparency=1
 local prose=Theme.label(dialog,'Dialogue','',UDim2.fromOffset(16,8),UDim2.new(1,-32,1,-64),13);prose.TextStrokeColor3=Color3.new(0,0,0);prose.TextStrokeTransparency=.2
 local dismiss=Theme.button(dialog,'Continue','CONTINUE',UDim2.new(1,-150,1,-50),UDim2.fromOffset(136,38))
 local left=Theme.button(dialog,'Sanctuary','',UDim2.new(0,12,1,-50),UDim2.new(.5,-18,0,38));left.Visible=false
 local right=Theme.button(dialog,'Share','',UDim2.new(.5,6,1,-50),UDim2.new(.5,-18,0,38));right.Visible=false
 local dialogKind,offerShown,dialogToken=nil,nil,0
 local function layoutDialogue(text)
  local camera=workspace.CurrentCamera;if not camera then return end
  local width=math.min(680,camera.ViewportSize.X-20)
  local height=game:GetService('TextService'):GetTextSize(text,13,Enum.Font.GothamMedium,Vector2.new(width-32,2000)).Y+78
  dialog.Size=UDim2.fromOffset(width,math.min(camera.ViewportSize.Y*.65,math.max(160,height)))
  dialog.Position=UDim2.new(.5,0,1,-math.min(195,camera.ViewportSize.Y*.2))
 end
 local navigation=Navigation.start();local gates=Gates.create()
 local marker=Instance.new('BillboardGui');marker.Name='DeepwoodWaypoint';marker.Size=UDim2.fromOffset(190,55);marker.AlwaysOnTop=true;marker.StudsOffset=Vector3.new(0,6,0);marker.MaxDistance=2400;marker.Parent=player:WaitForChild('PlayerGui')
 local anchor=Instance.new('Part');anchor.Name='PersonalWaypoint';anchor.Anchored=true;anchor.Size=Vector3.one;anchor.Transparency=1;anchor.CanCollide=false;anchor.CanTouch=false;anchor.CanQuery=false;anchor.Parent=workspace
 local waypoint=Theme.label(marker,'Waypoint','',UDim2.new(),UDim2.fromScale(1,1),12,Theme.color.gold);waypoint.TextXAlignment=Enum.TextXAlignment.Center;waypoint.TextStrokeTransparency=.15
 setOpen=function(open) panel.Visible=open;player:SetAttribute('TLTStoryOpen',open or (dialog.Visible and left.Visible)) end
 local function closeDialogue() dialog.Visible=false;dialogKind=nil;dialogToken+=1;setOpen(panel.Visible) end
 local function showDialogue(text,kind,first,second)
  dialogToken+=1;local token=dialogToken;dialog.Visible=true;dialogKind=kind;prose.Text=text;layoutDialogue(text)
  left.Visible=first~=nil;right.Visible=second~=nil;dismiss.Visible=not first
  if first then left.Caption.Text=first;right.Caption.Text=second end
  setOpen(panel.Visible)
  if not first then task.delay(8,function() if token==dialogToken then closeDialogue() end end) end
 end
 local function answer(index)
  if dialogKind=='offer' and current and current.questOffer then request:FireServer(index==1 and 'AcceptQuest' or 'LaterQuest',current.questOffer.id)
  elseif dialogKind=='dialogue' and current and current.dialogue then
   local d=current.dialogue;local choice=d.choices[index];request:FireServer('Answer',d.chapter..':'..d.goal..':'..d.step..':'..choice.id)
  elseif dialogKind=='restoration' then request:FireServer('Choose',index==1 and 'sanctuary' or 'shared') end
  closeDialogue()
 end
 left.Activated:Connect(function() answer(1) end);right.Activated:Connect(function() answer(2) end);dismiss.Activated:Connect(closeDialogue)
 track=function(id,goal) selectedChapter=id;selectedGoal=goal;render();setOpen(false) end
 book.close.Activated:Connect(function() setOpen(false) end)
 book.retry.Activated:Connect(function() request:FireServer('Retry');setOpen(false) end)
 if hud.journalMenu then hud.journalMenu.Activated:Connect(function() setOpen(true) end) end
 UIS.InputBegan:Connect(function(input,processed) if not processed and input.KeyCode==Enum.KeyCode.J and current and not current.training and player:GetAttribute('K0SessionPhase')=='Tutorial' then setOpen(not panel.Visible) end end)
 local function selectTarget()
  local s=current.journal;local c=selectedChapter and Content.byId[selectedChapter]
  if c and c.side and Progress.canAccept(s,c) and c.quest.offerPosition then return {chapter=c,goal=c.goals[1],offer=true} end
  if c and c.side and not s.clears[c.id] then local t=Log.target(s,c);if t then return t end end
  local main=Log.main(s)
  if main then return Log.target(s,main,selectedChapter==main.id and selectedGoal or nil) end
 end
 local function updateTracker()
  local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
  local guidance=Journal.guidance(current,target,root and root.Position)
  if hud.setStory then
   local title='EPIC 1 COMPLETE'
   if target then
    if target.chapter.side then title=target.offer and 'OPTIONAL REQUEST' or 'SIDE QUEST · '..Log.status(current.journal,target.chapter)
    else local _,index,total=Log.phase(current.journal,target.chapter);title=string.format('MAIN STORY %d / 7 · PHASE %d / %d',target.chapter.number,index,total) end
   end
   hud.setStory({title=title,objective=guidance and guidance.objective or 'Explore optional requests or return to the lobby.',note=guidance and guidance.note or '[J] Chronicle'})
  end
  return guidance
 end
 local promptsDirty=true
 render=function()
  if not current then return end
  if current.training then hud.setStory(nil);target=nil;marker.Adornee=nil;closeDialogue();setOpen(false);return end
  target=selectTarget();book.render(current);updateTracker();promptsDirty=true
 end
 local function updatePrompts()
  local world=workspace:FindFirstChild('DeepwoodCampaign');if not world or not current then return end
  local s=current.journal;local nodes=world:FindFirstChild('Objectives')
  for _,p in ipairs(nodes and nodes:GetChildren() or {}) do
   local c=Content.byId[p:GetAttribute('ChapterId')];local g=c and Progress.goal(c,p:GetAttribute('GoalId'));local prompt=p:FindFirstChildOfClass('ProximityPrompt')
   if prompt and g then
    if p:GetAttribute('QuestOffer') then
     prompt.Enabled=s.main>=c.minMain and not s.clears[c.id];prompt.ActionText=Log.status(s,c)=='Ready to report' and 'Report' or 'Talk'
     prompt.ObjectText=c.quest.giver..' · '..Log.status(s,c)
    elseif c.side and g==c.goals[1] and Progress.canAccept(s,c) then prompt.Enabled=true;prompt.ActionText='Read clue';prompt.ObjectText='Optional discovery · '..c.title
    elseif c.side and g.id==c.quest.turnIn and c.quest.offerPosition then prompt.Enabled=false
    else prompt.Enabled=Progress.available(s,c,g) and (not g.activity or g.activity.mode=='dialogue' or g.activity.mode=='escort');if c.side and g.id==c.quest.turnIn then prompt.ActionText='Report';prompt.ObjectText=c.quest.giver end end
   end
  end
  local steps=world:FindFirstChild('AdventureActivities')
  for _,p in ipairs(steps and steps:GetChildren() or {}) do if p:IsA('BasePart') and p:GetAttribute('StepId') then
   local c=Content.byId[p:GetAttribute('ChapterId')];local g=c and Progress.goal(c,p:GetAttribute('GoalId'));local prompt=p:FindFirstChildOfClass('ProximityPrompt');local step=g and Progress.nextStep(s,c,g)
   if prompt then
    local available=step~=nil and (g.activity.mode=='sequence' or step.id==p:GetAttribute('StepId'))
    if step and g.activity.mode=='investigate' then for index,candidate in ipairs(g.activity.steps) do if candidate.id==p:GetAttribute('StepId') then available=not Progress.collected(s,c,g,index) end end end
    prompt.Enabled=available
   end
  end end
 end
 workspace.DescendantAdded:Connect(function(v) if v:IsA('ProximityPrompt') then promptsDirty=true end end)
 local completed={}
 response.OnClientEvent:Connect(function(value)
  if current and current.heroId~=value.heroId then selectedChapter=nil;selectedGoal=nil;lastMessage=nil;offerShown=nil;closeDialogue();book.setTab('Main') end
  current=value;gates.update(value)
  local event=value.completion
  if event then
   if event.kind=='Accepted' then selectedChapter=event.id;selectedGoal=nil
   else
    local key=value.heroId..':'..event.id
    if not completed[key] then completed[key]=true;hud.showFeedback(event.kind..' complete · '..event.title..'\n'..(event.xp>0 and string.format('+%d XP · +%d Coins',event.xp,event.coins) or event.outcome),8) end
   end
  end
  render();local guidance=updateTracker();MapState.set(value,guidance and guidance.position)
  if value.notice and hud.showFeedback then hud.showFeedback(value.notice,4) end
  if value.message and value.message~=lastMessage then lastMessage=value.message;showDialogue(value.message,'message') end
  if value.questOffer then
   local c=Content.byId[value.questOffer.id]
   if offerShown~=c.id then offerShown=c.id;showDialogue('OPTIONAL · '..c.title..'\n'..c.quest.brief..'\n'..Log.reward(c),'offer',value.questOffer.discovery and 'ACCEPT & RECOVER CLUE' or 'ACCEPT QUEST','LATER') end
  else
   offerShown=nil
   if dialogKind=='offer' then closeDialogue();hud.showFeedback('This request is no longer nearby. Return to the resident or clue.',4) end
  end
  if not value.dialogue and dialogKind=='dialogue' then closeDialogue();hud.showFeedback('Return to the resident to continue the conversation.',4) end
  if value.dialogue and value.dialogue.choices then showDialogue(value.dialogue.text,'dialogue',value.dialogue.choices[1].title,value.dialogue.choices[2].title) end
 end)
 local elapsed=0
 RunService.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.2 then return end;elapsed=0
  local alive=player:GetAttribute('K0SessionPhase')=='Tutorial' and current and not current.training
  gui.Enabled=alive==true;marker.Enabled=alive==true
  if not alive then navigation.setTarget(nil);panel.Visible=false;closeDialogue();return end
  local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart');local guidance=updateTracker()
  navigation.setTarget(guidance and guidance.position);MapState.target=guidance and guidance.position
  marker.Adornee=guidance and anchor or nil
  if guidance and root then anchor.Position=guidance.position;waypoint.Text=(target.chapter.side and '◇ ' or '◆ ')..guidance.objective..'\n'..math.floor((root.Position-guidance.position).Magnitude)..' studs' end
  if promptsDirty then promptsDirty=false;updatePrompts() end
  if root then
   local c=Content.byId['DW-07'];local g=Progress.goal(c,'restoration')
   if Progress.available(current.journal,c,g) and (root.Position-Vector3.new(table.unpack(g.position))).Magnitude<14 and dialogKind~='restoration' then showDialogue(g.text,'restoration','ELVEN SANCTUARY','SHARE WITH REFUGEES') end
  end
 end)
 local function resize()
  local camera=workspace.CurrentCamera;if not camera then return end
  panel.Size=UDim2.fromOffset(math.min(680,camera.ViewportSize.X-20),math.min(540,camera.ViewportSize.Y-24))
  layoutDialogue(prose.Text)
  render()
 end
 if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(resize) end;resize()
 task.spawn(function() for _=1,3 do request:FireServer('GetState');task.wait(2) end end)
 return {open=function() setOpen(true) end}
end
return Journal
