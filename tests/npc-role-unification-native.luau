assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Use an isolated local fixture')
local World=game.ServerScriptService.Server.World
local Actors=require(World.NPCActors)
local Content=require(game.ReplicatedStorage.Shared.DeepwoodContent)
local Presentation=require(game.StarterPlayer.StarterPlayerScripts.Client.NPCPresentation)
local report={kind='NPC_ROLE_UNIFICATION_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local scratch=Instance.new('Folder');scratch.Name='NPCRoleQA';scratch.Parent=workspace
local view,world,companion
local function rig(position)
 local m=Instance.new('Model');m.Parent=scratch
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.CanCollide=false;root.Position=position;root.Parent=m
 local h=Instance.new('Humanoid');h.Parent=m
 return m,root
end
local function visible(model)
 for _,v in ipairs(model:GetDescendants())do if v:IsA('BasePart') and v.Transparency<1 and v.LocalTransparencyModifier<1 then return true end end
 return false
end
local function identityCount(folder,identity)
 local n=0;for _,m in ipairs(folder:GetDescendants())do if m:IsA('Model') and m:GetAttribute('NPCActorIdentity')==identity then n+=1 end end;return n
end
local ok,err=xpcall(function()
 local eryn=Actors.acquire(scratch,'Eryn',Vector3.new(20000,100,0),{role='scene'})
 local quest=Actors.acquire(scratch,'Outpost Scout',Vector3.new(20002,100,0),{role='quest'})
 local talk=Actors.acquire(scratch,'Eryn',Vector3.new(20004,100,0),{role='dialogue',priority=30})
 check(eryn==quest and quest==talk,'scenery, named alias and dialogue reuse the same instance')
 check(eryn:GetAttribute('NPCRole_scene') and eryn:GetAttribute('NPCRole_quest') and eryn:GetAttribute('NPCRole_dialogue'),'shared actor retains every role')
 check((eryn.PrimaryPart.Position-Vector3.new(20004,100,0)).Magnitude<.01,'authored dialogue anchor wins over decoration')
 local scout=Actors.acquire(scratch,'Wounded Scout',Vector3.new(20000,100,0))
 local survivor=Actors.acquire(scratch,'Supply Survivor',Vector3.new(20000,100,0))
 check(scout~=survivor and scout:GetAttribute('NPCActorIdentity')~=survivor:GetAttribute('NPCActorIdentity'),'sharing Tobin art never merges different residents')
 world=require(World.DeepwoodWorld).create()
 for _,id in ipairs({'eryn','liora','fen','pip','selene'})do check(identityCount(world.folder,'npc:'..id)==1,'one static actor for '..id)end
 for _,c in ipairs(Content.chapters)do if c.side and c.quest.offerPosition then
  local offer=world.nodes[c.id..':request'];local reportNode=world.nodes[c.id..':'..c.quest.turnIn]
  check((offer.part.Position-reportNode.part.Position).Magnitude<.01,'quest accept/report use the same character location')
  local _,identity=require(game.ReplicatedStorage.Shared.NPCIdentity).resolve(c.quest.giver)
  local actor
  for _,m in ipairs(world.folder.NPCActors:GetChildren())do if m:GetAttribute('NPCActorIdentity')==identity then actor=m end end
  check(actor and (actor.PrimaryPart.Position-(offer.part.Position-Vector3.new(0,1,0))).Magnitude<.01,'quest navigation and actor placement agree')
 end end
 local actionTitles={}
 for _,c in ipairs(Content.chapters)do for _,g in ipairs(c.goals)do for _,s in ipairs(g.activity and g.activity.steps or {})do if s.kind=='actor' and not s.actor then actionTitles[s.title]=true end end end end
 for _,m in ipairs(world.folder.NPCActors:GetChildren())do check(not actionTitles[m:GetAttribute('NPCStoryAlias')],'interaction title never spawns a placeholder resident')end
 local count=#world.folder.NPCActors:GetChildren();require(World.DeepwoodWorld).create()
 check(#world.folder.NPCActors:GetChildren()==count,'world reuse is idempotent')
 local camp
 for _,m in ipairs(world.folder.NPCActors:GetChildren())do if m:GetAttribute('NPCActorIdentity')=='npc:selene' then camp=m end end
 local journal={main=2,flags={['DW-03:report']=true},seleneFollowing=true}
 local character,root=rig(world.seleneCamp+Vector3.new(0,3,0))
 local owner={UserId=91,Character=character,GetAttribute=function()return 'Tutorial'end}
 local hero={heroId='qa',training=false};local enemies=Instance.new('Folder');enemies.Parent=scratch
 companion=require(game.ServerScriptService.Server.Story.SeleneCompanion).create({world=world,enemies=enemies,combat={},players=function()return {owner}end,
  active=function()return hero end,context=function()return hero,root end,state=function()return journal end,
  publish=function()end,select=function(_,_,following)journal.seleneFollowing=following end})
 check(identityCount(world.folder,'npc:selene')==1 and camp:GetAttribute('NPCRole_camp') and camp:GetAttribute('NPCRole_dialogue'),'camp selection reuses actual rescue-report model')
 companion.update(.1);local follower=assert(world.folder:FindFirstChild('Selene_91'))
 view=Presentation.create(owner,world.folder,function()return {journal=journal}end);view.update()
 check(visible(follower) and not visible(camp),'following has one visible Selene and hides camp body')
 check(not camp.PrimaryPart.NPCLabel.Enabled and not camp.PrimaryPart.Invite.Invite.Enabled,'hidden actor labels and inputs cannot leak')
 check(follower.PrimaryPart.Rest.Rest.Enabled and not follower.PrimaryPart.Invite.Invite.Enabled,'visible companion inherits the applicable camp selection role')
 view.destroy();view=nil
 local reporterCharacter=rig(world.seleneCamp+Vector3.new(2,3,0))
 local reporter={UserId=92,Character=reporterCharacter,GetAttribute=function()return 'Tutorial'end}
 local reporterJournal={main=2,flags={},seleneFollowing=false}
 view=Presentation.create(reporter,world.folder,function()return {journal=reporterJournal}end);view.update()
 check(visible(camp) and not visible(follower),'unfinished party member can still see rescue-report actor without a duplicate')
 check(not camp.PrimaryPart.Invite.Invite.Enabled and not camp.PrimaryPart.Rest.Rest.Enabled,'locked companion choices do not compete with rescue dialogue')
 view.destroy();view=nil
 local activity=require(World.DeepwoodActivityWorld)
 local mine=activity.actor(world.folder,'Wounded Scout',root.Position,false,{dynamic=true,role='escort',ownerUserId=91})
 local other=activity.actor(world.folder,'Wounded Scout',root.Position,false,{dynamic=true,role='escort',ownerUserId=92})
 view=Presentation.create(owner,world.folder,function()return {journal=journal}end);view.update()
 check(visible(mine) and not visible(other),'personal escorts never render twice for another party member')
 owner.Character=nil;view.update()
 check(visible(camp)~=visible(follower),'loading without a character still shows at most one Selene')
 owner.Character=character;view.update()
 check(visible(follower) and not visible(camp),'new character resumes the personal role without duplicate bodies')
 local extra=Instance.new('Part');extra.Transparency=0;extra.Parent=camp;view.update()
 check(extra.LocalTransparencyModifier==1,'late streamed body pieces stay hidden')
 journal.seleneFollowing=false;companion.update(.1);view.update()
 check(not follower.Parent and visible(camp),'rest removes follower and restores the same camp actor')
 check(camp.PrimaryPart.Invite.Invite.Enabled and not camp.PrimaryPart.Rest.Rest.Enabled,'rest restores invite on the original actor')
 view.destroy();view=nil
 check(extra.LocalTransparencyModifier==0,'presentation cleanup restores original local appearance')
 -- Upgrade a previously authored scene without retaining legacy duplicates.
 local legacy=Instance.new('Folder');legacy.Parent=scratch
 local visuals=require(World.NPCVisual)
 visuals.actor(legacy,'Eryn',Vector3.new(22000,100,0));visuals.actor(legacy,'Outpost Scout',Vector3.new(22001,100,0))
 visuals.actor(legacy,Content.byId['DW-02'].goals[4].title,Vector3.new(22003,100,0))
 local actionTitle=next(actionTitles);visuals.actor(legacy,actionTitle,Vector3.new(22002,100,0))
 Actors.reconcile(legacy)
 check(identityCount(legacy,'npc:eryn')==1,'legacy scene migration merges canonical aliases')
 for _,m in ipairs(legacy:GetDescendants())do if m:IsA('Model')then check(m:GetAttribute('NPCStoryAlias')~=actionTitle,'legacy action-title placeholder removed')end end
end,debug.traceback)
if view then view.destroy()end
if companion then companion.remove({})end
scratch:Destroy();if world then world.folder:Destroy()end
if not ok then table.insert(report.failures,tostring(err))end
report.pass=#report.failures==0
print('NPC_ROLE_UNIFICATION_NATIVE '..game.HttpService:JSONEncode(report))
assert(report.pass,'NPC role unification failed')
