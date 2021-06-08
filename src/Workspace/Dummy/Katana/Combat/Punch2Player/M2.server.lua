local m2 = script.Parent
local tweenService = game:GetService("TweenService")

m2.OnServerEvent:Connect(function(player,V1)
	local character  = player.Character
	
	
		 local Track5 = Instance.new("Animation")
	Track5.AnimationId = "rbxassetid://5740595758" -- M2  ANIMATION GOES HERE
        local Anim5 = character.Humanoid:LoadAnimation(Track5)
		Anim5:Play()
	
	

	local region = Region3.new(V1-Vector3.new(2,2,2),V1+Vector3.new(2,2,2))
	local RTable = workspace:FindPartsInRegion3(region,nil,20)

	for i,v in pairs(RTable) do
		if v.Parent:FindFirstChild("Humanoid") and v.Parent:FindFirstChild("Deb") == nil and v.Parent ~= character then
			local deb = Instance.new("BoolValue",v.Parent)
			deb.Name = "Deb"
			game.Debris:AddItem(deb,0.2)
			local closecharacter = v.Parent
			if closecharacter:FindFirstChild("Knocked") then return end

			if closecharacter.HumanoidRootPart:FindFirstChild("Block") then
				closecharacter.BlockBar.Value = 0
			else



				closecharacter.Humanoid:TakeDamage(15)	
				local bv = Instance.new("BodyVelocity",closecharacter.HumanoidRootPart)
				bv.MaxForce = Vector3.new(1e8,1e8,1e8)
				bv.Velocity = character.HumanoidRootPart.CFrame.lookVector*30
				game.Debris:AddItem(bv,0.3) 

			end

		end
	end
	
end)