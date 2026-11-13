-- Pure presentation lookup. Never changes a skill definition, hit, cooldown or resource.
local Config = require(script.Parent.K0Config)
local Presentation = require(script.Parent.SkillPresentation)
local Catalog = { byId = {}, basic = {knight="steel", dwarf="axe", elf="arrow", mage="arcane"} }
local elements = {steel="steel",holy="holy",gun="gun",bomb="bomb",shell="bomb",nature="nature",fire="fire",earth="earth",water="water",frost="frost",lightning="lightning",wind="wind",arcane="arcane"}
local effects = {slash="steel",shield="shield",taunt="holy",axe="axe",bullet="gun",bomb="bomb",shell="bomb",arrow="arrow",rain="arrow",vine="nature",steam="water",lava="fire",ash="fire",hail="frost",gravity="gravity"}
for classId, list in pairs(Config.Skills) do
 for _, d in ipairs(list) do
  local p = assert(Presentation.get(d), "PixelFX presentation missing: " .. d.id)
  local key = elements[d.element] or effects[p.effect] or p.effect
  if p.effect == "shield" and d.element ~= "holy" then key="shield" end
  if p.effect == "gravity" then key="gravity" end
  if p.effect == "arrow" and (d.element=="steel" or not d.element) then key="arrow" end
  if p.effect == "axe" and (d.element=="steel" or not d.element) then key="axe" end
  Catalog.byId[d.id] = {classId=classId, key=key, definition=d, effect=p.effect}
 end
end
function Catalog.get(classId, id)
 if id == nil or id == "" then
  local key=Catalog.basic[classId]
  return key and {classId=classId,key=key} or nil
 end
 local row=Catalog.byId[id]
 return row and row.classId==classId and row or nil
end
-- Timing follows accepted server attributes. Late stream-in never replays a backlog.
function Catalog.beat(d, age)
 local contact=d.windup+(d.hitDelay or 0)
 if age<contact then return 0,0 end
 local interval=d.shotInterval or d.interval or .3
 local count=d.shotCount or d.pulses or 1
 local index=math.floor((age-contact)/interval)+1
 if index>count then return 0,0 end
 local late=age-contact-(index-1)*interval
 if late>.15 then return 0,late end
 return index,late
end
return Catalog
