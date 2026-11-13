-- Absolute basic-attack phase transfers one cosmetic arrow: quiver -> hand -> bow.
-- All meshes are inert local presentation; no ammunition or hit authority.
local Q={}
local states=setmetatable({},{__mode='k'})
local function smooth(u)u=math.clamp(u,0,1);return u*u*(3-2*u)end
local function clearHeld(state)
 if state and state.arrow then state.arrow:Destroy();state.arrow=nil end
end
local function reconcileHeld(quiver,state)
 if not quiver then return end
 -- A replaced renderer must not leave an unowned visible arrow on the hand.
 for _,child in quiver:GetChildren()do
  if child.Name=='QuiverCarriedArrow' and (not state or child~=state.arrow)then child:Destroy()end
 end
end
function Q.render(model,pose)
 local character=model.Parent
 local quiver=model:FindFirstChild('ElfQuiver')
 local stored=quiver and quiver:FindFirstChild('QuiverArrow1')
 local source=model:FindFirstChild('NockedArrow')
 local hand=character and character:FindFirstChild('RightHand')
 local state=states[model]
 reconcileHeld(quiver,state)
 local dead=character and(character:GetAttribute('K0State')=='Dead'or character:GetAttribute('TLTDeathFalling'))
 local allowed=character and character:GetAttribute('K0ClassId')=='elf'and character:GetAttribute('K0State')=='Attack'
  and character:GetAttribute('TLTEquippedWeapon')~=''and not dead
 local holding=allowed and pose and pose.quiverArrow and stored and source and hand
 if stored then
  if allowed and pose and pose.quiverTaken then
   if not state then state={};states[model]=state end
   state.stored=stored;state.hidden=true;stored.LocalTransparencyModifier=1
  elseif state and state.hidden and not dead then
   if state.stored and state.stored.Parent then state.stored.LocalTransparencyModifier=0 end
   state.hidden=false
  end
 end
 if not holding then
  clearHeld(state)
  return
 end
 if not state then state={};states[model]=state end
 if state.source~=source or state.hand~=hand or not state.arrow or not state.arrow.Parent then
  clearHeld(state)
  local arrow=source:Clone();arrow.Name='QuiverCarriedArrow'
  arrow.Transparency=1;arrow.LocalTransparencyModifier=1
  for _,child in arrow:GetChildren()do if not child:IsA('SurfaceAppearance')then child:Destroy()end end
  arrow:SetAttribute('TLTPlayerWeaponPart',nil);arrow:SetAttribute('TLTElfQuiverPart',nil);arrow:SetAttribute('TLTElfCarriedArrow',true)
  arrow.Anchored=false;arrow.Massless=true;arrow.CanCollide=false;arrow.CanTouch=false;arrow.CanQuery=false
  local joint=Instance.new('Motor6D');joint.Name='QuiverCarriedArrowJoint';joint.Part0=hand;joint.Part1=arrow
  joint.C0=CFrame.new(0,0,-.9);joint.Parent=arrow
  arrow.CFrame=hand.CFrame*joint.C0;arrow.Parent=quiver
  state.arrow,state.joint,state.hand,state.source=arrow,joint,hand,source
 end
 local carried=hand.CFrame*CFrame.new(0,0,-.9)
 local nock=source:FindFirstChild('NockedArrowVisualJoint')
 if nock and nock.Part0 then
  local target=nock.Part0.CFrame*nock.C0*nock.Transform*nock.C1:Inverse()
  carried=carried:Lerp(target,smooth(((pose.time or 0)-.42)/.08))
 end
 -- Reconstructed from the current phase, so late observers need no pickup event.
 state.joint.C0=hand.CFrame:ToObjectSpace(carried)
 state.arrow.Transparency=0;state.arrow.LocalTransparencyModifier=0
end
return Q
