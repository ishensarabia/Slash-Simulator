local replicatedStorage = game:GetService("ReplicatedStorage")

script.Parent.OnServerInvoke = function(player)
	for _,attribute in pairs(player.Attributes:GetChildren()) do
		player.Stats.Points.Value = player.Stats.Points.Value + attribute.Value
		attribute.Value = 0
	end
	replicatedStorage.ClientRemotes.Notification:FireClient(player, "Your attributes have been reset!", Color3.fromRGB(0, 255, 0))
end