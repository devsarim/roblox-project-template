local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Store = require(script.Parent.Parent.modules.Store)
local PlayersReducer = require(ReplicatedStorage.shared.commonReducers.Players).Actions

local lastPaycheck = time()

RunService.Heartbeat:Connect(function()
	local t = time()
	if t - lastPaycheck <= 5 then
		return
	end

	lastPaycheck = t

	for _, player in ipairs(Players:GetPlayers()) do
		Store:dispatch(PlayersReducer.cashEarned(player.UserId, math.random(100)))
	end
end)

return {}
