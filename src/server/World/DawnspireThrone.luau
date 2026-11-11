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
 local origin = lobby.origin + Design.throneOffset
 throne:SetAttribute('HeartPosition', origin + Design.heartOffset)
 local make = A.builder(throne, origin)
 local crystal = Color3.fromRGB(145, 199, 218)
 -- Shallow steps provide a walkable approach without a jump requirement.
 for i = 1, 4 do
  make('SanctuaryStep' .. i, V(34 - i * 2, .35, 30 - i * 3), V(0, i * .35 - .175, 0), C.pale, Enum.Material.Marble, true)
 end
 make('SanctuaryRunner', V(7, .04, 22), V(0, 1.42, 0), C.blue, Enum.Material.Fabric)
 for _, x in ipairs({-4, 4}) do
  make('RunnerTrim', V(.16, .05, 22), V(x, 1.44, 0), C.gold, Enum.Material.Metal)
 end
 make('ThronePlinth', V(15, .65, 11), V(0, 1.725, -2), C.dark, Enum.Material.Slate, true)
 make('ThroneSeat', V(10, 1.1, 7), V(0, 4, -2), crystal, Enum.Material.Glass)
 make('ThroneBack', V(10, 12, 1.5), V(0, 9, -5.5), crystal, Enum.Material.Glass)
 make('BackInlay', V(6, 10, .25), V(0, 9, -4.6), C.blue, Enum.Material.Marble)
 for _, side in ipairs({-1, 1}) do
  make('ThroneLeg', V(1.3, 2.5, 6), V(side * 4.3, 2.7, -2), C.pale, Enum.Material.Marble)
  make('ThroneArm', V(1.8, 1, 8), V(side * 5.5, 6, -1.8), C.gold, Enum.Material.Metal)
  make('CrystalSpire', V(1.5, 15, 1.5), V(side * 6, 10, -5.5), crystal, Enum.Material.Glass, false, CFrame.Angles(0, 0, side * -.08))
  make('SanctuaryColumnFoot', V(6, 1, 6), V(side * 20, .5, -4), C.dark, Enum.Material.Slate)
  make('SanctuaryColumn', V(3, 19, 3), V(side * 20, 10, -4), C.pale, Enum.Material.Marble)
  make('SanctuaryCapital', V(5, .8, 5), V(side * 20, 19.5, -4), C.gold, Enum.Material.Metal)
  make('SanctuaryBanner', V(4, 10, .25), V(side * 25, 12, -8), C.blue, Enum.Material.Fabric)
  A.crown(make, V(side * 25, 13, -7.8), .8)
 end
 -- An open arch frames the throne, leaving the sky visible above the plaza.
 for i = 0, 16 do
  local angle = i * math.pi / 16
  make('SanctuaryArch', V(4.4, 2.4, 3), V(math.cos(angle) * 20, 19.5 + math.sin(angle) * 9, -4), C.pale, Enum.Material.Marble, false, CFrame.Angles(0, 0, math.atan2(9 * math.cos(angle), -20 * math.sin(angle))))
 end
 A.crown(make, V(0, 29, -3.5), 2)
 -- The open crown cradle makes the theft visible before the final clear.
 make('HeartPedestal', V(4, 1, 4), V(0, 6.1, 1), C.pale, Enum.Material.Marble)
 for i = 0, 5 do
  local angle = i * math.pi / 3
  make('EmptyHeartCradle', V(.45, 2, .45), V(math.cos(angle) * 1.6, 7.2, 1 + math.sin(angle) * 1.6), C.gold, Enum.Material.Metal, false, CFrame.Angles(0, 0, -.15 * math.cos(angle)))
 end
 local sign = make('ThroneStorySign', V(24, 3.5, .4), V(0, 3.2, 12), C.dark, Enum.Material.Slate)
 A.sign(sign, {title=Design.text.title, subtitle=Design.text.missing, key='lobby.throne'})
 throne.Parent = lobby.folder
 return throne
end
return T
