if game then return {} end
local G=dofile('src/shared/HeroProgression.luau')
local K=dofile('src/shared/K0Config.luau')
local P=dofile('src/shared/SkillStatPreview.luau')
local n=0
local function check(v,s) n=n+1;assert(v,s) end
local function near(a,b,s)check(math.abs(a-b)<1e-8,s)end
for _,classId in ipairs({'knight','elf','dwarf','mage'}) do
 for _,level in ipairs({2,20,40,60,80}) do
  local g=G.new(level)
  local before=G.derived(classId,g)
  for _,key in ipairs(G.statKeys) do
   local h=G.copy(g);h.stats[key]=4
   local d=G.derived(classId,h)
   near(d.physicalPower-before.physicalPower,key=='STR' and 8 or 0,classId..' physical damage scales only with STR')
   near(d.magicPower-before.magicPower,key=='INT' and 8 or 0,classId..' magic damage scales only with INT')
   near(d.health-before.health,key=='VIT' and 40 or 0,classId..' HP scales with VIT')
   near(d.attackRate-before.attackRate,key=='DEX' and .02 or 0,classId..' basic attack rate scales with DEX')
   near(d.moveRate-before.moveRate,key=='DEX' and .004 or 0,classId..' movement scales with DEX')
   near(d.mana-before.mana,key=='INT' and classId=='mage' and 12 or 0,classId..' existing mana gate preserved')
  end
 end
 local cap=G.new(80);cap.stats.DEX=316
 near(G.derived(classId,cap).attackRate,1.8,'attack rate cap')
 near(G.derived(classId,cap).moveRate,1.316,'316 invested points remain below movement cap')
 local ceiling=G.copy(cap);ceiling.stats.DEX=400 -- Synthetic ceiling check; exceeds the current legal budget.
 near(G.derived(classId,ceiling).moveRate,1.4,'movement ceiling at 400 points')
 for _,base in ipairs(K.BasicAttackProfiles[classId].attacks) do
  local d=K.scaledBasicAttack(base,1.8)
  for _,key in ipairs({'windup','active','recovery','hitDelay'})do
   if base[key]then near(d[key]*1.8,base[key],'server contact and duration rescale together')end
  end
  near(d.damage,base.damage,'speed does not add per-hit damage')
  check(d~=base,'timing projection leaves shared definitions intact')
 end
 check(P.statHint(classId,'DEX',cap):find('movement speed',1,true),'all heroes describe DEX effect')
end
local elf=G.new(20);elf.branch='magic_archer';elf.stage=1
local before=G.derived('elf',elf);elf.stats.INT=4
near(G.derived('elf',elf).mana-before.mana,12,'Magic Archer INT adds mana')
print('Hero stat effects: '..n..' checks passed')
