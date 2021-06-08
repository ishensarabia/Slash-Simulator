game:GetService("ReplicatedStorage"):WaitForChild("ClientRemotes"):WaitForChild("Notification").OnClientEvent:Connect(function(message, color)
	if not color then
		color = Color3.fromRGB(255, 255, 255) -- default to white if no color is sent
	end
	local newNotification = script:WaitForChild("Template"):Clone()
	local yScale = newNotification.Size.Y.Scale
	newNotification.Text = "  " .. message -- needs space from the edge of the screen
	newNotification.TextColor3 = color
	newNotification.Position = UDim2.new(0, 0, 1, 0)
	newNotification.Name = 1
	newNotification.Parent = script.Parent
	for _,otherLabel in pairs(script.Parent:GetChildren()) do -- move all other labels up to make room
		if otherLabel.ClassName == "TextLabel" then
			game:GetService("TweenService"):Create(otherLabel, TweenInfo.new(0.5), {Position = UDim2.new(0, 0, otherLabel.Name - yScale, 0)}):Play()
			otherLabel.Name = otherLabel.Name - yScale
		end
	end
	for _ = 1,6 do -- text animation
		game:GetService("TweenService"):Create(newNotification, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 0.25}):Play()
		wait(0.25)
		game:GetService("TweenService"):Create(newNotification, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 0}):Play()
		wait(0.25)
	end
	game:GetService("TweenService"):Create(newNotification, TweenInfo.new(0.5), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
	wait(0.5)
	newNotification:Destroy()
end)