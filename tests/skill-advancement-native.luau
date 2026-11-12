-- Isolated native GUI and existing server-rule checks; no real account writes.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated fixture only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local Shared=game.ReplicatedStorage.Shared
local G=require(Shared.HeroProgression)
local A=require(Shared.AdvancedSkills)
local View=require(client.SkillAdvancementView)
local Tree=require(client.HeroSkillTree)
local report={kind='SKILL_ADVANCEMENT_NATIVE',checks=0,cases={}}
local function check(ok,message)report.checks+=1;assert(ok,message)end
local gui=Instance.new('ScreenGui');gui.Name='SkillsAdvancementQA';gui.Parent=game.CoreGui
local body=Instance.new('ScrollingFrame');body.BackgroundTransparency=1;body.Parent=gui
local ok,err=xpcall(function()
 for classId,paths in pairs(A.order)do
  for _,path in ipairs(paths)do
   local g=G.new(1);local hero={heroId='qa',baseClassId=classId,progression=g}
   local snapshot={heroId='qa',revision=1,ready=true,atHub=true,stats={power=0},items={}}
   local state={path=path,selected=1,retry=function()end}
   local sent={};local function send(action,fields)table.insert(sent,{action=action,fields=fields})end
   for stage=1,4 do
    g.level=stage*20;g.battleWins=0;snapshot.atHub=false;snapshot.canInvest=false
    if stage>1 then g.stage=stage-1;g.branch=path end
    state.advanceConfirmation=nil
    check(not View.request(hero,snapshot,state,send,function()end),'first click only reviews')
    check(#sent==stage-1,'review sends no command')
    check(View.request(hero,snapshot,state,send,function()end),'second click confirms')
    local command=sent[#sent]
    check(command.action=='Advance' and command.fields.stage==stage and command.fields.branch==path,'exact existing command')
    local result,why=G.apply(g,{action='Advance',branch=path,stage=stage},classId)
    check(result~=nil,'existing progression rules accept command: '..tostring(why))
    local savedStage=g.stage
    for _,condition in ipairs({'level','saving','otherPath','unready'})do
     local beforeLevel,beforeWins,beforeBranch=g.level,g.battleWins,g.branch
     if condition=='level'then g.level=stage*20-1 end
     if condition=='unready'then snapshot.ready=false end
     if condition=='otherPath'then g.stage=1;g.branch=paths[1]==path and paths[2] or paths[1] end
     local before=#sent
     check(not View.request(hero,snapshot,state,send,function()end,condition=='saving' and {} or nil),'blocked '..condition)
     check(#sent==before,'no command on blocked '..condition)
     g.level,g.battleWins,g.branch,g.stage=beforeLevel,beforeWins,beforeBranch,savedStage;snapshot.atHub=false;snapshot.ready=true
    end
   end
   g.level=20;g.stage=0;g.branch='';g.battleWins=0;state.path=path;state.advanceConfirmation=nil
   View.request(hero,snapshot,state,send,function()end)
   snapshot.revision+=1
   local before=#sent
   check(not View.request(hero,snapshot,state,send,function()end) and #sent==before,'changed snapshot requires a fresh review')
   Tree.selectPath(classId,state,paths[1]==path and paths[2] or paths[1])
   check(state.advanceConfirmation==nil and g.branch=='','browsing clears review and does not save a path')
   state.path=path;state.selected=A.branches[path].skills[1].index
   for _,size in ipairs({Vector2.new(1160,650),Vector2.new(702,193),Vector2.new(390,650)})do
    body:ClearAllChildren();body.Size=UDim2.fromOffset(size.X,size.Y);task.wait()
    local height=Tree.render(body,hero,snapshot,state,send,function()end,nil)
    body.CanvasSize=UDim2.fromOffset(0,height);task.wait()
    local panel=body.SkillAdvancement
    check(panel:GetAttribute('PreviewPath')==path,'advancement uses browsed skill path')
    check(panel.CompleteAdvancement.Active,'eligible hero can review from skills')
    check(panel.Unlocks.Text:find(A.branches[path].skills[1].name,1,true)~=nil,'real catalog skill preview')
    check(body.SkillMap.Position.Y.Offset>=panel.Position.Y.Offset+panel.Size.Y.Offset,'tree clears advancement panel')
    check(body.CombatLoadout.Position.Y.Offset+body.CombatLoadout.Size.Y.Offset<height,'loadout remains scrollable')
    for _,label in panel:GetDescendants()do if label:IsA('TextLabel')then check(label.TextFits,'advancement text fits '..classId..' '..tostring(size)..' '..label.Name)end end
   end
   g.level=80;g.battleWins=12;g.stage=4;g.branch=path
   body:ClearAllChildren();View.render(body,hero,snapshot,state,send,function()end,nil,4,700)
   check(not body.SkillAdvancement:FindFirstChild('CompleteAdvancement'),'completed final stage has no extra advance button')
   check(body.SkillAdvancement.Unlocks.Text:find(A.branches[path].skills[13].name,1,true)~=nil,'ultimate remains named after final advancement')
   local other=paths[1]==path and paths[2] or paths[1]
   snapshot.canInvest=true
   for stage=1,4 do
    g.stage=stage;g.level=stage*20;g.branch=path
    for _,size in ipairs({Vector2.new(1160,650),Vector2.new(702,193),Vector2.new(390,650)}) do
     body.Size=UDim2.fromOffset(size.X,size.Y);task.wait()
     Tree.selectPath(classId,state,other)
     body:ClearAllChildren();Tree.render(body,hero,snapshot,state,send,function()end,nil);task.wait()
     local panel=body.SkillAdvancement
     check(panel.PathStatus.Text:find('PATH LOCKED',1,true)~=nil,'excluded path explicitly named')
     check(not panel:FindFirstChild('CompleteAdvancement'),'excluded path has no advance action')
     for i,id in ipairs(paths) do
      local tab=body.SkillHeader['Path'..i]
      check(tab:GetAttribute('PathLocked')==(id==other),'only other path tab is gray')
      check(tab.Active and tab.Selectable,'preview remains accessible to all inputs')
      check(tab.Caption.TextFits,'path caption fits '..id..' '..tostring(size))
     end
     for _,skill in ipairs(A.branches[other].skills) do
      local node=body.SkillMap['Skill'..skill.index]
      check(node:GetAttribute('PathLocked') and node.Rank.Text=='PATH LOCKED','all excluded skills marked')
      check(node.BackgroundColor3.R==node.BackgroundColor3.G and node.BackgroundColor3.G==node.BackgroundColor3.B,'excluded node is grayscale')
     end
     check(not body.SkillDetails.Train.Active,'excluded skill cannot train')
     for slot=1,5 do check(not body.CombatLoadout['Slot'..slot].Active,'excluded skill cannot equip') end
     local before=#sent
     check(not View.request(hero,snapshot,state,send,function()end) and #sent==before,'excluded preview sends no advancement')
     for _,label in panel:GetDescendants() do if label:IsA('TextLabel')then check(label.TextFits,'locked panel text fits '..label.Name)end end
     state.selected=1
     body:ClearAllChildren();Tree.render(body,hero,snapshot,state,send,function()end,nil)
     check(not body.SkillMap.Skill1:GetAttribute('PathLocked'),'shared skill not path locked')
     check(body.SkillDetails.Train.Active and body.CombatLoadout.Slot1.Active,'shared skill can train and equip in excluded preview')
     Tree.selectPath(classId,state,path)
     body:ClearAllChildren();Tree.render(body,hero,snapshot,state,send,function()end,nil)
     check(not body.SkillMap['Skill'..A.branches[path].skills[13].index]:GetAttribute('PathLocked'),'future saved path skill is ordinary level lock')
    end
    check(not G.apply(g,{action='Advance',branch=other,stage=stage+1},classId),'server rules reject other path advancement')
    check(not G.apply(g,{action='TrainSkill',skill=A.branches[other].skills[1].index},classId),'server rules reject other path training')
    check(not G.apply(g,{action='SetSkillSlot',slot=1,skill=A.branches[other].skills[1].index},classId),'server rules reject other path equip')
   end
   table.insert(report.cases,{classId=classId,path=path,stages=4,sizes=3})
  end
 end
end,debug.traceback)
gui:Destroy();report.pass=ok;report.error=not ok and err or nil;return report
