--[[

	Sets up the Rodux store on the client which is where all game related state will be stored and updated.
	
	Store from the client reducers will not be replicated to the server.

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rodux = require(ReplicatedStorage.Packages.Rodux)
local Loader = require(ReplicatedStorage.Packages.Loader)
local Sift = require(ReplicatedStorage.Packages.Sift)

local Remotes = require(ReplicatedStorage.shared.modules.Remotes).Client

local GetState = Remotes:Get("GetState")
local StateChanged = Remotes:Get("StateChanged")

local Store: Rodux.Store = nil

local CommonReducers = Loader.LoadChildren(ReplicatedStorage.shared.commonReducers)
local ClientReducers = Loader.LoadChildren(script.Parent.Parent.clientReducers)

for key, value in pairs(CommonReducers) do
	CommonReducers[key] = value.Reducer
end

for key, value in pairs(ClientReducers) do
	ClientReducers[key] = value.Reducer
end

GetState:CallServerAsync()
	:andThen(function(state)
		Store = Rodux.Store.new(
			Rodux.combineReducers(Sift.Dictionary.merge(CommonReducers, ClientReducers)),
			state,
			{ Rodux.loggerMiddleware }
		)

		StateChanged:Connect(function(action)
			Store:dispatch(action)
		end)
	end)
	:await()

return Store
