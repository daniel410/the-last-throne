-- Isolated presentation fixture: no profile writes, combat or live player required.
return function(Presentation)
 local report={checks=0}
 local function check(v,m)report.checks+=1;assert(v,m)end
 local Tags=game:GetService('CollectionService')
 local folder=Instance.new('Folder');folder.Name='SeleneRecruitmentPresentationQA';folder.Parent=workspace
 local view
 local ok,err=xpcall(function()
  local camp=Instance.new('Model');camp.Name='Camp';camp:SetAttribute('NPCActorIdentity','npc:selene');camp:SetAttribute('NPCRole_camp',true);camp:SetAttribute('SeleneCampPosition',Vector3.zero);camp.Parent=folder
  local part=Instance.new('Part');part.Anchored=true;part.Parent=camp;camp.PrimaryPart=part
  for _,name in ipairs({'Invite','Rest'})do local prompt=Instance.new('ProximityPrompt');prompt.Name=name;prompt.Parent=part end
  Tags:AddTag(camp,'TLTStoryNPC')
  local character=Instance.new('Model');character.Parent=folder
  local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Position=Vector3.new(0,3,0);root.Anchored=true;root.Parent=character
  local state={journal={main=2,flags={}},supporter={pass={active=false,credits=1}}}
  view=Presentation.create({UserId=91,Character=character},folder,function()return state end)
  view.update();check(not part.Invite.Enabled and not part.Rest.Enabled,'locked rescue cannot invite')
  state.journal.seleneUnlocked=true
  view.update();check(part.Invite.Enabled and not part.Rest.Enabled,'permanent unlock exposes invite before replay report')
  state.journal.seleneFollowing=true;state.supporter.pass.active=true
  view.update();check(part.Rest.Enabled and not part.Invite.Enabled,'active support exposes rest')
  local follower=camp:Clone();follower.Name='Follower';follower:SetAttribute('NPCRole_camp',nil);follower:SetAttribute('NPCActorRole','companion');follower:SetAttribute('OwnerUserId',91);follower.Parent=folder;Tags:AddTag(follower,'TLTStoryNPC')
  view.update();check(part.LocalTransparencyModifier==1 and follower.PrimaryPart.LocalTransparencyModifier==0,'replay rescue actor cannot hide recruited follower')
  follower:Destroy();state.supporter.pass.active=false
  view.update();check(part.Invite.Enabled and not part.Rest.Enabled,'next story offers explicit reinvitation')
  state.journal.seleneUnlocked=nil;state.journal.flags['DW-03:report']=true
  view.update();check(part.Invite.Enabled,'original rescue report still exposes invite')
  root.Position=Vector3.new(40,3,0);view.update();check(not part.Invite.Enabled,'invitation stays restricted to camp range')
 end,debug.traceback)
 if view then view.destroy()end;folder:Destroy()
 assert(ok,err);return report
end
