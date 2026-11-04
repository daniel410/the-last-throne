-- Native R6/R15 fixtures inspect actual joints and bow draw; not visual acceptance.
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local visual = require(game:GetService("StarterPlayer").StarterPlayerScripts.Client.K0SwordVisual)
local appearance = require(game:GetService("ServerScriptService").Server.Cosmetics.WeaponAppearance)
assert(game.PlaceId == 0 and #Players:GetPlayers() == 0, "isolated place required")
local result = { kind = "K0_SKILL_ANIMATION_NATIVE", checks = 0, failures = {}, samples = {}, coverage = "Actual R6/R15 joints and bow transforms; no Player, animation aesthetics, network latency or mobile acceptance" }
local function check(value, label) result.checks += 1; assert(value, label) end
local function joint(character, side)
	return character:FindFirstChild(side .. "Shoulder", true) or character:FindFirstChild(side .. " Shoulder", true)
end
local skills = {
	knight = {"knight.common.bash", "knight.common.whirlwind", "knight.common.provoke"},
	dwarf = {"dwarf.common.overhead", "dwarf.common.throw", "dwarf.common.ground"},
	elf = {"elf.common.aimed", "elf.common.rapid", "elf.common.multi"},
	mage = {"mage.common.mana_bolt", "mage.common.water_ball", "mage.common.gravity"},
}
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local Bow=require(game.StarterPlayer.StarterPlayerScripts.Client.K0BowMotion)
local Advanced=require(game.ReplicatedStorage.Shared.AdvancedSkills)
for classId,list in pairs(Advanced.common) do for _,d in ipairs(list) do table.insert(skills[classId],d.id) end end
table.insert(skills.knight,Advanced.branches.steel_knight.skills[1].id)
local windup = require(game:GetService("ReplicatedStorage").Shared.K0Config).Skills.dwarf[1].windup
for index = 0, 4 do
	local angle = visual.overheadSpinAngle(10, 10 + windup * index / 4)
	check(math.abs(angle - math.pi * index / 2) < 0.0001, "overhead windup traces one full turn")
end
for _, rig in ipairs({Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15}) do
	for _, classId in ipairs({"knight", "dwarf", "elf", "mage"}) do
		local character
		local ok, err = xpcall(function()
			local desc = Instance.new("HumanoidDescription")
			character = Players:CreateHumanoidModelFromDescriptionAsync(desc, rig)
			desc:Destroy(); character.Parent = workspace
			character:PivotTo(CFrame.new(0, 500, 0))
			local model = Instance.new("Model"); model.Name = "SkillTestAppearance"; model.Parent = character
			assert(appearance.attachInto(model, character, classId), "weapon attached")
			character:SetAttribute("K0ClassId", classId)
			character:SetAttribute("K0State", "Attack")
			character:SetAttribute("K0AttackKind", classId == "mage" and "Arcane" or "Basic")
			character:SetAttribute("K0Combo", 1)
			for index, skillId in ipairs(skills[classId]) do
				local definition
                for _,d in ipairs(Config.Skills[classId]) do if d.id==skillId then definition=d;break end end
                local started=100+index*10
                character:SetAttribute("K0AttackStartedAt",started)
                character:SetAttribute("K0SkillStartedAt",started)
                character:SetAttribute("K0SkillId", skillId)
				character:SetAttribute("K0AttackSeq", index)
				character:SetAttribute("K0RapidShotCount", 3)
				local selected = assert(joint(character, (classId == "knight" and (index == 1 or index == 3 or index==6 or index==7)) and "Left" or classId == "elf" and "Left" or "Right"))
				character:SetAttribute("K0AttackPhase", "Windup")
				for _ = 1, 18 do visual.renderArms(character, 1/60,started+definition.windup*(classId=="elf" and .8 or .35)); visual.renderCharacter(character, 1/60,started+definition.windup*(classId=="elf" and .8 or .35)) end
				local wind = selected.Transform
				local stringPart = model:FindFirstChild("String")
				local nock=model:FindFirstChild("NockedArrow")
                local nockJoint=nock and nock:FindFirstChild("NockedArrowVisualJoint")
                local drawn=nockJoint and nockJoint.Transform.Position.Magnitude
				character:SetAttribute("K0AttackPhase", "Active")
                if classId=="elf" then
                 character:SetAttribute("K0RapidShotAt",started+definition.windup)
                 character:SetAttribute("K0RapidShotCount",1)
                 if definition.advanced and definition.pulses>1 then Bow.confirmPulse(character,skillId,1,index,started+definition.windup,started,started+definition.windup+.04) end
                end
				for _ = 1, 18 do visual.renderArms(character, 1/60,started+definition.windup+.04); visual.renderCharacter(character, 1/60,started+definition.windup+.04) end
				local _, angle = wind:ToObjectSpace(selected.Transform):ToAxisAngle()
				if classId == "elf" then
					check(nockJoint and drawn > nockJoint.Transform.Position.Magnitude + 0.1, skillId .. " draws and releases bow")
				else
					check(math.abs(angle) > 0.05, skillId .. " changes arm pose between windup and active")
				end
				table.insert(result.samples, { rig = rig.Name, skill = skillId, armDelta = angle })
			end
			if classId == "elf" then
				character:SetAttribute("K0SkillId", "elf.common.rapid")
				character:SetAttribute("K0RapidShotCount", 1)
				character:SetAttribute("K0RapidShotAt", 10)
				check(visual.bowPhase(character, "Active", 10.03) == "Active", "first arrow releases string")
				check(visual.bowPhase(character, "Active", 10.10) == "Windup", "bow redraws for next shot")
				character:SetAttribute("K0RapidShotCount", 3)
				check(visual.bowPhase(character, "Active", 10.2) == "Active", "last shot stays released")
			end
		end, debug.traceback)
		if character then character:Destroy() end
		if not ok then table.insert(result.failures, rig.Name .. "/" .. classId .. ": " .. tostring(err)) end
	end
end
result.pass = #result.failures == 0
print("K0_SKILL_ANIMATION_NATIVE " .. HttpService:JSONEncode(result))
assert(result.pass, "Skill animation fixture failed")
