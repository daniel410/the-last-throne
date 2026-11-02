-- Native TD art and text geometry; empty local Studio fixture, not device acceptance.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Isolated local fixture required')
local Run=game:GetService('RunService');local started=not Run:IsRunning();if started then Run:Run()end
local Info=require(game.ReplicatedStorage.Shared.SupporterInfo)
local View=require(game.StarterPlayer.StarterPlayerScripts.Client.SupporterDetails)
local report={kind='SUPPORTER_DETAILS_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local api=View.create(game.CoreGui)
local ok,err=xpcall(function()
 local journal={main=4,flags={['DW-03:report']=true},seleneFollowing=true}
 check(not api:open({id='unknown',lines={}}),'unsupported NPC cannot masquerade as recruitable support')
 for _,size in ipairs({Vector2.new(1280,720),Vector2.new(844,390),Vector2.new(667,375)})do
  for _,key in ipairs({'Following','Available','PartyFull','Threat','Respawning','Distance','Locked','Unknown'})do
   check(api:open(Info.project(key=='Unknown' and nil or journal,nil,key)),'valid supporter detail opens')
   api:resize(size.X,size.Y);task.wait(.1)
   local panel=api.panel;local list=panel.Information
   check(panel.Size.X.Offset<=size.X-24 and panel.Size.Y.Offset<=size.Y-24,'desktop/mobile landscape panel fits available size')
   check(panel:FindFirstChild('TDPanelArt') and panel.Close:FindFirstChild('TDButtonArt'),'approved TD frame/button retained')
   check(panel:FindFirstChild('TDIcon_nun').Image~='','approved TD nun portrait used')
   check(list.AbsoluteSize.Y>=60 and list.AbsoluteCanvasSize.Y>list.AbsoluteSize.Y,'all detailed guidance remains scrollable')
   for _,label in ipairs(list:GetChildren())do if label:IsA('TextLabel')then
    check(label.TextBounds.Y<=label.AbsoluteSize.Y+1,'wrapped supporter text has enough vertical room')
    check(label.AbsoluteSize.X<=list.AbsoluteSize.X,'supporter text fits horizontal content width')
   end end
   api:dismiss();check(not panel.Visible,'close hides the detail')
  end
 end
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
api:destroy();if started then Run:Stop()end
report.pass=#report.failures==0;print('SUPPORTER_DETAILS_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'Supporter details native verification failed')
