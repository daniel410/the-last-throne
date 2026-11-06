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
 for _,size in ipairs({Vector2.new(1280,720),Vector2.new(1280,591),Vector2.new(844,390),Vector2.new(667,375),Vector2.new(568,320)})do
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
 for _,size in ipairs({Vector2.new(1280,720),Vector2.new(1280,591),Vector2.new(844,390),Vector2.new(667,375),Vector2.new(568,320)})do
  local data=Info.project(journal,nil,'SupportReady',true,{credits=5,active=false,story=4});data.balance=1000;data.canBuy=true;data.heroId='qa';data.revision=1
  api:setPending(false);api:open(data);api:resize(size.X,size.Y);task.wait(.1)
  check(api.panel.Buy1.Visible and api.panel.Buy5.Visible and api.panel.Buy10.Visible,'one/five/ten story packs are explicit')
  check(api.panel.Buy1.Active and api.panel.Buy5.Active and not api.panel.Buy10.Active,'affordability follows 200/1000/2000 Gold')
  check(api.panel.PurchaseTerms.Visible and api.panel.PurchaseTerms.TextBounds.Y<=api.panel.PurchaseTerms.AbsoluteSize.Y+1,'mandatory per-story and expiry terms fit above purchase buttons')
  check(api.panel.Information.AbsoluteSize.Y>=60,'mobile purchase terms leave a usable scrolling detail area')
  check(api.panel.Size.X.Offset<=680 and api.panel.Size.Y.Offset<=size.Y-56,'smaller panel leaves clear space around mobile details')
  local list=api.panel.Information;local terms=api.panel.PurchaseTerms;local pack=api.panel.Buy1
  check(list.AbsolutePosition.Y+list.AbsoluteSize.Y<=terms.AbsolutePosition.Y,'scroll content ends before purchase terms')
  check(terms.AbsolutePosition.Y+terms.AbsoluteSize.Y<=pack.AbsolutePosition.Y,'terms and purchase buttons do not overlap')
  check(pack.AbsolutePosition.Y+pack.AbsoluteSize.Y<=api.panel.AbsolutePosition.Y+api.panel.AbsoluteSize.Y-10,'purchase buttons remain inside the frame')
  check(api.panel.Close.AbsoluteSize.Y>=44,'close remains a full touch target')
  for _,n in ipairs({1,5,10})do check(api.panel['Buy'..n].AbsoluteSize.Y>=44,'pack buttons meet touch height')end
  api:setPending(true);check(not api.panel.Buy1.Active and not api.panel.Buy5.Active,'pending receipt blocks duplicate purchases')
 end
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
api:destroy();if started then Run:Stop()end
report.pass=#report.failures==0;print('SUPPORTER_DETAILS_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'Supporter details native verification failed')
