-- Real projectile lifecycle, with the skill VFX boundary observed separately.
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local A=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local FX=require(Client.HeroVFX)
local copy=Client.K0SwordVisual:Clone();copy.Name='ProjectileTimingQA'
copy.Source=copy.Source:gsub('return Visual%s*$','Visual.advanceQA=advanceSpells\nreturn Visual');copy.Parent=Client
local V=require(copy)
local original=FX.skill;local calls={};local checks,seq=0,0
local function check(v,label)checks+=1;assert(v,label)end
FX.skill=function(character,id,first,last)calls[#calls+1]={id=id,first=first,last=last}end
local ok,err=xpcall(function()
 for _,rig in {Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15}do
  local desc=Instance.new('HumanoidDescription');local c=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,rig);desc:Destroy()
  c.Parent=workspace;c:PivotTo(CFrame.new(0,500,0))
  local m=Instance.new('Model');m.Parent=c
  for _,row in {{'dwarf','dwarf.common.throw',0},{'mage','mage.common.mana_bolt',1},{'mage','mage.common.water_ball',1},{'mage','mage.common.gravity',0},{'mage',nil,0}}do
   c:SetAttribute('K0ClassId',row[1]);c:SetAttribute('K0SkillId',row[2]);c:SetAttribute('K0State','Idle')
   assert(A.attachInto(m,c,row[1]))
   for _,distance in {8,32}do for _,hz in {30,144}do
    calls={};seq+=1;local at=c.HumanoidRootPart.Position
    c:SetAttribute('K0SpellVisual',string.format('%d|%.3f|%.3f|%.3f|%.3f|%.3f|%.3f',seq,at.X,at.Y,at.Z,at.X,at.Y,at.Z-distance))
    V.renderCharacter(c,1/hz)
    check(#calls==0,'Release does not replay an arrival effect')
    V.renderCharacter(c,1/hz);check(#calls==0,'Duplicate snapshot does not emit effects')
    for _=1,hz do V.advanceQA(1/hz)end
    check(#calls==row[3],'Exactly one terminal burst for eligible spells; no delayed axe/gravity replay')
    for _,event in calls do
     check((event.first-event.last).Magnitude<.001,'Arrival stays at endpoint and never redraws the caster-to-target path')
     check((event.last-(at+Vector3.new(0,0,-distance))).Magnitude<.001,'Terminal burst uses actual endpoint')
    end
    V.advanceQA(1/hz);V.renderCharacter(c,1/hz)
    check(#calls==row[3],'Expired flight cannot replay its terminal effect')
   end end
  end
  c:Destroy()
 end
end,debug.traceback)
FX.skill=original;copy:Destroy()
task.wait(.35) -- Let this fixture's generic terminal flashes expire.
print('PROJECTILE_VFX_TIMING_NATIVE '..game.HttpService:JSONEncode({pass=ok,checks=checks,error=err}));assert(ok,err)
