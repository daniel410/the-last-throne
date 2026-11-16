-- Short, world-space brush strokes for hero releases and confirmed contacts.
-- Control points are in attack space. Trim the same cubic from its head and
-- tail so the mark is drawn and lifted, even at an irregular frame rate.
local Palette = require(game:GetService("ReplicatedStorage").Shared.CombatVFXPalette)
local Profiles = require(script.Parent.SkillVFXProfiles)
local Style = require(script.Parent.CombatVFXStyle)
local Touch = game:GetService("UserInputService")

local Strokes = {}
local v = Vector3.new
-- Each brush has its own pressure, tint and centre line from heel to tip.
local brushes = {
	Sweep = {.40, v(-1.3,.22,.35), v(-1.1,.25,-1.25), v(.8,-.16,-1.4), v(1.25,-.25,-.18)},
	Cleave = {.50, v(-.18,1.45,.25), v(-.08,1.4,-1.1), v(.12,-.8,-1.35), v(.23,-1.1,-.35)},
	Rising = {.36, v(.40,-1.05,.24), v(.32,-1.18,-1.25), v(-.22,1.05,-1.3), v(-.55,1.35,-.16)},
	Thrust = {.22, v(-.13,.1,.9), v(-.16,.18,.45), v(.06,.02,-.9), v(0,0,-1.55)},
	Fletching = {.27, v(-.52,.22,.55), v(-.31,.2,-.35), v(.05,.07,-1.1), v(0,0,-1.95)},
	Guard = {.32, v(-.9,-.6,.25), v(-1.1,.52,-.24), v(-.36,1.05,-.12), v(.1,.92,0)},
	Updraft = {.64, v(-.45,-.45,.1), v(.47,.15,-.35), v(-.62,.9,-.2), v(.16,1.55,-.45)},
	Crest = {.44, v(-.95,-.2,.05), v(-.35,.82,-.28), v(.63,.68,-.22), v(1.12,-.13,-.44)},
	Fracture = {.24, v(-.05,0,.12), v(-.33,.37,-.45), v(-.34,.8,-.68), v(-.72,1.05,-.86)},
	Inward = {.30, v(-1.16,.12,.28), v(-1.05,.8,-.55), v(.28,.53,-.68), v(0,0,0)},
	Fall = {.21, v(-.45,1.65,.12), v(-.35,1.03,-.1), v(-.04,.17,-.2), v(0,-.3,-.22)},
	Branch = {.28, v(0,-.38,.15), v(-.45,.05,.09), v(-.12,.64,-.32), v(-.76,.92,-.4)},
	Discharge = {.13, v(-.76,.5,.2), v(-.24,.48,-.23), v(-.74,-.22,-.65), v(.45,-.34,-1.1)},
}
local byShape = {
	thrust="Thrust", bullet="Thrust", arrow="Fletching", fan="Fletching", wind="Fletching",
	spin="Sweep", cross="Sweep", counter="Sweep", slash="Sweep", crescent="Sweep", areslash="Sweep", low="Sweep", axe="Sweep",
	cleave="Cleave", guard="Guard", ward="Guard", warcry="Crest", holy="Updraft",
	earth="Fracture", stone="Fracture", frost="Fracture", lava="Updraft", fire="Updraft", blast="Updraft",
	ash="Fall", rain="Fall", mortar="Fall", hail="Fall", vine="Branch", water="Crest", steam="Updraft",
	lightning="Discharge", gravity="Inward", arcane="Inward",
}
local contact = {
	steel="Sweep", axe="Cleave", arrow="Thrust", gun="Thrust", shield="Guard", bomb="Fracture",
	holy="Updraft", fire="Updraft", water="Crest", frost="Fracture", lightning="Discharge",
	earth="Fracture", nature="Branch", arcane="Inward", gravity="Inward", wind="Fletching",
}
local basic = {knight={"Cleave","Rising","Sweep"}, dwarf={"Cleave","Sweep","Sweep"}, elf={"Fletching"}, mage={"Sweep"}}
local twin = {Fletching=true, Guard=true, Inward=true, Crest=true, Branch=true, Fracture=true}
local smoke = "rbxasset://textures/particles/smoke_main.dds"
local glow = "rbxasset://textures/glow.png"
local bodyMask = NumberSequence.new({
	NumberSequenceKeypoint.new(0,.97), NumberSequenceKeypoint.new(.32,.38),
	NumberSequenceKeypoint.new(.74,.08), NumberSequenceKeypoint.new(1,.88),
})
local edgeMask = NumberSequence.new({
	NumberSequenceKeypoint.new(0,.94), NumberSequenceKeypoint.new(.68,.24), NumberSequenceKeypoint.new(1,.6),
})

local function cubic(p, t)
	local a, b, c = p[1]:Lerp(p[2],t), p[2]:Lerp(p[3],t), p[3]:Lerp(p[4],t)
	local left, right = a:Lerp(b,t), b:Lerp(c,t)
	return left:Lerp(right,t), (right-left)*3
end

local function strip(holder, points, width, color, hot, texture, delay)
	local a, b = Instance.new("Attachment"), Instance.new("Attachment")
	a.Parent, b.Parent = holder, holder
	local body = Instance.new("Beam")
	body.Name = "MaterialWake"
	body.Attachment0, body.Attachment1 = a, b
	body.FaceCamera, body.Segments = true, 8
	body.Texture, body.TextureMode, body.TextureSpeed = texture, Enum.TextureMode.Stretch, 0
	body.LightEmission, body.LightInfluence = .78, .15
	body.Color = ColorSequence.new(color:Lerp(Color3.new(),.40), color)
	body.Transparency = bodyMask
	body.Parent = holder

	local edge = body:Clone()
	edge.Name, edge.Texture = "LeadingFilament", ""
	edge.Transparency, edge.LightEmission, edge.LightInfluence = edgeMask, .94, .05
	edge.Color = ColorSequence.new(color, color:Lerp(hot,.50))
	edge.Parent = holder
	return {points=points, a=a, b=b, body=body, edge=edge, width=width, delay=delay}
end

function Strokes.mount(holder, row, direction, size, phase, beat, weaponSocket)
	local profile = row.definition and Profiles.get(row.definition.id)
	local combo = basic[row.classId]
	local kind = profile and byShape[profile.shape] or combo[beat] or combo[1]
	if phase=="Contact" then
		kind = contact[row.key] or kind
		if row.classId=="dwarf" and row.key=="steel" then kind="Cleave" end
	end
	local brush = brushes[kind]
	local color, hot = Palette.get(row.key,row.classId)
	local scale = math.clamp(size*.78,.45,2.8)
	local directionUp = math.abs(direction.Y)>.98 and Vector3.zAxis or Vector3.yAxis
	holder.CFrame = CFrame.lookAt(holder.Position,holder.Position+direction,directionUp)
	local lanes = twin[kind] and 2 or 1
	if profile and profile.signature and not Touch.TouchEnabled then lanes=3 end
	local width = brush[1] * scale * (profile and math.clamp(profile.width/.18,.7,1.45) or 1)
	local texture = (kind=="Updraft" or kind=="Fracture" or kind=="Crest") and smoke or glow
	local result = {}
	for i=1,lanes do
		local side = i==2 and -1 or 1
		local angle = i==3 and math.rad(65) or 0
		if beat%2==0 and kind=="Sweep" then side=-side end
		local rotation = CFrame.Angles(0,angle,kind=="Sweep" and (beat==3 and -.15 or .24) or 0)
		local points = {}
		for j=1,4 do
			local p = brush[j+1]
			if weaponSocket then
				-- Leave the newest edge on the blade. A bow wake starts at the nock.
				p -= kind=="Fletching" and brush[2] or brush[5]
			end
			points[j] = rotation:VectorToWorldSpace(v(p.X*side,p.Y,p.Z)) * scale * (i==1 and 1 or .76)
		end
		result[i] = strip(holder,points,width*(i==1 and 1 or .68),color,hot,texture,(i-1)*.055)
	end
	holder:SetAttribute("HeroBrush",kind)
	return result
end

function Strokes.step(strokes, progress)
	for _,s in ipairs(strokes) do
		local t = math.clamp((progress-s.delay)/(1-s.delay),0,1)
		local head = .16+.84*(1-(1-math.min(1,t/.62))^2)
		local tail = math.clamp((t-.17)/.83,0,1)^1.35
		local first, da = cubic(s.points,tail)
		local last, db = cubic(s.points,head)
		s.a.CFrame, s.b.CFrame = Style.frame(first,da), Style.frame(last,db)
		local fraction = (head-tail)/3
		local width = s.width * (1-t^1.7)
		s.body.CurveSize0, s.body.CurveSize1 = da.Magnitude*fraction, db.Magnitude*fraction
		s.edge.CurveSize0, s.edge.CurveSize1 = s.body.CurveSize0, s.body.CurveSize1
		s.body.Width0, s.body.Width1 = width*.38, width*1.8
		s.edge.Width0, s.edge.Width1 = width*.075, width*.35
	end
end
return Strokes
