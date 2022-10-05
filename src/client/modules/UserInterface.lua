--[[

	Sets up a root app component using Roact and RoactRodux, any component inside this root
	will be able to connect to the Rodux store and be in sync with the server/client state.

]]

local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Roact = require(game:GetService("ReplicatedStorage").Packages.Roact)
local RoactRodux = require(game:GetService("ReplicatedStorage").Packages.RoactRodux)
local Loader = require(game:GetService("ReplicatedStorage").Packages.Loader)

local Store = require(script.Parent.Store)

local UI = {}
UI.Components = Loader.LoadDescendants(script.Parent.Parent.roact)

UI.App = Roact.mount(
	Roact.createElement(RoactRodux.StoreProvider, {
		store = Store,
	}, {
		App = Roact.createElement("ScreenGui", {
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
		}, {
			--* Add components here
			--* ExampleComponent = Roact.createElement(UI.Components.ExampleComponent, ...)
			Example = Roact.createElement(UI.Components.Example),
		}),
	}),
	PlayerGui
)

return UI
