-- Read-only census of final runtime content. Run from the repository root.
local C=dofile('src/shared/CampaignContent.luau')
local B=dofile('src/shared/EncounterPopulation.luau')
local function units(g)
 if #g.enemies>0 then return 0 end
 return math.max(1,#(g.activity and g.activity.steps or {}))
end
print('chapter\tside\tbattle_goals\tsolo_packs\tsolo_enemies\tfour_player_enemies\tactivity_steps\tlongest_activity_streak\tsteps_after_last_battle\tsequence')
for _,c in ipairs(C.chapters)do
 local battles,packs,solo,four,steps,streak,longest,tail=0,0,0,0,0,0,0,0
 local sequence={}
 for _,g in ipairs(c.goals)do
  if #g.enemies>0 then
   battles=battles+1;streak=0;tail=0
   local waves=B.encounterWaves(c,g,1);packs=packs+#waves
   local count=0
   for _,wave in ipairs(waves)do count=count+#wave end
   solo=solo+count
   for _,wave in ipairs(B.encounterWaves(c,g,4))do four=four+#wave end
   sequence[#sequence+1]=g.id..':battle('..count..')'
  else
   local n=units(g);steps=steps+n;streak=streak+n;tail=tail+n;longest=math.max(longest,streak)
   sequence[#sequence+1]=g.id..':activity('..n..')'
  end
 end
 print(table.concat({c.id,tostring(c.side==true),battles,packs,solo,four,steps,longest,tail,table.concat(sequence,' > ')},'\t'))
end
