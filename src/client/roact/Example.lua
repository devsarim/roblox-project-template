local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local UserId = Player.UserId

local Roact = require(game:GetService("ReplicatedStorage").Packages.Roact)
local RoactRodux = require(game:GetService("ReplicatedStorage").Packages.RoactRodux)

local Component = Roact.Component:extend("Example")

function Component:init() end

function Component:render()
	local props = self.props
	local data = props.data

	if not data then
		return
	end

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
		IgnoreGuiInset = 0,
	}, {
		MoneyDisplay = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromScale(0.25, 0.1),
			Position = UDim2.new(0.5, 0, 1 - 0.1 / 2, -10),

			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			Font = Enum.Font.GothamBold,
			Text = ("$%d"):format(data.Cash),
			TextColor3 = Color3.fromRGB(73, 247, 57),
			TextStrokeTransparency = 0,
			TextScaled = true,
		}),
	})
end

function Component:didMount() end

return RoactRodux.connect(function(state)
	return { data = state.Players[UserId] }
end)(Component)
