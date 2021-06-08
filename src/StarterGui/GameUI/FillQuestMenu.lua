local questSystem = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("QuestSystem")
local module = {}

function module.FillRewards(rewardsMenu, quest)
	local layout = rewardsMenu.UIListLayout
	layout.Parent = script
	rewardsMenu:ClearAllChildren()
	layout.Parent = rewardsMenu
	local itemsPerPage = 8
	local rewards = quest.Rewards:GetChildren()
	local amount = math.clamp(#rewards, itemsPerPage, math.huge)
	rewardsMenu.CanvasSize = UDim2.new(0, 0, rewardsMenu.Size.Y.Scale + (rewardsMenu.Size.Y.Scale * (1 / itemsPerPage) * (amount - itemsPerPage)), 0)
	for _,reward in pairs(rewards) do
		local newLabel = script.RewardTemplate:Clone()
		newLabel.Size = UDim2.new(0.95, 0, 1 / amount, 0)
		if reward.Type.Value == "Stat" then
			newLabel.LayoutOrder = 1
			newLabel.Text = "+ " .. reward.Amount.Value .. " " .. reward.Name
		else -- Everything else looks fine with just the name displayed
			newLabel.LayoutOrder = 0
			newLabel.Text = reward.Name
		end
		newLabel.Parent = rewardsMenu
	end
end

function module.FillDescription(descriptionFrame, quest, showProgress)
	descriptionFrame.CanvasSize = UDim2.new(0, 0, descriptionFrame.Size.Y.Scale, 0)
	descriptionFrame.Description.Text = quest.Description.Value .. "\n\nObjective: " .. require(questSystem).GetObjectiveText(quest, showProgress)
	while descriptionFrame.Description.TextFits == false and descriptionFrame.Parent.Visible == true do
		descriptionFrame.CanvasSize = UDim2.new(0, 0, descriptionFrame.CanvasSize.Y.Scale + 0.1, 0)
		wait() -- TextFits can be janky, so this will prevent crashes if things get funky
	end
end

return module