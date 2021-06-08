local replicatedStorage = game:GetService("ReplicatedStorage")

script.Parent.OnServerInvoke = function(player, itemName)
	if replicatedStorage.Items:FindFirstChild(itemName) and replicatedStorage.Items[itemName]:FindFirstChild("Price") and player.StarterGear:FindFirstChild(itemName) and player.Backpack:FindFirstChild(itemName) then
		player.Stats.Gold.Value = player.Stats.Gold.Value + replicatedStorage.Items[itemName].Price.Value
		player.StarterGear[itemName]:Destroy()
		player.Backpack[itemName]:Destroy()
	end
end