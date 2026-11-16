-- Authored Coins remain the immutable journal checksum and pre-19 budget.
-- Only newly started rules-19 runs use the approved Gold reductions.
local T={rulesVersion=19}
function T.enabled(version)return version==nil or version>=T.rulesVersion end
function T.first(amount,version)return T.enabled(version)and math.floor(amount*7/10)or amount end
function T.killBudget(amount,version)return T.enabled(version)and math.floor(amount*3/4)or amount end
function T.completion(amount,version)return T.enabled(version)and math.floor(amount/2)or amount end
return T
