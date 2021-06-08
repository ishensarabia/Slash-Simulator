local replicatedStorage = game:GetService("ReplicatedStorage")
local equipArmor = replicatedStorage:WaitForChild("Modules"):WaitForChild("EquipArmor")

function CheckCooldown(playerName)
	if not script:FindFirstChild(playerName) then
		local cooldown = Instance.new("Model")
		cooldown.Name = playerName
		cooldown.Parent = script
		game:GetService("Debris"):AddItem(cooldown, 0.5)
		return true
	end
end

script.Parent.OnServerInvoke = function(player, armorName)
	if CheckCooldown(player.Name) then
		if armorName and replicatedStorage.Armor:FindFirstChild(armorName) and player.Armor[armorName].Value == true and player.Character and player.Character:FindFirstChild("Humanoid") then
			require(equipArmor)(player, armorName)
			return true
		elseif not armorName then
			require(equipArmor)(player)
			return true
		end
	end
end