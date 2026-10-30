-- Visual progression map over the actual skill catalog, never concept-image rules.
local RS=game:GetService('ReplicatedStorage')
local TextService=game:GetService('TextService')
local Theme=require(script.Parent.TDInventoryTheme)
local Menu=require(script.Parent.HeroMenuChrome)
local Advanced=require(RS.Shared.AdvancedSkills)
local Growth=require(RS.Shared.HeroProgression)
local Config=require(RS.Shared.K0Config)
local Preview=require(RS.Shared.SkillStatPreview)
local SkillText=require(RS.Shared.SkillStatText)
local Glyph=require(script.Parent.SkillGlyph)
local Tree={}
local portraits={knight='103255177842108',elf='80894238854345',dwarf='74628903359757',mage='91907986271282'}
local classNames={knight='Knight',elf='Elf Archer',dwarf='Dwarf Axe Thrower',mage='Mage'}
local defaultIcons={knight='shieldbearer',elf='archer',dwarf='axe',mage='arcanist'}
local function label(p,n,t,x,y,w,h,size,color)
 return Theme.label(p,n,t,UDim2.fromOffset(x,y),UDim2.fromOffset(w,h),size or 12,color)
end
local function line(p,n,a,b,active)
 local v=Instance.new('Frame');v.Name=n;v.AnchorPoint=Vector2.new(.5,.5);v.Position=UDim2.fromOffset((a.X+b.X)/2,(a.Y+b.Y)/2);v.Size=UDim2.fromOffset((a-b).Magnitude,active and 3 or 2);v.Rotation=math.deg(math.atan2(b.Y-a.Y,b.X-a.X));v.BackgroundColor3=active and Color3.fromRGB(63,178,255) or Color3.fromRGB(75,94,117);v.BorderSizePixel=0;v.Parent=p
 return v
end
function Tree.render(body,hero,snapshot,state,send,redraw,pending)
 local g,classId=hero.progression,hero.baseClassId
 local width=math.max(280,body.AbsoluteSize.X-8)
 local narrow=width<760
 local editable=snapshot.ready and snapshot.atHub and not pending
 local canTrain=snapshot.ready and (snapshot.atHub or snapshot.canInvest) and not pending
 local _,points=Growth.points(g)
 local path=state.path or (g.branch~='' and g.branch or Advanced.order[classId][1])
 if not Advanced.branches[path] or Advanced.branches[path].classId~=classId then path=Advanced.order[classId][1] end
 state.path=path
 local selected=state.selected or 1
 local selectedBase=Config.Skills[classId][selected]
 if not selectedBase or selectedBase.branch and selectedBase.branch~=path then selected=1;state.selected=1 end
 local header=Menu.frame(body,'SkillHeader',UDim2.fromOffset(4,4),UDim2.fromOffset(width-8,narrow and 150 or 92))
 local portrait=Instance.new('ImageLabel');portrait.Name='HeroPortrait';portrait.BackgroundTransparency=1;portrait.Position=UDim2.fromOffset(8,8);portrait.Size=UDim2.fromOffset(76,76);portrait.Image='rbxassetid://'..portraits[classId];portrait.ScaleType=Enum.ScaleType.Crop;portrait.Parent=header
 label(header,'HeroName',classNames[classId]..'  /  Lv. '..g.level,98,10,math.max(150,width-125),30,20,Theme.color.text)
 label(header,'SkillPoints','SKILL POINTS  '..points,98,43,200,28,15,Theme.color.gold)
 local branchWidth=narrow and (width-40)/2 or math.min(170,(width-390)/2)
 for i,id in ipairs(Advanced.order[classId]) do
  local b=Theme.button(header,'Path'..i,Advanced.branches[id].name,UDim2.fromOffset(narrow and 12+(i-1)*(branchWidth+8) or width-24-(3-i)*branchWidth-(2-i)*8,narrow and 96 or 24),UDim2.fromOffset(branchWidth,42),id==path)
  b.Caption.TextSize=12;b.Activated:Connect(function() state.path=id;state.selected=1;redraw() end)
 end
 local top=narrow and 174 or 116
 local treeWidth=narrow and width-8 or math.floor(width*.65)
 local treeHeight=876
 local map=Menu.frame(body,'SkillMap',UDim2.fromOffset(4,top),UDim2.fromOffset(treeWidth,treeHeight))
 local rows={{stage=0,indices={}},{stage=0,early=true,indices={}},{stage=1,indices={}},{stage=2,indices={}},{stage=3,indices={}},{stage=4,indices={}}}
 for index,base in ipairs(Config.Skills[classId]) do
  if index<=3 then table.insert(rows[1].indices,index)
  elseif base.common then table.insert(rows[2].indices,index)
  elseif base.branch==path then table.insert(rows[base.stage+2].indices,index) end
 end
 label(map,'MapTitle','BASIC SKILLS  →  '..string.upper(Advanced.branches[path].name),16,10,treeWidth-32,28,13,Theme.color.gold)
 local positions={}
 local size=math.clamp(math.floor((treeWidth-100)/5)-12,38,64)
 for rowIndex,row in ipairs(rows) do
  local y=66+(rowIndex-1)*126
  local count=#row.indices
  local left=treeWidth<440 and 58 or 76
  local available=treeWidth-left-20
  local tag=Menu.plaque(map,'Stage'..(row.early and 'Early' or row.stage),row.early and 'Lv.5–15' or row.stage==0 and 'BASE' or 'Lv.'..row.stage*20,UDim2.fromOffset(8,y+8),UDim2.fromOffset(left-12,34));tag.Caption.TextSize=treeWidth<440 and 9 or 11;tag.Caption.Position=UDim2.fromOffset(2,0);tag.Caption.Size=UDim2.new(1,-4,1,0);tag.Caption.TextWrapped=false
  for order,index in ipairs(row.indices) do
   local base=Config.Skills[classId][index]
   positions[index]=Vector2.new(left+available*(order-.5)/math.max(count,1),y+size/2)
  end
 end
 -- Lines show a skill's basic action family, not extra purchase prerequisites.
 for _,row in ipairs(rows) do
  for _,index in ipairs(row.indices) do
   local base=Config.Skills[classId][index]
   if base.advanced then
    local previous=base.root or 0
    if previous==0 then previous=2 end
    for stage=row.stage-1,1,-1 do
     local found
     for _,candidate in ipairs(rows[stage+2].indices) do if Config.Skills[classId][candidate].root==base.root then found=candidate;break end end
     if found then previous=found;break end
    end
    local a,b=positions[previous],positions[index]
    if a and b then line(map,'FamilyLink'..index,a,b,Advanced.unlocked(g,classId,index)) end
   end
  end
 end
 for _,row in ipairs(rows) do
  for _,index in ipairs(row.indices) do
   local base=Config.Skills[classId][index]
   local learned=Advanced.unlocked(g,classId,index)
   local pos=positions[index]
   local node=Menu.node(map,'Skill'..index,'',UDim2.fromOffset(pos.X-size/2,pos.Y-size/2),size,learned,index==selected)
   node:SetAttribute('SkillIndex',index);node:SetAttribute('Unlocked',learned)
   local symbol=table.clone(base);symbol.root=index<=3 and index or base.root;Glyph.draw(node,classId,symbol,size*.72,learned)
   local badge=label(node,'Rank',learned and ('Lv.'..(1+g.mastery[index])) or 'LOCKED',-5,size-3,size+10,20,9,learned and Theme.color.gold or Theme.color.muted)
   badge.BackgroundTransparency,badge.BackgroundColor3=0,Theme.color.ink;badge.TextXAlignment=Enum.TextXAlignment.Center
   local title=label(map,'SkillName'..index,base.name,pos.X-((treeWidth-90)/math.max(#row.indices,3)-6)/2,pos.Y+size/2+22,(treeWidth-90)/math.max(#row.indices,3)-6,38,treeWidth<440 and 8 or 10,learned and Theme.color.text or Theme.color.muted);title.TextXAlignment=Enum.TextXAlignment.Center
   node.Activated:Connect(function() state.selected=index;redraw() end)
  end
 end
 label(map,'MapNote','Lines group action families. Each skill uses its own level and advancement requirement.',16,treeHeight-40,treeWidth-32,30,10,Theme.color.muted)
 local detailX=narrow and 4 or treeWidth+24
 local detailY=narrow and top+treeHeight+20 or top
 local detailW=narrow and width-8 or width-detailX-4
 local detail=Menu.frame(body,'SkillDetails',UDim2.fromOffset(detailX,detailY),UDim2.fromOffset(detailW,500))
 local base=Config.Skills[classId][selected]
 local skill=Growth.skill(classId,selected,base,g)
 local learned=Advanced.unlocked(g,classId,selected)
 local heading=Menu.plaque(detail,'SkillTitle',base.name,UDim2.fromOffset(10,10),UDim2.new(1,-20,0,50));heading.Caption.TextSize=15
 local detailIcon=Menu.node(detail,'SelectedSkillIcon','',UDim2.new(.5,-44,0,84),88,learned,true)
 local symbol=table.clone(base);symbol.root=selected<=3 and selected or base.root;Glyph.draw(detailIcon,classId,symbol,66,learned)
 local rank=label(detail,'Mastery','MASTERY  '..(1+g.mastery[selected])..' / 4',12,196,detailW-24,28,15,Theme.color.gold);rank.TextXAlignment=Enum.TextXAlignment.Center
 local effect=skill.form=='self' and string.format('Barrier: %.0f%% max HP / %gs',skill.shield*100,skill.shieldDuration) or skill.damage>0 and string.format('Damage × %.2f',skill.damage) or string.format('Provoke %.1fs',skill.provokeDuration or 0)
 if skill.guardReduction then effect=effect..string.format(' / %.0f%% guard',skill.guardReduction*100) end
 if skill.pulses and skill.pulses>1 then effect=effect..'  /  '..skill.pulses..' hits' end
 local effectText=effect..'\n'..Preview.scalingText(classId,skill)..'\n'..Preview.effectText(classId,selected,g,snapshot.stats)..'\n'..SkillText.EstimateNote..(base.description and '\n'..base.description or '')
 local effectHeight=math.max(44,TextService:GetTextSize(effectText,12,Enum.Font.GothamMedium,Vector2.new(detailW-36,10000)).Y+4)
 local detailExtra=effectHeight-44
 detail.Size=UDim2.fromOffset(detailW,500+detailExtra)
 label(detail,'Effect',effectText,18,226,detailW-36,effectHeight,12,Theme.color.text)
 label(detail,'Cost',string.format('%gs cooldown%s',skill.cooldown,skill.manaCost and '  /  '..skill.manaCost..' MP' or ''),18,274+detailExtra,detailW-36,30,12,Theme.color.silver)
 label(detail,'Requirements',learned and (base.ultimate and 'LEARNED  /  Dedicated ultimate button. Does not use slots 1–5.' or 'LEARNED  /  Select a combat slot below to equip.') or base.common and string.format('LOCKED  /  Reach Level %d. No advancement required.',base.level) or string.format('LOCKED  /  Level %d + advancement stage %d\nPreview only. Complete this path first.',base.level or 1,base.stage or 0),18,310+detailExtra,detailW-36,66,12,learned and Theme.color.green or Theme.color.muted)
 local train=Theme.button(detail,'Train','+1 MASTERY  /  1 SP',UDim2.fromOffset(14,386+detailExtra),UDim2.new(1,-28,0,44),true)
 Theme.enabled(train,canTrain and learned and points>0 and g.mastery[selected]<3)
 train.Activated:Connect(function() if train.Active then send('TrainSkill',{skill=selected}) end end)
 local hint=learned and (g.mastery[selected]>=3 and 'Maximum mastery reached.' or 'Mastery strengthens this skill. Skills are learned automatically when eligible.') or 'Locked nodes remain available to inspect.'
 label(detail,'MasteryHint',hint,18,442+detailExtra,detailW-36,44,11,Theme.color.muted)
 local loadY=math.max(top+treeHeight,narrow and detailY+500+detailExtra or 0)+24
 local load=Menu.frame(body,'CombatLoadout',UDim2.fromOffset(4,loadY),UDim2.fromOffset(width-8,narrow and 200 or 120))
 label(load,'Heading','COMBAT LOADOUT  /  SELECT A SLOT TO EQUIP '..base.name,14,8,width-36,32,12,Theme.color.gold)
 for slot=1,5 do
  local index=g.skillSlots[slot];local equipped=Config.Skills[classId][index];local active=slot<=Advanced.slotCount(g)
  local col=narrow and (slot-1)%3 or slot-1;local row=narrow and math.floor((slot-1)/3) or 0
  local columns=narrow and 3 or 5;local w=(width-40-(columns-1)*8)/columns
  local b=Theme.button(load,'Slot'..slot,slot..'  '..(active and (equipped and equipped.name or 'EMPTY') or ('Lv.'..(slot==4 and 5 or 10))),UDim2.fromOffset(14+col*(w+8),48+row*66),UDim2.fromOffset(w,56),index==selected)
  b.Caption.TextSize=10;Theme.enabled(b,editable and active and learned and not base.ultimate)
  b.Activated:Connect(function() if b.Active then send('SetSkillSlot',{slot=slot,skill=selected}) end end)
 end
 local finish=loadY+(narrow and 200 or 120)+12
 label(body,'PathNote','Path names are provisional. Slots 4 / 5 open at Lv.5 / 10. The Lv.80 ultimate has a separate button, shown only after its final advancement.',8,finish,width-16,42,11,Theme.color.muted)
 if pending then
  local retry=Theme.button(body,'RetrySave','RETRY SAVE',UDim2.fromOffset(8,finish+50),UDim2.fromOffset(width-16,44))
  retry.Activated:Connect(state.retry)
  finish=finish+56
 end
 return finish+58
end
return Tree
