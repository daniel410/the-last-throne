-- Rotations are in the anatomical shoulder frame. The right fist and the full
-- blade are a single rigid piece, so the wrist never lets go during recovery.
local Snapshot = require(script.Parent.EnemyPatternDefinition)
local BladeSwing = {}

local v = Vector3.new
local cleave = {v(120, -56, -18), v(56, 18, -5), v(28, 49, 7)}
local downward = {v(143, -22, -7), v(53, 6, 0), v(20, 12, 4)}
local release = {v(103, -43, -14), v(70, 17, -2), v(56, 29, 5)}
local secondBlade = {v(36, 23, 10), v(77, -20, -5), v(46, -30, -7)}

local function blend(a, b, t)
	t = math.clamp(t, 0, 1)
	return a:Lerp(b, t * t * (3 - 2 * t))
end

function BladeSwing.joint(model, channel, phase)
	local pattern = Snapshot.get(model)
	local poses = cleave
	if channel == "off" then
		poses = secondBlade
	elseif pattern and (pattern.shape == "projectile" or pattern.motion == "cast") then
		poses = release
	elseif pattern and pattern.motion == "slam" then
		poses = downward
	end

	local rotation
	if phase < .47 then
		rotation = blend(Vector3.zero, poses[1], phase / .47)
	elseif phase < .62 then
		rotation = blend(poses[1], poses[2], (phase - .47) / .15)
	elseif phase < .78 then
		rotation = blend(poses[2], poses[3], (phase - .62) / .16)
	else
		rotation = blend(poses[3], Vector3.zero, (phase - .78) / .22)
	end
	return CFrame.fromEulerAnglesYXZ(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z))
end

return BladeSwing
