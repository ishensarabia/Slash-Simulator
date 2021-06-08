local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local playSoundEffect = replicatedStorage:WaitForChild("Modules"):WaitForChild("PlaySoundEffect")
local attributes = script.Parent:WaitForChild("Attributes")
local switchMenu = replicatedStorage:WaitForChild("Modules"):WaitForChild("SwitchMenu")
players.LocalPlayer:WaitForChild("IsLoaded")

-- The names of the frames in the Attribute frame correspond to stat names

function UpdateAttributes()
	script.Parent:WaitForChild("Points").Text = "Points: " .. players.LocalPlayer.Stats.Points.Value
	for _,attribute in pairs(attributes:GetChildren()) do
		if attribute.ClassName == "Frame" then
			local cap = replicatedStorage.ServerSettings:FindFirstChild(attribute.Name .. "Cap")
			local stat = players.LocalPlayer.Attributes:FindFirstChild(attribute.Name)
			local percentage = 1
			if cap and stat then
				percentage = stat.Value / cap.Value
			end
			attribute.Bar.Fill.Position = UDim2.new(percentage - 1, 0, 0, 0)
			attribute.Title.Text = attribute.Name .. " (" .. stat.Value .. ")"
		end
	end
end

script.Parent:WaitForChild("Reset").MouseButton1Click:Connect(function()
	require(playSoundEffect)("Unequip")
	workspace.Remotes.ResetPoints:InvokeServer()
	UpdateAttributes()
end)

script.Parent:WaitForChild("Close").MouseButton1Click:Connect(function()
	require(switchMenu)(true)
end)

script.Parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if script.Parent.Visible == true then
		UpdateAttributes()
	end
end)

for _,attribute in pairs(attributes:GetChildren()) do
	if attribute.ClassName == "Frame" then
		attribute:WaitForChild("Add").MouseButton1Click:Connect(function()
			local success = workspace.Remotes.UsePointForAttribute:InvokeServer(attribute.Name)
			if success then
				require(playSoundEffect)("Equip")
				UpdateAttributes()
			end
		end)
	end
end