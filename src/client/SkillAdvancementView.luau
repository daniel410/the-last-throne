-- Advancement shares the skill tree's preview path and existing server command.
local Shared=game:GetService('ReplicatedStorage').Shared
local Advanced=require(Shared.AdvancedSkills)
local Text=require(Shared.AdvancementText)
local TextService=game:GetService('TextService')
local Theme=require(script.Parent.TDInventoryTheme)
local Menu=require(script.Parent.HeroMenuChrome)
local View={}
local function context(hero,snapshot,state,pending)
 local g=hero.progression
 local path=state.path
 local branch=Advanced.branches[path]
 if not branch or branch.classId~=hero.baseClassId then return nil end
 local stage=g.stage+1
 local samePath=g.stage==0 or g.branch==path
 local ready=snapshot.ready and not pending and samePath and stage<=4 and g.level>=stage*20
 local key=table.concat({hero.heroId or snapshot.heroId or '',tostring(snapshot.revision),path,tostring(stage)},':')
 return {g=g,path=path,branch=branch,stage=stage,samePath=samePath,ready=ready==true,key=key}
end
function View.request(hero,snapshot,state,send,redraw,pending)
 local c=context(hero,snapshot,state,pending)
 if not c or not c.ready then return false end
 if state.advanceConfirmation~=c.key then
  state.advanceConfirmation=c.key;redraw();return false
 end
 state.advanceConfirmation=nil
 send('Advance',{branch=c.path,stage=c.stage})
 return true
end
function View.render(body,hero,snapshot,state,send,redraw,pending,top,width)
 local c=context(hero,snapshot,state,pending)
 if not c then return 0 end
 local g=c.g
 local panel=Menu.frame(body,'SkillAdvancement',UDim2.fromOffset(4,top),UDim2.fromOffset(width-8,100))
 local y=10
 local function line(name,text,size,color)
  local w=width-40
  local h=math.max(size+6,TextService:GetTextSize(text,size,Enum.Font.GothamMedium,Vector2.new(w,10000)).Y+6)
  local value=Theme.label(panel,name,text,UDim2.fromOffset(12,y),UDim2.fromOffset(w,h),size,color)
  value.TextYAlignment=Enum.TextYAlignment.Top;y+=h+4
  return value
 end
 line('PathStatus',string.format(g.branch==c.path and Text.saved or Text.preview,c.branch.name),14,Theme.color.gold)
 line('PathRole',Text.roles[c.path],12,Theme.color.text)
 if not c.samePath then
  line('Requirements',string.format(Text.pathLocked,Advanced.branches[g.branch].name),12,Theme.color.muted)
 elseif c.stage>4 then
  line('Requirements',Text.complete,12,Theme.color.green)
 else
  line('NextStage',string.format(Text.next,c.stage*20,c.stage),13,Theme.color.gold)
  line('Requirements',string.format(Text.requirements,g.level,c.stage*20),12,Theme.color.text)
 end
 -- Other paths stay inspectable; final stages still show the ultimate's name.
 local previewStage=math.min(c.stage,4)
 local skills={}
 for _,skill in ipairs(c.branch.skills)do
  if skill.stage==previewStage then table.insert(skills,string.format('Lv.%d · %s',skill.level,skill.name))end
 end
 line('Unlocks',Text.unlocks..'\n'..table.concat(skills,'  /  '),12,Theme.color.text)
 if c.samePath and c.stage<=4 then
  local armed=state.advanceConfirmation==c.key
  local hint=pending and Text.saving or armed and string.format(Text.review,c.branch.name) or c.ready and Text.ready or Text.locked
  line('ActionHint',hint,12,c.ready and Theme.color.gold or Theme.color.muted)
  local caption=armed and string.format(Text.confirm,c.branch.name,c.stage) or string.format(Text.advance,c.stage)
  local button=Theme.button(panel,'CompleteAdvancement',caption,UDim2.fromOffset(12,y),UDim2.new(1,-24,0,44),true)
  button.Caption.TextSize=12
  Theme.enabled(button,c.ready)
  button.Activated:Connect(function()View.request(hero,snapshot,state,send,redraw,pending)end)
  y+=52
 end
 line('Milestones',Text.milestones,11,Theme.color.muted)
 panel.Size=UDim2.fromOffset(width-8,y+8)
 panel:SetAttribute('PreviewPath',c.path);panel:SetAttribute('NextStage',c.stage);panel:SetAttribute('CanAdvance',c.ready==true)
 return y+8
end
return View
