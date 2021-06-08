local players = game:GetService("Players")
local switchMenu = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("SwitchMenu")
local questSystem = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("QuestSystem")
local fillQuestMenu = players.LocalPlayer.PlayerGui:WaitForChild("GameUI"):WaitForChild("FillQuestMenu")
local tracking = script.Parent:WaitForChild("TrackingQuest")
local updateConnections = {}
players.LocalPlayer:WaitForChild("IsLoaded")

function DisconnectAll()
	for _,connection in pairs(updateConnections) do
		if connection then
			connection:Disconnect()
		end
	end
	updateConnections = {}
end

tracking.Changed:Connect(function()
	local quest = tracking.Value
	if quest then
		local canvasPosition
		local function UpdateDescription()
			require(fillQuestMenu).FillDescription(script.Parent.Description, quest, true)
			if canvasPosition then
				wait()
				script.Parent.Description.CanvasPosition = canvasPosition
			end
		end
		script.Parent.Visible = true
		script.Parent.Title.Text = quest.Name
		UpdateDescription()
		DisconnectAll()
		for _,value in pairs(quest:GetDescendants()) do
			if value:IsA("ValueBase") then
				table.insert(updateConnections, value.Changed:Connect(function()
					canvasPosition = script.Parent.Description.CanvasPosition
					UpdateDescription()
				end))
			end
		end
		table.insert(updateConnections,
			quest.AncestryChanged:Connect(function()
				if not quest.Parent then
					script.Parent.Visible = false
					DisconnectAll()
				end
			end)
		)
	else
		script.Parent.Visible = false
		DisconnectAll()
	end
end)