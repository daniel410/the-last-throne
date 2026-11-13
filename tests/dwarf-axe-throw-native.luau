-- Isolated engine fixture: spinning mesh, curved flight and visibility cleanup.
local A = require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local source = game.StarterPlayer.StarterPlayerScripts.Client.K0SwordVisual
local copy = source:Clone()
copy.Name = "AxeThrowVisualQA"
copy.Source = copy.Source:gsub("return Visual%s*$", "Visual.advanceSpellsQA = advanceSpells\nreturn Visual")
copy.Parent = source.Parent
local V = require(copy)
local FX=require(source.Parent.HeroVFX)
local originalSkill=FX.skill
local lateAxeEffects=0
FX.skill=function(character,id,...)
 if id=='dwarf.common.throw'then lateAxeEffects+=1;return end
 return originalSkill(character,id,...)
end
local checks, seq = 0, 0
local function check(value, label) checks += 1; assert(value, label) end
local function send(c, distance)
	seq += 1
	local p = c.HumanoidRootPart.Position
	c:SetAttribute("K0SpellVisual", string.format("%d|%.3f|%.3f|%.3f|%.3f|%.3f|%.3f", seq, p.X, p.Y, p.Z, p.X, p.Y, p.Z - distance))
	V.renderCharacter(c, 1/60)
	return workspace:FindFirstChild("K0VisualThrownAxe")
end
for _, rig in ipairs({ Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15 }) do
	local desc = Instance.new("HumanoidDescription")
	local c = game.Players:CreateHumanoidModelFromDescriptionAsync(desc, rig)
	desc:Destroy()
	c.Parent = workspace; c:PivotTo(CFrame.new(0, 500, 0))
	c:SetAttribute("K0ClassId", "dwarf"); c:SetAttribute("K0SkillId", "dwarf.common.throw")
	local model = Instance.new("Model"); model.Parent = c
	assert(A.attachInto(model, c, "dwarf"))
	local held, root = model.Weapon, c.HumanoidRootPart
	local original = root.CFrame
	held.LocalTransparencyModifier = 0.2
	for _, distance in ipairs({ 10, 32 }) do
		for _, dt in ipairs({ 1/30, 1/144 }) do
			local release = held.CFrame
			local axe = assert(send(c, distance))
			check(axe.MeshId == held.MeshId and axe.CFrame:FuzzyEq(release, .0001), "actual axe mesh releases continuously from hand")
			check(held.LocalTransparencyModifier == 1 and axe.LocalTransparencyModifier == 0, "one visible axe while airborne")
			check(axe.Anchored and not axe.CanCollide and not axe.CanTouch and not axe.CanQuery, "visual has no collision authority")
			check(not axe:FindFirstChildOfClass("PointLight") and not axe:FindFirstChildOfClass("ParticleEmitter"), "no rocket glow or exhaust")
			local trail = assert(axe:FindFirstChildOfClass("Trail"))
			check(trail.Lifetime < .08 and trail.LightEmission == 0, "short non-glowing blade sweep")
			for _, child in ipairs(axe:GetDescendants()) do
				check(not child:IsA("Constraint") and not child:IsA("JointInstance"), "no live weapon connections")
			end
			local endpoint = root.Position + Vector3.new(0, 0, -distance)
			local travel = endpoint - release.Position
			local duration = math.clamp(travel.Magnitude / 42, .28, .85)
			local time, maxArc, turns = 0, 0, 0
			local previous = axe.CFrame.Rotation
			while time + dt < duration do
				V.advanceSpellsQA(dt); time += dt
				local progress = time / duration
				local linear = release.Position + travel * progress
				maxArc = math.max(maxArc, axe.Position.Y - linear.Y)
				local _, angle = previous:ToObjectSpace(axe.CFrame.Rotation):ToAxisAngle()
				turns += angle / (2 * math.pi)
				previous = axe.CFrame.Rotation
				check((Vector3.new(axe.Position.X, 0, axe.Position.Z) - Vector3.new(linear.X, 0, linear.Z)).Magnitude < .002, "arc keeps approved horizontal endpoint")
			end
			check(maxArc > .4 and turns > .9, string.format("visible arc and full rotation %s distance=%d dt=%.5f arc=%.3f turns=%.3f", rig.Name, distance, dt, maxArc, turns))
			if distance == 32 then check(turns > 2.5, "full-range throw visibly spins several times") end
			V.advanceSpellsQA(dt)
			check(not axe.Parent and math.abs(held.LocalTransparencyModifier - .2) < .0001, "arrival restores held weapon")
			check(not workspace:FindFirstChild("K0VisualImpact"), "axe arrival does not explode like a missile")
			check(lateAxeEffects==0,"Axe flight never replays a second throw effect on arrival")
		end
	end
	local first = assert(send(c, 32))
	local second = assert(send(c, 32))
	check(not first.Parent and held.LocalTransparencyModifier == 1, "superseded throw restores then re-hides correctly")
	second:Destroy(); V.advanceSpellsQA(1/60)
	check(math.abs(held.LocalTransparencyModifier - .2) < .0001, "externally removed projectile restores hand")
	assert(send(c, 32)); c:SetAttribute("K0State", "Dead"); V.advanceSpellsQA(1/60)
	check(math.abs(held.LocalTransparencyModifier - .2) < .0001, "death restores hand")
	c:SetAttribute("K0State", "Idle")
	assert(send(c, 32)); c:SetAttribute("TLTEquippedWeapon", ""); V.advanceSpellsQA(1/60)
	check(math.abs(held.LocalTransparencyModifier - .2) < .0001, "unequip cleans up throw")
	check(root.CFrame == original, "throw never moves authoritative character root")
	model:Destroy(); check(send(c, 32) == nil and not workspace:FindFirstChild("K0VisualSpell"), "missing axe never falls back to a missile orb")
	c:Destroy()
end
FX.skill=originalSkill
copy:Destroy()
print("DWARF_AXE_THROW_NATIVE PASS checks=" .. checks)
