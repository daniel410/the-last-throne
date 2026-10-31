local Players=game:GetService('Players');local RS=game:GetService('ReplicatedStorage')
assert(game.PlaceId==0 and #Players:GetPlayers()==0,'isolated local place only')
local Content=require(RS.Shared.CampaignContent)
local Gate=require(game.ServerScriptService.Server.Story.DeepwoodRegionAccess)
local Notice=require(game.StarterPlayer.StarterPlayerScripts.Client.StoryRegionNotice)
local report={kind='STORY_REGION_NOTICE_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local fixture=Instance.new('Folder');fixture.Name='StoryRegionQA';fixture.Parent=workspace
local gui=Instance.new('ScreenGui');gui.Name='StoryRegionQA';gui.Parent=game.CoreGui
local ok,err=xpcall(function()
 local attrs=Instance.new('Folder');attrs.Parent=fixture
 local character=Instance.new('Model');character.Parent=fixture
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Parent=character;character.PrimaryPart=root
 local human=Instance.new('Humanoid');human.RequiresNeck=false;human.Parent=character
 local player={Character=character,GetAttribute=function(_,k)return attrs:GetAttribute(k)end,SetAttribute=function(_,k,v)attrs:SetAttribute(k,v)end,GetAttributeChangedSignal=function(_,k)return attrs:GetAttributeChangedSignal(k)end}
 local frame=Notice.create(gui,player);local changes={};local state={main=0};local hero={heroId='qa',training=false}
 check(frame.RegionName:FindFirstChildOfClass('UITextSizeConstraint').MaxTextSize==22,'region entry name uses the larger text size')
 local spawns={};for id,z in pairs(Content.zones)do spawns[id]={CFrame=CFrame.new(table.unpack(z.center))}end
 local gate=Gate.create({heroSession={getActiveHero=function()return hero end},inventory={storyState=function()return state end},world={spawns=spawns},combat={relocateForStoryGate=function(_,cf)character:PivotTo(cf)end},notice=function()end,regionChanged=function(_,id)table.insert(changes,id or 'cleared');attrs:SetAttribute('TLTStoryRegion',id)end})
 local function move(id)local c=Content.zones[id].center;root.Position=Vector3.new(c[1],c[2]+4,c[3])end
 local function enter(id)move(id);gate.update(player);task.wait(.7);gate.update(player);task.wait()end
 attrs:SetAttribute('K0SessionPhase','Tutorial');attrs:SetAttribute('TLTRoute','Adventure')
 move('DW-01');gate.update(player);check(not frame.Visible,'no notice before stable entry')
 task.wait(.7);gate.update(player);task.wait();check(frame.Visible and frame.RegionName.Text==Content.zones['DW-01'].name,'first valid story region is shown')
 gate.update(player);check(#changes==1,'staying in a region does not repeat')
 move('DW-02');gate.update(player);task.wait(.7);gate.update(player);check(#changes==1,'locked region is never announced')
 state.main=14;enter('FV-01');check(frame.RegionName.Text==Content.zones['FV-01'].name and changes[#changes]=='FV-01','Frozen Vale region uses actual zone name')
 enter('EC-01');check(frame.RegionName.Text==Content.zones['EC-01'].name and changes[#changes]=='EC-01','Ember Caldera region uses actual zone name')
 local count=#changes;move('DW-01');gate.update(player);move('EC-01');gate.update(player);task.wait(.7);gate.update(player);check(#changes==count,'brief boundary crossing does not announce')
 attrs:SetAttribute('K0SessionPhase','Lobby');gate.update(player);check(not frame.Visible and changes[#changes]=='cleared','leaving adventure clears notice and server state')
 attrs:SetAttribute('K0SessionPhase','Tutorial');hero.training=true;gate.update(player);check(not frame.Visible,'training does not announce campaign regions')
 hero.training=false;enter('DW-01');check(frame.Visible,'a new adventure can announce its initial region')
 task.wait(3.6);check(not frame.Visible,'notice disappears automatically')
 gate.remove(player)
end,debug.traceback)
gui:Destroy();fixture:Destroy();if not ok then table.insert(report.failures,tostring(err))end;report.pass=ok;return report
