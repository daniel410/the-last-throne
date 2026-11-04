-- The client may suggest a target. The server validates combat, damage,
-- mana, range and obstruction before rendering its replicated result.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
require(script.TravelLoadingScreen).start(player)
task.spawn(function() require(script.LobbyCommerce).start() end)
task.spawn(function() require(script.LobbyLandmarkVisuals).start() end)
task.spawn(function() require(script.NPCDialogue).start() end)
require(script.NPCPresentation).start()
require(script.NPCMotionPresentation).start()
require(script.SelenePresentation).start()
require(script.InteractionPrompts).start()
require(script.AdventureCamera).start()
require(script.WorldPresentationBudget).start()
local StarterGui=game:GetService("StarterGui")
local function hideDefaultHealth()
	task.spawn(function()
		for _=1,20 do
			local ok=pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health,false) end)
			if ok then return end
			task.wait(.25)
		end
		warn("Default health UI could not be hidden; custom health HUD remains active.")
	end)
end
hideDefaultHealth()
player.CharacterAdded:Connect(hideDefaultHealth)
require(script.SkillUnlockNotice).start(player)
local battle,startingBattle
local lobby,inventory,growthGui,settingsGui
local heroSnapshot,heroRequestRemote,pendingRequest
local requestSequence,lastRevision=0,-1
local function cancelBattle()
 if battle then battle.cancel()end
end
local function feedback(message)
 if battle then battle.feedback(message)end
end
local function requestHero(action, argument)
	if pendingRequest then return end
	if not heroRequestRemote then
		if lobby then lobby.showError("Unavailable") end
		return
	end
	cancelBattle()
	requestSequence += 1
	local requestId = "ui-" .. tostring(requestSequence)
	pendingRequest = requestId
	lobby.setBusy(true)
	heroRequestRemote:FireServer(action, requestId, argument)
	task.delay(8, function()
		if pendingRequest ~= requestId then return end
		pendingRequest = nil
		lobby.setBusy(false)
		lobby.showError("Unavailable")
	end)
end

lobby = require(script.HeroLobbyGui).create(requestHero,function() if growthGui then growthGui.open("Skills") end end)
inventory = require(script.InventoryGui).create(function(opened)
	if opened then
		if growthGui and growthGui.isOpen() then growthGui.close() end
		cancelBattle()
	end
	lobby.setSuppressed(opened)
end, feedback)
growthGui = require(script.HeroGrowthGui).create(function(opened)
	if opened then
		if inventory.isOpen() then inventory.close() end
		cancelBattle()
	end
	lobby.setSuppressed(opened)
end)
settingsGui=require(script.SettingsGui).create(player,function(opened)
 if opened then
  if inventory.isOpen() then inventory.close() end
  if growthGui.isOpen() then growthGui.close() end
  cancelBattle()
 end
 lobby.setSuppressed(opened or inventory.isOpen() or growthGui.isOpen())
end)
require(script.LobbyTopMenu).create(player,{
 Hero=function()growthGui.open('Stats')end,
 Bag=inventory.open,
 DiamondShop=function()require(script.LobbyMenuBridge):Fire('DiamondShop')end,
 LoginRewards=function()require(script.LobbyMenuBridge):Fire('LoginRewards')end,
 Journal=function()require(script.LobbyMenuBridge):Fire('Quest')end,
 Settings=settingsGui.open,
})

local function updateSessionView()
 local phase=player:GetAttribute('K0SessionPhase')
 if not battle and not startingBattle and (phase=='LoadingTutorial' or phase=='Tutorial' or phase=='Respawning')then
  startingBattle=true
  task.spawn(function()
   require(script.DeepwoodAtmosphere).start()
   battle=require(script.BattleController).start({inventory=inventory,growthGui=growthGui,settingsGui=settingsGui,requestHero=requestHero,snapshot=heroSnapshot})
   startingBattle=false;battle.update(heroSnapshot)
  end)
 elseif battle then battle.update(heroSnapshot)end
end
player:GetAttributeChangedSignal('K0SessionPhase'):Connect(updateSessionView)
updateSessionView()
task.spawn(function()
	local remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
	local requestRemote = remotes and remotes:WaitForChild("K0HeroRequest", 15)
	local responseRemote = remotes and remotes:WaitForChild("K0HeroState", 15)
	if not requestRemote or not requestRemote:IsA("RemoteEvent") or not responseRemote or not responseRemote:IsA("RemoteEvent") then
		lobby.showError("Unavailable")
		return
	end
	heroRequestRemote = requestRemote
	responseRemote.OnClientEvent:Connect(function(value, requestId, errorCode)
		if type(value) ~= "table" or type(value.revision) ~= "number" or value.revision < lastRevision then return end
		if type(value.heroes) ~= "table" then return end
		lastRevision, heroSnapshot = value.revision, value
		if requestId == pendingRequest or errorCode and requestId == nil then
			pendingRequest = nil
			lobby.setBusy(false)
		end
		lobby.setState(value, errorCode)
		if inventory then inventory.refresh() end
		updateSessionView()
	end)
	requestHero("GetState")
end)
