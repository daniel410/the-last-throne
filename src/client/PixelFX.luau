-- Client-only, occluded pixel accents on existing server-confirmed presentation.
-- PixelFX art is MIT; see assets/effects/pixelfx-v1/LICENSE.pixelfx.txt.
local RS=game:GetService("ReplicatedStorage")
local Run=game:GetService("RunService")
local Assets=require(RS.Shared.PixelFXAssets)
local Catalog=require(RS.Shared.PixelFXCatalog)
local Curated=require(script.Parent.CuratedVFX)
local FX={}
local records={}
local connection
local MAX_ACTIVE=24
local MAX_DISTANCE=80
local function finite(n) return type(n)=="number" and n==n and math.abs(n)<1e7 end
local function vector(v) return typeof(v)=="Vector3" and finite(v.X) and finite(v.Y) and finite(v.Z) end
local function remove(index)
 local r=table.remove(records,index)
 if r then Curated.release(r.curated) end
 if r and r.holder.Parent then r.holder:Destroy() end
end
local function cancelled(r)
 if not r.character then return false end
 local c=r.character
 if not c:IsDescendantOf(workspace) or c:GetAttribute("TLTDeathFalling") or c:GetAttribute("K0State")=="Dead" then return true end
 if r.seq and c:GetAttribute("K0AttackSeq")~=r.seq then return true end
 if r.seq then
  local state=c:GetAttribute("K0State")
  if state=="Dodge" or state=="Block" or state=="HitStun" or state=="Stunned" then return true end
 end
 local h=c:FindFirstChildOfClass("Humanoid")
 return h~=nil and h.Health<=0
end
function FX.step(dt)
 if not finite(dt) or dt<0 then return end
 for i=#records,1,-1 do
  local r=records[i]
  r.age+=dt
  if not r.holder.Parent or r.age>=r.duration or cancelled(r) or r.follow and not r.follow:IsDescendantOf(workspace) then remove(i)
  else
   if r.follow then r.holder.Position=r.follow.Position+r.offset end
   Curated.step(r.curated,r.age)
   if r.image then
    local index=math.min(15,math.floor(r.age/r.duration*16))
    r.image.ImageRectOffset=Vector2.new(index%4*128,math.floor(index/4)*128)
    r.image.ImageTransparency=.12+math.clamp((r.age/r.duration-.7)/.3,0,1)*.88
   end
  end
 end
 if #records==0 and connection then connection:Disconnect();connection=nil end
end
function FX.emit(key,position,size,duration,options)
 options=options or {}
 if not Assets[key] or not vector(position) or not finite(size) or size<=0 or not finite(duration) or duration<=0 then return false end
 local camera=workspace.CurrentCamera
 if camera and (camera.CFrame.Position-position).Magnitude>MAX_DISTANCE then return false end
 -- Decorative accents may be dropped under load; the existing 3D information remains.
 if #records>=MAX_ACTIVE then return false end
 local holder=Instance.new("Part")
 holder.Name="PixelFXAccent";holder.Size=Vector3.one*.05;holder.Position=position
 holder.Anchored=true;holder.Transparency=1;holder.CanCollide=false;holder.CanTouch=false;holder.CanQuery=false;holder.CastShadow=false
 holder:SetAttribute("PixelFXKey",key)
 local curated=options.curated and Curated.mount(holder,options.curated,math.clamp(size,.3,6))
 local image
 if not curated then
 local gui=Instance.new("BillboardGui")
 gui.Name="PixelFXSprite";gui.Size=UDim2.fromScale(math.clamp(size,.3,6),math.clamp(size,.3,6))
 gui.AlwaysOnTop=false;gui.LightInfluence=0;gui.MaxDistance=MAX_DISTANCE;gui.Adornee=holder;gui.Parent=holder
 image=Instance.new("ImageLabel")
 image.Name="Frame";image.Size=UDim2.fromScale(1,1);image.BackgroundTransparency=1
 image.Image=Assets[key];image.ImageRectSize=Vector2.new(128,128);image.ImageRectOffset=Vector2.zero
 image.ResampleMode=Enum.ResamplerMode.Pixelated;image.ImageTransparency=.12;image.Parent=gui
 end
 holder.Parent=workspace
 Curated.play(curated)
 local r={holder=holder,image=image,curated=curated,key=key,age=0,duration=math.clamp(duration,.12,1.6),character=options.character,seq=options.seq,follow=options.follow,offset=options.offset or Vector3.zero}
 table.insert(records,r)
 -- Fixtures can step explicitly without leaving a frame connection behind.
 if not options.manual and not connection and Run:IsClient() then connection=Run.RenderStepped:Connect(FX.step) end
 return true,holder
end
function FX.hit(position,classId,id,scale)
 local row=Catalog.get(classId,id)
 if not row then return false end
 return FX.emit(row.key,position,(row.key=="axe" and 2.5 or 1.8)*(scale or 1),.32)
end
local seenPulses=setmetatable({},{__mode="k"})
function FX.skill(character,id,origin,center,pulse,points,seq,firedAt)
 local row=Catalog.byId[id]
 if not row or not vector(origin) or not vector(center) or not finite(pulse) or pulse<1 then return false end
 if finite(firedAt) then
  local age=workspace:GetServerTimeNow()-firedAt
  if age<-.1 or age>.5 then return false end
 end
 if character then
  if seq and character:GetAttribute("K0AttackSeq")~=seq then return false end
  local old=seenPulses[character]
  if old and seq and old.seq==seq and old.id==id and old.pulse>=pulse then return false end
  seenPulses[character]={seq=seq,id=id,pulse=pulse}
 end
 local d=row.definition
 local area=d.form=="area" or d.form=="ground" or d.detonate
 local at=center
 if d.form=="melee" or d.form=="cone" or d.form=="self" or d.form=="area" then
  local delta=center-origin
  at=origin+(delta.Magnitude>.01 and delta.Unit or Vector3.new(0,0,-1))*((d.form=="self" or d.form=="area") and 0 or 2)
 end
 local opts={character=character,seq=seq}
 local imported=Curated.keyFor(id)
 if imported then
  opts.curated=imported
  -- Ground-centered artwork follows the same world floor as the existing 3D.
  local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
  params.FilterDescendantsInstances=character and {character}or{};params.RespectCanCollide=true
  local hit=workspace:Raycast(at+Vector3.new(0,2,0),Vector3.new(0,-18,0),params)
  at=hit and hit.Position+Vector3.new(0,.12,0)or at-Vector3.new(0,2.7,0)
  -- Keep the camera-facing burst above the floor; it is not the area boundary.
  if imported=='blast'then at=at+Vector3.new(0,1.6,0)end
  return FX.emit(row.key,at,imported=='blast'and 3.2 or 4.5,Curated.duration(imported),opts)
 end
 return FX.emit(row.key,at,area and 4.5 or d.form=="self" and 3.5 or 2.5,area and .7 or .4,opts)
end
function FX.support(character,action)
 local root=character and character:FindFirstChild("HumanoidRootPart")
 local key=({Heal="heal",Protect="ward",Cleanse="cleanse"})[action]
 if not root or not key then return false end
 local curated=action=='Heal'and'heal'or action=='Cleanse'and'cleanse'or nil
 return FX.emit(key,root.Position,3.8,curated and Curated.duration(curated)or .8,{character=character,follow=root,curated=curated})
end
function FX.preloadCurated()Curated.preload()end
local seenEnemies=setmetatable({},{__mode="k"})
function FX.enemy(model,now)
 if model:GetAttribute("K0EnemyState")~="Active" then return false end
 local clock=model:GetAttribute("K0EnemyAttackClock")
 if type(clock)~="string" or #clock>150 then return false end
 local seq,at,windup=clock:match("^(%d+)|([%d%.]+)|([%d%.]+)|")
 seq,at,windup=tonumber(seq),tonumber(at),tonumber(windup)
 if not seq or not at or not windup or model:GetAttribute("K0AttackSeq")~=seq or seenEnemies[model]==clock then return false end
 local age=now-at-windup
 if age<0 or age>.15 then return false end
 local origin,direction=model:GetAttribute("K0AttackOrigin"),model:GetAttribute("K0AttackDirection")
 if not vector(origin) or not vector(direction) then return false end
 seenEnemies[model]=clock
 local delta=direction.Magnitude>.01 and direction.Unit or Vector3.new(0,0,-1)
 return FX.emit("enemy",origin+delta*2,2,.3,{character=model,seq=seq})
end
function FX.count() return #records end
function FX.clear()
 for i=#records,1,-1 do remove(i) end
 if connection then connection:Disconnect();connection=nil end
end
return FX
