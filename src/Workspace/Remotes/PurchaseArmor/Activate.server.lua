local replicatedStorage = game:GetService("ReplicatedStorage")

script.Parent.OnServerInvoke = function(player, armorName)
	if replicatedStorage.Armor:FindFirstChild(armorName) and player.Stats.Gold.Value >= replicatedStorage.Armor[armorName].Price.Value and player.Armor[armorName].Value == false then
		player.Stats.Gold.Value = player.Stats.Gold.Value - replicatedStorage.Armor[armorName].Price.Value
		player.Armor[armorName].Value = true
		return true
	end
end