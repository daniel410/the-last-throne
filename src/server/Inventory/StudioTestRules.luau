-- Only InventoryService's Studio session path installs these test defaults.
local StudioTestRules = {}
function StudioTestRules.wrap(base, growth)
	local rules = setmetatable({}, {__index = base})
	function rules.new(userId)
		local profile = base.new(userId)
		profile.wallet.gold = 10000
		profile.wallet.diamonds = 5000
		return profile
	end
	function rules.addHero(profile, heroId, classId, catalog)
		local result, errorCode = base.addHero(profile, heroId, classId, catalog)
		if not result then return nil, errorCode end
		local hero = result.heroes[heroId]
		hero.level = 10
		hero.progression = growth.new(10)
		return result
	end
	return rules
end
return StudioTestRules
