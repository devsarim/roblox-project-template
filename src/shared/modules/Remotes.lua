local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Packages.Net)

return Net.CreateDefinitions({
	GetState = Net.Definitions.ServerAsyncFunction(),
	StateChanged = Net.Definitions.ServerToClientEvent(),
})
