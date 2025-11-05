local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")

local Tycoon = script.Parent
local Models = script.Models

local Cash = Instance.new("NumberValue")
local CollectedEvent = Instance.new("RemoteEvent")
CollectedEvent.OnServerEvent:Connect(function(Player: Player, Price: number?)
	Cash.Value = Cash.Value + Price
	print(Cash.Value)
end)

local Manager = {}

Manager.Init = function(self: typeof(Manager))
	--[[
		Components:
		- Collectors (Cash)
		- Conveyors
		- Buttons
		- Walls
		- Stairs
	--]]
	-- Manager.PlayerCollisionGroupHandler()
	task.spawn(Manager.CurrencyHandler)
	task.spawn(Manager.OwnershipHandler)
	task.spawn(Manager.LoadDroppers, 0.01)
	task.spawn(Manager.LoadConveyorBelts, 20)
	task.spawn(Manager.LoadCollectors)
end

Manager.OwnershipHandler = function()
	if Manager.Owner ~= nil then
		return Manager.Owner
	end
	
	local OwnershipPad = Tycoon:WaitForChild("OwnershipPad")
	OwnershipPad.Touched:Connect(function(BasePart)
		if BasePart.Parent:IsA("Model") then
			local Player = game:GetService("Players"):GetPlayerFromCharacter(BasePart.Parent)
			if Player then
				Manager.Owner = Player
				OwnershipPad.Transparency = 1
				OwnershipPad.CanCollide = false
				OwnershipPad.CanTouch = false
			end
		end
	end)
end

Manager.LoadDroppers = function(WaitTime: number)
	local modTime = 0
	
	RunService.Heartbeat:Connect(function(deltaTime: number)
		modTime = modTime + deltaTime
		if modTime > WaitTime then
			for _, Dropper: typeof(Models.Dropper) in Tycoon.Assets:WaitForChild("Droppers"):GetChildren() do
				local Drop = Instance.new("Part", Tycoon.Assets:WaitForChild("Drops"))
				Drop.Anchored = false
				Drop.CollisionGroup = "Drops"
				Drop.Name = "Drop"
				Drop.Position = Dropper.Reference.Position
				Drop.Size = Vector3.new(1, 1, 1)
				CollectionService:AddTag(Drop, "Drop")
			end
			modTime = 0
		end
	end)
end

Manager.LoadConveyorBelts = function(Speed: number)
	local ConveyorBelts = Tycoon.Assets:WaitForChild("ConveyorBelts")
	for _, BasePart: BasePart in ConveyorBelts:GetChildren() do -- Initial/First Load
		BasePart.AssemblyLinearVelocity = BasePart.CFrame.LookVector * Speed
	end
	ConveyorBelts.ChildAdded:Connect(function(Child: BasePart?)
		if Child:IsA("BasePart") then
			Child.AssemblyLinearVelocity = Child.CFrame.LookVector * Speed
		end
	end)
end

Manager.LoadCollectors = function()
	local Inspect = function(BasePart: BasePart)
		if CollectionService:HasTag(BasePart, "Drop") then
			CollectedEvent:FireServer(1)
			BasePart:Destroy()
		end
	end
	
	for _, Collector: BasePart in Tycoon.Assets:WaitForChild("Collectors"):GetChildren() do -- Initial/First Load
		Collector.Touched:Connect(Inspect)
	end
end

--[[ "Set Player Group Collision to Drops OFF"
Manager.PlayerCollisionGroupHandler = function()
	game:GetService("Players").PlayerAdded:Connect(function(Player: Player)
		Player.CharacterAdded:Connect(function(Character: Model)
			for _, BasePart: BasePart in Character:GetDescendants() do
				if BasePart:IsA("BasePart") then
					BasePart.CollisionGroup = "Player"
				end
			end
		end)
	end)
end
--]]

return Manager
