--[[

	Sets up the Rodux store on the server which is where all game related state will be stored and updated.
	This module also handles the replication of said store to all clients.
	
	Store from the server reducers will not be replicated to clients.

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rodux = require(ReplicatedStorage.Packages.Rodux)
local Loader = require(ReplicatedStorage.Packages.Loader)
local Sift = require(ReplicatedStorage.Packages.Sift)

local Remotes = require(ReplicatedStorage.shared.modules.Remotes).Server
local GetStateFunction = Remotes:Get("GetState")

local CommonReducers = Loader.LoadChildren(ReplicatedStorage.shared.commonReducers)
local ServerReducers = Loader.LoadChildren(script.Parent.Parent.serverReducers)

for key, value in pairs(CommonReducers) do
	CommonReducers[key] = value.Reducer
end

for key, value in pairs(ServerReducers) do
	ServerReducers[key] = value.Reducer
end

local Store = Rodux.Store.new(Rodux.combineReducers(Sift.Dictionary.merge(CommonReducers, ServerReducers)), nil, {
	require(script.Replication),
	Rodux.loggerMiddleware,
})

GetStateFunction:SetCallback(function()
	local state = Store:getState()

	for key, _ in pairs(state) do
		if not ServerReducers[key] then
			continue
		end

		state[key] = nil
	end

	return state
end)

return Store
