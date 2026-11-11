-- The throne remains in Dawnspire throughout the story; its heart is personal.
local A = require(script.Parent.LobbyArchitecture)
local Design = require(game.ReplicatedStorage.Shared.DawnspireDesign)
local C = A.color
local V = Vector3.new
local T = {}

function T.create(lobby)
 local throne = Instance.new('Model')
 throne.Name = 'DawnspireThrone'
 throne.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
 throne:SetAttribute('DawnspireThrone', true)
 throne:SetAttribute('ThroneSource', 'TDLobbyRoyalChair')
 local origin = lobby.origin + Design.throneOffset
 throne:SetAttribute('HeartPosition', origin + Design.heartOffset)
 local make = A.builder(throne, origin)
 local sourceChair = require(game.ReplicatedStorage.Shared.TDLobbyThroneGeometry)
 -- Shallow steps provide a walkable approach without a jump requirement.
 for i = 1, 8 do
  make('SanctuaryStep' .. i, V(36 - i * 1.75, .225, 40 - i * 2.5), V(0, i * .225 - .1125, 0), C.pale, Enum.Material.Marble, true)
 end
 make('SanctuaryRunner', V(7, .04, 22), V(0, 1.82, 0), C.blue, Enum.Material.Fabric)
 for _, x in ipairs({-4, 4}) do
  make('RunnerTrim', V(.16, .05, 22), V(x, 1.84, 0), C.gold, Enum.Material.Metal)
 end
 -- Exact TD lobby chair coordinates, lowered from its source terrace onto this dais.
 sourceChair.build(throne, origin + V(0, -16.6, 116))
 for _, side in ipairs({-1, 1}) do
  make('SanctuaryColumnFoot', V(6, 1, 6), V(side * 20, .5, -4), C.dark, Enum.Material.Slate)
  make('SanctuaryColumn', V(3, 29, 3), V(side * 20, 15, -4), C.pale, Enum.Material.Marble)
  make('SanctuaryCapital', V(5, .8, 5), V(side * 20, 29.5, -4), C.gold, Enum.Material.Metal)
  make('SanctuaryBanner', V(4, 10, .25), V(side * 25, 12, -8), C.blue, Enum.Material.Fabric)
  A.crown(make, V(side * 25, 13, -7.8), .8)
 end
 -- An open arch frames the throne, leaving the sky visible above the plaza.
 for i = 0, 16 do
  local angle = i * math.pi / 16
  make('SanctuaryArch', V(4.4, 2.4, 3), V(math.cos(angle) * 20, 29.5 + math.sin(angle) * 13, -4), C.pale, Enum.Material.Marble, false, CFrame.Angles(0, 0, math.atan2(13 * math.cos(angle), -20 * math.sin(angle))))
 end
 A.crown(make, V(0, 43.5, -3.5), 2)
 -- The open crown cradle makes the theft visible before the final clear.
 make('HeartPedestal', V(4, 1, 4), V(0, 2, 12), C.pale, Enum.Material.Marble)
 for i = 0, 5 do
  local angle = i * math.pi / 3
  make('EmptyHeartCradle', V(.45, 2, .45), V(math.cos(angle) * 1.6, 3.1, 12 + math.sin(angle) * 1.6), C.gold, Enum.Material.Metal, false, CFrame.Angles(0, 0, -.15 * math.cos(angle)))
 end
 local sign = make('ThroneStorySign', V(24, 3.5, .4), V(0, 2.8, 19), C.dark, Enum.Material.Slate)
 A.sign(sign, {title=Design.text.title, subtitle=Design.text.missing, key='lobby.throne'})
 throne.Parent = lobby.folder
 return throne
end
return T
