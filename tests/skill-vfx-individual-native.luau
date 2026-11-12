-- Direction and semantic regressions found during the 128-skill visual review.
assert(game.PlaceId==0)
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local FX=require(Client.HeroVFX)
local Profiles=require(Client.SkillVFXProfiles)
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local A=require(game.ReplicatedStorage.Shared.AdvancedSkills)
local result={checks=0,skills=0,failures={}}
local function check(v,m)result.checks+=1;assert(v,m)end
local camera=workspace.CurrentCamera;local old=camera.CFrame;camera.CFrame=CFrame.new(0,10,15)
local floor=Instance.new('Part');floor.Anchored=true;floor.Size=Vector3.new(150,.5,150);floor.Position=Vector3.new(0,-.25,0);floor.Parent=workspace
local from=Vector3.new(0,3,0);local target=Vector3.new(0,3,-12)
local function beams(model,name)
 local list={};for _,node in ipairs(model:GetDescendants())do if node:IsA('Beam')and(not name or node.Name==name)then table.insert(list,node)end end;return list
end
local function cast(id,origin,center,pulse,points)
 FX.clear();return assert(FX.skill(nil,id,origin or from,center or target,pulse or 1,points))
end
local ok,err=xpcall(function()
 for _,list in pairs(Config.Skills)do for _,d in ipairs(list)do
  local profile=Profiles.get(d.id);check(profile~=nil,'individual profile '..d.id)
  check(profile.width>0 and profile.life>0 and profile.life<=.8,'bounded authored values '..d.id)
  result.skills+=1
 end end
 local echo=A.branches.iron_axe.skills[2].id
 local m=cast(echo,nil,nil,2)
 check(m:GetAttribute('Returning')==true,'Returning Echo reverses the second flight')
 local wake=beams(m,'AxeWake')[1]
 check((wake.Attachment0.WorldPosition-target).Magnitude<.001 and(wake.Attachment1.WorldPosition-from).Magnitude<.001,'return endpoints reverse')
 local chain=A.branches.cryo.skills[5].id
 m=cast(chain,nil,nil,1,{target,target+Vector3.xAxis*4})
 local links=beams(m,'ElectricCore')
 check(#links==12,'two confirmed lightning links')
 check((links[6].Attachment1.WorldPosition-target).Magnitude<.001,'first chain ends at first actual target')
 check((links[7].Attachment0.WorldPosition-target).Magnitude<.001,'next chain starts from previous target')
 m=cast(chain,nil,nil,1,{})
 check(#beams(m)==0,'empty chain never fabricates a hit')
 m=cast(A.branches.pyro.skills[6].id,Vector3.new(15,3,0),Vector3.new(0,3,0))
 local sum=Vector3.zero;local list=beams(m,'CinderRing')
 for _,v in ipairs(list)do sum+=v.Attachment0.WorldPosition end
 check(math.abs((sum/#list).X)<.01,'Ember Step remains at server departure center')
 m=cast(A.branches.pyro.skills[7].id)
 check(#beams(m,'StoneLanceAxis')==1 and #beams(m,'EarthFissure')==0,'Stone Lance is airborne rather than a ground earthquake')
 m=cast(A.branches.paladin.skills[11].id)
 check(#beams(m,'SunwardCross')==2,'Sunward Cross has actual crossing blades')
 m=cast('dwarf_low_sweep')
 for _,v in ipairs(beams(m,'LowSweep'))do check(v.Attachment0.WorldPosition.Y<.7,'Low Sweep stays at ankle height')end
 m=cast(A.branches.gunner.skills[7].id)
 check(#beams(m,'ArrowPressure')==5,'Scatter Shot has five authored fan lanes')
 m=cast('knight.common.bash',from,from+Vector3.xAxis*5)
 for _,v in ipairs(beams(m,'GuardHalo'))do check(math.abs(v.Attachment0.WorldPosition.X-2)<.01,'shield plane faces the actual attack direction')end
 FX.clear()
 local char=Instance.new('Model');char.Name='ConfirmedMultiVFX';char.Parent=workspace
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Position=from;root.Parent=char
 char:SetAttribute('K0ClassId','elf');char:SetAttribute('K0State','Idle');char:SetAttribute('K0SkillId','elf.common.multi')
 char:SetAttribute('K0ArrowVisual','1|0|3|0|0|3|-12')
 char:SetAttribute('K0MultiShotVisual','1|0|3|0|-4|3|-10|-2|3|-11|2|3|-11|4|3|-10')
 require(Client.K0SwordVisual).renderCharacter(char,1/60,workspace:GetServerTimeNow())
 local lanes=0
 for _,node in ipairs(workspace:GetChildren())do if node.Name=='HeroVFX'then lanes+=#beams(node,'ArrowPressure')end end
 check(lanes==5,'live multishot renders one primary plus four confirmed lanes, never a second synthetic fan')
 FX.clear();char:Destroy()
 for _,node in ipairs(workspace:GetChildren())do if node.Name=='K0VisualArrow'then node:Destroy()end end
 local endpoints={Vector3.new(-3,3,-8),Vector3.new(0,3,-10),Vector3.new(3,3,-8)}
 m=cast('elf.common.multi',from,target,1,endpoints)
 local pressure=beams(m,'ArrowPressure');check(#pressure==3,'common multishot uses confirmed released arrows')
 for i,v in ipairs(pressure)do check((v.Attachment1.WorldPosition-endpoints[i]).Magnitude<.001,'confirmed multishot endpoint '..i)end
end,debug.traceback)
FX.clear();floor:Destroy();camera.CFrame=old
if not ok then table.insert(result.failures,err)end
result.pass=#result.failures==0
print('SKILL_VFX_INDIVIDUAL_NATIVE '..game.HttpService:JSONEncode(result))
assert(result.pass,'individual skill VFX regression')
