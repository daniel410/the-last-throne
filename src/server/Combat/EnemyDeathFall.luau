-- Server-owned presentation for humanoid enemies; combat ends immediately.
local TweenService=game:GetService('TweenService')
local Workspace=game:GetService('Workspace')
local Fall={fallSeconds=.65,holdSeconds=1.1,fadeSeconds=.25}
local bipeds={
 Goblin=true,Orc=true,Ogre=true,Shaman=true,Warlord=true,GoblinKing=true,KingOgre=true,EnragedWarlord=true,KingShaman=true,
 IceTroll=true,IceGolem=true,IceTrollKing=true,IceElf=true,KingIceGolem=true,AncientGlacierKing=true,QueenIceElf=true,
 MagmaGolem=true,VolcanoShaman=true,KingVolcanoShaman=true,Imp=true,CalderaTitan=true,InfernoOverlord=true,MagmaImp=true,Golem=true,
}
function Fall.supports(kind) return bipeds[kind]==true end
function Fall.prepare(humanoid,kind)
 if Fall.supports(kind) then humanoid.BreakJointsOnDeath=false end
end
local function lowestVisual(model,root,rotation)
 local visual=model:FindFirstChild('TdMonsterVisual');local bottom=math.huge
 if visual then for _,part in ipairs(visual:GetDescendants()) do if part:IsA('BasePart') then
  local localFrame=root.CFrame:ToObjectSpace(part.CFrame)
  for x=-1,1,2 do for y=-1,1,2 do for z=-1,1,2 do
   local point=localFrame:PointToWorldSpace(part.Size*Vector3.new(x,y,z)*.5)
   bottom=math.min(bottom,rotation:VectorToWorldSpace(point).Y)
  end end end
 end end end
 return bottom<math.huge and bottom or -root.Size.Z*.5
end
function Fall.play(model,kind,enemyFolder)
 local human=model:FindFirstChildOfClass('Humanoid');local root=model:FindFirstChild('HumanoidRootPart')
 if not Fall.supports(kind) or not human or human.Health>0 or not root or not root:IsA('BasePart') or not model:IsDescendantOf(Workspace) or model:GetAttribute('K0EnemyDeathFalling') then return false end
 model:SetAttribute('K0EnemyDeathFalling',true)
 human.EvaluateStateMachine=false;human.AutoRotate=false;human.WalkSpeed=0;human.JumpPower=0
 local animator=human:FindFirstChildOfClass('Animator');if animator then for _,track in ipairs(animator:GetPlayingAnimationTracks())do track:Stop(.1)end end
 local look=root.CFrame.LookVector;local forward=Vector3.new(look.X,0,look.Z)
 if forward.Magnitude<.001 then forward=Vector3.new(0,0,-1)else forward=forward.Unit end
 local destination=root.Position+forward*math.clamp((model:GetAttribute('TdMonsterTargetHeight') or 5)*.12,.3,1.2)
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
 local excluded={model};if enemyFolder then table.insert(excluded,enemyFolder)end
 for _,player in ipairs(game:GetService('Players'):GetPlayers())do if player.Character then table.insert(excluded,player.Character)end end
 params.FilterDescendantsInstances=excluded;params.RespectCanCollide=true
 local hit=Workspace:Raycast(destination+Vector3.new(0,3,0),Vector3.new(0,-60,0),params)
 local floor=hit and hit.Position.Y or root.Position.Y-human.HipHeight-root.Size.Y*1.5
 local rotation=CFrame.lookAt(Vector3.zero,forward)*CFrame.Angles(-math.pi/2,0,0)
 local position=Vector3.new(destination.X,floor-lowestVisual(model,root,rotation)+.05,destination.Z)
 for _,part in ipairs(model:GetDescendants())do
  if part:IsA('BasePart')then part.CanCollide=false;part.CanTouch=false;part.CanQuery=false
  elseif part:IsA('BillboardGui') or part:IsA('ParticleEmitter') or part:IsA('Trail') or part:IsA('Beam') then part.Enabled=false end
 end
 root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero;root.Anchored=true
 local tween=TweenService:Create(root,TweenInfo.new(Fall.fallSeconds,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{CFrame=CFrame.new(position)*rotation})
 local destroying=model.Destroying:Connect(function()tween:Cancel()end)
 tween.Completed:Once(function()destroying:Disconnect()end);tween:Play()
 task.delay(Fall.fallSeconds+Fall.holdSeconds,function()
  if not model.Parent then return end
  for _,object in ipairs(model:GetDescendants())do
   if object:IsA('BasePart') or object:IsA('Decal') or object:IsA('Texture') then
    TweenService:Create(object,TweenInfo.new(Fall.fadeSeconds),{Transparency=1}):Play()
   end
  end
 end)
 return true
end
return Fall
