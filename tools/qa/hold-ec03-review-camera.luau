-- Run only in an isolated Edit QA place. Capture WITHOUT camera overrides
-- after status becomes ready; temporary camera captures can show coarse Terrain.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, 'isolated Edit QA required')
local camera = assert(workspace.CurrentCamera)
_G.EC03ReviewCamera = {status = 'settling'}
camera.CameraType = Enum.CameraType.Scriptable
camera.CFrame = CFrame.lookAt(
 Vector3.new(345.99094, 170.41486, -12556.67578),
 Vector3.new(404.52621, 149.41486, -12538.74219))
camera.Focus = CFrame.new(404.52621, 149.41486, -12538.74219)
local expected = camera.CFrame
local expectedFocus = camera.Focus
local started = os.clock()
task.delay(3, function()
 _G.EC03ReviewCamera = {
  status = (camera.CFrame.Position - expected.Position).Magnitude < .01 and camera.CFrame.LookVector:Dot(expected.LookVector) > .99999 and (camera.Focus.Position - expectedFocus.Position).Magnitude < .01 and 'ready' or 'camera-moved',
  elapsed = os.clock() - started,
  position = tostring(camera.CFrame.Position), focus = tostring(camera.Focus.Position),
  fieldOfView = camera.FieldOfView,
 }
end)
return 'settling; inspect _G.EC03ReviewCamera before capture; confirm successive frames visually'
