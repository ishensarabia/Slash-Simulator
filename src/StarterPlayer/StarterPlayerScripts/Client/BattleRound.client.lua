local mainGui = game.Players.LocalPlayer.PlayerGui:WaitForChild("MainGUI")
local topStatus = mainGui:WaitForChild("TopStatus")
--Remotes
local replicatedStorage = game.ReplicatedStorage
local events = game.ReplicatedStorage.Common.RoundSystem.Remotes
-- This indicates the status of the battle
local status = game.ReplicatedStorage.Common.RoundSystem:WaitForChild("Status")
-- Button to join the battle
local joinBattleButton = game.Players.LocalPlayer.PlayerGui.MainGUI.JoinButton

local player  = game.Players.LocalPlayer
topStatus.Visible = true

local voteGrid = mainGui:WaitForChild("MapVoting"):WaitForChild("Grid")


for i, v in pairs(voteGrid:GetChildren()) do
	if v:IsA("ImageButton") and game.Workspace.Maps:FindFirstChild(v.Name) then
		v.MouseButton1Click:Connect(function()
			game.SoundService.GUI.button:Play()
			events.PlaceVote:FireServer(v.Name)
		end)
	end
end

events.ToggleMapVote.OnClientEvent:Connect(function(visibility)
	
	if not game.Players.LocalPlayer:FindFirstChild("InMenu") then
		mainGui.MapVoting.Visible = visibility
	end		
							
end)


events.UpdateVoteCount.OnClientEvent:Connect(function(data)
	for i, v in pairs(data) do
		if voteGrid[i] then
			voteGrid[i].Votes.Text = #v
		end
	end		
end)

status:GetPropertyChangedSignal("Value"):Connect(function()

	if replicatedStorage.Common.RoundSystem.GameInProgress.Value then
		if player:FindFirstChild("InBattle") then
			topStatus.Text = status.Value;
		else
			topStatus.Text = ""	
		end
	else
		if not player:WaitForChild("inMenu").Value then
			topStatus.Text = status.Value;
		end
	end

end)

joinBattleButton.MouseButton1Click:connect(function()

	events.JoinBattle:FireServer();

end)



