-- TD-native frame; shared projection keeps desktop/mobile numbers identical.
local Shared=game:GetService('ReplicatedStorage').Shared
local Theme=require(script.Parent.TDInventoryTheme)
local Menu=require(script.Parent.HeroMenuChrome)
local Preview=require(Shared.SkillStatPreview)
local Text=require(Shared.CombatStatText)
local TextService=game:GetService('TextService')
local View={}
function View.render(parent,hero,snapshot,draft,x,y,width)
 local panel=Menu.frame(parent,'StatInvestmentPreview',UDim2.fromOffset(x,y),UDim2.fromOffset(width,1))
 local top=10
 for _,entry in ipairs({{'Title',Text.InvestmentTitle,12,Theme.color.gold},
  {'Changes',Preview.investmentText(hero.baseClassId,hero.progression,snapshot.stats,draft),12,Theme.color.text}}) do
  local height=math.ceil(TextService:GetTextSize(entry[2],entry[3],Enum.Font.GothamMedium,Vector2.new(width-24,10000)).Y)+8
  Theme.label(panel,entry[1],entry[2],UDim2.fromOffset(12,top),UDim2.fromOffset(width-24,height),entry[3],entry[4])
  top+=height+4
 end
 panel.Size=UDim2.fromOffset(width,top+8)
 return top+8
end
return View
