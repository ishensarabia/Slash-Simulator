local players = game:GetService("Players")
local switchMenu = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("SwitchMenu")
local fillQuestMenu = players.LocalPlayer.PlayerGui:WaitForChild("GameUI"):WaitForChild("FillQuestMenu")
players.LocalPlayer:WaitForChild("IsLoaded")

script.Parent:WaitForChild("Decline").MouseButton1Click:Connect(function()
	script.QuestOfferResponse:Fire()
	require(switchMenu)()
end)

script.Parent:WaitForChild("Accept").MouseButton1Click:Connect(function()
	script.QuestOfferResponse:Fire(true)
	require(switchMenu)()
end)

game:GetService("ReplicatedStorage").ClientRemotes.OfferQuest.OnClientInvoke = function(quest)
	require(switchMenu)("QuestOfferMenu", true)
	require(fillQuestMenu).FillRewards(script.Parent.Rewards, quest)
	require(fillQuestMenu).FillDescription(script.Parent.Description, quest)
	return script:WaitForChild("QuestOfferResponse").Event:Wait() -- True if player accepts quest, nil if deny
end