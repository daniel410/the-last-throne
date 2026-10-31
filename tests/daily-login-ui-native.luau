-- Real calendar UI with synthetic server snapshots; no account or real network.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local report={kind='DAILY_LOGIN_UI_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local gui=Instance.new('ScreenGui');gui.Name='DailyLoginQA';gui.Parent=game.CoreGui
local host=Instance.new('Frame');host.Name='Host';host.Parent=gui
local requests={};local view=require(client.DailyLoginGui).create(host,function(c)table.insert(requests,c)end)
local ok,err=xpcall(function()
 view.open();check(requests[1].action=='GetState','opening requests server state')
 check(not view.claim.Active,'cannot claim before account loaded')
 for i,n in ipairs({20,20,20,50,50,50,100})do check(view.cells[i].reward.Text=='+'..n..' Gold','correct reward day '..i)end
 local rewards={20,20,20,50,50,50,100}
 view.receive({state={status='Ready',day=1,canClaim=true,rewards=rewards}})
 check(view.claim.Active and view.claim.Caption.Text=='CLAIM DAY 1 · 20 Gold','claim available when authorized')
 check(view.cells[1].status.Text=='TODAY' and view.cells[2].status.Text=='LOCKED','calendar state visible')
 view.requestClaim();local first=requests[#requests];check(first.action=='Claim' and #first.requestId>0,'claim submits request identifier')
 check(not view.claim.Active,'pending request disables duplicate clicks')
 view.receive({requestId=first.requestId,error='SaveUnknown',state={status='SaveUnknown',retryPending=true}})
 check(view.claim.Active and view.claim.Caption.Text=='CHECK SAVE','uncertain result provides safe retry')
 view.requestClaim();local retry=requests[#requests];check(retry.requestId==first.requestId,'retry uses the exact same request')
 view.receive({requestId=retry.requestId,claimed=true,state={status='Ready',day=1,canClaim=false,rewards=rewards,record={day=1,amount=20}}})
 check(not view.claim.Active and view.claim.Caption.Text=='COME BACK TOMORROW','success prevents another claim today')
 check(view.panel.Status.Text:find('+20 Gold',1,true)~=nil,'success amount is visible')
 view.receive({state={status='Ready',day=2,canClaim=true,rewards=rewards}})
 check(view.cells[1].status.Text=='CLAIMED' and view.cells[2].status.Text=='TODAY','next UTC day progression shown')
 for _,size in ipairs({Vector2.new(1280,800),Vector2.new(750,323),Vector2.new(390,780)})do
  host.Size=UDim2.fromOffset(size.X,size.Y);task.wait(.1)
  check(view.panel.Days.AbsoluteSize.Y>0,'reward calendar scrolls on screen')
  check(view.claim.AbsolutePosition.Y>=view.panel.Days.AbsolutePosition.Y+view.panel.Days.AbsoluteSize.Y,'claim button stays below calendar')
  check(view.claim.AbsoluteSize.Y>=44,'touch claim remains accessible')
 end
end,debug.traceback)
gui:Destroy();if not ok then table.insert(report.failures,tostring(err))end;report.pass=ok;return report
