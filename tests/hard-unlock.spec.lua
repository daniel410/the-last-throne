local function load(n)return dofile('src/shared/'..n..'.luau')end
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C,A,P,Content,E=load('ItemCatalog'),load('AdventureRules'),load('DeepwoodProgress'),load('CampaignContent'),load('EconomyRules')
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local p=assert(R.addHero(R.new(956),'hero','knight',C))
local function complete(mode,run)
 p=assert(A.begin(p,'hero','DW-01',mode,run,p.revision,R,C))
 for _,g in ipairs(Content.byId['DW-01'].goals)do if P.required(A.projection(p.heroes.hero),g)then
  local function event(choice,step)
   p=assert(A.event(p,'hero','DW-01',g.id,choice,step,R,C,run))
   local again=assert(A.event(p,'hero','DW-01',g.id,choice,step,R,C,run))
   check(again.wallet.diamonds==p.wallet.diamonds and again.wallet.gold==p.wallet.gold,'event retry preserves balances')
  end
  if g.activity and g.activity.steps then for _,step in ipairs(g.activity.steps)do event(step.choices and step.choices[1].id,step.id)end
  else event(g.choice and 'shared')end
 end end
 check(R.validate(p,C),'completed account validates')
end
complete('Hard','hard_first')
check(p.wallet.diamonds==3,'Hard first pays only Hard Diamonds')
check(p.wallet.heroClaims.hero['DW-01'].Hard and not p.wallet.heroClaims.hero['DW-01'].Easy,'Hard does not consume Easy entitlement')
check(p.heroes.hero.deepwood.clears['DW-01'],'Hard first advances campaign')
local gold=p.wallet.gold
check(gold==Content.byId['DW-01'].reward.coins,'first quest Gold replaces repeat completion Gold')
E.upgrade(p);E.upgrade(p)
check(p.wallet.diamonds==3 and not p.wallet.heroClaims.hero['DW-01'].Easy,'reloading does not infer unplayed Easy')
complete('Hard','hard_repeat')
check(p.wallet.diamonds==3 and p.wallet.gold>gold,'Hard replay pays repeat Gold without Diamonds')
complete('Easy','easy_later')
check(p.wallet.diamonds==6 and p.wallet.heroClaims.hero['DW-01'].Easy,'later Easy earns its own three Diamonds')
E.upgrade(p);check(p.wallet.diamonds==6,'upgrade remains idempotent after both modes')
print('Hard unlock rewards: '..n..' checks passed')
