local Base = dofile('src/server/Inventory/InventoryRules.luau')
local Growth = dofile('src/shared/HeroProgression.luau')
local Catalog = dofile('src/shared/ItemCatalog.luau')
local Studio = dofile('src/server/Inventory/StudioTestRules.luau').wrap(Base, Growth)
local Store = dofile('src/server/Inventory/AccountStore.luau')
local data = {}
local adapter = {UpdateAsync = function(_, key, callback)
 local result = callback(Base.copy(data[key]))
 if result then data[key] = Base.copy(result) end
 return result
end}
local store = Store.new(adapter, Studio, Catalog, function() return 100 end, function() end, 'studio')
local profile = assert(store:open(42))
assert(profile.wallet.gold == 10000 and profile.wallet.diamonds == 5000)
for _, classId in ipairs({'knight','elf','dwarf','mage'}) do
 profile = assert(store:transact(42, function(current)
  return Studio.addHero(current, classId, classId, Catalog)
 end))
 local hero = profile.heroes[classId]
 assert(hero.level == 10 and hero.progression.level == 10 and hero.progression.xp == 0)
 assert(Growth.validate(hero.progression, classId) and Base.validate(profile, Catalog))
end
local failed, reason = Studio.addHero(profile, 'duplicate', 'knight', Catalog)
assert(failed == nil and reason == 'ClassAlreadyCreated')
profile = assert(store:transact(42, function(current)
 current.wallet.gold = 9500
 current.wallet.diamonds = 4900
 current.heroes.knight.level = 11
 current.heroes.knight.progression = Growth.new(11)
 return current
end))
assert(store:renew(42))
assert(store:close(42))
profile = assert(store:open(42))
assert(profile.wallet.gold == 9500 and profile.wallet.diamonds == 4900)
assert(profile.heroes.knight.level == 11)
local fresh = Studio.new(42)
assert(fresh.wallet.gold == 10000 and fresh.wallet.diamonds == 5000 and next(fresh.heroes) == nil)
local normal = Base.addHero(Base.new(42), 'knight', 'knight', Catalog)
assert(normal.wallet.gold == 0 and normal.wallet.diamonds == 0 and normal.heroes.knight.level == 1)
assert(Base.new(42).wallet.gold == 0)
local f = assert(io.open('src/server/Inventory/InventoryService.luau')); local source = f:read('*a'); f:close()
assert(source:find('local sessionOnly = RunService:IsStudio()\nif sessionOnly then\n\tRules = require(script.Parent.StudioTestRules).wrap(Rules, Growth)\nend', 1, true))
print('PASS: Studio defaults, four classes, account validation, mutation/rejoin preservation, fresh session and production isolation')
