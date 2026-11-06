-- Read-only in-game guide; all chances and costs come from the runtime rules.
local RS=game:GetService('ReplicatedStorage')
local T=require(script.Parent.TDInventoryTheme)
local E=require(RS.Shared.Enhancement)
local Text=require(RS.Shared.AdventureText)
local TextService=game:GetService('TextService')
local G={}
function G.create(panel)
 local scroll=Instance.new('ScrollingFrame');scroll.Name='EnhancementGuide';scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=6;scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.CanvasSize=UDim2.new();scroll.Visible=false;scroll.Parent=panel
 local list=Instance.new('UIListLayout');list.Padding=UDim.new(0,10);list.SortOrder=Enum.SortOrder.LayoutOrder;list.Parent=scroll
 local sections={}
 local function section(name,body,color)
  local box=T.frame(scroll,name,UDim2.new(),UDim2.new(1,-8,0,100));box.LayoutOrder=#sections+1
  local label=T.label(box,'Body',body,UDim2.fromOffset(14,10),UDim2.new(1,-28,1,-20),14,color)
  label.TextYAlignment=Enum.TextYAlignment.Top
  table.insert(sections,{box=box,label=label})
 end
 section('Introduction',Text.EnhancementHelpIntro,T.color.gold)
 section('AttemptRules',string.format(Text.EnhancementHelpRules,E.cost({},1).gold))
 for target=1,E.cap({})do
  local cost=E.cost({},target);local chance=E.successPercent(target)
  section('Stage'..target,string.format(Text.EnhancementGuideStage,target,chance,100-chance,cost.gold,cost.gems,cost.stones,target*3),T.color.gold)
 end
 section('Recovery',Text.EnhancementHelpRecovery)
 local g,s=E.exchanges.gems,E.exchanges.stones
 section('Materials',string.format(Text.EnhancementHelpExchange,g.gold,g.amount,s.gems,s.gold,s.amount))
 section('ConfirmationAndSaving',Text.EnhancementHelpSaving)
 local function resize()
  local width=math.max(80,scroll.AbsoluteSize.X-36)
  for _,entry in ipairs(sections)do
   local height=TextService:GetTextSize(entry.label.Text,14,entry.label.Font,Vector2.new(width,10000)).Y+24
   entry.box.Size=UDim2.new(1,-8,0,math.max(64,height))
  end
 end
 scroll:GetPropertyChangedSignal('AbsoluteSize'):Connect(resize)
 return {scroll=scroll,resize=resize}
end
return G
