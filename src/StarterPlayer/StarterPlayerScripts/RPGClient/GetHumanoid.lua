local players = game:GetService("Players")

return function()
	if players.LocalPlayer.Character then
		return players.LocalPlayer.Character:WaitForChild("Humanoid")
	else
		local character = players.LocalPlayer.CharacterAdded:Wait()
		return character:WaitForChild("Humanoid")
	end
end