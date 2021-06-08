local questSystem = script.Parent
local module = {}

function module.CheckIfCompleted(player, quest)
	for _,requirement in pairs(quest.Requirements:GetChildren()) do
		if not player.StarterGear:FindFirstChild(requirement.Name) then
			return
		end
	end
	require(questSystem).CompleteQuest(player, quest)
end

function module.GetObjectiveText(quest, showProgress)
	local text = "Obtain "
	local requirements = quest.Requirements:GetChildren()
	for i,item in pairs(requirements) do
		text = text .. item.Name
		if #requirements > 1 then
			if #requirements ~= 2 then -- Only lists longer than two items should have comma separation
				if i == #requirements - 1 then
					text = text .. ", and "
				elseif i ~= #requirements then
					text = text .. ", "
				end
			elseif i == 1 then
				text = text .. " and "
			end
		end
	end
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