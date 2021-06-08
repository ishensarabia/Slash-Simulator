local players = game:GetService("Players")
local playerFunctions = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("PlayerFunctions")

script.Parent.Touched:Connect(function(part)
	local player = players:FindFirstChild(part.Parent.Name)
	if player and not script:FindFirstChild(player.Name) and part.Parent:FindFirstChild("HumanoidRootPart") then
		player.Stats.Mana.Value = require(playerFunctions).GetManaCap(player)
		script.Parent.Sound:Play()
		script.Parent.Splash:Emit(10)
		local cooldown = Instance.new("Model")
		cooldown.Name = player.Name
		cooldown.Parent = script
		wait(2)
		cooldown:Destroy()
	end
end)