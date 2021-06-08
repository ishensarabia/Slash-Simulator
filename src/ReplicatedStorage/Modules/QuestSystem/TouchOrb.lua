local questSystem = script.Parent
local module = {}

function module.CheckIfCompleted(player, quest)
	if player.Character then -- This quest type should only have a single destination
		local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
		local destinationOrb = quest.Requirements:FindFirstChildOfClass("ObjectValue")
		if rootPart and destinationOrb and destinationOrb.Value and (rootPart.Position - destinationOrb.Value.Position).magnitude < destinationOrb.Value.Size.X * 0.75 then
			require(questSystem).CompleteQuest(player, quest)
		end
	end
end

function module.GetObjectiveText(quest, showProgress)
	local text = "Travel to the given destination"
	return text
end

function module.GetSaveTable(quest)
	local allProgress = {} -- Progress on this type doesn't need to be saved and can be checked elsewhere
	return allProgress
end

function module.LoadFromTable(player, questTable)
	if questTable[1] and questTable[2] then
		local loadedQuest = require(questSystem).GiveQuest(player, questTable[1])
		return loadedQuest
	end
end

return module