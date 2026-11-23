-- Validate icon-derived cues on actual engine geometry, not only profile entries.
assert(game.PlaceId==0 and game.GameId==0)
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local FX=require(Client.HeroVFX)
local Wind=require(Client.WindLanceVisual)
local Profiles=require(Client.SkillIconVFXProfiles)
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local report={checks=0,skills=0,pulses=0,missing={},maxBeams=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local camera=workspace.CurrentCamera;local old=camera.CFrame;camera.CFrame=CFrame.new(0,12,18)
local floor=Instance.new('Part');floor.Anchored=true;floor.Size=Vector3.new(160,.5,160);floor.Position=Vector3.new(0,-.25,0);floor.Parent=workspace
local first=Vector3.new(0,3,0);local last=Vector3.new(0,3,-10)
local function iconBeams(model)
 local count=0
 for _,node in ipairs(model:GetDescendants())do
  if node:IsA('Beam') and node.Name:sub(1,4)=='Icon'then count+=1 end
 end
 return count
end
local ok,err=xpcall(function()
 for _,class in ipairs({'knight','dwarf','elf','mage'})do for _,d in ipairs(Config.Skills[class])do
  check(Profiles[d.id]~=nil,'icon profile '..d.id)
  local target=(d.form=='area' or d.form=='self') and first or last
  local count=d.pulses or d.shotCount or 1
  for pulse=1,count do
   FX.clear();Wind.clear();local now=workspace:GetServerTimeNow()
   local m
   if d.id=='mage_wind_lance'then
    m=assert(Wind.play(nil,first,target,1,{last},nil,now,nil,d.windup,now))
    check(m:GetAttribute('IconCue')=='wind','dedicated wind icon cue')
    local faces=0;for _,v in ipairs(m:GetDescendants())do if v.Name=='WindSurface'then faces+=1 end end
    check(faces>0,'paired open wind surfaces exist')
   else
    m=assert(FX.skill(nil,d.id,first,target,pulse,{target,target+Vector3.xAxis*3}))
    check(m:GetAttribute('IconCue')==Profiles[d.id].cue,'authored cue reaches geometry '..d.id)
    if iconBeams(m)==0 and not m:GetAttribute('PrimaryIconCue') then table.insert(report.missing,d.id)end
    local _,b=FX.count();report.maxBeams=math.max(report.maxBeams,b)
    check(b<=48,'preserved beam ceiling '..d.id)
    local latest={}
    FX.step(now+.08)
    for _,node in ipairs(m:GetDescendants())do
     if node:IsA('Beam')then
      local a,b=node.Attachment0.WorldPosition,node.Attachment1.WorldPosition
      check(a.X==a.X and b.X==b.X and a.Magnitude<1e5 and b.Magnitude<1e5,'finite moving cue '..d.id)
      if node.Name:sub(1,4)=='Icon'then latest[node]={a,b}end
     elseif node:IsA('BasePart')then check(node.Anchored and not node.CanCollide and not node.CanTouch and not node.CanQuery,'no physics authority '..d.id)end
    end
    FX.step(now+.10);FX.step(now+.08)
    for node,positions in pairs(latest)do check((node.Attachment0.WorldPosition-positions[1]).Magnitude<.002,'frame history independent '..d.id)end
    FX.step(now+1);check(m.Parent==nil and FX.count()==0,'expired cue releases parent and budget '..d.id)
   end
   report.pulses+=1
  end
  report.skills+=1
 end end
 check(report.skills==128,'all 128 skills reviewed')
 check(#report.missing==0,'every skill produces icon-derived geometry: '..table.concat(report.missing,','))
 FX.clear()
 local dawn=assert(FX.skill(nil,'knight.paladin.oath_of_dawn',first,first,1,{}))
 check(dawn:GetAttribute('UltimateSignature')=='DawnAegis','dawn ultimate follows new allied-shield icon')
 check(dawn:FindFirstChild('DawnAegisPanel',true)~=nil and not dawn:FindFirstChild('DawnBladeSpine',true),'dawn has shield panels instead of old solar sword')
 local shields=0;for _,node in ipairs(dawn:GetDescendants())do if node.Name=='IconDawnAegis' and node:IsA('Beam')then shields+=1 end end
 check(shields==18,'three complete shield outlines')
 FX.clear()
 local m=assert(FX.skill(nil,'mage.cryo.chain_lightning',first,last,1,{}))
 check(iconBeams(m)==0,'empty chain does not create lightning targets')
 FX.clear()
 for _=1,30 do FX.skill(nil,'mage.common.gravity',first,last,1,{last})end
 local n,b,c,g,p,f=FX.count()
 check(n<=12 and b<=240 and c<=48 and g<=96 and p<=192 and f<=160,'global scene budgets unchanged')
 FX.clear();Wind.clear()
 check(select(2,FX.count())==0 and select(6,FX.count())==0,'all geometry budgets returned')
end,debug.traceback)
FX.clear();Wind.clear();floor:Destroy();camera.CFrame=old
if not ok then table.insert(report.failures,err)end
report.pass=#report.failures==0
print('SKILL_ICON_VFX_NATIVE '..game.HttpService:JSONEncode(report))
assert(report.pass,'icon VFX acceptance failed')
