local replicatedStorage = game:GetService("ReplicatedStorage")

script.Parent.OnServerInvoke = function(player, attributeName)
	if player.Attributes:FindFirstChild(attributeName) then
		local cap = replicatedStorage.ServerSettings:FindFirstChild(attributeName .. "Cap")
		if not cap or cap and player.Attributes[attributeName].Value < cap.Value then
			if player.Stats.Points.Value > 0 then
				player.Stats.Points.Value = player.Stats.Points.Value - 1
				player.Attributes[attributeName].Value = player.Attributes[attributeName].Value + 1
				return true
			else
				replicatedStorage.ClientRemotes.Notification:FireClient(player, "Need more points!", Color3.fromRGB(255, 0, 0))
			end
		else
			replicatedStorage.ClientRemotes.Notification:FireClient(player, "Maximum " .. attributeName .. " reached!", Color3.fromRGB(255, 0, 0))
		end
	end
end