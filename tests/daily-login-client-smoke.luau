-- Run in an isolated fresh Studio Play client, using its in-memory account only.
assert(game:GetService('RunService'):IsStudio() and workspace:GetAttribute('TLTServerRole')=='Lobby','isolated Studio lobby only')
local p=game.Players.LocalPlayer;local remotes=game.ReplicatedStorage.Remotes
local result={kind='DAILY_LOGIN_CLIENT_SMOKE',checks=0,failures={}}
local function check(v,m)result.checks+=1;assert(v,m)end
local responses={};local connection=remotes.DailyLoginState.OnClientEvent:Connect(function(value)table.insert(responses,value)end)
local wallet;local inventory=remotes.InventoryState.OnClientEvent:Connect(function(s)if s.ready and s.wallet then wallet=s.wallet.gold end end)
local function send(c)remotes.DailyLoginRequest:FireServer(c);task.wait(.6)end
local ok,err=xpcall(function()
 check(p:GetAttribute('K0SessionPhase')=='Lobby','lobby ready')
 remotes.InventoryRequest:FireServer({action='GetState',requestId='daily-smoke-wallet'});task.wait(.6)
 check(type(wallet)=='number','saved wallet loaded')
 local before=wallet;send({action='GetState'});local state=responses[#responses]and responses[#responses].state
 check(state and state.status=='Ready' and state.day==1 and state.canClaim,'fresh account is eligible')
 local id=game:GetService('HttpService'):GenerateGUID(false):gsub('%-','')
 send({action='Claim',requestId=id});local claimed=responses[#responses]
 check(claimed and claimed.claimed and claimed.state.record.amount==20,'server confirms Day 1 reward')
 check(wallet==before+20,'server publishes exactly one Gold credit')
 send({action='Claim',requestId=id});local repeatResult=responses[#responses]
 check(repeatResult.replayed and repeatResult.claimed and wallet==before+20,'same request recovers without another credit')
 send({action='Claim',requestId=id..'x'});local duplicate=responses[#responses]
 check(duplicate.error=='AlreadyClaimed' and wallet==before+20,'another request cannot claim again')
 local count=#responses;send({action='Claim',requestId='forged',amount=999999,day=7})
 check(#responses==count and wallet==before+20,'forged amount/day request is rejected')
 local lobby=p.PlayerGui:FindFirstChild('LobbyServices')
 check(lobby and lobby.LobbyNavigation:FindFirstChild('LoginRewards') and lobby:FindFirstChild('DailyLogin'),'login button and panel created')
end,debug.traceback)
connection:Disconnect();inventory:Disconnect();if not ok then table.insert(result.failures,tostring(err))end;result.pass=ok;return result
