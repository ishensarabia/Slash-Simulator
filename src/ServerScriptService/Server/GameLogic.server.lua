local Round = require(game.ServerScriptService.Server:WaitForChild("Modules").RoundModule)
local RoundConfiguration = game.ServerScriptService.Server.Configurations.Round
local status = game.ReplicatedStorage.Common.RoundSystem:WaitForChild("Status")
local roundSystemRemotes= game.ReplicatedStorage.Common.RoundSystem.Remotes

--Data
local DataManager = require(game.ServerScriptService.Server.Data.DataManager)

-- Round variable	
local roundStarted = false
local timeToJoin = RoundConfiguration.TimeToJoin.Value
-- Services
local players = game:GetService("Players")

--Shop
local buyItemFunction = game.ReplicatedStorage.Shop.BuyItem
local equipItemEvent = game.ReplicatedStorage.Shop.EquipItem

local function PlayerJoinedBattle(player)
	local inBattle = Instance.new("BoolValue",player)
	inBattle.Value = true
	inBattle.Name = "InBattle"
end

roundSystemRemotes.JoinBattle.OnServerEvent:Connect(PlayerJoinedBattle)
function GetLevel(totalXP, playerLevel)
	local Increment = 0
	local RequiredXP = 100
	for i = playerLevel or 0, game.ReplicatedStorage.LevelSystem.Configuration.MaxLevel.Value do
		RequiredXP = 100 + (25*i)
		if totalXP >= (100*i) + Increment then
			if i ~= game.ReplicatedStorage.LevelSystem.Configuration.MaxLevel.Value then
				if totalXP < ((100*i) + Increment) + RequiredXP then
					return i,RequiredXP
				end
			else
				return i,RequiredXP
			end
		end
		Increment = Increment+(i*25)
	end

	
end

function dataTableToInstances (dataTable, folderToSave)
	for dataName, dataValue in pairs(dataTable)	do	
		local instanceToRegister = Instance.new("BoolValue",folderToSave)
		instanceToRegister.Name = dataName
		instanceToRegister.Value = dataValue
		
		if instanceToRegister.Name == "BASIC HOOK" or instanceToRegister.Name == "BASIC ENERGY CONTAINER" or instanceToRegister.Name == "BEGINNER BADGE" then
			instanceToRegister.Value =  true
		end
	end	
end
---------------------------------------------------------------- Load data -----------------------------
--Function to load the fetched data 
function loadData (player)
	print("Fetching data for: " .. player.Name)
	local data = DataManager:Get(player)

	if data then
		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
		

		local diamonds = Instance.new("IntValue", leaderstats)
		diamonds.Name = "Diamonds"
		diamonds.Value = data.Diamonds

		local coins = Instance.new("IntValue", leaderstats)
		coins.Name = "Coins"
		coins.Value = data.Coins

		player:SetAttribute("TotalXP",data.TotalXP)
		
		local prestige = Instance.new("StringValue", leaderstats)
		prestige.Name = "Prestige"
		prestige.Value = data.Prestige

		local level = Instance.new("IntValue", leaderstats)
		level.Name = "Level"
		level.Value = data.Level

		local meleeWeapons = Instance.new("Folder",player)
		meleeWeapons.Name = "Melee Weapons"
		dataTableToInstances(data.MeleeWeapons,meleeWeapons)

		local meleeWeaponEquipped = Instance.new("StringValue",meleeWeapons)
		meleeWeaponEquipped.Name = "Equipped"
		meleeWeaponEquipped.Value = data.MeleeWeaponEquipped


		player:SetAttribute("XPNeededForNextLevel", data.XPNeeded)

	else
		print("Data didn't load")	
	end
end



----------------------------------------------------------------Game Events -----------------------------
game.ReplicatedStorage.Data.LoadData.Event:Connect(loadData)
local meleeWeaponsInGame = game.ReplicatedStorage.Items["Melee Weapons"]
local armorsInGame = game.ReplicatedStorage.Items.Armor

function buyItem(player, item)
	local data = DataManager:Get(player)
	if data then
		local meleeWeaponToBuy = meleeWeaponsInGame:FindFirstChild(item)
		local armorToBuy = armorsInGame:FindFirstChild(item)
		
		if meleeWeaponToBuy then
			print("Buyed")
			if data[meleeWeaponToBuy.Currency.Value] >= meleeWeaponToBuy.Price.Value then
				data[meleeWeaponToBuy.Currency.Value] -= meleeWeaponToBuy.Price.Value
				player.leaderstats:WaitForChild(meleeWeaponToBuy.Currency.Value).Value = data[meleeWeaponToBuy.Currency.Value]
				data.MeleeWeapons[meleeWeaponToBuy.Name] = true
				player["Melee Weapons"]:FindFirstChild(meleeWeaponToBuy.Name).Value = data.MeleeWeapons[meleeWeaponToBuy.Name]
				
				return true -- Purchase successful
			else
				return false -- Purchased not completed 
			end
		end	
		
		if armorToBuy then
			print("Buyed")
			if data[armorToBuy.Currency.Value] >= armorToBuy.Price.Value then
				data[armorToBuy.Currency.Value] -= armorToBuy.Price.Value
				player.leaderstats:WaitForChild(armorToBuy.Currency.Value).Value = data[armorToBuy.Currency.Value]
				data.Armors[armorToBuy.Name] = true
				player.Armors:FindFirstChild(armorToBuy.Name).Value = data.MeleeWeapons[armorToBuy.Name]
				
				return true -- Purchase successful
			else
				return false -- Purchased not completed 
			end	
		end
	end	
end

function EquipItem (player, item)
	local data = DataManager:Get(player)
	if data then
		--Checks through the in game items and picks accordingly to its category
		local meleeWeaponToEquip = meleeWeaponsInGame:FindFirstChild(item)
		local armorToEquip = armorsInGame:FindFirstChild(item)
		
		
		if meleeWeaponToEquip then
			local previousEquippedMeleeWeapon = player.Backpack:FindFirstChild(player["Melee Weapons"].Equipped.Value)
			if previousEquippedMeleeWeapon then previousEquippedMeleeWeapon:Destroy()end
			
			meleeWeaponToEquip:Clone()
			meleeWeaponToEquip.Parent = player.Backpack
			data.EquippedHook = meleeWeaponToEquip.Name	
			
			player["Melee Weapons"].Equipped.Value = meleeWeaponToEquip.Name
			return true
			
		elseif armorToEquip then
			armorToEquip:Clone()
			player.Character.Humanoid:AddAccessory(armorToEquip)
			data.EquippedEnergyContainer = armorToEquip.Name
			local previousEquippedArmor = player.Character:FindFirstChild(player.EnergyContainers.Equipped.Value)
			if previousEquippedArmor then previousEquippedArmor:Destroy() end
			player.EnergyContainers.Equipped.Value = armorToEquip.Name
			player.EnergyContainers.energyContainerCapacity.Value = armorToEquip.Capacity.Value
			return true				
		end		
	end
end

players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		player.Character.Humanoid.Died:Connect(function()
			if player:FindFirstChild("InBattle") then
				player.InBattle:Destroy()
			end
		end)
	end)
end)

players.PlayerAdded:Connect(function(player)
	player:GetAttributeChangedSignal("TotalXP"):Connect(function(newValue)
		if player:GetAttribute("XPNeededForNextLevel") ~= nil and player.leaderstats.Level.Value then
				if player:GetAttribute("TotalXP") >= player:GetAttribute("XPNeededForNextLevel") then
				local data = DataManager:Get(player)
				data.Level += 1
				data.TotalXP = 0
				player.leaderstats.Level.Value = data.Level
				player:SetAttribute("TotalXP",data.TotalXP)
				player:SetAttribute("XPNeededForNextLevel", 100 + (player:GetAttribute("XPNeededForNextLevel") * 2.6))
				data.XPNeeded = player:GetAttribute("XPNeededForNextLevel")
			end	
		end
	end)
end)

buyItemFunction.OnServerInvoke = buyItem
equipItemEvent.OnServerInvoke = EquipItem
----------------------------------------------------------------Game Loop --------------------------------
while wait() do
	
	repeat
	    local availablePlayers = {}
	    for i, plr in pairs(game.Players:GetPlayers()) do
		    if  plr:FindFirstChild("InBattle") then
			    table.insert(availablePlayers,plr)
		    end
	    end

		status.Value = "A battle is about to start would you like to join? (" .. #availablePlayers .. "/" ..  RoundConfiguration.MaxPlayers.Value .. ")".. "\nTime left to join: " .. timeToJoin .. " seconds"

		wait(1)
		timeToJoin -= 1

	until #availablePlayers >= 2 or timeToJoin == 0 
	

		
	local chosenMap = Round.SelectMap()

	-- for i, v in pairs(game.Players:GetChildren()) do

	-- 	v.PlayerGui.MainGUI.ResetToMenu:FireClient(v,false)
	-- end
	
	
	wait(2)
	


	
			
	local contenders = {}
	
	for i, v in pairs(game.Players:GetPlayers()) do
		if v:FindFirstChild("InBattle") then
			table.insert(contenders,v)
			print("Added Player "..v.Name.." to contenders")
		end
	end 

	if chosenMap:FindFirstChild("PlayerSpawns") then
	    Round.TeleportPlayers(contenders, chosenMap.PlayerSpawns:GetChildren())
	else
		warn("Fatal Error: You didn't add a PlayerSpawns folder into your map")
	end
	
	Round.InsertTag(contenders,"Contestant")
	


	

	chosenMap.Name = "Map"


	

	Round.StartRound(RoundConfiguration.Duration.Value,chosenMap,RoundConfiguration.RoundMessage.Value)
	
	
	
	contenders = {}
	
	for i, v in pairs(game.Players:GetPlayers()) do
		if not v:FindFirstChild("InMenu") then
			table.insert(contenders,v)
		end
	end 
	
	if game.Workspace.Lobby:FindFirstChild("Spawns") then
		Round.TeleportPlayers(contenders,game.Workspace.Lobby.Spawns:GetChildren())
	else
	    warn("Fatal Error: You have not added a Spawns folder into your lobby with the SpawnLocations inside. Please do this to make the script work.")
	end
	
	chosenMap:Destroy()
	
	Round.RemoveTags()
	
	Round.Intermission(13)
	wait(2)
end

