-- The lobby and battle inspect the same field map. All locations are world X/Z.
local Shared = game.ReplicatedStorage.Shared
local Content = require(Shared.CampaignContent)
local Survey = require(Shared.CampaignCartography)
local Access = require(Shared.CampaignAccess)
local Checkpoints = require(Shared.CheckpointTravel)
local Bounds = require(Shared.CampaignBounds)
local Areas = require(Shared.CampaignAreas)
local Progress = require(Shared.DeepwoodProgress)
local Text = require(Shared.K0Text).Map
local Theme = require(script.Parent.TDInventoryTheme)
local Canvas = require(script.Parent.DeepwoodMapCanvas)

local Field = {}

local function unlock(journal, id)
 if not journal or journal.main < 0 then return Text.AreaNoHero end
 if Access.allowed(journal, id) then return nil end
 local chapter = Content.mainChapters[Content.zones[id].requiresMain]
 return chapter and string.format(Text.Unlock, chapter.title) or Text.Locked
end

local function locations(id, journal)
 local z = Content.zones[id]
 local signature = Survey.zones[id].signature
 local spawn = Survey.zones[id].spawn
 local dx, dz = signature.anchor[1] - spawn[1], signature.anchor[2] - spawn[2]
 local bearing = math.floor(math.atan2(dx, -dz) / (math.pi/4) + .5) % 8 + 1
 local places = {{
  category = Text.Surface, title = signature.title, at = signature.anchor,
  note = string.format(Text.LandmarkNote, math.round(math.sqrt(dx*dx+dz*dz)), Text.Directions[bearing]),
 }}
 for _, area in ipairs(z.expansionAreas or {}) do
  local goal = Progress.goal(Content.byId[area.chapterId], area.goalId)
  local done = journal and journal.flags and journal.flags[area.chapterId .. ":" .. area.goalId]
  table.insert(places, {
   category = done and Text.Complete or Text.Incident, title = area.name,
   at = {goal.position[1], goal.position[3]}, note = goal.title,
  })
 end
 for _, edge in ipairs(Access.edges) do
  if edge[1] == id or edge[2] == id then
   local first, last = Bounds.ends(edge)
   local forward = edge[1] == id
   local other = forward and edge[2] or edge[1]
   local mouth = forward and first or last
   local destination = Content.zones[other].name
   table.insert(places, {
    category = Text.Passage, title = string.format(Text.RoadTo, destination),
    at = {mouth[1], mouth[3]}, destination = other,
    note = unlock(journal, other) or string.format(Text.OpenRoad, destination),
   })
  end
 end
 return places
end

function Field.create(parent, onBack, mapState, onTravel)
 local panel = Theme.frame(parent, "RegionFieldMap", UDim2.new(), UDim2.fromScale(1, 1))
 panel.ZIndex = 35
 panel.Active = true
 panel.ClipsDescendants = true
 panel.Visible = false
 local back = Theme.button(panel, "Back", Text.AreaBack, UDim2.fromOffset(8, 6), UDim2.fromOffset(90, 44))
 local kicker = Theme.label(panel, "Epic", "", UDim2.fromOffset(110, 4), UDim2.new(1, -120, 0, 15), 10, Theme.color.gold)
 local title = Theme.label(panel, "Title", "", UDim2.fromOffset(110, 19), UDim2.new(1, -118, 0, 34), 19)
 local chart = Instance.new("Frame")
 chart.Name = "Chart"
 chart.BackgroundColor3 = Theme.color.ink
 chart.ClipsDescendants = true
 chart.BorderSizePixel = 0
 chart.Parent = panel
 local scene = Instance.new("Frame")
 scene.Name = "Survey"
 scene.AnchorPoint = Vector2.new(.5, .5)
 scene.Position = UDim2.fromScale(.5, .5)
 scene.BackgroundTransparency = 1
 scene.Parent = chart
 local north = Theme.label(chart, "North", "N\n↑", UDim2.fromOffset(3, 2), UDim2.fromOffset(25, 38), 12, Theme.color.silver)
 north.ZIndex = 18
 north.TextXAlignment = Enum.TextXAlignment.Center

 local tracked = Theme.label(chart,"TrackedObjective","",UDim2.new(0,5,1,-37),UDim2.new(1,-10,0,34),12,Theme.color.gold)
 tracked.BackgroundColor3 = Theme.color.ink
 tracked.BackgroundTransparency = .12
 tracked.TextXAlignment = Enum.TextXAlignment.Center
 tracked.Visible = false
 tracked.ZIndex = 18

 local info = Instance.new("Frame")
 info.Name = "FieldGuide"
 info.BackgroundColor3 = Color3.fromRGB(18, 32, 42)
 info.BorderSizePixel = 0
 info.Parent = panel
 local status = Theme.label(info, "Access", "", UDim2.fromOffset(10, 1), UDim2.new(1, -20, 0, 34), 11, Theme.color.gold)
 local list = Instance.new("ScrollingFrame")
 list.Name = "Locations"
 list.BackgroundTransparency = 1
 list.BorderSizePixel = 0
 list.ScrollBarThickness = 4
 list.ScrollBarImageColor3 = Theme.color.silver
 list.Position = UDim2.fromOffset(4, 38)
 list.Size = UDim2.new(1, -8, 1, -42)
 list.Parent = info
 local layout = Instance.new("UIListLayout")
 layout.SortOrder = Enum.SortOrder.LayoutOrder
 layout.Padding = UDim.new(0, 3)
 layout.Parent = list
 list.AutomaticCanvasSize = Enum.AutomaticSize.Y
 list.CanvasSize = UDim2.new()

 local atlas, id, places, journal
 local rows = {}
 local chosen
 local open

 local travel
 if onTravel then
  travel = Theme.button(list,"TravelCheckpoint","",UDim2.new(),UDim2.new(1,-5,0,44),true)
  travel.LayoutOrder = 0
  travel.Caption.TextSize = 11
  travel.Activated:Connect(function()
   if panel.Visible and Checkpoints.completed(journal,id) then onTravel(id) end
  end)
 end

 local function resize()
  if not atlas then return end
  local w, h = panel.AbsoluteSize.X, panel.AbsoluteSize.Y
  local top = 56
  local horizontal = w >= 610 or w > h * 1.35
  if horizontal then
   local guideWidth = math.clamp(math.floor(w * .29), 165, 290)
   chart.Position = UDim2.fromOffset(8, top)
   chart.Size = UDim2.new(1, -guideWidth - 20, 1, -top - 8)
   info.Position = UDim2.new(1, -guideWidth - 8, 0, top)
   info.Size = UDim2.new(0, guideWidth, 1, -top - 8)
  else
   local chartHeight = math.floor((h - top - 20) * .49)
   chart.Position = UDim2.fromOffset(8, top)
   chart.Size = UDim2.new(1, -16, 0, chartHeight)
   info.Position = UDim2.fromOffset(8, top + chartHeight + 5)
   info.Size = UDim2.new(1, -16, 1, -top - chartHeight - 13)
  end
  title.TextSize = w < 500 and 15 or 19
  local available = chart.AbsoluteSize
  local width = math.max(1, math.min(available.X - 12, (available.Y - 12) * atlas.aspect))
  scene.Size = UDim2.fromScale(width / math.max(1, available.X), width / atlas.aspect / math.max(1, available.Y))
  atlas.present(width, true)
  atlas.update({journal = journal})
 end

 local function focus(index, scroll)
  chosen = index
  for i, row in ipairs(rows) do
   local active = index == i
   row.button.BackgroundColor3 = active and Color3.fromRGB(47, 64, 67) or Theme.color.navy
   row.number.TextColor3 = active and Theme.color.gold or Theme.color.silver
   row.marker.BackgroundColor3 = active and Theme.color.gold or Theme.color.ink
   row.marker.TextColor3 = active and Theme.color.ink or Theme.color.text
   row.marker.ZIndex = active and 17 or 14
   row.note.Visible = active
   local place = places[i]
   row.visit.Visible = active and place.destination ~= nil
   row.mark.Visible = active and mapState ~= nil and not unlock(journal,id)
   local pinned = mapState and mapState.waypoint
   row.mark.Caption.Text = pinned and pinned.zone == id and pinned.site == i and Text.Unmark or Text.Mark
   local both = row.visit.Visible and row.mark.Visible
   row.visit.Size = UDim2.new(both and .5 or 1,both and -6 or -12,0,44)
   row.mark.Position = UDim2.new(both and .5 or 0,both and 1 or 6,0,83)
   row.mark.Size = row.visit.Size
   row.button.Size = UDim2.new(1, -5, 0, active and ((row.visit.Visible or row.mark.Visible) and 130 or 83) or 46)
  end
  if scroll then
   local y = rows[index].button.AbsolutePosition.Y - list.AbsolutePosition.Y + list.CanvasPosition.Y
   list.CanvasPosition = Vector2.new(0, math.max(0, y))
  end
 end

 local function populate()
  for _, row in ipairs(rows) do row.button:Destroy();row.marker:Destroy() end
  table.clear(rows)
  places = locations(id, journal)
  for index, place in ipairs(places) do
   local p = atlas.project(place.at[1], place.at[2])
   local marker = Instance.new("TextButton")
   marker.Name = "SitePin" .. index
   marker.Text = tostring(index)
   marker.Font = Enum.Font.GothamBold
   marker.TextSize = 13
   marker.AutoLocalize = false
   marker.AnchorPoint = Vector2.new(.5, .5)
   marker.Position = UDim2.fromScale(p.X, p.Y)
   marker.Size = UDim2.fromOffset(23, 23)
   marker.BorderSizePixel = 0
   marker.Parent = scene
   local corner = Instance.new("UICorner")
   corner.CornerRadius = UDim.new(1, 0)
   corner.Parent = marker
   local stroke = Instance.new("UIStroke")
   stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
   stroke.Color = Theme.color.silver
   stroke.Parent = marker
   local button = Instance.new("TextButton")
   button.Name = "Site" .. index
   button.Text = ""
   button.LayoutOrder = index
   button.BorderSizePixel = 0
   button.Parent = list
   local number = Theme.label(button, "Number", tostring(index), UDim2.fromOffset(6, 0), UDim2.fromOffset(24, 44), 15)
   number.TextXAlignment = Enum.TextXAlignment.Center
   local kind = Theme.label(button, "Kind", place.category, UDim2.fromOffset(36, 2), UDim2.new(1, -41, 0, 12), 9, Theme.color.silver)
   local name = Theme.label(button, "Title", place.title, UDim2.fromOffset(36, 14), UDim2.new(1, -42, 0, 31), 12)
   name.Font = Enum.Font.GothamBold
   local note = Theme.label(button, "Note", place.note, UDim2.fromOffset(10, 46), UDim2.new(1, -20, 0, 36), 11)
   local visit = Theme.button(button, "ViewArea", Text.OpenArea, UDim2.fromOffset(5, 83), UDim2.new(1, -12, 0, 44))
   local mark = Theme.button(button, "Pin", Text.Mark, UDim2.fromOffset(6,83), UDim2.new(1,-12,0,44))
   for _,control in ipairs({visit,mark}) do
    control.Caption.TextSize = 11
    control.Caption.Position = UDim2.fromOffset(3,1)
    control.Caption.Size = UDim2.new(1,-6,1,-2)
   end
   mark.Activated:Connect(function()
    if not mapState or unlock(journal,id) then return end
    local pinned = mapState.waypoint
    if pinned and pinned.zone == id and pinned.site == index then mapState.waypoint = nil
    else mapState.waypoint = {zone=id,site=index,position=Vector3.new(place.at[1],0,place.at[2])} end
    focus(index,false)
   end)
   visit.Activated:Connect(function() if place.destination then open(place.destination, journal) end end)
   button.Activated:Connect(function() focus(index, false) end)
   marker.Activated:Connect(function() focus(index, true) end)
   rows[index] = {button = button, number = number, marker = marker, note = note, visit = visit, mark = mark, kind = kind}
  end
 end

 local function refreshStatus()
  local z = Content.zones[id]
  local row = atlas.rows[id]
  local percent = row.name:GetAttribute("ExploredPercent") or 0
  local completed = Checkpoints.completed(journal,id)
  if travel then
   Theme.enabled(travel,completed)
   travel.Caption.Text = completed and Checkpoints.text.checkpoint or Checkpoints.text.locked
  end
  status.Text = unlock(journal, id) or string.format(Text.FieldSub,
   completed and Text.Complete or Text.AreaOpen, string.format(Text.AreaExplore, percent))
  title.Text = z.name
  kicker.Text = string.format(Text.FieldTitle, Content.epics[z.epic].region:upper())
 end

 open = function(region, snapshot)
  if not Content.zones[region] then return end
  id, journal = region, snapshot
  tracked.Visible = false
  for _, row in ipairs(rows) do row.button:Destroy() end
  table.clear(rows)
  scene:ClearAllChildren()
  atlas = Canvas.create(scene, id, false)
  panel.Visible = true
  resize()
  populate()
  focus(1, false)
  list.CanvasPosition = Vector2.zero
  refreshStatus()
 end
 local function close()
  if not panel.Visible then return end
  panel.Visible = false
  scene:ClearAllChildren()
  for _, row in ipairs(rows) do row.button:Destroy() end
  table.clear(rows)
  atlas, id = nil, nil
 end
 back.Activated:Connect(function() local last = id;close();onBack(last) end)
 panel:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
 chart:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
 return {panel = panel, open = open, close = close, focus = focus, update = function(snapshot, root, target, party)
  if not atlas then return end
  local changed = journal ~= snapshot
  journal = snapshot
  local function inside(position) return Areas.containsZone(Content.zones[id], position.X, position.Z) end
  local goal = target and inside(target) and target
  local pin = mapState and mapState.waypoint
  atlas.update({journal = journal}, root and inside(root.Position) and root, goal, party, pin and pin.zone == id and pin)
  tracked.Visible = goal ~= nil and goal ~= false
  if tracked.Visible then tracked.Text = string.format(Text.TrackedObjective, mapState and mapState.targetTitle or Text.ActiveObjective) end
  if changed then
   refreshStatus()
   local nextPlaces = locations(id, journal)
   for i, place in ipairs(nextPlaces) do rows[i].kind.Text = place.category;rows[i].note.Text = place.note end
   places = nextPlaces
   focus(chosen, false)
  end
 end}
end

return Field
