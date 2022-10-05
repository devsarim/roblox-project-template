local Rodux = require(game:GetService("ReplicatedStorage").Packages.Rodux)
local Sift = require(game:GetService("ReplicatedStorage").Packages.Sift)

local Dictionary = Sift.Dictionary
local None = Sift.None

local Reducer = Rodux.createReducer({}, {
	playerDataAdded = function(state, action)
		local player = state[action.userId]
		if player then
			return state
		end

		return Dictionary.merge(state, {
			[action.userId] = Dictionary.copyDeep(action.data),
		})
	end,

	playerDataRemoved = function(state, action)
		local player = state[action.userId]
		if not player then
			return state
		end

		return Dictionary.merge(state, {
			[action.userId] = None,
		})
	end,

	cashEarned = function(state, action)
		local player = state[action.userId]
		if not player then
			return state
		end

		return Dictionary.merge(state, {
			[action.userId] = Dictionary.merge(player, {
				Cash = player.Cash + action.amount,
			}),
		})
	end,
})

local Actions = {
	playerAdded = function(userId: number, data: { any })
		return {
			type = "playerDataAdded",
			userId = userId,
			data = data,
		}
	end,

	playerRemoved = function(userId: number)
		return {
			type = "playerDataRemoved",
			userId = userId,
		}
	end,

	cashEarned = function(userId: number, amount: number)
		return {
			type = "cashEarned",
			userId = userId,
			amount = amount,
		}
	end,
}

return {
	Reducer = Reducer,
	Actions = Actions,
}
