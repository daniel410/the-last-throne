-- Presentation only. Free Creator Store provenance is pinned in assets/audio/combat-store-v1.
local FXCatalog = require(script.Parent.PixelFXCatalog)
local Catalog = {}
-- User-requested rollback to the pre-0.76.0 contact sounds. Those paths had
-- no release layer; preserve their original volume, pitch and falloff.
local legacyKnightImpact = {id = "rbxasset://sounds/action_jump_land.mp3", volume = .15, speed = 1.35, duration = 1.2, fixedPitch = true, maxDistance = 70}
local legacyMageImpact = {id = "rbxasset://sounds/impact_water.mp3", volume = .12, speed = 1.25, duration = 1.2, fixedPitch = true, maxDistance = 70}
local function clip(id, volume, speed, duration)
    return {id = "rbxassetid://" .. id, volume = volume, speed = speed or 1, duration = duration or 1.2}
end
local swing = clip("9125959472", .18, 1.65, .75)
local heavySwing = clip("9125959472", .22, 1.25, .95)
local steel = clip("9119744718", .22, 1.05, .65)
local shield = clip("9119072660", .25, 1, .85)
local thud = clip("9118598279", .26, .9, .65)
local bow = clip("7258329846", .20, 1, .85)
local magic = clip("9125648149", .18, 1, .8)
local chime = clip("9116395089", .16, 1.2, 1.1)
local water = clip("9125703168", .23, 1.1, .85)
local fire = clip("9117988736", .23, 1.05, 1.1)
local frost = clip("9114855626", .20, 1.1, 1.3)
local zap = clip("9114277757", .18, 1.15, 1)
local gun = clip("9113852810", .20, 1.1, .8)
Catalog.profiles = {
    steel = {release = swing, impact = steel},
    axe = {release = heavySwing, impact = thud},
    shield = {release = heavySwing, impact = shield},
    arrow = {release = bow, impact = thud},
    arcane = {release = magic, impact = chime},
    gravity = {release = clip("9125648149", .22, .7, 1.1), impact = thud},
    wind = {release = magic, impact = magic},
    holy = {release = chime, impact = chime},
    nature = {release = bow, impact = chime},
    water = {release = magic, impact = water},
    fire = {release = fire, impact = fire},
    frost = {release = magic, impact = frost},
    lightning = {release = zap, impact = zap},
    earth = {release = heavySwing, impact = thud},
    gun = {release = gun, impact = steel},
    bomb = {release = heavySwing, impact = clip("9118598279", .30, .65, .85)},
}
function Catalog.get(classId, skillId, kind)
    local row = FXCatalog.get(classId, skillId)
    if not row or (kind ~= "release" and kind ~= "impact") then return nil end
    if classId == "knight" and not row.definition then
        return kind == "impact" and legacyKnightImpact or nil
    end
    if classId == "mage" and row.definition then
        return kind == "impact" and legacyMageImpact or nil
    end
    local key = row.key
    -- Physical axe descendants and common ground attacks keep a heavy contact.
    if row.effect == "earth" or skillId == "dwarf.common.ground" then key = "earth"
    elseif classId == "dwarf" and key == "steel" then key = "axe" end
    if classId == "mage" and not row.definition then
        return kind == "release" and swing or thud
    end
    local profile = Catalog.profiles[key]
    return profile and profile[kind] or nil
end
return Catalog
