-- Player-facing outcomes: damage rounding, equipment, thresholds and speed caps.
local G=dofile('src/shared/HeroProgression.luau')
local P=dofile('src/shared/SkillStatPreview.luau')
local n=0
local function check(v,m)n=n+1;assert(v,m)end
local function has(s,v)check(s:find(v,1,true)~=nil,'expected '..v..' in '..s)end
local zero={STR=0,DEX=0,INT=0,VIT=0}
for _,c in ipairs({'knight','elf','dwarf','mage'})do
 local g=G.new(20);g.stats.VIT=3
 local draft={STR=4,DEX=1,INT=1,VIT=1}
 local text=P.investmentText(c,g,{power=13,armor=2,health=30},draft)
 has(text,'Physical Power: 177.41 → 186.45 (+9.04)')
 has(text,'Defense: 2 → 3 (+1)')
 has(text,'1x → 1.005x (+0.5% of base)')
 has(text,'1x → 1.001x (+0.1% of base)')
 check(g.stats.VIT==3 and draft.VIT==1,'preview preserves saved and draft allocations')
 if c~='mage' then has(text,'Max MP: 0 → 0 (+0; not unlocked)')else has(text,'Max MP: 176 → 179 (+3)')end
 has(P.investmentText(c,g,nil,zero),'Use + to preview')
 local current=P.basicAttacks(c,G.new(1))
 check(current[1].before==(c=='elf' and 70 or 75),'basic damage differs from power 100')
 if c=='knight' then check(#current==3 and current[2].before==90 and current[3].before==120,'combo hits stay distinct')end
end
local g=G.new(80);g.stats.DEX=200
local text=P.investmentText('knight',g,nil,{STR=0,DEX=1,INT=0,VIT=0})
has(text,'2x → 2x (+0% of base)')
has(text,'1.2x → 1.201x (+0.1% of base)')
g.stats.DEX=300
has(P.investmentText('knight',g,nil,{STR=0,DEX=1,INT=0,VIT=0}),'1.3x → 1.3x (+0% of base)')
g=G.new(20)
has(P.investmentText('knight',g,nil,{STR=0,DEX=0,INT=0,VIT=1}),'Defense: 0 → 0 (+0)')
g.branch='magic_archer';g.stage=1
has(P.investmentText('elf',g,nil,{STR=0,DEX=0,INT=1,VIT=0}),'Max MP: 80 → 83 (+3)')
local after=G.new(1);after.stats.STR=1
local hits=P.basicAttacks('knight',G.new(1),{power=5},after)
check(hits[1].before==79 and hits[1].after==80 and hits[1].delta==1,'equipment applied before final per-hit rounding')
after=G.new(1);after.stats.INT=1
check(P.basicAttacks('mage',G.new(1),nil,after)[1].after==77,'staff uses INT magic power')
print('Stat investment preview: '..n..' checks passed')
