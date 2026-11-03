-- Native transform capture from real TD meshes, including per-model grip overrides.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated fixture only')
local Run=game:GetService('RunService');Run:Run();task.wait(1)
local Motion=require(game.StarterPlayer.StarterPlayerScripts.Client.K0EnemyMotion)
local Field=require(game.ServerScriptService.Server.World.TrainingField)
local folder=Instance.new('Folder');folder.Name='IndividualMonsterReview';folder.Parent=workspace
-- Run once per region to stay below run-in-roblox's 1 MiB output limit.
-- Prefix the fixture with _G.TLTReviewRegion='EmberCaldera' for the second capture.
local regions={FrozenVale={'IceWolf','IceTroll','IceBear','IceGolem','IceElf','IceTrollKing','KingIceBear','KingIceGolem','QueenIceElf','AncientGlacierKing'},EmberCaldera={'Imp','LavaSlime','Golem','MagmaWorm','VolcanoShaman','MagmaImp','MagmaGolem','InfernoOverlord','CalderaTitan','KingVolcanoShaman'}}
local kinds=assert(regions[_G.TLTReviewRegion or 'FrozenVale'])
local phases={0,.125,.25,.375,.5,.625,.75,.875,1}
local function array(cf)local a={cf:GetComponents()};for i,v in ipairs(a)do a[i]=math.round(v*1e6)/1e6 end;return a end
local function age(p)
 local times={0,.55,.8,1,1.2,2};local points={0,.4,.5,.62,.78,1}
 for i=2,#points do if p<=points[i]then return times[i-1]+(times[i]-times[i-1])*(p-points[i-1])/(points[i]-points[i-1])end end;return 2
end
for _,kind in ipairs(kinds)do
 local m=Field.makeEnemy(folder,kind,10000,10000,1,1);m.HumanoidRootPart.Anchored=true
 local s=assert(Motion.bind(m));local root=m.HumanoidRootPart;local record={kind=kind,height=s.height,parts={},clips={}}
 for _,part in ipairs(m.TdMonsterVisual:GetChildren())do if part:IsA('BasePart')then
  record.parts[part.Name]={size={part.Size.X,part.Size.Y,part.Size.Z},rest=array(root.CFrame:ToObjectSpace(part.CFrame))}
 end end
 for _,clip in ipairs({'Idle','Walk','Attack','AttackAlt','Heavy','HeavyAlt','Stunned'})do
  local frames={};record.clips[clip]=frames
  local ps=(clip=='Walk' or clip=='Idle' or clip=='Stunned')and phases or {0,.18,.4,.5,.55,.62,.69,.78,.9,1}
  for _,phase in ipairs(ps)do
   s.pose=Motion.sample(kind,clip,phase);s.move=clip=='Walk' and 1 or 0;s.phase=phase
   m:SetAttribute('K0EnemyState',clip=='Walk'and'Chase'or clip=='Idle'and'Idle'or clip=='Stunned'and'Stunned'or'Windup')
   m:SetAttribute('K0EnemyStunUntil',clip=='Stunned'and 2000 or nil)
   m:SetAttribute('K0EnemyAttackClock',(clip=='Idle'or clip=='Walk'or clip=='Stunned')and nil or ((clip:find('Alt')and'2'or'1')..'|100|1|0.2|0.8|'..(clip:find('Heavy')and'1'or'0')))
   Motion.step(s,0,100+age(phase))
   local body=root.CFrame*s.joint.C0*s.joint.Transform*s.joint.C1:Inverse()
   local f={phase=phase,parts={}};table.insert(frames,f)
   for _,part in ipairs(m.TdMonsterVisual:GetChildren())do if part:IsA('BasePart')then
    local weld=part:FindFirstChild('TdVisualWeld');local anchor=weld.Part0;local anchorCF=body
    for _,motor in ipairs(m.Torso:GetChildren())do if motor:IsA('Motor6D')and motor.Part1==anchor then anchorCF=body*motor.C0*motor.Transform*motor.C1:Inverse()end end
    local cf=anchorCF*anchor.CFrame:ToObjectSpace(part.CFrame)
    f.parts[part.Name]={cf=array(root.CFrame:ToObjectSpace(cf)),size={part.Size.X,part.Size.Y,part.Size.Z}}
   end end
  end
 end
 print('REGIONAL_REVIEW '..game.HttpService:JSONEncode(record));Motion.unbind(s);m:Destroy()
end
folder:Destroy();Run:Stop()
