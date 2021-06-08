-- Made by Chrythm

local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local enemyFunctions = replicatedStorage:WaitForChild("Modules"):WaitForChild("EnemyFunctions")
local playerFunctions = replicatedStorage:WaitForChild("Modules"):WaitForChild("PlayerFunctions")
local questSystem = replicatedStorage:WaitForChild("Modules"):WaitForChild("QuestSystem")
local follow = script:WaitForChild("Follow")
local music = game:GetService("SoundService"):WaitForChild("Music")

-- Join control
players.PlayerAdded:Connect(require(playerFunctions).PlayerAdded)
players.PlayerRemoving:Connect(require(playerFunctions).Save)

-- Make sure all music "Loop" properties are true
for _,song in pairs(music:GetChildren()) do
	song.Looped = true
end

-- Set up portals
for _,portal in pairs(workspace.Portals:GetChildren()) do
	local label = script.PortalLabel:Clone()
	label.RankLabel.Text = portal.RequiredRank.Value
	label.Parent = portal.Portal
	portal.Portal.Touched:Connect(function(part)
		local player = players:GetPlayerFromCharacter(part.Parent)
		if player and player.Stats.Rank.Value >= portal.RequiredRank.Value and not portal:FindFirstChild(player.Name .. "Cooldown") then
			replicatedStorage.ClientRemotes.TeleportToArea:FireClient(player, portal.AreaToTeleportTo.Value.Name)
			player.Stats.CurrentArea.Value = portal.AreaToTeleportTo.Value
			player.RespawnLocation = portal.AreaToTeleportTo.Value.Spawn
			local tag = Instance.new("Model")
			tag.Name = player.Name .. "Cooldown"
			tag.Parent = portal
			game:GetService("Debris"):AddItem(tag, 3)
		end
	end)
end

-- Set up quest triggers
for _,trigger in pairs(workspace.QuestTriggers:GetChildren()) do
	local quest = replicatedStorage.Quests:FindFirstChild(trigger.Name)
	if quest then
		trigger.Touched:Connect(function(part)
			local player = players:GetPlayerFromCharacter(part.Parent)
			if player and not script:FindFirstChild(player.Name .. "Deciding") and not player.Quests:FindFirstChild(quest.Name) and not player.CompletedQuests:FindFirstChild(quest.Name) then
				local tag = Instance.new("Model")
				tag.Name = player.Name .. "Deciding"
				tag.Parent = script
				local acceptedQuest
				pcall(function() -- Player might leave during the invoke, causing the tag to stay forever
					acceptedQuest = replicatedStorage.ClientRemotes.OfferQuest:InvokeClient(player, quest)
				end)
				if acceptedQuest then
					local quest = require(questSystem).GiveQuest(player, quest.Name)
					require(questSystem[quest.QuestType.Value]).CheckIfCompleted(player, quest) -- Player may have already met the completion requirements
				end
				wait(2)
				tag:Destroy()
			end
		end)
	else
		warn('Could not find a matching quest in ReplicatedStorage.Quests for the trigger named "' .. trigger.Name .. '"')
	end
end
for _,quest in pairs(replicatedStorage.Quests:GetChildren()) do
	if quest.QuestType.Value == "TouchOrb" then -- Make quest touch connections
		local destinationOrb = quest.Requirements:FindFirstChildOfClass("ObjectValue")
		if destinationOrb and destinationOrb.Value then
			destinationOrb.Value.Touched:Connect(function(part)
				local player = players:GetPlayerFromCharacter(part.Parent)
				if player then
					local matchingQuest = player.Quests:FindFirstChild(quest.Name)
					if matchingQuest then
						require(questSystem.TouchOrb).CheckIfCompleted(player, matchingQuest)
					end
				end
			end)
		end
	end
end

-- Enemy spawn system
for _,area in pairs(workspace.Areas:GetChildren()) do
	local function RefillEnemies()
		local function SpawnEnemy(spawnRegion)
			local enemyToSpawn = spawnRegion.EnemiesToSpawnHere:GetChildren()[math.random(1,#spawnRegion.EnemiesToSpawnHere:GetChildren())].Name
			local xVectorRandom = spawnRegion.CFrame.RightVector * spawnRegion.Size.X * (math.random(-50, 50) / 100)
			local yVectorRandom = spawnRegion.CFrame.UpVector * spawnRegion.Size.Y * (math.random(-50, 50) / 100)
			local zVectorRandom = spawnRegion.CFrame.LookVector * spawnRegion.Size.Z * (math.random(-50, 50) / 100)
			local spawnPosition = spawnRegion.Position + xVectorRandom + yVectorRandom + zVectorRandom
			require(enemyFunctions).SpawnEnemy(enemyToSpawn, spawnPosition, area.Enemies)
		end
		local enemyCounts = {}
		for _,enemy in pairs(area.Enemies:GetChildren()) do
			if not enemyCounts[enemy.Name] then
				enemyCounts[enemy.Name] = 1
			else
				enemyCounts[enemy.Name] = enemyCounts[enemy.Name] + 1
			end
		end
		for _,spawnRegion in pairs(area.SpawnRegions:GetChildren()) do
			local enemiesInRegion = 0
			for _,enemyToSpawn in pairs(spawnRegion.EnemiesToSpawnHere:GetChildren()) do
				if enemyCounts[enemyToSpawn.Name] then
					enemiesInRegion = enemiesInRegion + enemyCounts[enemyToSpawn.Name]
				end
			end
			for i = 1, spawnRegion.MaximumEnemies.Value - enemiesInRegion do
				SpawnEnemy(spawnRegion)
			end
		end
	end
	if area:FindFirstChild("Enemies") and area:FindFirstChild("SpawnRegions") then
		RefillEnemies()
		area.Enemies.ChildRemoved:Connect(RefillEnemies)
	end
end

-- Enemy AI system
follow.Event:Connect(require(enemyFunctions).Follow)

while true do
	local enemiesToConsider = {}
	for _,player in pairs(players:GetChildren()) do -- Adds all enemies in loaded areas to the considered table
		if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
			if player:FindFirstChild("Stats") and player.Stats:FindFirstChild("CurrentArea") and player.Stats.CurrentArea.Value then
				local enemiesFolder = player.Stats.CurrentArea.Value:FindFirstChild("Enemies")
				if enemiesFolder then
					for _,enemy in pairs(enemiesFolder:GetChildren()) do
						if not table.find(enemiesToConsider, enemy) then
							table.insert(enemiesToConsider, enemy)
						end
					end
				end
			end
		end
	end
	for _,enemy in pairs(enemiesToConsider) do
		local closestPlayer = require(enemyFunctions).FindClosestPlayer(enemy, true)
		if closestPlayer then
			if closestPlayer.Character then
				local rootPart = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
				if rootPart then
					follow:Fire(enemy, rootPart)
				end
			end
		elseif enemy:FindFirstChild("Stats") and enemy.Stats:FindFirstChild("OriginalPosition") then
			enemy.EnemyHumanoid:MoveTo(enemy.Stats.OriginalPosition.Value)
		end
	end
	wait()
end