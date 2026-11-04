-- Aim assistance only chooses an intent; server hit geometry remains authoritative.
local Rules = {}
Rules.forwardAngle = 120
Rules.movementThreshold = 0.01

function Rules.directional(definition)
 return definition and definition.form ~= 'self' and definition.form ~= 'area'
  and definition.effect ~= 'whirlwind' and definition.effect ~= 'provoke'
  and definition.effect ~= 'slam' and definition.effect ~= 'recall'
end

function Rules.inRange(distance, height, definition)
 return distance <= definition.range and height <= definition.maxHeight
end

function Rules.inFront(dot)
 return dot >= math.cos(math.rad(Rules.forwardAngle / 2))
end

return Rules
