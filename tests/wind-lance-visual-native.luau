assert(game.PlaceId==0,'Local fixture only')
local Wind=require(game.StarterPlayer.StarterPlayerScripts.Client.WindLanceVisual)
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local report={kind='WIND_LANCE_VISUAL_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local camera=workspace.CurrentCamera;local old=camera.CFrame;camera.CFrame=CFrame.new(0,6,12)
local character=Instance.new('Model');character.Name='MageWindQA';character.Parent=workspace
character:SetAttribute('K0State','Attack');character:SetAttribute('K0SkillId','mage_wind_lance')
local weapon=Instance.new('Model');weapon:SetAttribute('WeaponClassId','mage');weapon.Parent=character
local grip=Instance.new('Part');grip.Name='WeaponGrip';grip.Anchored=true;grip.Position=Vector3.new(1,5,0);grip.Parent=weapon
local tip=Instance.new('Attachment');tip.Name='WeaponTip';tip.Position=Vector3.new(0,2,0);tip.Parent=grip
local origin=Vector3.new(0,5,0);local center=Vector3.new(0,5,-30)
local ok,e=xpcall(function()
 local live=Wind.play(character,origin,center,1,{},-1,workspace:GetServerTimeNow(),nil,.25)
 check(live~=nil,'real epoch-sized server clock renders confirmed casts')
 Wind.clear()
 character:SetAttribute('K0State','Idle')
 local early=assert(Wind.play(character,origin,center,0,nil,0,nil,99,.25,99))
 Wind.step(99.04);check(early.Parent~=nil,'server cast survives late replication of action attributes')
 character:SetAttribute('K0State','Attack');Wind.step(99.09);check(early.Parent~=nil,'late action attributes join the same charge')
 Wind.clear()
 local d=Config.Skills.mage[30]
 check(d.id=='mage_wind_lance' and d.range==30 and d.maxTargets==3 and d.manaCost==14 and d.cooldown==6,'existing skill and balance unchanged')
 local charge=assert(Wind.play(character,origin,center,0,nil,1,nil,100,.25,100))
 Wind.step(100.1)
 check((charge.WindCarrier.Position-tip.WorldPosition).Magnitude<.001,'charge follows actual staff tip')
 check(charge:GetAttribute('Stage')=='Charge','separate visible windup')
 local cast=assert(Wind.play(character,origin,center,1,{Vector3.new(0,5,-12)},1,100.25,100,.25,100.25))
 check(charge.Parent==nil,'release removes old charge')
 check(Wind.play(character,origin,center,1,{},1,100.25,100,.25,100.25)==nil,'duplicate server pulse cannot double effect')
 local carrier=cast.WindCarrier
 for _,hz in ipairs({30,60,144})do
  Wind.step(100.25+1/hz)
  check((carrier.WindLanceCore2.WorldPosition-center).Magnitude<.002,'visual ends exactly at server endpoint')
  check(math.abs(carrier.AirSpiral2.Position.X)>.001 or math.abs(carrier.AirSpiral2.Position.Y)>.001,'air curls around lance axis')
 end
 local parts,beams=0,0
 for _,v in cast:GetDescendants()do
  if v:IsA('BasePart')then parts+=1;check(v.Anchored and not v.CanCollide and not v.CanTouch and not v.CanQuery,'effects have no physics or hit authority')end
  if v:IsA('Beam')then beams+=1;check(v.Width0>=0 and v.Width0==v.Width0,'finite ribbon geometry')end
 end
 check(parts==1 and beams==71,'bounded single carrier and 71 ribbons for one hit')
 Wind.step(101);check(cast.Parent==nil,'expired effect destroys every ribbon and attachment')
 local canceled=assert(Wind.play(character,origin,center,0,nil,2,nil,102,.25,102))
 character:SetAttribute('K0State','Dodge');Wind.step(102.01);check(canceled.Parent==nil,'canceled cast removes windup immediately')
 character:SetAttribute('K0State','Attack')
 check(Wind.play(character,origin,center,1,{},3,99,nil,.25,103)==nil,'stale pulses do not replay')
 check(Wind.play(character,Vector3.new(0/0,0,0),center,1,{},3,103,nil,.25,103)==nil,'invalid coordinates rejected')
 for seq=4,7 do check(Wind.play(character,origin,center,1,{},seq,104,nil,.25,104)~=nil,'four visible casts allowed')end
 check(Wind.play(character,origin,center,1,{},8,104,nil,.25,104)==nil,'global cast budget bounds simultaneous effects')
 Wind.clear();check(not workspace:FindFirstChild('WindLanceVFX'),'clear removes all transient instances')
 camera.CFrame=CFrame.new(1000,5,0)
 check(Wind.play(character,origin,center,1,{},9,105,nil,.25,105)==nil,'distant casts are culled')
end,debug.traceback)
Wind.clear();character:Destroy();camera.CFrame=old
if not ok then table.insert(report.failures,e)end
report.pass=#report.failures==0;print('WIND_LANCE_VISUAL_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'Wind Lance VFX failed')
