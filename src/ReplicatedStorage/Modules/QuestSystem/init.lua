local module = {}

function module.CompleteQuest(player, quest)
	local function GiveRewards()
		for _,reward in pairs(quest.Rewards:GetChildren()) do
			if reward.Type.Value == "Stat" then
				local stat = player.Stats:FindFirstChild(reward.Name)
				if stat then
					stat.Value = stat.Value + reward.Amount.Value
					game:GetService("ReplicatedStorage").ClientRemotes.Notification:FireClient(player, "+" .. reward.Amount.Value .. " " .. reward.Name, Color3.fromRGB(0, 255, 255))
				else
					warn('Stat reward named "' .. reward.Name .. '" was not found in the player stats folder; quest: "' .. quest.Name .. '"')
				end
			elseif reward.Type.Value == "Item" then
				local item = game:GetService("ReplicatedStorage").Items:FindFirstChild(reward.Name)
				if item then
					item:Clone().Parent = player.StarterGear
					item:Clone().Parent = player.Backpack
					game:GetService("ReplicatedStorage").ClientRemotes.Notification:FireClient(player, "Got " .. reward.Name .. "!", Color3.fromRGB(255, 255, 0))
				else
					warn('Item reward named "' .. reward.Name .. '" was not found in the ReplicatedStorage.Items folder; quest: "' .. quest.Name .. '"')
				end
			elseif reward.Type.Value == "Armor" then
				local armor = player.Armor:FindFirstChild(reward.Name)
				if armor then
					if armor.Value == false then -- Don't notify if they already had this armor
						armor.Value = true
						game:GetService("ReplicatedStorage").ClientRemotes.Notification:FireClient(player, "Got " .. reward.Name .. "!", Color3.fromRGB(255, 150, 0))
					end
				else
					warn('Armor reward named "' .. reward.Name .. '" was not found in the player armor folder; quest: "' .. quest.Name .. '"')
				end
			end
		end
	end
	local completedTag = Instance.new("Model")
	completedTag.Name = quest.Name
	completedTag.Parent = player.CompletedQuests
	game:GetService("ReplicatedStorage").ClientRemotes.Notification:FireClient(player, quest.Name .. " quest complete!", Color3.fromRGB(255, 0, 255))
	GiveRewards()
	quest:Destroy()
end

function module.GetObjectiveText(quest, showProgress)
	local questModule = script:FindFirstChild(quest.QuestType.Value)
	if questModule then
		local getter = require(questModule).GetObjectiveText
		if getter then
			return getter(quest, showProgress)
		else
			warn('No matching function found for getting the objective text of quest type "' .. quest.QuestType.Value .. '"')
		end
	end
end

function module.GiveQuest(player, questName)
	if not player.Quests:FindFirstChild(questName) and not player.CompletedQuests:FindFirstChild(questName) then
		local quest = game:GetService("ReplicatedStorage").Quests:FindFirstChild(questName)
		local questModule = script:FindFirstChild(quest.QuestType.Value)
		if quest and questModule then
			local newQuest = quest:Clone()
			local progressSetup = require(questModule).ProgressSetup -- This isn't required, only if you want to customize what the quest type does to the progress folder
			if progressSetup then
				progressSetup(newQuest)
			end
			newQuest.Parent = player.Quests
			if player:FindFirstChild("IsLoaded") then -- The function is used in loading, so we don't want to notify them when they are loading
				game:GetService("ReplicatedStorage").ClientRemotes.Notification:FireClient(player, "Started quest: " .. quest.Name, Color3.fromRGB(0, 255, 0))
			end
			return newQuest
		else
			warn('No matching module found for quest type "' .. quest.QuestType.Value .. '"')
		end
	end
end

function module.PlayerDefeatedEnemy(player, enemyName) -- Utility function for checking if any DefeatedEnemies type quests are completed when an enemy is defeated
	for _,quest in pairs(player.Quests:GetChildren()) do
		local questModule = script:FindFirstChild(quest.QuestType.Value)
		if questModule and quest.QuestType.Value == "DefeatEnemies" then
			local requirement = quest.Requirements:FindFirstChild(enemyName)
			local progress = quest.Progress:FindFirstChild(enemyName)
			if requirement and progress then
				if progress.Value < requirement.Value then
					progress.Value = progress.Value + 1
				end
				require(questModule).CheckIfCompleted(player, quest)
			end
		end
	end
end

function module.PlayerObtainedItem(player, itemName) -- Utility function for checking if any ObtainItems type quests are completed when an item is obtained
	for _,quest in pairs(player.Quests:GetChildren()) do
		local questModule = script:FindFirstChild(quest.QuestType.Value)
		if questModule and quest.QuestType.Value == "ObtainItems" then
			local requirement = quest.Requirements:FindFirstChild(itemName)
			if requirement then
				require(questModule).CheckIfCompleted(player, quest)
			end
		end
	end
end

return module