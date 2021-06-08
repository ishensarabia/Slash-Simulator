local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local enemyFunctions = replicatedStorage:WaitForChild("Modules"):WaitForChild("EnemyFunctions")
local serverSettings = replicatedStorage:WaitForChild("ServerSettings")
local equipArmor = replicatedStorage:WaitForChild("Modules"):WaitForChild("EquipArmor")
local useFunctions = script:WaitForChild("UseFunctions")
local questSystem = replicatedStorage:WaitForChild("Modules"):WaitForChild("QuestSystem")
local module = {}

function module.Save(player)
	if players:FindFirstChild(player.Name) and player:FindFirstChild("IsLoaded") then
		local status, message = pcall(function()
			local items = {}
			for _,item in pairs(player.StarterGear:GetChildren()) do
				table.insert(items, item.Name)
			end
			local stats = {}
			for _,stat in pairs(player.Stats:GetChildren()) do
				if stat:IsA("ValueBase") and stat.ClassName ~= "ObjectValue" and stat.ClassName ~= "CFrameValue" then -- These types cannot be stored using data store
					table.insert(stats, {stat.Name, stat.Value})
				end
			end
			local armors = {}
			for _,armor in pairs(player.Armor:GetChildren()) do
				if armor:IsA("ValueBase") then
					table.insert(armors, {armor.Name, armor.Value})
				end
			end
			local attributes = {}
			for _,attribute in pairs(player.Attributes:GetChildren()) do
				if attribute:IsA("ValueBase") then
					table.insert(attributes, {attribute.Name, attribute.Value})
				end
			end
			local quests = {}
			for _,quest in pairs(player.Quests:GetChildren()) do
				local questModule = questSystem:FindFirstChild(quest.QuestType.Value)
				if questModule then
					local getSaveTable = require(questModule).GetSaveTable
					if getSaveTable then
						local saveTable = getSaveTable(quest)
						if saveTable then
							table.insert(quests, {quest.Name, saveTable})
						else
							warn('WARNING: GetSaveTable function for the quest "' .. quest.Name .. '" did not return a table')
						end
					else
						warn('WARNING: Quest module for the quest "' .. quests.Name .. '" does not have a GetSaveTable function')
					end
				else
					warn('WARNING: Quest module for the quest "' .. quests.Name .. '" could not be found')
				end
			end
			local completedQuests = {}
			for _,completedQuest in pairs(player.CompletedQuests:GetChildren()) do
				table.insert(completedQuests, completedQuest.Name)
			end
			local saveFile = {items, stats, armors, attributes, quests, completedQuests}
			game:GetService("DataStoreService"):GetDataStore("Save"):SetAsync(player.UserId, saveFile)
		end)
		if status ~= true then
			print(player.Name .. " couldn't save, retrying... \n" .. message)
			wait(10)
			module.Save(player)
		else
			print(player.Name .. " saved successfully!")
		end
	end
end

function module.Load(player)
	if players:FindFirstChild(player.Name) then
		local status = pcall(function()
			local saveFile = game:GetService("DataStoreService"):GetDataStore("Save"):GetAsync(player.UserId)
			if saveFile then
				if saveFile[1] then
					for _,item in pairs(saveFile[1]) do -- Items
						item = replicatedStorage.Items:FindFirstChild(item)
						if item then
							item:Clone().Parent = player.StarterGear
							item:Clone().Parent = player.Backpack
						end
					end
				end
				if saveFile[2] then
					for _,stat in pairs(saveFile[2]) do -- Stats
						if stat[1] and stat[2] and player.Stats:FindFirstChild(stat[1]) then
							player.Stats[stat[1]].Value = stat[2]
						end
					end
				end
				if saveFile[3] then
					for _,armor in pairs(saveFile[3]) do -- Armors
						if armor[1] and armor[2] and player.Armor:FindFirstChild(armor[1]) then
							player.Armor[armor[1]].Value = armor[2]
						end
					end
				end
				if saveFile[4] then
					for _,attribute in pairs(saveFile[4]) do -- Attributes
						if attribute[1] and attribute[2] and player.Attributes:FindFirstChild(attribute[1]) then
							player.Attributes[attribute[1]].Value = attribute[2]
						end
					end
				end
				if saveFile[5] then
					for _,questTable in pairs(saveFile[5]) do -- Quests
						if questTable[1] and questTable[2] then
							local quest = replicatedStorage.Quests:FindFirstChild(questTable[1])
							if quest then
								local questModule = questSystem:FindFirstChild(quest.QuestType.Value)
								if questModule then
									local loadFunction = require(questModule).LoadFromTable
									if loadFunction then	
										local loadedQuest = loadFunction(player, questTable)
										if loadedQuest then
											loadedQuest.Parent = player.Quests
										else
											warn('WARNING: LoadFromTable function for the quest "' .. questTable[1] .. '" did not return a loaded quest')
										end
									else
										warn('WARNING: Quest module for the quest "' .. questTable[1] .. '" does not have a LoadFromTable function')
									end
								end
							end
						end
					end
				end
				if saveFile[6] then
					for _,completedQuest in pairs(saveFile[6]) do -- Completed Quests
						local tag = Instance.new("Model")
						tag.Name = completedQuest
						tag.Parent = player.CompletedQuests
					end
				end
			end
		end)
		if status ~= true then
			print(player.Name .. " couldn't load, retrying...")
			wait(10)
			module.Load(player)
		else
			print(player.Name .. " loaded successfully!")
		end
	end
end

function module.PlayerAdded(player)
	local function UpdateCharacter(noHeal)
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			local rankBoost = (player.Stats.Rank.Value - 1) * serverSettings.HealthBoostPerRank.Value
			local vitalityBoost = player.Attributes.Vitality.Value * serverSettings.HealthBoostPerVitality.Value
			player.Character.Humanoid.WalkSpeed = 16 + player.Attributes.Haste.Value * serverSettings.WalkSpeedPerHaste.Value
			player.Character.Humanoid.MaxHealth = serverSettings.StartingHealth.Value + rankBoost + vitalityBoost
			if not noHeal then
				player.Character.Humanoid.Health = player.Character.Humanoid.MaxHealth
			end
		end
	end
	local function CreateObject(className, parent, properties)
		local object = Instance.new(className, parent)
		for _,property in pairs(properties) do
			object[property[1]] = property[2]
		end
		return object
	end
	local stats = CreateObject("Folder", player, {
		{"Name", "Stats"}
	})
	local attributes = CreateObject("Folder", player, {
		{"Name", "Attributes"}
	})
	local armors = CreateObject("Folder", player, {
		{"Name", "Armor"}
	})
	CreateObject("Folder", player, {
		{"Name", "Quests"}
	})
	CreateObject("Folder", player, {
		{"Name", "CompletedQuests"}
	})
	local rank = CreateObject("IntValue", stats, {
		{"Name", "Rank"},
		{"Value", 1}
	})
	local xp = CreateObject("NumberValue", stats, {
		{"Name", "XP"}
	})
	local points = CreateObject("IntValue", stats, {
		{"Name", "Points"}
	})
	local mana = CreateObject("IntValue", stats, {
		{"Name", "Mana"}
	})
	local currentArea = CreateObject("ObjectValue", stats, {
		{"Name", "CurrentArea"}
	})
	local vitality = CreateObject("IntValue", attributes, {
		{"Name", "Vitality"}
	})
	local mythicality = CreateObject("IntValue", attributes, {
		{"Name", "Mythicality"}
	})
	local haste = CreateObject("IntValue", attributes, {
		{"Name", "Haste"}
	})
	CreateObject("IntValue", attributes, {
		{"Name", "Power"}
	})
	CreateObject("IntValue", stats, {
		{"Name", "Arrows"}
	})
	CreateObject("NumberValue", stats, {
		{"Name", "Gold"}
	})
	CreateObject("StringValue", stats, {
		{"Name", "CurrentArmor"}
	})
	for _,armor in pairs(replicatedStorage.Armor:GetChildren()) do
		CreateObject("BoolValue", armors, {
			{"Name", armor.Name}
		})
	end
	xp.Changed:Connect(function()
		if xp.Value >= replicatedStorage.ServerSettings.XPPerRank.Value * rank.Value then
			xp.Value = xp.Value - (replicatedStorage.ServerSettings.XPPerRank.Value * rank.Value)
			points.Value = points.Value + 1
			if rank.Value < serverSettings.RankCap.Value then
				rank.Value = rank.Value + 1
			end
			replicatedStorage.ClientRemotes.Notification:FireClient(player, "+1 Attribute Point", Color3.fromRGB(255, 150, 0))
		end
	end)
	rank.Changed:Connect(function()
		UpdateCharacter()
		mana.Value = module.GetManaCap(player)
	end)
	vitality.Changed:Connect(function()
		UpdateCharacter(true)
	end)
	mythicality.Changed:Connect(function()
		if mana.Value > module.GetManaCap(player) then
			mana.Value = module.GetManaCap(player)
		end
	end)
	haste.Changed:Connect(function()
		UpdateCharacter(true)
	end)
	player.RespawnLocation = serverSettings.DefaultSpawnLocation.Value
	module.Load(player)
	if serverSettings.DefaultSpawnLocation.Value then
		local function FindCurrentArea()
			for _,area in pairs(workspace.Areas:GetChildren()) do
				if serverSettings.DefaultSpawnLocation.Value:IsDescendantOf(area) then
					return area
				end
			end
		end
		local starterArea = FindCurrentArea()
		if starterArea then
			currentArea.Value = starterArea
		end
	end
	mana.Value = module.GetManaCap(player)
	if rank.Value > serverSettings.RankCap.Value then
		rank.Value = serverSettings.RankCap.Value
	end
	if replicatedStorage.ServerSettings.StarterItem.Value == nil then
		warn("ReplicatedStorage.ServerSettings.StarterItem has not been set!")
	elseif not player.StarterGear:FindFirstChild(replicatedStorage.ServerSettings.StarterItem.Value.Name) then
		replicatedStorage.ServerSettings.StarterItem.Value:Clone().Parent = player.StarterGear
	end
	-- Gives people points if they are missing any
	local totalPoints = 0
	for _,attribute in pairs(attributes:GetChildren()) do
		totalPoints = totalPoints + attribute.Value
	end
	local shouldHave = rank.Value - 1
	if totalPoints < shouldHave then
		points.Value = shouldHave - totalPoints
	end
	local tag = Instance.new("Model", player)
	tag.Name = "IsLoaded"
	player.StarterGear.ChildAdded:Connect(function(item)
		require(questSystem).PlayerObtainedItem(player, item.Name)
	end)
	local function CharacterSpawned()
		UpdateCharacter()
		if replicatedStorage.Armor:FindFirstChild(player.Stats.CurrentArmor.Value) then
			require(equipArmor)(player, player.Stats.CurrentArmor.Value)
		end
	end
	if player.Character then
		CharacterSpawned()
	end
	player.CharacterAdded:Connect(CharacterSpawned)
	repeat -- Autosave every 4 minutes
		wait(240)
		module.Save(player)
	until not players:FindFirstChild(player.Name)
end

function module.UseItem(player, tool, itemType, targetPosition) -- just passes things on so you don't have to do extra work
	require(useFunctions)(player, tool, itemType, targetPosition)
end

function module.GetManaCap(player)
	return serverSettings.StartingMana.Value + (player.Attributes.Mythicality.Value * serverSettings.ManaBoostPerMythicality.Value)
end

return module