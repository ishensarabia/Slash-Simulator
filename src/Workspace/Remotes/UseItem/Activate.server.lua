local playerFunctions = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("PlayerFunctions")

function FindToolInHand(player)
	if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
		return player.Character:FindFirstChildOfClass("Tool")
	end
end

script.Parent.OnServerEvent:Connect(function(player, targetPosition)
	local tool = FindToolInHand(player)
	if not script:FindFirstChild(player.Name) and tool then
		local tag = Instance.new("Model")
		tag.Name = player.Name
		tag.Parent = script
		require(playerFunctions).UseItem(player, tool, tool.ItemType.Value, targetPosition)
		tag:Destroy()
	end
end)