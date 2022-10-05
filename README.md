# Roblox Project Template
If you're like me, you've probably found yourself running these commands and setting up the directory when starting a project:

`aftman init`
`aftman add rojo-rbx/rojo`
`aftman add wally`
`wally init && rojo init`
`mkdir bla bla bla`

After that, you probably go ahead and set up your Rodux store, your data saving system by either writing it from scratch the same way you have for every other project or copying and pasting from another project, all of this, takes a lot of time and takes away from the initial burst of motivation you have for a project, to solve this for myself and hopefully my fellow developers, I've made this very opinionated template that gives you all of these things out of the box:

![image](https://user-images.githubusercontent.com/55910649/194168049-c62413ca-9e3f-495a-bd9a-9691c1d1a4e1.png)

* A Rodux store that is replicated between the server and the clients.
  * This store can have reducers that are shared between the server and the clients, reducers only for the server and reducers only for the clients.
* The modules in the `client` and `server` folders are automatically required on runtime.

![image](https://user-images.githubusercontent.com/55910649/194168464-086b237c-3b25-4b54-b47f-1d540dcb65c3.png)

* The `UserInterface` module creates a root/app component that is connected with the Rodux store, all components inside this component will be able to connect to the Rodux store and be in sync with the state.

```lua
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
			Example = Roact.createElement(UI.Components.Example),
		}),
	}),
	PlayerGui
)

return UI
```

* Along with a data saving system, there's a wrapper class for `OrderedDataStore` that implements automatic retries, pcalls and a very helpful method called `GetSorted(pages: number?, pageSize: number?, isAscending: boolean?)` which can be used for things like global leaderboards. `Example: local topTenMoney = OrderedDataStore.new("GlobalMoney.01a"):GetSorted(1, 10)`

![image](https://user-images.githubusercontent.com/55910649/194168928-b0bfb60d-e104-4b94-beee-045f4a121d3f.png)

> In conclusion, this provides you with boilerplate for synced game state, player data saving, state synced UI and a nice organized structure.

I mainly made this for myself and this kind of structure and practice might not be what you prefer so feel free to fork it and edit it however you want, I'm sure it'll still save you some precious developer time. :)
