-- Run in each isolated baseline/final Edit scene after create; capture after loading.
local b=_G.PassWorld.folder.QuestSetpieces.Epic4['EC-01_FreightMachinery'].FreightCarrier:GetPivot().Position
local low=false -- true for before-low / after-low
local target=b+Vector3.new(0,low and 16 or 14,0)
local offset=low and Vector3.new(18,6,22)or Vector3.new(64,26,72)
local c=workspace.CurrentCamera;c.Focus=CFrame.new(target);c.CFrame=CFrame.lookAt(b+offset,target);c.FieldOfView=70
game.Lighting.ClockTime=14
return {base=tostring(b),position=tostring(c.CFrame.Position),target=tostring(target),fov=70,clock=14}
