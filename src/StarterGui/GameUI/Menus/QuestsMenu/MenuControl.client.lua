local players = game:GetService("Players")
local switchMenu = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("SwitchMenu")
local tracking = script.Parent.Parent.Parent:WaitForChild("HUD"):WaitForChild("TrackingQuest"):WaitForChild("TrackingQuest")
players.LocalPlayer:WaitForChild("IsLoaded")

function UpdateQuests()
	local layout = script.Parent.Quests.UIListLayout
	layout.Parent = script
	script.Parent.Quests:ClearAllChildren()
	layout.Parent = script.Parent.Quests
	local itemsPerPage = 8
	local quests = players.LocalPlayer.Quests:GetChildren()
	local amount = math.clamp(#quests, itemsPerPage, math.huge)
	script.Parent.Quests.CanvasSize = UDim2.new(0, 0, script.Parent.Quests.Size.Y.Scale + (script.Parent.Quests.Size.Y.Scale * (1 / itemsPerPage) * (amount - itemsPerPage)), 0)
	if #quests <= 0 then
		script.Parent.None.Visible = true
		return
	end
	script.Parent.None.Visible = false
	for _,quest in pairs(quests) do
		local newLabel = script.QuestTemplate:Clone()
		newLabel.Size = UDim2.new(0.95, 0, 1 / amount, 0)
		newLabel.Title.Text = quest.Name
		if tracking.Value == quest then
			newLabel.LayoutOrder = 0
			newLabel.Title.TextColor3 = Color3.fromRGB(255, 255, 0)
			newLabel.Track.Text = "Untrack"
		else
			newLabel.LayoutOrder = 1
			newLabel.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
			newLabel.Track.Text = "Track"
		end
		newLabel.Parent = script.Parent.Quests
		newLabel.Track.MouseButton1Click:Connect(function()
			if newLabel.Track.Text == "Track" then
				tracking.Value = quest
				UpdateQuests()
			else
				tracking.Value = nil
				UpdateQuests()
			end
		end)
	end
end

script.Parent:WaitForChild("Close").MouseButton1Click:Connect(function()
	require(switchMenu)(true)
end)

script.Parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if script.Parent.Visible == true then
		UpdateQuests()
	end
end)