-- Actual runtime views/controllers with isolated remote snapshot.
assert(game.PlaceId==0)
local p=game.Players.LocalPlayer
p:SetAttribute('K0SessionPhase','Lobby')
workspace:SetAttribute('TLTServerRole','Lobby')
local C=p.PlayerScripts:WaitForChild('Client')
local growth=require(C.HeroGrowthGui).create()
require(C.LobbyTopMenu).create(p,{Hero=function()growth.open()end,Bag=function()p:SetAttribute('QAAction','Bag')end,Journal=function()p:SetAttribute('QAAction','Journal')end,Settings=function()p:SetAttribute('QAAction','Settings')end})
p:SetAttribute('QAFixtureReady',true)
-- Follow-up runtime scope: existing lobby icon rail and real battle HUD.
local home=Instance.new('ScreenGui');home.Name='QALobbyNavigation';home.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;home.Parent=p.PlayerGui
require(C.LobbyNavigation).create(home,{close=function()end,open=function(id)p:SetAttribute('QAAction',id)end})
local hud=require(C.K0Hud).create()
hud.setVisible(false)
hud.heroMenu.Activated:Connect(function()growth.open()end)
hud.settingsMenu.Activated:Connect(function()p:SetAttribute('QAAction','BattleSettings')end)
hud.bagMenu.Activated:Connect(function()p:SetAttribute('QAAction','BattleBag')end)
local function mode()
 local battle=p:GetAttribute('QAViewMode')=='Battle'
 home.Enabled=not battle
 workspace:SetAttribute('TLTServerRole',battle and 'Battle' or 'Lobby')
 p:SetAttribute('K0SessionPhase',battle and 'Adventure' or 'Lobby')
 hud.setVisible(battle)
end
p:GetAttributeChangedSignal('QAViewMode'):Connect(mode)
mode()
