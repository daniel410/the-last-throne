-- Isolated Edit scene only. Set _G.ECReviewGoal to a chapter goal id before running.
-- This is a repeatable orbit approximation, not a live player camera/input test.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, 'isolated local scene required')
local Shared = game.ReplicatedStorage.Shared
local Content = require(Shared.CampaignContent)
local Bounds = require(Shared.CampaignBounds)
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Navigation = require(Client.DeepwoodNavigation)
local AdventureCamera = require(Client.AdventureCamera)
local world = assert(workspace:FindFirstChild('DeepwoodCampaign'), 'generate EC world first')
local chapter
for _, c in ipairs(Content.chapters) do if c.id == 'EC-03' then chapter = c end end
assert(chapter)
local goal, previous
for i, g in ipairs(chapter.goals) do
 if g.id == (_G.ECReviewGoal or 'supports') then
  goal = g
  previous = chapter.goals[math.max(1, i - 1)]
 end
end
assert(goal, 'unknown EC-03 goal')
local function vector(p) return Vector3.new(table.unpack(p)) end
local target = vector(goal.position)
local route = Navigation.route(vector(previous.position), target)
assert(#route >= 2, 'approach route missing')
-- Walk backward along the actual guidance polyline, rather than cutting a corner.
local approach = target
local remaining = 20
for i = #route - 1, 1, -1 do
 local delta = route[i] - approach
 local flat = Vector3.new(delta.X, 0, delta.Z)
 if flat.Magnitude >= remaining then
  approach += flat.Unit * remaining
  remaining = 0
  break
 end
 remaining -= flat.Magnitude
 approach = route[i]
end
assert(remaining == 0, 'approach route too short')
local geometry = {workspace.Terrain}
for _, name in ipairs({'TerrainBlockout', 'GroundedForest'}) do
 local folder = world:FindFirstChild(name)
 if folder then table.insert(geometry, folder) end
end
local floor = assert(Bounds.surface(approach.X, approach.Z), 'unsupported approach')
local focus = Vector3.new(approach.X, floor + 4.5, approach.Z)
local heading = Vector3.new(target.X - focus.X, 0, target.Z - focus.Z).Unit
local distance = 24
assert(distance >= AdventureCamera.min and distance <= AdventureCamera.max)
local desired = focus - heading * (distance * math.cos(math.rad(30))) + Vector3.new(0, distance * .5, 0)
local camera = workspace.CurrentCamera
_G.ECReviewOriginalCamera = _G.ECReviewOriginalCamera or {cframe=camera.CFrame, focus=camera.Focus, kind=camera.CameraType}
camera.CameraType = Enum.CameraType.Scriptable
local expected = AdventureCamera.constrain(focus, desired, geometry)
camera.CFrame = expected
camera.Focus = CFrame.new(focus)
task.wait(3) -- settling opportunity only; does not prove Terrain render completion
assert((camera.CFrame.Position - expected.Position).Magnitude < .01, 'camera moved')
assert(camera.CFrame.LookVector:Dot(expected.LookVector) > .99999, 'camera rotated')
-- Studio may switch Scriptable to Fixed and normalize Focus distance; record it.
local point = target + Vector3.new(0, 3, 0)
local screen, inFrame = camera:WorldToViewportPoint(point)
local ray = RaycastParams.new()
ray.FilterType = Enum.RaycastFilterType.Include
ray.FilterDescendantsInstances = {world, workspace.Terrain}
ray.RespectCanCollide = true
local hit = workspace:Raycast(expected.Position, point - expected.Position, ray)
local function xyz(v) return {v.X, v.Y, v.Z} end
local result = {goal=goal.id, approach=xyz(approach), target=xyz(point), camera=xyz(expected.Position),
 requestedFocus=xyz(focus), observedFocus=xyz(camera.Focus.Position), cameraType=tostring(camera.CameraType), viewport=xyz(screen), inFrame=inFrame, viewportSize=xyz(Vector3.new(camera.ViewportSize.X,camera.ViewportSize.Y,0)),
 desiredDistance=distance, actualDistance=(expected.Position-focus).Magnitude,
 firstSolid=hit and hit.Instance:GetFullName(), hitDistance=hit and hit.Distance,
 note='Edit orbit approximation; no hero, input, HUD, NPC projection or combat acceptance'}
_G.ECReviewResults = _G.ECReviewResults or {}
_G.ECReviewResults[goal.id] = result
return result
