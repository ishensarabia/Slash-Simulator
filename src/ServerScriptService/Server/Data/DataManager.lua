--Copyright Ishen Sarabia 2021, produced for slash simulator 4/27/2021.

--Services 
local ProfileService = require(script.Parent.ProfileService)
local Players = game:GetService("Players")

--Items
local meleeWeapons = game.ReplicatedStorage.Items["Melee Weapons"]

local saveStructure = {
	
	Coins = 0;
	Prestige = "Novice";
    Diamonds = 0;
    TotalXP = 0;
	XPNeeded = 0;
    Level = 0;
	MeleeWeapons = {};
	MeleeWeaponEquipped = "Starter";
	Armor = {};
	ArmorEquipped = "Starter";

	
}
--Adds the different data structures (items, unlockables, accessories, etc) to the data table save structure 
function addDataToTable(instance, tableToAddData)
	local instanceToSave = Instance.new("BoolValue")
	instanceToSave.Name = instance.Name
	instanceToSave.Value = false --Default value meaning each loop through the data will register false (not obtained yet)
	tableToAddData[instanceToSave.Name] = instanceToSave.Value
end

for index, meleeWeapon in pairs(meleeWeapons:GetChildren()) do
	addDataToTable(meleeWeapon,saveStructure.MeleeWeapons)
end

local ProfileStore = ProfileService.GetProfileStore("611116", saveStructure)


local DataManager = {}

local Profiles = {}


--Functions

function DataManager:Get(player)
	local profile = Profiles[player]
	
	if profile then
		return profile.Data
	end
end

local function DeepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = DeepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

local function MergeDataWithTemplate(data, template)
	for k, v in pairs(template) do
		if type(k) == "string" then -- Only string keys will be merged
			if data[k] == nil then
				if type(v) == "table" then
					data[k] = DeepCopy(v)
				else
					data[k] = v
				end
			elseif type(data[k]) == "table" and type(v) == "table" then
				MergeDataWithTemplate(data[k], v)
			end
		end
	end
end


local function onPlayerAdded(player)
	local profile = ProfileStore:LoadProfileAsync(
		"Player_" .. player.UserId,
		"ForceLoad"
	)
	
	
	if profile then
		profile:ListenToRelease(function()
			Profiles[player] = nil
			player:Kick()
			
		end)
		
		if player:IsDescendantOf(Players) then
			Profiles[player] = profile
			MergeDataWithTemplate(profile.Data, saveStructure)
			game.ReplicatedStorage.Data.LoadData:Fire(player)
		else
			profile:Release()	
		end
	else
		player:Kick()	
	end
end


function onPlayerRemoving(player)
	local profile = Profiles[player]
	if profile then
		profile:Release()
	end
end





--Connecting events
Players.PlayerRemoving:Connect(onPlayerRemoving)

Players.PlayerAdded:Connect(onPlayerAdded)





return DataManager