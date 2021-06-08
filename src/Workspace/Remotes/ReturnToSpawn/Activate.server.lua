local replicatedStorage = game:GetService("ReplicatedStorage")
local serverSettings = replicatedStorage:WaitForChild("ServerSettings")

script.Parent.OnServerInvoke = function(player)
	local function GetAreaFromSpawnLocation(spawnLocation)
		for _,area in pairs(replicatedStorage.UnloadedAreas:GetChildren()) do
			if spawnLocation:IsDescendantOf(area) then
				return area
			end
		end
		for _,area in pairs(workspace.Areas:GetChildren()) do
			if spawnLocation:IsDescendantOf(area) then
				return area
			end
		end
	end
	if not script:FindFirstChild(player.Name) then
		local tag = Instance.new("Model")
		tag.Name = player.Name
		tag.Parent = script
		game:GetService("Debris"):AddItem(tag, 3)
		local defaultSpawnLocation = serverSettings.DefaultSpawnLocation.Value
		if defaultSpawnLocation then
			local area = GetAreaFromSpawnLocation(defaultSpawnLocation)
			if area then
				return area.Name
			end
		else
			replicatedStorage.ClientRemotes.Notification:FireClient(player, "Spawn has not been set!", Color3.fromRGB(255, 0, 0))
		end
	end
end