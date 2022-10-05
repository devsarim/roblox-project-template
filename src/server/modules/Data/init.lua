--[[

	Handles the loading, updating and saving of player data to a ProfileService store.

	Data is added to the Rodux store upon loading, from there, you should access and update
	a player's data using the Rodux store itself, the ProfileService profile will be kept in
	sync with the data in the Rodux store.

	The 'Settings' module inside this module defines what intial player data should like and
	what the name of the ProfileService store should be.

]]

export type Config = { Name: string, Template: { any } }

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileService = require(ReplicatedStorage.Packages.ProfileService)
local Promise = require(ReplicatedStorage.Packages.Promise)

local Store = require(script.Parent.Store)
local Settings = require(script.Settings)

local PlayerReducer = require(ReplicatedStorage.shared.commonReducers.Players).Actions

local Data = {
	Store = ProfileService.GetProfileStore(Settings.Name, Settings.Template),
	Profiles = {},

	OrderedDataStore = require(script.OrderedDatastore),
}

function Data:Load(player: Player)
	return Promise.new(function(res, rej)
		local profile = Data.Store:LoadProfileAsync("Player_" .. player.UserId)
		if not profile then
			-- The profile couldn't be loaded possibly due to other
			--   Roblox servers trying to load this profile at the same time:
			player:Kick()

			rej("Profile could not be loaded")
			return
		end

		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
		profile:ListenToRelease(function()
			Data.Profiles[player] = nil
			-- The profile could've been loaded on another Roblox server:
			player:Kick()
		end)

		if player:IsDescendantOf(Players) == true then
			Data.Profiles[player] = profile
			res(profile)
		else
			-- Player left before the profile loaded:
			profile:Release()

			rej("Player left before profile loaded")
		end
	end)
end

function Data:Release(player: Player)
	local profile = Data.Profiles[player]
	if not profile then
		return
	end

	profile:Release()
end

local function PlayerAdded(player: Player)
	Data:Load(player)
		:andThen(function(profile)
			Store:dispatch(PlayerReducer.playerAdded(player.UserId, profile.Data))
		end)
		:catch(warn)
end

local function PlayerRemoving(player: Player)
	Data:Release(player)
	Store:dispatch(PlayerReducer.playerRemoved(player.UserId))
end

local function StateChanged(newState, oldState)
	for userId, data in pairs(newState.Players) do
		if data == oldState.Players[userId] then
			continue
		end

		Data.Profiles[Players:GetPlayerByUserId(userId)].Data = data
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(PlayerAdded, player)
end

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerRemoving)
Store.changed:connect(StateChanged)

return Data
