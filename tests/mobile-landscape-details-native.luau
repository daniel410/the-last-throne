-- Native geometry/contract regression for landscape detail views, not hardware input.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated fixture only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local G=require(game.ReplicatedStorage.Shared.HeroProgression)
local P=require(game.ReplicatedStorage.Shared.SkillStatPreview)
local Stats=require(client.HeroStatsView)
local report={kind='MOBILE_LANDSCAPE_DETAILS_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local screen=Instance.new('ScreenGui');screen.Parent=game.CoreGui
local body=Instance.new('ScrollingFrame');body.Parent=screen
local ok,err=xpcall(function()
 for _,size in ipairs({Vector2.new(702,193),Vector2.new(702,260),Vector2.new(796,260)}) do
  body.Size=UDim2.fromOffset(size.X,size.Y);task.wait()
  for _,classId in ipairs({'knight','elf','dwarf','mage'}) do
   local g=G.new(20);local hero={heroId='qa',baseClassId=classId,progression=g}
   local snapshot={ready=true,atHub=true,items={},stats={power=7,health=30,armor=2}}
   local draft={STR=1,DEX=0,INT=0,VIT=0};local after=G.copy(g);after.stats.STR+=1
   for _,section in ipairs({'Combat','Points','Gear','Skills'}) do
    body:ClearAllChildren()
    local height=Stats.render(body,hero,snapshot,P.derived(classId,after,snapshot.stats),draft,nil,function()end,function()end,function()end,function()end,{mobile=true,section=section})
    task.wait()
    check(not body.ScrollingEnabled,'landscape section selector does not scroll out')
    check(body.MobileHero.HeroPortrait.Image~='','approved hero portrait is connected')
    local scroll=body.MobileDetail
    check(scroll.AbsoluteSize.Y>0 and scroll.CanvasSize.Y.Offset>0,'inner detail is scrollable')
    for _,id in ipairs({'Combat','Points','Gear','Skills'}) do
     local b=body['Section'..id];check(b.Size.Y.Offset>=44,'44px section touch target')
     check(b:GetAttribute('Selected')==(id==section),'selected section state')
    end
    if section=='Points' then
     for _,key in ipairs(G.statKeys) do
      local row=scroll[key]
      check(row.AbsolutePosition.Y>=scroll.AbsolutePosition.Y and row.AbsolutePosition.Y+row.AbsoluteSize.Y<=scroll.AbsolutePosition.Y+scroll.AbsoluteSize.Y,'all allocation rows visible initially '..key)
      check(row.Plus.AbsoluteSize==Vector2.new(44,44) and row.Minus.AbsoluteSize==Vector2.new(44,44),'full touch target '..key)
     end
     check(body.ApplyPoints.Active,'safe draft remains confirmable')
     check(body.ApplyPoints.Position.Y.Offset+44<=height,'confirm stays inside viewport')
    elseif section=='Combat' then
     for _,entry in ipairs(P.breakdown(classId,g,snapshot.stats,after)) do
      local row=scroll[entry.key]
      check(math.abs(tonumber(row.Total.Text)-entry.total)<=.0051,'saved total stays separate from draft')
      check(row.Draft~=nil,'draft comparison remains explicit')
     end
    elseif section=='Gear' then
     for _,slot in ipairs(require(game.ReplicatedStorage.Shared.ItemCatalog).slots) do check(scroll:FindFirstChild('EquipSlot_'..slot)~=nil,'all eight equipment slots') end
    else check(scroll:FindFirstChild('SkillPreview1')~=nil,'equipped skill preview exists') end
    body:ClearAllChildren()
    Stats.render(body,hero,snapshot,P.derived(classId,after,snapshot.stats),draft,{requestId='same'},function()end,function()end,function()end,function()end,{mobile=true,section=section})
    check(body.RetrySave.Active and body.RetrySave.Position.Y.Offset+44<=height,'same-request retry visible for every section')
    check(not body:FindFirstChild('ApplyPoints'),'pending save blocks repeated confirmation')
   end
  end
 end
end,debug.traceback)
screen:Destroy();if not ok then table.insert(report.failures,tostring(err))end
report.pass=ok;return report
