-- Real R6/R15 default class prop and client-only absolute-time arrow transfer.
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local A=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local Q=require(game.ServerScriptService.Server.Cosmetics.ElfQuiverAppearance)
local Bow=require(Client.K0BowMotion)
local Visual=require(Client.K0SwordVisual)
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local report={checks=0,pass=false,parts=0}
local function check(v,label)report.checks+=1;assert(v,label)end
for _,rig in {Enum.HumanoidRigType.R15,Enum.HumanoidRigType.R6}do
 local desc=Instance.new('HumanoidDescription');local c=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,rig);desc:Destroy()
 c.Parent=workspace;c:PivotTo(CFrame.new(0,500,0))
 local root=c.HumanoidRootPart;local origin=root.CFrame
 local model=Instance.new('Model');model.Parent=c
 local w=assert(A.attachInto(model,c,'elf'));local q=assert(model:FindFirstChild('ElfQuiver'))
 check(Q.valid(model,c)and A.isAttached(model,c,'elf'),'Default quiver participates in appearance lifecycle')
 check(q.QuiverRoot.QuiverTorsoJoint.Part0.Name==(rig==Enum.HumanoidRigType.R15 and'UpperTorso'or'Torso'),'Back prop follows the animated torso')
 local socket=q.QuiverRoot.QuiverDrawSocket
 local torso=q.QuiverRoot.QuiverTorsoJoint.Part0
 local opening=torso.CFrame:PointToObjectSpace(socket.WorldPosition)
 check(opening.X>.4 and opening.Y>.3 and opening.Z>torso.Size.Z*.5,'Arrow grip lies behind the right shoulder')
 local count=0
 for _,p in q:GetDescendants()do if p:IsA('BasePart')then
  count+=1;check(not p.Anchored and p.Massless and not p.CanCollide and not p.CanTouch and not p.CanQuery,'Quiver parts cannot affect physics or targeting')
 end end
 check(count==14,'Bounded default prop part count');report.parts=count
 local old=q;assert(A.attachInto(model,c,'elf'))
 check(model.ElfQuiver==old,'Repeated appearance synchronization never duplicates the quiver')
 for i=1,3 do
  check(q['QuiverArrow'..i].MeshId==model.NockedArrow.MeshId and q['QuiverArrow'..i].Size==model.NockedArrow.Size,'Stored arrows share the actual fired arrow geometry')
 end
 -- Texture-backed bows have a white mesh tint; use their actual texture palette.
 local palettes=require(game.ServerScriptService.Server.Cosmetics.ElfQuiverPalette)
 local bow=model.Bow;local tint=bow.Color;local surface=bow:FindFirstChildOfClass('SurfaceAppearance')
 local originalMap=surface and surface.ColorMapContent.Uri;local originalTexture=bow.TextureID
 if surface then surface.Parent=nil end
 for texture,palette in pairs(palettes)do
  bow.TextureID=texture;bow.Color=Color3.new(1,1,1)
  assert(A.attachInto(model,c,'elf'))
  check(model.ElfQuiver==q,'Changing bow palette preserves the quiver and draw socket')
  check(q.QuiverFront.Color==palette.body and q.QuiverHarness.Color==palette.body,'Body and harness match the bow texture')
  check(q['QuiverRimX1'].Color==palette.trim,'Rim matches the bow accent')
  check(A.isAttached(model,c,'elf'),'Updated palette remains attached')
  bow.Color=Color3.new(.5,.75,1);assert(A.attachInto(model,c,'elf'))
  check(q.QuiverFront.Color==Color3.fromRGB(math.round(palette.body.R*bow.Color.R*255),math.round(palette.body.G*bow.Color.G*255),math.round(palette.body.B*bow.Color.B*255)),'Bow tint also affects the quiver palette')
  check(A.isAttached(model,c,'elf'),'Rounded tinted colors do not trigger endless appearance rebuilding')
 end
 bow.TextureID='';bow.Color=Color3.fromRGB(40,120,190)
 check(not A.isAttached(model,c,'elf'),'Stale colors request appearance synchronization')
 assert(A.attachInto(model,c,'elf'))
 check(q.QuiverFront.Color==bow.Color and q.QuiverRimX1.Color==bow.Color,'Untextured bows automatically use their mesh color')
 if surface then
  surface.Parent=bow
  bow.TextureID='rbxassetid://138212965806098';bow.Color=Color3.new(1,1,1)
  assert(A.attachInto(model,c,'elf'))
  check(q.QuiverFront.Color==palettes[originalMap].body,'SurfaceAppearance takes precedence over TextureID')
 end
 bow.TextureID=originalTexture;bow.Color=tint;assert(A.attachInto(model,c,'elf'))
 c:SetAttribute('K0ClassId','elf');c:SetAttribute('K0Combo',1);c:SetAttribute('K0SkillId',nil);c:SetAttribute('K0BasicAttackRate',1)
 local d=Config.BasicAttackProfiles.elf.attacks[1]
 local function sample(t,start)
  local now=start+d.windup*t/.8
  Visual.renderArms(c,1/60,now);Visual.render(model,'Windup',1,1/60,'Basic',now)
 end
 for cycle=1,2 do
  local start=100+cycle*10
  c:SetAttribute('K0State','Dodge');Bow.forCharacter(c,start-1)
  c:SetAttribute('K0State','Attack');c:SetAttribute('K0AttackStartedAt',start)
  for _,t in {.10,.20,.23,.35,.49999,.55,.70,.81}do
   sample(t,start)
   local carried=q:FindFirstChild('QuiverCarriedArrow')
   local copies=0;for _,p in q:GetChildren()do if p.Name=='QuiverCarriedArrow'then copies+=1 end end
   check(copies<=1,'At most one carried arrow despite repeated sampling')
   check(root.CFrame==origin,'Quiver and handoff never move authoritative root')
   if rig==Enum.HumanoidRigType.R15 then
    local visible=(q.QuiverArrow1.LocalTransparencyModifier<.5 and 1 or 0)+(carried and carried.Transparency<.5 and 1 or 0)+(model.NockedArrow.Transparency<.5 and 1 or 0)
    check(visible<=1,'Pickup, hand and nocked arrow never duplicate the same visible arrow')
    if t==.20 then
     local ik=c.Humanoid:FindFirstChild('K0BowDrawIK')
     check(ik and ik.Enabled and ik.Target==socket and ik.Type==Enum.IKControlType.Transform,'Pickup IK targets the real back-quiver grip')
    elseif t==.23 then
     check(carried and carried.Transparency==0 and q.QuiverArrow1.LocalTransparencyModifier==1,'Arrow leaves its quiver and appears in the right hand')
     check(carried.MeshId==model.NockedArrow.MeshId and carried.Size==model.NockedArrow.Size,'Carried mesh and scale match the nocked arrow')
     check(carried.Massless and not carried.CanCollide and not carried.CanQuery,'Carried arrow is inert')
    elseif t==.70 then
     check(carried and carried.Transparency==1 and model.NockedArrow.Transparency==0,'Handoff seats the arrow on the bow before firing')
     check(c.Humanoid.K0BowDrawIK.Target~=socket,'Hand IK returns from quiver to bow nock')
    end
   else
    check(not carried,'R6 keeps its existing reload fallback')
   end
  end
  c:SetAttribute('K0State','Idle');sample(3,start)
  check(q.QuiverArrow1.LocalTransparencyModifier==0,'Stored visual arrow resets for the next attack without ammunition bookkeeping')
 end
 -- A late observer starts in the carried phase without a preceding pickup event.
 c:SetAttribute('K0State','Dodge');Bow.forCharacter(c,199)
 c:SetAttribute('K0State','Attack');c:SetAttribute('K0AttackStartedAt',200);sample(.35,200)
 if rig==Enum.HumanoidRigType.R15 then check(q.QuiverCarriedArrow.Transparency==0,'Late observer reconstructs an already carried arrow')end
 for _,mode in {'Block','Dodge','Dead'}do
  c:SetAttribute('K0State',mode);Visual.renderArms(c,1/60,200.2);Visual.render(model,'None',1,1/60,'Basic',200.2)
  local carried=q:FindFirstChild('QuiverCarriedArrow');check(not carried or carried.Transparency==1,'Cancellation hides the carried arrow: '..mode)
  local ik=c.Humanoid:FindFirstChild('K0BowDrawIK');check(not ik or not ik.Enabled,'Cancellation immediately releases pickup IK: '..mode)
 end
 c:SetAttribute('K0State','Idle');c:SetAttribute('TLTEquippedWeapon','');Visual.render(model,'None',1,1/60,'Basic',201)
 check(q.QuiverFront.Transparency==0,'The default class quiver does not require an equipped bow')
 c:SetAttribute('TLTEquippedWeapon',nil)
 q.QuiverArrow3:Destroy();check(not A.isAttached(model,c,'elf'),'Missing stored arrow invalidates the appearance')
 assert(A.attachInto(model,c,'elf'));check(Q.valid(model,c),'Damaged quiver rebuilds without duplicating the weapon')
 assert(A.attachInto(model,c,'knight'));check(not model:FindFirstChild('ElfQuiver'),'Other classes never inherit the elf prop')
 check(root.CFrame==origin,'Repair and class-visual replacement preserve the physics root')
 c:Destroy()
end
report.pass=true;print('ELF_QUIVER_NATIVE '..game.HttpService:JSONEncode(report))
