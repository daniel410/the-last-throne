local Tutorial = {
	waypoint = Vector3.new(4, 0.12, 56),
	radius = 4,
	enemyTag = "TLTTrainingEnemy",
	hitAttribute = {basic = "TLTTrainingBasicHit", skill = "TLTTrainingSkillHit"},
	order = {"moved", "attacked", "dodged", "usedSkill", "cast", "followUp"},
	skillChapterStart = 4,
}

function Tutorial.reached(position)
	local delta = position - Tutorial.waypoint
	return delta.X * delta.X + delta.Z * delta.Z <= Tutorial.radius ^ 2 and math.abs(delta.Y) <= 6
end

function Tutorial.current(practice)
	for index, key in ipairs(Tutorial.order) do
		if not practice[key] then return key, index end
	end
	return "complete", #Tutorial.order
end

return Tutorial
