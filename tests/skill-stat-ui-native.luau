-- Native GUI and shared math in an empty, unpublished Studio fixture.
-- No real Player, rendered device, network or save acceptance.
local Players=game:GetService('Players')
assert(game.PlaceId==0 and #Players:GetPlayers()==0,'requires empty unpublished fixture')
local client=game:GetService('StarterPlayer').StarterPlayerScripts.Client
local Shared=game:GetService('ReplicatedStorage').Shared
local G=require(Shared.HeroProgression)
local K=require(Shared.K0Config)
local A=require(Shared.AdvancedSkills)
local P=require(Shared.SkillStatPreview)
local Stats=require(client.HeroStatsView)
local Tree=require(client.HeroSkillTree)
local TextService=game:GetService('TextService')
local report={kind='SKILL_STAT_UI_NATIVE',checks=0,failures={},coverage='Native GUI constructors and measured text; no real Player, rendered client or device'}
local function check(v,label)report.checks+=1;assert(v,label)end
local body=Instance.new('Frame');body.Parent=workspace
local function textFits(root)
 for _,label in ipairs(root:GetDescendants()) do
  if label:IsA('TextLabel') and (label:FindFirstAncestor('CombatStats')~=nil or label.Name=='Effect' or label.Name=='Estimate' or label.Name=='SkillName' or label.Name=='EffectHint' or label.Name=='PreviewNote') then
   local width=label.Size.X.Offset+label.Size.X.Scale*label.Parent.AbsoluteSize.X
   local height=TextService:GetTextSize(label.Text,label.TextSize,label.Font,Vector2.new(width,10000)).Y
   local availableHeight=label.Size.Y.Offset+label.Size.Y.Scale*label.Parent.AbsoluteSize.Y
   check(height<=availableHeight+1,label:GetFullName()..' text fits height')
  end
 end
end
local ok,failure=xpcall(function()
 for _,width in ipairs({1160,740,390,280}) do
  body.Size=UDim2.fromOffset(width,700);task.wait()
  for classId,paths in pairs(A.order) do
   for _,path in ipairs(paths) do
    local g=G.new(80);g.branch=path;g.stage=4
    local hero={heroId='qa',baseClassId=classId,progression=g}
    local snapshot={ready=true,atHub=true,items={},stats={power=7,health=30,armor=2}}
    local draft={STR=4,DEX=4,INT=4,VIT=4}
    local after=G.copy(g);for key,value in pairs(draft) do after.stats[key]+=value end
    body:ClearAllChildren()
    local height=Stats.render(body,hero,snapshot,P.derived(classId,after,snapshot.stats),draft,nil,function()end,function()end,function()end,function()end)
    task.wait()
    check(body:FindFirstChild('SkillPreview0')~=nil,'dedicated unlocked ultimate preview')
    local summary=body.CombatStats
    check(summary.Position.Y.Offset==4,'combat totals appear at the top')
    check(summary.GearDetails.Size.Y.Offset>=44 and summary.GearDetails.Selectable,'gear details are touch and gamepad accessible')
    local current=P.derived(classId,g,snapshot.stats)
    for _,entry in ipairs(P.breakdown(classId,g,snapshot.stats,after))do
     local row=summary[entry.key]
     check(math.abs(tonumber(row.Total.Text)-current[entry.key])<=.0051,'saved total does not silently become the draft')
     check(row.Breakdown.Text:find('Hero',1,true) and row.Breakdown.Text:find('Gear',1,true),'hero and gear sources are explicit')
     check(row.Draft.Text:find('DRAFT',1,true),'unsaved change is labeled separately')
    end
    check(body.StatAllocation.Position.Y.Offset>=summary.Position.Y.Offset+summary.Size.Y.Offset,'allocation never overlaps totals')
    if width<768 then check(body.HeroEquipment.Position.Y.Offset>=summary.Position.Y.Offset+summary.Size.Y.Offset,'narrow screen stacks gear below totals')end
    check(body.SkillPreview1.Estimate.Text:find('scales with',1,true)~=nil,'starter scaling visible')
    check(body.SkillPreview1.Estimate.Text:find(' %-> ')~=nil,'draft shows actual damage delta')
    check(body.StatAllocation.ApplyPoints.Active,'draft remains confirmable')
    check(body.StatAllocation.STR.Plus.Size.X.Offset>=44,'allocation retains touch target')
    check(body.SkillPreview0.Position.Y.Offset+body.SkillPreview0.Size.Y.Offset<height,'last preview stays inside canvas')
    textFits(body)
    for _,entry in ipairs({1,3,32,A.branches[path].skills[7].index}) do
     body:ClearAllChildren()
     local treeHeight=Tree.render(body,hero,snapshot,{path=path,selected=entry},function()end,function()end,nil)
     task.wait()
     local detail=body.SkillDetails
     check(detail.Effect.Text:find(P.scalingText(classId,K.Skills[classId][entry]),1,true)~=nil,'skill detail shows true scaling')
     check(detail.Effect.Position.Y.Offset+detail.Effect.Size.Y.Offset<=detail.Cost.Position.Y.Offset,'effects clear cost')
     check(detail.MasteryHint.Position.Y.Offset+detail.MasteryHint.Size.Y.Offset<=detail.Size.Y.Offset,'mastery hint stays in panel')
     check(treeHeight>detail.Position.Y.Offset+detail.Size.Y.Offset,'scroll canvas includes details')
     textFits(body)
    end
   end
  end
 end
 for _,width in ipairs({1160,390,280})do
  body.Size=UDim2.fromOffset(width,700);body:ClearAllChildren();task.wait()
  local g=G.new(10)
  local snapshot={ready=true,atHub=true,stats={power=10,armor=2,health=0},items={
   {definitionId='knight_weapon_fine',location={kind='equipped',heroId='qa',slot='weapon'}},
   {definitionId='traveler_hood',location={kind='equipped',heroId='qa',slot='head'}},
   {definitionId='traveler_coat',location={kind='bag',heroId='qa'}},
  }}
  local height=Stats.render(body,{heroId='qa',baseClassId='knight',progression=g},snapshot,P.derived('knight',g,snapshot.stats),{STR=0,DEX=0,INT=0,VIT=0},nil,function()end,function()end,function()end,function()end,{gearExpanded=true})
  task.wait()
  local summary=body.CombatStats
  check(summary.Gear_weapon.Text:find('Tempered Sword',1,true),'equipped weapon source names the item')
  check(summary.Bonus_weapon.Text=='+10% attack power','weapon percent unit is explicit')
  check(summary.Bonus_head.Text=='+2 defense','armor uses flat points')
  check(not summary:FindFirstChild('Gear_body'),'carried gear never appears as an equipped bonus')
  check(not summary.physicalPower:FindFirstChild('Draft'),'no unsaved preview without a draft')
  check(summary.Size.Y.Offset+summary.Position.Y.Offset<height,'expanded details stay inside outer scroll canvas')
  textFits(body)
 end
 local g=G.new(2);body:ClearAllChildren()
 Stats.render(body,{heroId='qa',baseClassId='knight',progression=g},{ready=true,atHub=false,canInvest=false,items={}},P.derived('knight',g),{STR=4,DEX=0,INT=0,VIT=0},{},function()end,function()end,function()end,function()end)
 check(not body.StatAllocation.ApplyPoints.Active,'pending unsafe draft cannot submit')
 check(body:FindFirstChild('RetrySave')~=nil,'pending save retains retry control')
 check(body:FindFirstChild('SkillPreview0')==nil,'locked ultimate stays hidden')
 check(P.value('knight',1,G.new(2),{power=5}).damage==87,'native final rounding matches server formula')
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(failure))end
body:Destroy();report.pass=ok
print('SKILL_STAT_UI_NATIVE '..game:GetService('HttpService'):JSONEncode(report))
assert(ok,'skill/stat UI fixture failed')
