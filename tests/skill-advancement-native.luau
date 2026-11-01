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
    g.level=stage*20;g.battleWins=stage*3
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
    for _,condition in ipairs({'level','defeats','hub','saving','otherPath','unready'})do
     local beforeLevel,beforeWins,beforeBranch=g.level,g.battleWins,g.branch
     if condition=='level'then g.level=stage*20-1 end
     if condition=='defeats'then g.battleWins=stage*3-1 end
     if condition=='hub'then snapshot.atHub=false end
     if condition=='unready'then snapshot.ready=false end
     if condition=='otherPath'then g.stage=1;g.branch=paths[1]==path and paths[2] or paths[1] end
     local before=#sent
     check(not View.request(hero,snapshot,state,send,function()end,condition=='saving' and {} or nil),'blocked '..condition)
     check(#sent==before,'no command on blocked '..condition)
     g.level,g.battleWins,g.branch,g.stage=beforeLevel,beforeWins,beforeBranch,savedStage;snapshot.atHub=true;snapshot.ready=true
    end
   end
   g.level=20;g.stage=0;g.branch='';g.battleWins=3;state.path=path;state.advanceConfirmation=nil
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
   table.insert(report.cases,{classId=classId,path=path,stages=4,sizes=3})
  end
 end
end,debug.traceback)
gui:Destroy();report.pass=ok;report.error=not ok and err or nil;return report
