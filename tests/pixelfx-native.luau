-- Actual Roblox instances; no damage, saving, purchases or published-place mutation.
assert(game.PlaceId==0,"PixelFX QA requires a local isolated place")
local RS=game:GetService("ReplicatedStorage")
local Config=require(RS.Shared.K0Config)
local Catalog=require(RS.Shared.PixelFXCatalog)
local Assets=require(RS.Shared.PixelFXAssets)
local Client=game:GetService("StarterPlayer").StarterPlayerScripts.Client
local FX=require(Client.PixelFX)
local Controller=require(Client.PixelFXController)
local report={kind="PIXELFX_NATIVE",checks=0,skills=0,basic=0,assets=0,failures={}}
local function check(v,label)report.checks+=1;assert(v,label)end
local camera=workspace.CurrentCamera
local saved=camera and camera.CFrame
if camera then camera.CFrame=CFrame.new(0,503,10) end
local character=Instance.new("Model");character.Name="PixelFXFixture";character.Parent=workspace
local root=Instance.new("Part");root.Name="HumanoidRootPart";root.Anchored=true;root.Position=Vector3.new(0,500,0);root.Parent=character
character:SetAttribute("K0State","Attack");character:SetAttribute("K0AttackSeq",1)
local function inspect()
 check(FX.count()>0,"effect exists")
 for _,p in ipairs(workspace:GetChildren()) do if p.Name=="PixelFXAccent" then
  check(p.CanCollide==false and p.CanTouch==false and p.CanQuery==false,"cosmetic physics only")
  check(p.PixelFXSprite.AlwaysOnTop==false,"world occlusion preserved")
  local image=p.PixelFXSprite.Frame
  check(image.ResampleMode==Enum.ResamplerMode.Pixelated,"pixelated sampling")
  check(image.ImageRectSize==Vector2.new(128,128),"padded atlas cell")
  check(image.ImageRectOffset.X%128==0 and image.ImageRectOffset.Y%128==0,"aligned frame")
 end end
end
local ok,err=xpcall(function()
 for key in pairs(Assets) do
  report.assets+=1;FX.clear()
  check(FX.emit(key,root.Position,2,.5,{manual=true}),key.." texture configured")
  FX.step(.15);inspect();FX.step(1);check(FX.count()==0,"expiry cleans instances")
 end
 check(report.assets==20,"20 texture profiles")
 for classId,list in pairs(Config.Skills) do
  character:SetAttribute("K0ClassId",classId)
  for _,d in ipairs(list) do
   FX.clear();report.skills+=1
   local row=Catalog.get(classId,d.id)
   check(row and Assets[row.key],d.id.." has valid texture mapping")
   check(Catalog.get(classId=="knight" and "mage" or "knight",d.id)==nil,"foreign class ID rejected")
   check(FX.hit(root.Position,classId,d.id),d.id.." confirmed contact")
   inspect();FX.clear()
   if d.advanced then
    character:SetAttribute("K0AttackSeq",report.skills+1)
    check(not FX.skill(character,d.id,root.Position,root.Position+Vector3.new(0,0,-3),0,nil,1),"windup never emits contact")
    for pulse=1,d.pulses do
     FX.clear();check(FX.skill(character,d.id,root.Position,root.Position+Vector3.new(0,0,-3),pulse,nil,report.skills+1),d.id.." pulse "..pulse)
    end
   else
    character:SetAttribute("K0SkillId",d.id);character:SetAttribute("K0AttackStartedAt",100)
    character:SetAttribute("K0AttackSeq",report.skills+1)
    for beat=1,d.shotCount or 1 do
     FX.clear()
     local now=100+d.windup+(d.hitDelay or 0)+(beat-1)*(d.shotInterval or .3)+.01
     check(Controller.renderCharacter(character,now),d.id.." release "..beat)
     check(not Controller.renderCharacter(character,now),"release is idempotent")
    end
   end
  end
  character:SetAttribute("K0SkillId",nil);character:SetAttribute("K0Combo",1)
  character:SetAttribute("K0AttackSeq",1000+report.skills);character:SetAttribute("K0AttackStartedAt",100)
  local d=Config.BasicAttackProfiles[classId].attacks[1]
  FX.clear();check(Controller.renderCharacter(character,100+d.windup+(d.hitDelay or 0)+.01),classId.." basic release")
  report.basic+=1
 end
 check(report.skills==128 and report.basic==4,"all 128 skills and 4 basic profiles")
 FX.clear()
 for _,action in ipairs({"Heal","Protect","Cleanse"})do check(FX.support(character,action),"Selene "..action)end
 FX.clear();check(FX.emit("steel",root.Position,2,1,{manual=true,character=character,seq=character:GetAttribute("K0AttackSeq")}),"cancellable cast")
 character:SetAttribute("K0State","Dodge");FX.step(.01);check(FX.count()==0,"dodge cancels")
 character:SetAttribute("K0State","Attack")
 for _,state in ipairs({"Dead","Stunned","Block"}) do
  FX.emit("steel",root.Position,2,1,{manual=true,character=character,seq=character:GetAttribute("K0AttackSeq")})
  character:SetAttribute("K0State",state);FX.step(.01);check(FX.count()==0,state.." cancels")
  character:SetAttribute("K0State","Attack")
 end
 FX.emit("steel",root.Position,2,1,{manual=true,character=character,seq=character:GetAttribute("K0AttackSeq")})
 character:SetAttribute("K0AttackSeq",9999);FX.step(.01);check(FX.count()==0,"new attack clears previous accent")
 for i=1,24 do check(FX.emit("steel",root.Position,2,.5,{manual=true}),"budget slot "..i)end
 check(not FX.emit("steel",root.Position,2,.5,{manual=true}) and FX.count()==24,"global budget enforced")
 FX.step(2);check(FX.count()==0,"busy burst leaves no residual")
 check(not FX.emit("unknown",root.Position,2,.5),"unknown texture ignored")
 check(not FX.emit("steel",Vector3.new(0/0,0,0),2,.5),"nonfinite position ignored")
 check(not FX.emit("steel",root.Position,-1,.5),"negative size ignored")
 local d=Config.Skills.elf[2]
 check(Catalog.beat(d,20)==0,"old rapid-fire is not replayed")
 character:SetAttribute("K0HurtAt",200);character:SetAttribute("K0HurtDamage",1)
 check(Controller.renderHurt(character,200.01),"enemy confirmed damage accent")
 check(not Controller.renderHurt(character,200.02),"hurt accent idempotent");FX.clear()
 character:SetAttribute("K0EnemyState","Active");character:SetAttribute("K0AttackSeq",2)
 character:SetAttribute("K0EnemyAttackClock","2|100.000000|0.500000|0.100000|0.500000|0")
 character:SetAttribute("K0AttackOrigin",root.Position);character:SetAttribute("K0AttackDirection",Vector3.new(0,0,-1))
 check(FX.enemy(character,100.51),"enemy release accent")
 check(not FX.enemy(character,100.52),"enemy release idempotent");FX.clear()
end,debug.traceback)
FX.clear();character:Destroy();if camera then camera.CFrame=saved end
if not ok then table.insert(report.failures,err)end
report.status=ok and "PASS" or "FAIL"
print(game:GetService("HttpService"):JSONEncode(report))
assert(ok,err)
return report
