-- Adapter owns UpdateAsync; this module never replaces a failed read with a new profile.
local AccountStore = {}
AccountStore.__index = AccountStore
function AccountStore.new(adapter, rules, catalog, clock, waitForRetry, token)
	return setmetatable({adapter = adapter, rules = rules, catalog = catalog, clock = clock,
		waitForRetry = waitForRetry, token = token, profiles = {}, leaseSeconds = 120}, AccountStore)
end
function AccountStore:update(userId, transform)
	local outcome, replayed
	for attempt = 1, 3 do
		local time = self.clock()
		local ok, result = pcall(function()
			return self.adapter:UpdateAsync("account:" .. userId, function(current)
				outcome, replayed = nil, nil
				if current ~= nil and (type(current) ~= "table" or current.userId ~= userId or not self.rules.validate(current, self.catalog)) then outcome = "Incompatible"; return nil end
				local nextProfile, errorCode, repeated = transform(current, time)
				outcome, replayed = errorCode, repeated
				return nextProfile
			end)
		end)
		if ok then
			if outcome then return nil, outcome end
			if type(result) ~= "table" then return nil, "Unavailable" end
			self.profiles[userId] = self.rules.copy(result)
			return self.rules.copy(result), nil, replayed
		end
		if attempt < 3 then self.waitForRetry(0.4 * 2 ^ (attempt - 1)) end
	end
	return nil, "SaveUnknown"
end
function AccountStore:open(userId)
	return self:update(userId, function(current, time)
		local profile = current or self.rules.new(userId)
		local lease = profile.lease
		if lease and lease.token ~= self.token and lease.expiresAt > time then return nil, "AccountBusy" end
		profile = self.rules.copy(profile)
		if self.rules.upgrade then profile = self.rules.upgrade(profile) end
		if not lease or lease.token ~= self.token then profile.epoch = profile.epoch + 1 end
		profile.lease = {token = self.token, epoch = profile.epoch, expiresAt = time + self.leaseSeconds}
		return profile
	end)
end
function AccountStore:transact(userId, transform)
	local known = self.profiles[userId]
	if not known then return nil, "Unavailable" end
	local epoch = known.epoch
	return self:update(userId, function(profile, time)
		if not profile or not profile.lease or profile.lease.token ~= self.token or profile.epoch ~= epoch
			or profile.lease.expiresAt <= time then return nil, "AccountBusy" end
		local nextProfile, errorCode, repeated = transform(self.rules.copy(profile))
		if not nextProfile then return nil, errorCode end
		if not self.rules.validate(nextProfile, self.catalog) then return nil, "Incompatible" end
		if nextProfile.lease then nextProfile.lease.expiresAt = time + self.leaseSeconds end
		return nextProfile, nil, repeated
	end)
end
function AccountStore:renew(userId)
	return self:transact(userId, function(profile) return profile end)
end
function AccountStore:close(userId)
	local profile = self.profiles[userId]
	if not profile then return end
	local result, errorCode = self:transact(userId, function(current)
		current.lease = nil
		return current
	end)
	self.profiles[userId] = nil
	return result, errorCode
end
return AccountStore
