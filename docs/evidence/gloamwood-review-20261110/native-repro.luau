local G=require(game.ServerScriptService.Appearance)
local rig=Instance.new('Model');rig.Name='SovereignReviewRig'
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.CFrame=CFrame.new(0,30,0);root.Parent=rig;rig.PrimaryPart=root;rig.Parent=workspace
local visual=G.attach(rig,'HollowbarkSovereign',3,1)
local body=visual.Body
local connected=false
for _,p in root:GetConnectedParts(true)do if p==body then connected=true end end
local before=body.Position
root.CFrame=root.CFrame+CFrame.new(10,0,0).Position
local moved=(body.Position-before).Magnitude
print('SOVEREIGN_REVIEW connectedToRig='..tostring(connected)..' bodyAnchored='..tostring(body.Anchored)..' bodyCanCollide='..tostring(body.CanCollide)..' rootMove=10 bodyMove='..tostring(moved))
print('SOVEREIGN_REVIEW confirmsMissingWeld='..tostring(not connected and moved<.001))
