-- Veyr carries the blade in his right hand between attacks. The shoulder turns
-- through contact in one continuous arc, then brings the sword back underneath.
local Snapshot = require(script.Parent.EnemyPatternDefinition)
local Sword = {}
local v = Vector3.new
local guard = v(88, -10, -9)
local lowReturn = v(44, 32, 8)
local cleave = {raised=v(137,-54,11), finish=v(55,104,11)}
local slam = {raised=v(146,-26,-18), finish=v(34,93,2)}
local spell = {raised=v(132,-52,9), finish=v(66,104,12)}

local function frame(angles)
	return CFrame.fromEulerAnglesYXZ(math.rad(angles.X),math.rad(angles.Y),math.rad(angles.Z))
end
Sword.guard = frame(guard)

local function ease(t)
	t = math.clamp(t, 0, 1)
	return t*t*(3-2*t)
end

local function cut(pose, progress)
	return frame(pose.raised:Lerp(pose.finish, ease(progress))), true
end

function Sword.sample(model, attack, now)
	local d = Snapshot.get(model)
	local pose = cleave
	if d and d.motion == "slam" then
		pose = slam
	elseif d and (d.motion == "cast" or d.shape == "projectile") then
		pose = spell
	end

	local sinceHit = now - attack.start - attack.w
	local before = math.min(.25, attack.w*.24)
	if sinceHit < -before then
		local liftTime = (attack.w-before)*.80
		return frame(guard:Lerp(pose.raised, ease((now-attack.start)/liftTime))), false
	elseif sinceHit < 0 then
		return cut(pose, .69*(1+sinceHit/before))
	end

	local pulses = d and d.pulses or 1
	local interval = d and d.interval or attack.a
	local pulse = math.min(pulses-1, math.floor(sinceHit/interval))
	local elapsed = sinceHit-pulse*interval
	local follow = math.min(before*.31/.69, attack.a+attack.r)
	if pulses > 1 then follow = math.min(follow, interval*.23) end
	if elapsed < follow then
		return cut(pose, .69+.31*elapsed/follow)
	end

	if pulse < pulses-1 then
		local nextCut = interval*.71
		if elapsed >= nextCut then
			return cut(pose, .69*(elapsed-nextCut)/(interval-nextCut))
		end
		-- Roll back under the blade between pulses instead of replaying the slash backwards.
		local t = (elapsed-follow)/(nextCut-follow)
		if t < .42 then
			return frame(pose.finish:Lerp(lowReturn, ease(t/.42))), false
		end
		return frame(lowReturn:Lerp(pose.raised, ease((t-.42)/.58))), false
	end

	local remaining = attack.a+attack.r-pulse*interval-follow
	local recovery = math.max(.001, math.min(remaining, attack.r+.12))
	local t = (elapsed-follow)/recovery
	if t < .4 then
		return frame(pose.finish:Lerp(lowReturn, ease(t/.4))), false
	end
	return frame(lowReturn:Lerp(guard, ease((t-.4)/.6))), false
end

return Sword
