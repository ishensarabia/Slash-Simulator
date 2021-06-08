local module = {}
local MarketplaceService = game:GetService("MarketplaceService")

local status = game.ReplicatedStorage.Common.RoundSystem:WaitForChild("Status")



function module.Intermission(length)

	for i = length,0,-1 do
		status.Value = "Next battle starts in "..i.." seconds"
		wait(1)
	end
end


function module.SelectMap()

    local Votes = {}


	for i, v in pairs(game.Players:GetPlayers()) do
		if v:FindFirstChild("InBattle") then
			game.ReplicatedStorage.Common.RoundSystem.Remotes.ToggleMapVote:FireClient(v,true)
		end
	end



    for i, v in pairs(game.Workspace.Maps:GetChildren()) do
	    Votes[v.Name] = {}
    end


    local placeVoteConnection = game.ReplicatedStorage.Common.RoundSystem.Remotes.PlaceVote.OnServerEvent:Connect(function(player,mapName)
     	if Votes[mapName] then

            for i, playerVotesTab in pairs(Votes) do
	            for x, playerName in pairs(playerVotesTab) do
		            if playerName == player.Name then
			        	table.remove(playerVotesTab,x)
			            break
		            end
	            end
            end

	        table.insert(Votes[mapName],player.Name)

	        game.ReplicatedStorage.Common.RoundSystem.Remotes.UpdateVoteCount:FireAllClients(Votes)

        end
    end)


    game.ReplicatedStorage.Common.RoundSystem.MapVoting.Value = true

    wait(8)

    game.ReplicatedStorage.Common.RoundSystem.MapVoting.Value = false

	game.ReplicatedStorage.Common.RoundSystem.Remotes.ToggleMapVote:FireAllClients(false)


    placeVoteConnection:Disconnect()


	local mostVotes = nil
	local mostVoted = nil


	for i, mapTable in pairs(Votes) do

		local votes = #mapTable

		if mostVotes == nil then
			mostVotes = votes
			mostVoted = i

		else

			if votes >= mostVotes then
				mostVotes = votes
				mostVoted = i
			end

		end

	end

	local chosenMap
	if mostVotes == nil or mostVoted == nil then
		chosenMap = game.Workspace.Maps:GetChildren()[math.random(1,#game.Workspace.Maps:GetChildren())]
	else
		chosenMap = game.Workspace.Maps[mostVoted]
    end

	status.Value = chosenMap.Name.." has been selected!"

	wait(5)
	status.Value = ""
	return chosenMap

end


function module.TeleportPlayers(players, mapSpawns)

    for i, player in pairs(players) do
	    if player.Character then
		    local character = player.Character

		    if character:FindFirstChild("HumanoidRootPart") then

			    player.Character.Humanoid.WalkSpeed = 16

			    local rand = Random.new()
			    player.Character.HumanoidRootPart.CFrame = mapSpawns[rand:NextInteger(1,#mapSpawns)].CFrame + Vector3.new(0,10,0)

		    end
	    end
    end

end



local function toMS(s)
	return ("%02i:%02i"):format(s/60%60, s%60)
end

function module.StartRound(length,chapterMap,roundMessage) -- length (in seconds)

	local outcome
	local killerBotReplacementDebounce = false
	local statusDebounce = false
	local contenders
	game.ReplicatedStorage.Common.RoundSystem.GameInProgress.Value = true


	for i = length,0,-1 do

		if statusDebounce == false then
			status.Value = roundMessage
			statusDebounce = true
			wait(3)
		end

		contenders = {}

		for i, player in pairs(game.Players:GetPlayers()) do

			if player:FindFirstChild("InBattle") then
				table.insert(contenders,player)
			end

		end

		status.Value = toMS(i)

		if #contenders == 1 then
			outcome = "Won"
			break
		end

		if i == 0 then
			outcome = "time-up"
			break
		end

		wait(1)
	end

	if outcome == "Won" then
		status.Value = contenders[1].Name .. " has won the battle!"
	elseif outcome == "time-up" then
		status.Value = "Draw"
	end



	wait(5)

end

function module.InsertTag(contenders,tagName)
	for i, player in pairs(contenders) do
		local Tag = Instance.new("StringValue")
		Tag.Name = tagName
		Tag.Parent = player
	end
end

function module.RemoveTags()
	game.ReplicatedStorage.Common.RoundSystem.GameInProgress.Value = false

	for i, v in pairs(game.Players:GetPlayers()) do
		if v:FindFirstChild("InBattle") then
			v.InBattle:Destroy()

			for _, p in pairs(v.Backpack:GetChildren()) do
				if p:IsA("Tool") then
			        p:Destroy()
				end
			end

			for _, p in pairs(v.Character:GetChildren()) do
				if p:IsA("Tool") then
			        p:Destroy()
				end
			end

		end
	end
end


return module
