assert(game.PlaceId==0,"Local fixture only")
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local FX=require(Client.HeroVFX)
local Visual=require(Client.AdvancedSkillVisual)
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local Sword=require(Client.K0SwordVisual)
local Catalog=require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local report={checks=0,skills=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local camera=workspace.CurrentCamera;local old=camera.CFrame;camera.CFrame=CFrame.new(0,8,12)
local char=Instance.new('Model');char.Name='HeroVFXQA';char.Parent=workspace
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Position=Vector3.new(0,4,0);root.Parent=char
local first,last=root.Position,Vector3.new(0,4,-8)
local ok,err=xpcall(function()
 for class,list in pairs(Config.Skills)do
  for _,d in ipairs(list)do
   FX.clear()
   local model=FX.skill(char,d.id,first,last,1,{last,last+Vector3.new(3,0,-2)})
   if d.id=="mage_wind_lance"then check(model==nil,"dedicated wind renderer is not duplicated")else
   check(model~=nil,'skill resolves '..d.id)
   local count,beams,chips=FX.count()
   check(count==1 and beams<=48 and chips<=7,'per skill budget '..d.id)
   -- Wind Lance has its own existing renderer; all other styles must draw geometry.
   check(beams+chips>0 or d.id=='mage_wind_lance','authored silhouette '..d.id)
   for _,v in ipairs(model:GetDescendants())do
    if v:IsA('BasePart')then check(v.Anchored and not v.CanCollide and not v.CanTouch and not v.CanQuery,'no physics authority')end
   end
   for _,hz in ipairs({30,60,144})do FX.step(workspace:GetServerTimeNow()+1/hz)end
   for _,v in ipairs(model:GetDescendants())do
    if v:IsA('Attachment')then check(v.WorldPosition.Magnitude<1e7,'finite geometry')end
   end
   FX.step(workspace:GetServerTimeNow()+2)
   check(model.Parent==nil and FX.count()==0,'complete cleanup')
   end
   local hit=FX.contact(last,class,d.id,Vector3.new(0,0,-1),1)
   check(hit~=nil and hit:GetAttribute('Style')==Catalog.byId[d.id].key,'elemental contact '..d.id)
   report.skills+=1
  end
  FX.clear();check(FX.contact(last,class,nil,Vector3.new(0,0,-1),1)~=nil,'class basic contact')
 end
 FX.clear()
 local seq=100
 for _,classId in ipairs({'knight','dwarf'})do
  for i=1,3 do
   local d=Config.Skills[classId][i]
   if not d.ranged then
    FX.clear();seq+=1
    char:SetAttribute('K0ClassId',classId);char:SetAttribute('K0SkillId',d.id)
    char:SetAttribute('K0State','Attack');char:SetAttribute('K0AttackPhase','Active')
    char:SetAttribute('K0AttackSeq',seq);char:SetAttribute('K0SkillStartedAt',workspace:GetServerTimeNow())
    local at=char:GetAttribute('K0SkillStartedAt')+d.windup+(d.hitDelay or 0)
    Sword.renderCharacter(char,1/60,at-.02)
    check(FX.count()==0,'common effect waits for contact '..d.id)
    Sword.renderCharacter(char,1/60,at+.01)
    check(FX.count()==1,'common attribute wiring '..d.id)
    Sword.renderCharacter(char,1/60,at+.02)
    check(FX.count()==1,'common effect plays once '..d.id)
   end
  end
 end
 FX.clear()
 local d=Config.Skills.knight[4]
 Visual.play(char,d.id,first,last,1,{},1000,workspace:GetServerTimeNow())
 check(FX.count()==1,'first confirmed sequence renders')
 Visual.play(char,d.id,first,last,1,{},1000,workspace:GetServerTimeNow())
 check(FX.count()==1,'duplicate pulse cannot replay')
 FX.clear()
 Visual.play(char,d.id,first,last,1,{},1001,workspace:GetServerTimeNow()-2)
 check(FX.count()==0,'stale pulse cannot replay')
 check(FX.skill(char,'unknown',first,last,1)==nil,'unknown skill rejected')
 check(FX.skill(char,'mage.common.gravity',Vector3.new(0/0,0,0),last,1)==nil,'invalid vectors rejected')
 camera.CFrame=CFrame.new(1000,10,0)
 check(FX.skill(char,'mage.common.gravity',first,last,1)==nil,'distant casts culled')
 camera.CFrame=old
 for _=1,30 do FX.skill(char,'mage.common.gravity',first,last,1)end
 local count,beamCount,chipCount=FX.count()
 check(count<=12 and beamCount<=240 and chipCount<=48,'global load bounded')
 FX.clear();check(select(2,FX.count())==0 and select(3,FX.count())==0,'all budgets released')
 -- Confirm the actual advanced event renderer reaches the new layer.
 camera.CFrame=CFrame.new(0,8,12)
 for _,list in pairs(Config.Skills)do for _,d in ipairs(list)do if d.advanced and d.id~='mage_wind_lance'then
  FX.clear();Visual.play(char,d.id,first,last,1,{},nil,workspace:GetServerTimeNow())
  check(FX.count()==1,'advanced event wiring '..d.id)
  -- Same sequence: a charge packet cannot run after its release, including
  -- ground telegraphs and temporary weapon props.
  local sequence=2000+report.skills
  Visual.play(char,d.id,first,last,1,{},sequence,workspace:GetServerTimeNow())
  local before=#workspace:GetDescendants()
  Visual.play(char,d.id,first,last,0,nil,sequence)
  check(#workspace:GetDescendants()==before,'late preparation does not replay after release '..d.id)
 end end end
end,debug.traceback)
FX.clear();char:Destroy();camera.CFrame=old
if not ok then table.insert(report.failures,err)end
report.pass=#report.failures==0
print('HERO_VFX_NATIVE '..game.HttpService:JSONEncode(report))
assert(report.pass,'Hero VFX failed')
