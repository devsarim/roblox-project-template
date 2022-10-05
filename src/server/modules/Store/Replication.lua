local Remotes = require(game:GetService("ReplicatedStorage").shared.modules.Remotes).Server

local StateChanged = Remotes:Get("StateChanged")

return function(nextDispatch)
	return function(action)
		nextDispatch(action)

		StateChanged:SendToAllPlayers(action)
	end
end
