-- Test the observable confirmed-hit result for every skill, not palette labels.
assert(game.PlaceId==0 and game.GameId==0 and #game.Players:GetPlayers()==0,'Local fixture only')
local RS=game.ReplicatedStorage;local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Palette=require(RS.Shared.CombatVFXPalette);local Catalog=require(RS.Shared.PixelFXCatalog)
local Config=require(RS.Shared.K0Config);local Hit=require(Client.K0HitEffects)
local Hero=require(Client.HeroVFX);local Pixel=require(Client.PixelFX);local Focus=require(Client.K0MageFocus)
local report={checks=0,skills=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local actor=Instance.new('Model');actor.Name='PaletteReviewTarget';actor.Parent=workspace
local body=Instance.new('Part');body.Name='HumanoidRootPart';body.Anchored=true;body.Position=Vector3.new(0,3,-5);body.Parent=actor;actor.PrimaryPart=body
local camera=workspace.CurrentCamera;local old=camera.CFrame;camera.CFrame=CFrame.new(0,8,12)
local function clear()
 Hero.clear();Pixel.clear()
 for _,p in ipairs(workspace:GetChildren())do if p.Name=='K0HitEffect'or p.Name=='K0CombatAudioEmitter'then p:Destroy()end end
end
local ok,err=xpcall(function()
 for classId,list in pairs(Config.Skills)do for _,d in ipairs(list)do
  clear();check(Hit.show(actor,body.Position,17,classId,'Goblin',Vector3.new(0,0,-1),d.id),'confirmed hit resolves '..d.id)
  local hit=assert(workspace:FindFirstChild('K0HitEffect'))
  local color,hot,key=Palette.resolve(classId,d.id)
  check(hit.Color==color and hit.K0HitFlash.FillColor==color and hit.K0SkillImpact.Color==color,'all visible legacy layers share the element '..d.id)
  check(hit.K0HitFlash.FillTransparency>=.75,'target silhouette remains visible '..d.id)
  check(hit.K0DamageNumber.Amount.Text=='17','actual damage number preserved '..d.id)
  if key=='fire'then check(color.R>color.B*2,'fire stays warm '..d.id)
  elseif key=='lightning'then check(color.B>color.R*1.5,'lightning stays blue '..d.id)
  elseif key=='holy'then check(color.R>.95 and color.B<.25 and hot.B<.6,'holy body and highlight stay gold '..d.id)end
  if classId=='dwarf'and Catalog.byId[d.id].key=='steel'then check(color.R>color.B,'dwarf physical cast/contact stays warm '..d.id)end
  report.skills+=1
 end end
 clear();check(Hit.show(actor,body.Position,17,'elf','Goblin',Vector3.zAxis,'mage.pyro.ember_lance'),'wrong-class ID keeps baseline hit')
 local hit=assert(workspace:FindFirstChild('K0HitEffect'));check(not hit:FindFirstChild('K0SkillImpact')and hit.Color==Palette.colors.arrow,'wrong class cannot select a spell palette')
 local staff=Instance.new('Model');staff.Parent=actor
 local stone=Instance.new('Part');stone.Name='SmallCrystal';stone.Anchored=true;stone.Color=Color3.fromRGB(120,120,120);stone.Parent=staff
 local tip=Instance.new('Attachment');tip.Name='WeaponTip';tip.Parent=stone
 for _,element in ipairs({'fire','water','wind','frost','earth','lightning','arcane','gravity'})do
  Focus.render(staff,{element=element,focus=1},false)
  local light=assert(tip:FindFirstChild('K0StaffFocusLight'))
  check(light.Color==Palette.colors[element]and tip.K0StaffFocus.Color.Keypoints[1].Value==light.Color,'staff and hit palette agree '..element)
 end
 Focus.clear(staff);check(not tip.K0StaffFocusLight.Enabled and tip.K0StaffFocus.Rate==0,'staff focus stops completely')
 staff:Destroy();clear();task.wait(1.4)
 check(not workspace:FindFirstChild('K0HitEffect'),'confirmed-hit layers expire')
end,debug.traceback)
clear();actor:Destroy();camera.CFrame=old
if not ok then report.failures[#report.failures+1]=err end
report.pass=ok;print('VFX_ART_PALETTE_NATIVE '..game.HttpService:JSONEncode(report));assert(ok,err)
