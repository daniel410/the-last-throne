-- Repository root: lua docs/evidence/easy-epic-difficulty-review-20261113/measure.lua > /tmp/tlt-easy-review.csv
local C=dofile('src/shared/CampaignContent.luau')
local B=dofile('src/shared/DeepwoodEncounterBalance.luau')
local D=dofile('src/shared/Difficulty.luau')
assert(#C.mainChapters==35 and #C.chapters==47)
print('party,chapter,side,epic,goal,pacing,wave,waveSize,kind,boss,level,hp,damage,killIndex')
for party=1,4 do
 for _,c in ipairs(C.chapters)do
  for _,g in ipairs(c.goals)do
   if #g.enemies>0 then
    local waves=B.encounterWaves(c,g,party)
    local seen={}
    for wave,batch in ipairs(waves)do
     assert(#batch<=B.packCapacity(c,g,party))
     for index,s in ipairs(batch)do
      assert(not seen[s.killIndex]);seen[s.killIndex]=true
      local hp,damage,level=B.unitStats(s,party,'Easy',D.version,index)
      assert(hp>0 and damage>0 and level==s.level)
      print(table.concat({party,c.id,tostring(c.side==true),c.epic,g.id,tostring(g.pacing==true),wave,#batch,s.kind,tostring(B.isBoss(s.kind)),level,hp,damage,s.killIndex},','))
     end
    end
   end
  end
 end
end
