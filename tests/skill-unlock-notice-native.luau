local Players=game:GetService('Players');local RS=game:GetService('ReplicatedStorage')
assert(game.PlaceId==0 and #Players:GetPlayers()==0,'isolated local place only')
local G=require(RS.Shared.HeroProgression);local A=require(RS.Shared.AdvancedSkills)
local Notice=require(game.StarterPlayer.StarterPlayerScripts.Client.SkillUnlockNotice)
local report={kind='SKILL_UNLOCK_NOTICE_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local parent=Instance.new('Folder');parent.Name='SkillUnlockQA';parent.Parent=workspace
local ok,err=xpcall(function()
 local view=Notice.create(parent);local frame=view.gui.Announcement
 local function snapshot(rev,id,class,g)return {ready=true,revision=rev,heroId=id,heroes={[id]={baseClassId=class,progression=g}}}end
 local g=G.new(4);view.receive(snapshot(1,'knight','knight',g));check(not frame.Visible,'existing skills do not trigger on initial load')
 g=G.copy(g);g.level=5;local first=snapshot(2,'knight','knight',g);view.receive(first)
 check(frame.Visible and frame.Heading.Text=='NEW SKILL UNLOCKED!' and frame.SkillName.Text==A.common.knight[1].name,'level 5 displays the newly unlocked skill')
 check(frame.Hint.Text:find('loadout',1,true)~=nil,'explains where to equip the skill')
 view.receive(first);view.receive(snapshot(1,'knight','knight',G.new(4)));task.wait(3.7)
 check(not frame.Visible,'duplicate and older snapshots do not replay the notice')
 g=G.copy(g);g.level=15;view.receive(snapshot(3,'knight','knight',g))
 check(frame.Visible and frame.SkillName.Text==A.common.knight[2].name,'multi-level jump shows the first new skill')
 task.wait(3.7);check(frame.Visible and frame.SkillName.Text==A.common.knight[3].name,'multi-level jump queues the next skill')
 local promoted=G.new(80);promoted.branch='steel_knight';promoted.stage=3
 view.receive(snapshot(4,'other','knight',promoted));check(not frame.Visible,'switching heroes clears the old queue without replaying existing skills')
 promoted=G.copy(promoted);promoted.stage=4;view.receive(snapshot(5,'other','knight',promoted))
 check(frame.Visible and frame.SkillName.Text==A.branches.steel_knight.skills[13].name,'final advancement announces its ultimate')
 check(frame.Hint.Text:find('ultimate',1,true)~=nil,'ultimate explains its dedicated button')
 local bad=snapshot(6,'other','knight',promoted);bad.ready=false;view.receive(bad)
 check(frame.Visible,'unavailable snapshot does not invent or clear an unlock')
 view.gui:Destroy()
end,debug.traceback)
parent:Destroy();if not ok then table.insert(report.failures,tostring(err))end;report.pass=ok;return report
