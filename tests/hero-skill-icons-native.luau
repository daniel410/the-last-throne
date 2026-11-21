-- Native UI integration with a fixture actor; no saves, combat or publishing.
return function(req,tree,root,actor)
 local A=req(tree.src.shared.SkillIconAssets)
 local K=req(tree.src.shared.K0Config)
 local G=req(tree.src.shared.HeroProgression)
 local Advanced=req(tree.src.shared.AdvancedSkills)
 local Glyph=req(tree.src.client.SkillGlyph)
 local Icon=req(tree.src.client.SkillIcon)
 local Tree=req(tree.src.client.HeroSkillTree)
 local TextService=game:GetService('TextService')
 local report={checks=0,skills=0,treeCases=0,hudCases=0,coverage='Studio native GUI with fixture actor; no live Player, published client or physical device'}
 local function check(value,label)report.checks+=1;assert(value,label)end
 local count=0;local seen={}
 for id,asset in pairs(A.byId)do
  count+=1;check(asset:match('^rbxassetid://%d+$')~=nil,id..' asset format')
  check(not seen[asset],id..' unique asset');seen[asset]=true
 end
 check(count==128,'all 128 registered assets')
 local skill=K.Skills.elf[1]
 local art=A.byId[skill.id]
 A.byId[skill.id]='rbxassetid://0'
 local probe=Glyph.draw(root,'elf',skill,44,true)
 A.byId[skill.id]=art
 check(probe.Fallback.Visible and probe.Fallback.Text=='AI','unavailable tree image has a skill glyph')
 task.wait()
 check(not probe.IsLoaded and probe.Fallback.Visible,'unavailable image keeps the glyph')
 Icon.set(probe,skill,true,true)
 check(probe.Fallback.Visible and probe.Fallback.TextTransparency==probe.ImageTransparency,'cooldown dims the fallback glyph')
 Icon.set(probe,skill,true,false)
 local deadline=os.clock()+10
 repeat task.wait() until (probe.IsLoaded and not probe.Fallback.Visible) or os.clock()>=deadline
 check(probe.IsLoaded and not probe.Fallback.Visible,
  string.format('late image replaces glyph without a redraw (loaded=%s, fallback=%s, status=%s)',tostring(probe.IsLoaded),tostring(probe.Fallback.Visible),game:GetService('ContentProvider'):GetAssetFetchStatus(art).Name))
 probe:Destroy()
 local unregistered=Glyph.draw(root,'elf',{id='fixture.unregistered',name='TEST SKILL'},44,false)
 check(unregistered.Fallback.Visible and unregistered.Fallback.Text=='TE' and unregistered.Fallback.TextColor3.R<.5,'unregistered skill has a locked glyph')
 Icon.set(unregistered,nil,false,false)
 check(not unregistered.Visible and not unregistered.Fallback.Visible and unregistered.Fallback.Text=='','cleared skill also clears its glyph')
 unregistered:Destroy()
 for classId,skills in pairs(K.Skills)do
  check(#skills==32,classId..' 32 definitions')
  for _,skill in ipairs(skills)do
   report.skills+=1
   local caption=TextService:GetTextSize(skill.name,8,Enum.Font.GothamMedium,Vector2.new(58,10000))
   check(caption.Y<=20,skill.id..' HUD name fits')
   local image=Glyph.draw(root,classId,skill,44,true)
   check(image:IsA('ImageLabel')and image.Image==A.byId[skill.id],skill.id..' glyph identity')
   check(image:GetAttribute('SkillId')==skill.id,skill.id..' provenance')
   Icon.set(image,skill,false,false);check(image.ImageColor3.R<.5,skill.id..' locked tint')
   Icon.set(image,skill,true,true);check(image.Visible and image.ImageTransparency>0,skill.id..' cooldown keeps art')
   Icon.set(image,nil,false,false);check(not image.Visible and image.Image=='',skill.id..' cleared reuse')
   image:Destroy()
  end
 end
 local stat=Glyph.draw(root,'dwarf',{root=1},36,true)
 check(stat:IsA('Frame')and #stat:GetChildren()>1,'stat emblem retained');stat:Destroy()
 for _,width in ipairs({1160,640,280})do
  for classId,paths in pairs(Advanced.order)do
   for _,path in ipairs(paths)do
    root:ClearAllChildren();root.Size=UDim2.fromOffset(width,700);task.wait()
    local growth=G.new(99);growth.branch=path;growth.stage=4;growth.skillSlots={1,2,3,30,31}
    local hero={heroId='icon-qa',baseClassId=classId,progression=growth}
    local snapshot={ready=true,atHub=true,stats={power=0}}
    Tree.render(root,hero,snapshot,{selected=1,path=path},function()error('unexpected save')end,function()end,nil)
    task.wait()
    local nodes=0
    for _,n in ipairs(root.SkillMap:GetChildren())do
     local index=n:GetAttribute('SkillIndex')
     if index then nodes+=1;check(n.SkillGlyph.Image==A.byId[K.Skills[classId][index].id],'tree ID '..classId..index)end
    end
    check(nodes==19,'selected path has 19 skills')
    check(root.SkillDetails.SelectedSkillIcon.SkillGlyph.Image==A.byId[K.Skills[classId][1].id],'detail identity')
    for slot=1,5 do
     local button=root.CombatLoadout['Slot'..slot]
     check(button.SkillIcon.Image==A.byId[K.Skills[classId][growth.skillSlots[slot]].id],'loadout identity')
     check(button.SkillIcon.Position.X.Offset>=0 and button.SkillIcon.Size.X.Offset<button.Size.X.Offset,'loadout bounds')
    end
    report.treeCases+=1
   end
  end
 end
 root:ClearAllChildren();root.Size=UDim2.fromOffset(1160,700);task.wait()
 local growth=G.new(99);growth.branch='magic_archer';growth.stage=4;growth.skillSlots={1,2,3,30,31}
 A.byId[skill.id]=nil
 Tree.render(root,{heroId='icon-qa',baseClassId='elf',progression=growth},{ready=true,atHub=true,stats={power=0}},
  {selected=1,path=growth.branch},function()error('unexpected save')end,function()end,nil)
 A.byId[skill.id]=art
 check(root.SkillDetails.SelectedSkillIcon.SkillGlyph.Fallback.Visible,'unavailable detail image has a glyph')
 check(root.CombatLoadout.Slot1.SkillIcon.Fallback.Text=='AI' and root.CombatLoadout.Slot1.SkillIcon.Fallback.Visible,'unavailable loadout image has a glyph')
 local hud=req(tree.src.client.K0Hud).create()
 local character=Instance.new('Model');character.Name='IconQACharacter'
 for classId,skills in pairs(K.Skills)do
  character:SetAttribute('K0ClassId',classId);character:SetAttribute('K0Level',99);character:SetAttribute('K0SkillSlotCount',5)
  for first=1,32,5 do
   for slot=1,5 do
    local skill=skills[(first+slot-2)%32+1]
    character:SetAttribute('K0EquippedSkill'..slot,skill.id)
    character:SetAttribute('K0SkillReady'..slot,0)
   end
   hud.setCooldowns(character)
   for slot,button in ipairs(hud.skills)do
    local skill=skills[(first+slot-2)%32+1]
    check(button.SkillIcon.Image==A.byId[skill.id]and button.SkillIcon.Visible,'HUD equipped identity')
    check(button.SkillIcon.Fallback.Visible~=button.SkillIcon.IsLoaded,'HUD shows a glyph only while artwork is unloaded')
    check(button.Hint.ZIndex>button.SkillIcon.ZIndex,'key above icon')
   end
   report.hudCases+=1
  end
  character:SetAttribute('K0SkillReady1',workspace:GetServerTimeNow()+5);hud.setCooldowns(character)
  check(hud.skills[1].SkillIcon.Visible and hud.skills[1].SkillIcon.ImageTransparency>0 and hud.skills[1].Cooldown.Visible,'HUD cooldown art and timer')
  character:SetAttribute('K0SkillSlotCount',3);hud.setCooldowns(character)
  check(not hud.skills[4].SkillIcon.Visible and not hud.skills[5].SkillIcon.Visible,'locked slots hide art')
  for _,path in ipairs(Advanced.order[classId])do
   local skillsInPath=Advanced.branches[path].skills
   local ultimate=skillsInPath[#skillsInPath]
   local ultimateArt=A.byId[ultimate.id]
   A.byId[ultimate.id]='rbxassetid://0'
   character:SetAttribute('K0UltimateId',ultimate.id);hud.setCooldowns(character)
   check(hud.ultimate.SkillIcon.Fallback.Visible and hud.ultimate.SkillIcon.Fallback.Text==ultimate.glyph,'unavailable ultimate displays a glyph')
   A.byId[ultimate.id]=ultimateArt
   character:SetAttribute('K0UltimateId',ultimate.id);character:SetAttribute('K0UltimateReady',0);hud.setCooldowns(character)
   check(hud.ultimate.Visible and hud.ultimate.SkillIcon.Image==A.byId[ultimate.id],'ultimate identity')
   character:SetAttribute('K0UltimateReady',workspace:GetServerTimeNow()+5);hud.setCooldowns(character)
   check(hud.ultimate.SkillIcon.Visible and hud.ultimate.SkillIcon.ImageTransparency>0,'ultimate cooldown')
  end
 end
 hud.setCooldowns(nil)
 check(not hud.ultimate.Visible and hud.ultimate.SkillIcon.Image=='','ultimate clears with no hero')
 for _,button in ipairs(hud.skills)do check(not button.SkillIcon.Visible and button.SkillIcon.Image=='','slots clear with no hero')end
 character:Destroy();hud.setVisible(false)
 root:ClearAllChildren();root.Size=UDim2.fromOffset(1160,700)
 return report
end
