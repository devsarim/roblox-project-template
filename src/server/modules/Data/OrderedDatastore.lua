--[[
  
  Wrapper for OrderedDataStore that implements automatic retries, pcalls and other helpful
	functions.

	This can be useful for things like global leaderboards (eg. Top 10 Cash)

	Example:
	
		local moneyLeaderboard = OrderedDataStore.new("GlobalMoney.01a")

		local lastUpdate = time()
		local lastRefresh = time()

		game:GetService("RunService").Heartbeat:Connect(function
			local t = time()
			
			if t - lastUpdate >= 10 then
				lastUpdate = t

				for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
					moneyLeaderboard:UpdateAsync(player.UserId, player:GetAttribute("Money"))
				end
			end

			if t - lastRefresh >= 15 then
				lastRefresh = t

				local topFifteen = moneyLeaerboard:GetSorted(1, 15):andThen(function(result)
					--*: Refresh UI
				end)
			end
		end)
  
  ]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)

local Dictionary = Sift.Dictionary

local OrderedDataStore = {}
OrderedDataStore.__index = OrderedDataStore

local MAX_RETRIES = 5
local DEFAULT_PAGE_SIZE = 10
local DEFAULT_PAGES = 1

local function getPagesObject(store, pageSize, isAscending)
	local tries = 0
	local success, pagesObject

	repeat
		tries += 1
		success, pagesObject = pcall(store.GetSortedAsync, store, isAscending, pageSize)

		task.wait(1)
	until success or tries >= MAX_RETRIES

	if not success then
		return
	end

	return pagesObject
end

local function advanceToNextPage(pagesObject: DataStorePages)
	local tries = 0
	local success

	repeat
		tries += 1
		success = pcall(pagesObject.AdvanceToNextPageAsync, pagesObject)

		task.wait()
	until success or tries >= MAX_RETRIES

	return success
end

function OrderedDataStore.new(name: string)
	local self = setmetatable({
		Store = DataStoreService:GetOrderedDataStore(name),
	}, OrderedDataStore)

	return self
end

function OrderedDataStore:UpdateAsync(key, value)
	local tries = 0
	local success

	repeat
		tries += 1
		success = pcall(self.Store.UpdateAsync, self.Store, key, function()
			return value
		end)

		task.wait(1)
	until success or tries >= MAX_RETRIES

	return success
end

function OrderedDataStore:SetAsync(key, value)
	local tries = 0
	local success

	repeat
		tries += 1
		success = pcall(self.Store.SetAsync, self.Store, key, value)

		task.wait(1)
	until success or tries >= MAX_RETRIES

	return success
end

function OrderedDataStore:GetAsync(key)
	local tries = 0
	local success, data

	repeat
		tries += 1
		success, data = pcall(self.Store.GetAsync, self.Store, key)

		task.wait(1)
	until success or tries >= MAX_RETRIES

	if not success then
		return
	end

	return data
end

function OrderedDataStore:RemoveAsync(key)
	local tries = 0
	local success, data

	repeat
		tries += 1
		success, data = pcall(self.Store.RemoveAsync, self.Store, key)

		task.wait(1)
	until success or tries >= MAX_RETRIES

	if not success then
		return
	end

	return data
end

function OrderedDataStore:GetSorted(pages: number?, pageSize: number?, isAscending: boolean?)
	return Promise.new(function(res, rej)
		pages = pages or DEFAULT_PAGES
		pageSize = pageSize or DEFAULT_PAGE_SIZE
		isAscending = isAscending ~= nil and isAscending or false

		local pagesObject = getPagesObject(self.Store, pageSize, isAscending)
		if not pagesObject then
			rej("Failed to get sorted pages")
			return
		end

		if pages == 1 then
			res({ pagesObject:GetCurrentPage() })
			return
		end

		local allPages = {}
		local lastPage = {}

		for _ = 1, pages do
			local currentPage = pagesObject:GetCurrentPage()
			if not currentPage or Dictionary.equalsDeep(currentPage, lastPage) then
				res(allPages)
				return
			end
			lastPage = currentPage

			table.insert(allPages, currentPage)
			advanceToNextPage(pagesObject)

			task.wait()
		end

		res(allPages)
	end)
end

return OrderedDataStore
