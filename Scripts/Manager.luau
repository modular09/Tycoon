local Manager = {}
local Tycoon = script.Parent

Manager.Init = function(self: typeof(Manager))
	Manager.Ownership()
	Manager.ProvideConveyorVelocity(30)
	Manager.LoadSpawners(0.1)
	Manager.LoadDestroyers()
end

Manager.LoadDestroyers = function()
	--[[task.spawn(function()
		while true do
			for _, Destroyer in Tycoon.InGameAssets.Destroyers:GetChildren() do
				local Connection: RBXScriptConnection
				Connection = Destroyer.Touched:Connect(function(BasePart: BasePart)
					if BasePart.Name == "ClonePart" then
						BasePart:Destroy()
						Connection:Disconnect()
					end
				end)
			end
			task.wait(0.1)
		end
	end)
	]]
	coroutine.create(function()
		
	end)
end

Manager.LoadSpawners = function(SpawnWaitDuration: number)
	task.spawn(function()
		while true do
			for _, Spawner: typeof(Tycoon.Assets.Spawner) in Tycoon.InGameAssets.Spawners:GetChildren() do
				local Clone = Spawner.ClonePart:Clone()
				Clone.Parent = Tycoon.InGameAssets.Parts
				Clone.Anchored = false
				Clone.Transparency = 0
				Clone.CanCollide = true
			end
			task.wait(SpawnWaitDuration)
		end
	end)
end
Manager.ProvideConveyorVelocity = function(Speed)
	task.spawn(function()
		while true do
			for _, Conveyor in Tycoon.InGameAssets.Conveyors:GetChildren() do
				Conveyor.Velocity = Conveyor.CFrame.lookVector * Speed
			end
			task.wait(0.1)
		end
	end)
end

Manager.Ownership = function()
	if Manager.OwnerId ~= nil then
		return Manager.OwnerId
	end
	
	local ClaimPad = Tycoon.ClaimPad
	ClaimPad.Touched:Connect(function(BasePart)
		if BasePart.Parent:IsA("Model") then
			local Player = game:GetService("Players"):GetPlayerFromCharacter(BasePart.Parent)
			if Player then
				Manager.OwnerId = Player.UserId
				ClaimPad.CanTouch = false
				ClaimPad.Transparency = 1
			end
		end
	end)
end

return Manager
