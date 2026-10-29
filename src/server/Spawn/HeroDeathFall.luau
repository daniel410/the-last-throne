-- Keep the complete hero rig together and fall face down. No ragdoll or debris.
local TweenService=game:GetService('TweenService')
local Workspace=game:GetService('Workspace')
local Fall={}
function Fall.prepare(humanoid)
 humanoid.BreakJointsOnDeath=false
end
function Fall.play(character)
 local human=character:FindFirstChildOfClass('Humanoid')
 local root=character:FindFirstChild('HumanoidRootPart')
 if not human or human.Health>0 or not root or not root:IsA('BasePart') or not character:IsDescendantOf(Workspace) or character:GetAttribute('TLTDeathFalling') then return false end
 character:SetAttribute('TLTDeathFalling',true)
 human.EvaluateStateMachine=false
 human.AutoRotate=false;human.WalkSpeed=0;human.JumpPower=0
 local animator=human:FindFirstChildOfClass('Animator')
 if animator then for _,track in ipairs(animator:GetPlayingAnimationTracks()) do track:Stop(.1) end end
 local forward=Vector3.new(root.CFrame.LookVector.X,0,root.CFrame.LookVector.Z)
 if forward.Magnitude<.001 then forward=Vector3.new(0,0,-1) else forward=forward.Unit end
 local ignored={character}
 local field=Workspace:FindFirstChild('DeepwoodK0');local enemies=field and field:FindFirstChild('Enemies');if enemies then table.insert(ignored,enemies) end
 for _,player in ipairs(game:GetService('Players'):GetPlayers()) do if player.Character and player.Character~=character then table.insert(ignored,player.Character) end end
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances=ignored;params.RespectCanCollide=true
 local destination=root.Position+forward*1.1
 local hit=Workspace:Raycast(destination+Vector3.new(0,2,0),Vector3.new(0,-20,0),params)
 local floor=hit and hit.Position.Y or root.Position.Y-human.HipHeight-root.Size.Y/2
 local position=Vector3.new(destination.X,floor+root.Size.Z/2+.15,destination.Z)
 for _,part in ipairs(character:GetDescendants()) do if part:IsA('BasePart') then part.CanCollide=false;part.CanTouch=false;part.CanQuery=false end end
 root.AssemblyLinearVelocity,root.AssemblyAngularVelocity=Vector3.zero,Vector3.zero
 root.Anchored=true
 local target=CFrame.lookAt(position,position+forward)*CFrame.Angles(-math.pi/2,0,0)
 local tween=TweenService:Create(root,TweenInfo.new(.7,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{CFrame=target})
 local destroyConnection=character.Destroying:Connect(function() tween:Cancel() end)
 tween.Completed:Once(function() destroyConnection:Disconnect() end)
 tween:Play()
 return true
end
return Fall
