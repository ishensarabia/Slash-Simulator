local plr = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local Anim2
script.Parent.Equipped:Connect(function()
	
	
	
	
		local Track2 = Instance.new("Animation")
	Track2.AnimationId = "rbxassetid://6374456201" --Idle 
		 Anim2 = plr.Character.Humanoid:LoadAnimation(Track2)
		Anim2:Play()
	
	
		
end)


script.Parent.Unequipped:Connect(function()
	
	Anim2:Stop()
	
	
	
	
	
end)