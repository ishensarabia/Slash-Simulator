local replicatedStorage = game:GetService("ReplicatedStorage")

script.Parent.OnServerInvoke = function(player, itemName)
	local item = replicatedStorage.Items:FindFirstChild(itemName)
	if item and item:FindFirstChild("Price") and player.Stats.Gold.Value >= item.Price.Value then
		if not item:FindFirstChild("MinumumDamage") or not player.StarterGear:FindFirstChild(itemName) then
			player.Stats.Gold.Value = player.Stats.Gold.Value - replicatedStorage.Items[itemName].Price.Value
			replicatedStorage.Items[itemName]:Clone().Parent = player.StarterGear
			replicatedStorage.Items[itemName]:Clone().Parent = player.Backpack
			return true
		end
	end
end