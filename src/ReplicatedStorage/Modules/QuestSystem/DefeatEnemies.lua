local questSystem = script.Parent
local module = {}

function module.CheckIfCompleted(player, quest)
	for _,requirement in pairs(quest.Requirements:GetChildren()) do
		local progress = quest.Progress:FindFirstChild(requirement.Name)
		if not progress or progress.Value < requirement.Value then
			return
		end
	end
	require(questSystem).CompleteQuest(player, quest)
end

function module.ProgressSetup(quest) -- Optional for modifying the progress folder
	for _,requirement in pairs(quest.Requirements:GetChildren()) do
		local progress = requirement:Clone()
		progress.Value = 0
		progress.Parent = quest.Progress
	end
end

function module.GetObjectiveText(quest, showProgress)
	local text = "Defeat "
	local requirements = quest.Requirements:GetChildren()
	for i,enemy in pairs(requirements) do
		local name = enemy.Name
		local lastLetter = string.lower(string.sub(name, string.len(name), -1))
		local plural = "s"
		if enemy.Value == 1 then
			plural = ""
		elseif lastLetter == "y" then
			plural = "ies"
			name = string.sub(name, 0, string.len(name) - 1)
		elseif lastLetter == "x" or lastLetter == "o" then
			plural = "es"
		end
		if showProgress then
			local progress = quest.Progress:FindFirstChild(enemy.Name)
			if progress then
				progress = progress.Value
			else
				progress = 0
			end
			text = text .. "(" .. progress .. "/" .. enemy.Value .. ") " .. name .. plural
		else
			text = text .. enemy.Value .. " " .. name .. plural
		end
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
	local allProgress = {}
	for _,progress in pairs(quest.Progress:GetChildren()) do
		table.insert(allProgress, {progress.Name, progress.Value})
	end
	return allProgress
end

function module.LoadFromTable(player, questTable)
	if questTable[1] and questTable[2] then
		local loadedQuest = require(questSystem).GiveQuest(player, questTable[1])
		if loadedQuest then
			for _,progress in pairs(questTable[2]) do
				if progress[1] and progress[2] then
					local progressValue = loadedQuest.Progress:FindFirstChild(progress[1])
					if progressValue then
						progressValue.Value = progress[2]
					end
				end
			end
		end
		return loadedQuest
	end
end

return module