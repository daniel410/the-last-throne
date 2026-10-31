-- Production curves + native R6/R15 forward kinematics. Synthetic server time;
-- this measures socket/arc/continuity, not Player input, latency or visual taste.
local Players = game:GetService("Players")
local Http = game:GetService("HttpService")
local Config = require(game.ReplicatedStorage.Shared.K0Config)
local Visual = require(game.StarterPlayer.StarterPlayerScripts.Client.K0SwordVisual)
local Motion = require(game.StarterPlayer.StarterPlayerScripts.Client.K0MeleeMotion)
local Appearance = require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
assert(game.PlaceId == 0 and #Players:GetPlayers() == 0, "Unpublished empty fixture required")
local report = { kind = "K0_MELEE_CURVES_NATIVE", checks = 0, failures = {}, samples = {} }
local function check(value, label) report.checks += 1; assert(value, label) end
local function vec(v) return {x=v.X, y=v.Y, z=v.Z} end
for _, rig in ipairs({Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15}) do
	for _, classId in ipairs({"knight", "dwarf"}) do
		local character
		local ok, err = xpcall(function()
			local desc = Instance.new("HumanoidDescription")
			character = Players:CreateHumanoidModelFromDescriptionAsync(desc, rig); desc:Destroy()
			character.Parent = workspace; character:PivotTo(CFrame.new(0, 500, 0))
			local model = Instance.new("Model"); model.Name = "MotionAppearance"; model.Parent = character
			local weapon = assert(Appearance.attachInto(model, character, classId))
			local shield = classId == "knight" and assert(Appearance.attachShieldInto(model, character))
			local shieldHand = shield and shield.joint.Part0
			local shieldOffset = shield and shieldHand.CFrame:ToObjectSpace(shield.shield.CFrame)
			character:SetAttribute("K0ClassId", classId); character:SetAttribute("K0State", "Attack")
			character:SetAttribute("K0AttackKind", "Basic"); character:SetAttribute("K0AttackStartedAt", 100)
			local root = character.HumanoidRootPart
			local originalRoot = root.CFrame
			local joints = {}
			for _, j in ipairs(character:GetDescendants()) do
				if (j:IsA("Motor6D") or j:IsA("AnimationConstraint")) and j.Part0 and j.Part1 then joints[j.Part1] = j end
			end
			local function frame(part)
				local j = joints[part]
				return j and frame(j.Part0) * j.C0 * j.Transform * j.C1:Inverse() or part.CFrame
			end
			local function sample(age, dt)
				Visual.renderArms(character, dt, 100+age); Visual.renderCharacter(character, dt, 100+age)
				local grip = frame(weapon.grip)
				local tip = root.CFrame:PointToObjectSpace(grip:PointToWorldSpace(weapon.tip.Position))
				local hand = frame(weapon.joint.Part0)
				local socket = hand * weapon.joint.C0
				check((socket.Position-grip.Position).Magnitude < 0.0001, "Grip remains fixed in palm")
				check(root.CFrame == originalRoot, "Presentation never moves authoritative root")
				if shield then
					-- Conservative OBB vs cutting segment, excluding the hilt. Tests
					-- original shield geometry rather than a hand-authored proxy.
					local box = frame(shieldHand) * shieldOffset
					local first = box:PointToObjectSpace(grip:PointToWorldSpace(Vector3.new(0,.7,0)))
					local last = box:PointToObjectSpace(grip:PointToWorldSpace(weapon.tip.Position))
					local delta, half = last-first, shield.shield.Size/2
					local low, high = 0, 1
					for _,axis in ipairs({"X","Y","Z"}) do
						if math.abs(delta[axis]) < .00001 then
							if math.abs(first[axis]) > half[axis] then high=-1;break end
						else
							local a,b=(-half[axis]-first[axis])/delta[axis],(half[axis]-first[axis])/delta[axis]
							low,high=math.max(low,math.min(a,b)),math.min(high,math.max(a,b))
						end
					end
					check(low>high, "Sword cutting segment clears held shield")
				end
				return tip, grip
			end
			for combo, d in ipairs(Config.BasicAttackProfiles[classId].attacks) do
				character:SetAttribute("K0Combo", combo)
				local total, impact = d.windup+d.active+d.recovery, d.windup+(d.hitDelay or 0)
				local previous, minY, maxStep, maxReach = nil, math.huge, 0, 0
				local points = {}
				for i=0,120 do
					local age = total*i/120
					character:SetAttribute("K0AttackPhase", age < d.windup and "Windup" or age < d.windup+d.active and "Active" or "Recovery")
					local tip = sample(age, 1/60)
					if previous then maxStep = math.max(maxStep, (tip-previous).Magnitude) end
					previous, minY, maxReach = tip, math.min(minY,tip.Y), math.max(maxReach,Vector3.new(tip.X,0,tip.Z).Magnitude)
					if i%20 == 0 then table.insert(points, {age=age, tip=vec(tip)}) end
				end
				local hit = sample(impact, 1/60)
				local loaded = sample(d.windup*.45, 1/60)
				local finish = sample(total, 1/60)
				local initial = sample(0, 1/60)
				check(finish.Z < -1.5 and (finish-initial).Magnitude > .15, "Ends combat-ready instead of dropping to neutral")
				check(hit.Z < -3 and math.abs(hit.X) < 1.6, "Contact passes through target corridor in front")
				check(minY > -3.4, "Blade stays above floor on default rig")
				check(maxReach < 6.5, "Compact arc stays near combat reach")
				check(maxStep < .7, "Continuous arc without snapping")
				if classId == "dwarf" or combo == 3 then
					check(loaded.Y-hit.Y > 1, "Loaded weapon descends into contact")
				else
					check((hit.X-loaded.X)*(combo == 2 and 1 or -1) > 1, "Sword alternates cutting direction")
				end
				for _, boundary in ipairs({d.windup*.45,impact,d.windup+d.active+d.recovery*.15,total}) do
					local before = sample(boundary-.00001, 1/30)
					local after = sample(boundary+.00001, 1/144)
					check((after-before).Magnitude < .01, "No discontinuity at curve boundary")
				end
				local beforeContact=sample(impact-.0005,1/60)
                local contact=sample(impact,1/60)
                local afterContact=sample(impact+.0005,1/60)
                local arriving,leaving=(contact-beforeContact)/.0005,(afterContact-contact)/.0005
                check(arriving.Magnitude>5 and leaving.Magnitude>5,"Blade carries momentum through contact")
                check(arriving.Unit:Dot(leaving.Unit)>.99,"Contact does not reverse or freeze the blade")
                check((arriving-leaving).Magnitude/math.max(arriving.Magnitude,leaving.Magnitude)<.12,"Contact velocity stays continuous")
                local low = sample(impact, 1/30)
				local high = sample(impact, 1/144)
				check((low-high).Magnitude < .0001, "30/144Hz observers agree at hit time")
				table.insert(report.samples, {rig=rig.Name,class=classId,combo=combo,impact=vec(hit),loaded=vec(loaded),minY=minY,maxStep=maxStep,maxReach=maxReach,points=points})
			end
			-- Accepted recovery cancel: position and angular velocity continue from
            -- the outgoing stroke, evaluated at the shared server timestamp.
            character:SetAttribute("K0Combo",1);character:SetAttribute("K0AttackStartedAt",200)
            local d=Config.BasicAttackProfiles[classId].attacks[1]
            local transition=d.windup+d.active+d.recovery-.10
            local a=Motion.forCharacter(character,200+transition-.0005)
            local b=Motion.forCharacter(character,200+transition)
            character:SetAttribute("K0AttackStartedAt",200+transition)
            character:SetAttribute("K0Combo",classId=="knight" and 2 or 1)
            local c=Motion.forCharacter(character,200+transition)
            local e=Motion.forCharacter(character,200+transition+.0005)
            for _,channel in ipairs({"right","elbow","wrist","torso","weapon"}) do
             check((b.angles[channel]-c.angles[channel]).Magnitude<.001,"Chained attack preserves entry pose")
             local v0=(b.angles[channel]-a.angles[channel])/.0005
             local v1=(e.angles[channel]-c.angles[channel])/.0005
             check((v0-v1).Magnitude<35,"Chained attack preserves outgoing momentum")
            end
            character:SetAttribute("K0State","Idle");character:SetAttribute("K0AttackStartedAt",nil)
            check(Motion.forCharacter(character,201.5)==nil,"Idle releases the procedural layer after settling")
            character:SetAttribute("K0State","Attack");character:SetAttribute("K0AttackStartedAt",202)
            character:SetAttribute("K0SkillId", classId == "knight" and "knight.common.bash" or "dwarf.common.throw")
			check(Motion.forCharacter(character,100.1) == nil, "Skills retain authored specialist motion")
			character:SetAttribute("K0SkillId",nil); character:SetAttribute("K0State","Dodge")
			check(Motion.forCharacter(character,100.1) == nil, "Dodge cancels melee curve immediately")
			character:SetAttribute("K0State","Dead")
			check(Motion.forCharacter(character,100.1) == nil, "Death cancels melee curve immediately")
		end, debug.traceback)
		if character then character:Destroy() end
		if not ok then table.insert(report.failures,rig.Name.."/"..classId..": "..tostring(err)) end
	end
end
report.pass = #report.failures == 0
print("K0_MELEE_CURVES_NATIVE "..Http:JSONEncode(report))
assert(report.pass,"Melee curves failed; see report")
