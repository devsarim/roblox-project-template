local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require(ReplicatedStorage.Packages.Loader)

Loader.LoadChildren(script.modules)
Loader.LoadChildren(script.components)
