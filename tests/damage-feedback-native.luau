assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Unpublished isolated fixture only')
local Run=game:GetService('RunService');if not Run:IsRunning()then Run:Run()end
local Feedback=require(game.StarterPlayer.StarterPlayerScripts.Client.K0PlayerHitFeedback)
local Reaction=require(game.StarterPlayer.StarterPlayerScripts.Client.K0EnemyHitReaction)
local Http=game.HttpService
local report={kind='DAMAGE_FEEDBACK_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local ok,err=xpcall(function()
 local folder=Instance.new('Folder');folder.Parent=workspace
 local c=Feedback.create(folder)
 for _,args in ipairs({{0,100,'knight'},{0/0,100,'mage'},{10,0,'elf'},{10,100,'invalid'}})do check(not c:pulse(unpack(args)),'invalid damage creates no feedback')end
 for _,class in ipairs({'knight','elf','dwarf','mage'})do
  c:clear();c.lastSound=-math.huge
  check(c:pulse(20,200,class,100),'all four classes get feedback')
  check(c.gui.Veil.BackgroundTransparency>=.955,'centre tint stays very faint')
  check(c.gui.Top.BackgroundTransparency>=.82,'edge tint capped')
  check(c.gui.Top.Active==false and not c.gui.Top.Selectable,'overlay cannot intercept controls')
  local voices=c.gui:GetAttribute('GruntCount');c:pulse(90,200,class,100.1)
  check(c.gui:GetAttribute('GruntCount')==voices,'rapid hits do not stack voice')
  for i=1,20 do c:pulse(90,200,class,100.15)end
  check(c.gui.Veil.BackgroundTransparency>=.955 and c.gui.Top.BackgroundTransparency>=.82,'burst cannot accumulate opacity')
 end
 local model=Instance.new('Model');model:SetAttribute('K0ClassId','knight');model:SetAttribute('K0SpawnReady',true);model:SetAttribute('K0HurtAt',10);model.Parent=folder
 c:bind(model);local count=c.pulses
 model:SetAttribute('K0HurtDamage',12);model:SetAttribute('K0HurtMaxHealth',100);task.wait()
 check(c.pulses==count,'payload changes and binding old pulse do not fake damage')
 model:SetAttribute('K0HurtAt',11);task.wait();check(c.pulses==count+1,'fresh server pulse appears once')
 model:SetAttribute('K0HurtAt',11);task.wait();check(c.pulses==count+1,'duplicate server timestamp ignored')
 c:bind(nil);model:SetAttribute('K0HurtAt',12);task.wait();check(c.pulses==count+1,'old character disconnected')
 check(c.gui.Veil.BackgroundTransparency==1,'respawn clears tint')
 c:pulse(10,100,'knight');task.wait(.5);check(c.gui.Veil.BackgroundTransparency==1 and c.gui.Top.BackgroundTransparency==1,'tint fully fades')
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.CFrame=CFrame.new(0,100,0);root.Anchored=true;root.Parent=model
 local before=root.CFrame
 Reaction.record(model,Vector3.new(0,0,-1),100)
 local peak=Reaction.sample(model,100.025)
 check(peak.Position.Magnitude>.1,'confirmed monster hit produces visible short flinch')
 check(root.CFrame==before,'visual flinch cannot move authoritative root')
 check(Reaction.sample(model,100.181)==CFrame.identity,'flinch recovers without residual transform')
 check(Reaction.sample(model,101)==CFrame.identity,'expired reaction removed')
 game.ContentProvider:PreloadAsync({c.sound})
 report.sound={id=c.sound.SoundId,loaded=c.sound.IsLoaded,duration=c.sound.TimeLength}
 check(c.sound.IsLoaded and c.sound.TimeLength>0,'shipped hurt grunt actually loads')
 c:destroy();folder:Destroy()
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
report.pass=#report.failures==0;print('DAMAGE_FEEDBACK_NATIVE '..Http:JSONEncode(report));assert(report.pass,'damage feedback failed')
