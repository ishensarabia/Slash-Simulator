local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

return function(player, armorName)
	local tool = player.Character:FindFirstChildOfClass("Tool")
	if tool then
		tool.Parent = player.Backpack
	end
	if armorName then
		player.Stats.CurrentArmor.Value = armorName
		local modified = players:GetHumanoidDescriptionFromUserId(player.UserId)
		modified.BackAccessory = ""
		modified.FrontAccessory = ""
		modified.WaistAccessory = ""
		modified.ShouldersAccessory = ""
		modified.LeftArm = replicatedStorage.Armor[armorName].LeftArm
		modified.RightArm = replicatedStorage.Armor[armorName].RightArm
		modified.LeftLeg = replicatedStorage.Armor[armorName].LeftLeg
		modified.RightLeg = replicatedStorage.Armor[armorName].RightLeg
		modified.Torso = replicatedStorage.Armor[armorName].Torso
		player.Character.Humanoid:ApplyDescription(modified)
	else
		player.Stats.CurrentArmor.Value = ""
		player.Character.Humanoid:ApplyDescription(players:GetHumanoidDescriptionFromUserId(player.UserId))
	end
end