-- Cosmetic appendage motion only. Roots, hit windows and damage stay server-owned.
local M={}
function M.bind(model)
 if not model:GetAttribute('GloamwoodPrototypeVersion')then return nil end
 local motors={}
 for _,v in ipairs(model:GetDescendants())do if v:IsA('Motor6D') and v.Name=='GloamLimb'then table.insert(motors,v)end end
 return motors
end
function M.step(motors,model,current,moving,attack)
 if not motors then return end
 local stunned=(model:GetAttribute('K0EnemyStunUntil')or 0)>current
 for _,motor in ipairs(motors)do
  local side=motor:GetAttribute('GloamSide');local index=motor:GetAttribute('GloamIndex');local shape=motor:GetAttribute('GloamShape')
  local wave=math.sin(current*(shape=='bat' and 12 or 7)+index*1.1+side*math.pi)
  local angle=stunned and .05 or (shape=='bat' and .5 or moving and .24 or .035)*wave
  motor.Transform=CFrame.Angles(shape=='bat' and 0 or angle,attack and math.sin(attack*math.pi)*.25*side or 0,shape=='bat' and angle*side or 0)
 end
end
return M
