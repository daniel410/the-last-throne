assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local existingWorld = require(game.ServerScriptService.Server.World.CampaignWorld).create()
local shots = {}
for _, row in ipairs({
    {id = 'FV-04_close', name = 'EastArchiveConduitBed', theme = 'FrozenVale',
        eye = Vector3.new(10, 9, -16), aim = Vector3.new(0, 1, 0)},
    {id = 'HG-03_front', name = 'KeeperDrainCulvert', theme = 'HauntedGraveyard',
        eye = Vector3.new(-12, 8, -26), aim = Vector3.new(0, 4, 0)},
}) do
    local model = assert(existingWorld.folder:FindFirstChild(row.name, true), row.name)
    local pivot = model:GetPivot()
    local eye = pivot:PointToWorldSpace(row.eye)
    local aim = pivot:PointToWorldSpace(row.aim)
    table.insert(shots, {
        id = row.id, theme = row.theme, origin = {eye.X, eye.Y, eye.Z}, aim = {aim.X, aim.Y, aim.Z},
    })
end
local cameraPlan = game.HttpService:JSONEncode(shots)
