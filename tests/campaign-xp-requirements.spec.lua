local function load(n)return dofile('src/shared/'..n..'.luau')end
local G,M,C,B,D=load('HeroProgression'),load('CampaignGrowthBudget'),load('CampaignContent'),load('DeepwoodEncounterBalance'),load('Difficulty')
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local previous,total=0,0
for level=1,98 do
 local required=G.xpToNext(level)
 check(required>previous,'requirements strictly increase with hero level')
 check(G.xpAtLevel(level)==total,'cumulative XP is the sum of requirements')
 total=total+required;previous=required
end
check(G.xpAtLevel(99)==total and G.xpToNext(99)==0,'only the Lv99 cap stops growth')
check(total==303675,'upper progression curve')
for level=80,98 do
 local g=G.new(level);g.xp=100+25*(level-1)-1
 check(G.validate(g,'knight'),'all previously valid within-level XP still loads')
 check(G.upgrade(g).level==level and G.upgrade(g).xp==g.xp,'curve update never resets saved growth')
end
for _,mode in ipairs(D.order)do for party=1,4 do
 local sums={}
 for _,cycle in ipairs({1,4,5,6,20})do
  local amount=0
  for _,c in ipairs(C.mainChapters)do
   local quest=M.questXP(c.id,mode,D.version,cycle)
   check(quest>0,'every main quest, including safe hubs, pays completion XP')
   check(quest==M.questXP(c.id,mode,D.version,1),'completion XP independent of pass')
   amount=amount+quest
   for _,g in ipairs(c.goals)do for _,wave in ipairs(B.encounterWaves(c,g,party,mode,D.version))do for _,s in ipairs(wave)do
    local xp=B.rewards(s,mode,D.version,cycle)
    check(xp>0,'every actual enemy pays XP, even after five Hell clears')
    check(xp==B.rewards(s,mode,D.version,1),'kill XP independent of pass')
    amount=amount+xp
   end end end
  end
  sums[#sums+1]=amount
 end
 for _,sum in ipairs(sums)do check(sum==sums[1],'unchanged main rewards on every attempt')end
 check(sums[1]==({Easy=13667,Hard=36242,Insane=36867,Hell=44367})[mode],'fixed authored award total')
end end
local original=M.targets.Hell[5];local quest=M.questXP('HG-07','Hell',D.version,1)
M.targets.Hell[5]=99
check(M.questXP('HG-07','Hell',D.version,1)==quest,'estimated checkpoint never sets XP awards')
M.targets.Hell[5]=original
local g=G.new(80)
g=assert(G.apply(g,{action='AwardXP',stream='normal-xp',sequence=1,amount=1000},'knight'))
check(g.level==80 and g.xp==1000,'XP accumulates below the next-level requirement')
g=assert(G.apply(g,{action='AwardXP',stream='normal-xp',sequence=2,amount=1800},'knight'))
check(g.level==81 and g.xp==0,'level changes only when accumulated XP crosses the requirement')
print('Fixed XP and increasing requirements: '..n..' checks passed')
