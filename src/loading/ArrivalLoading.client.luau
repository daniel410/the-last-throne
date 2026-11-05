-- This must run in ReplicatedFirst: StarterPlayerScripts starts too late to
-- conceal the arrival platform between teleport and expedition admission.
local Players = game:GetService('Players')
local Teleport = game:GetService('TeleportService')
local First = game:GetService('ReplicatedFirst')
local Run = game:GetService('RunService')
local player = Players.LocalPlayer
local role = require(script.Parent:WaitForChild('PlaceRole')).resolve(
 game.PlaceId, Run:IsStudio(), workspace:GetAttribute('TLTStudioRole'))
local ok, arriving = pcall(function() return Teleport:GetArrivingTeleportGui() end)
if not ok then arriving = nil end
if role ~= 'Battle' and not arriving then return end

local gui = arriving or require(script.Parent:WaitForChild('TravelLoadingScreen')).create(1)
gui.Name = 'ArrivalLoadingScreen'
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 10000
gui.Enabled = true
gui.Parent = player:WaitForChild('PlayerGui')
-- Install our opaque cover before removing Roblox's loading screen.
First:RemoveDefaultLoadingScreen()

local function ready()
 local phase = player:GetAttribute('K0SessionPhase')
 if role == 'Battle' then
  if phase ~= 'Tutorial' or workspace:GetAttribute('TLTCombatReady') ~= true
   or player:GetAttribute('TLTBattleClientReady') ~= true
   or player:GetAttribute('TLTTravelLock') == true then return end
 elseif phase ~= 'Lobby' then return end
 local character = player.Character
 if not character or not character:IsDescendantOf(workspace)
  or character:GetAttribute('K0SpawnReady') ~= true then return end
 local root = character:FindFirstChild('HumanoidRootPart')
 local human = character:FindFirstChildOfClass('Humanoid')
 local camera = workspace.CurrentCamera
 if not root or not human or human.Health <= 0 or player.GameplayPaused
  or not camera or camera.CameraSubject ~= human
  or camera.CameraType ~= Enum.CameraType.Custom
  or (camera.Focus.Position - root.Position).Magnitude > 16 then return end
 -- A server-ready character does not mean its destination has streamed locally.
 local params = RaycastParams.new()
 params.FilterType = Enum.RaycastFilterType.Exclude
 local excluded = {character}
 for _, name in ipairs({'BattleArrival', 'Baseplate'}) do
  local instance = workspace:FindFirstChild(name)
  if instance then table.insert(excluded, instance) end
 end
 params.FilterDescendantsInstances = excluded
 params.RespectCanCollide = true
 if not workspace:Raycast(root.Position, Vector3.new(0, -32, 0), params) then return end
 return character, root
end

-- Stream around the final spawn, never the temporary arrival platform. Streaming
-- completion alone is not proof of readiness; the rendered-world gate still runs.
local streamingCharacter, streamingPosition, streamingComplete
local stableFrames = 0
while gui.Parent do
 Run.RenderStepped:Wait()
 local character, root = ready()
 if character then
  if character ~= streamingCharacter or (root.Position - streamingPosition).Magnitude > 16 then
   streamingCharacter, streamingPosition, streamingComplete = character, root.Position, false
   local position = streamingPosition
   task.spawn(function()
    local streamed = true
    if workspace.StreamingEnabled then
     streamed = pcall(function() player:RequestStreamAroundAsync(position, 5) end)
    end
    if streamingCharacter == character and streamingPosition == position then
     streamingComplete = streamed
     if not streamed then streamingCharacter = nil end
    end
   end)
   stableFrames = 0
  elseif streamingComplete then
   stableFrames = stableFrames + 1
   -- Allow camera and destination geometry to render behind the cover, and
   -- recheck every frame so death/replacement/late admission cannot reveal it.
   if stableFrames >= 3 then gui:Destroy(); break end
  end
 else
  stableFrames = 0
 end
end
