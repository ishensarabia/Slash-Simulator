local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local playSoundEffect = replicatedStorage:WaitForChild("Modules"):WaitForChild("PlaySoundEffect")
local equipButton = script.Parent:WaitForChild("Equip")
local itemList = script.Parent:WaitForChild("ItemList")
local itemNameLabel = script.Parent:WaitForChild("ItemName")
local itemInfo = script.Parent:WaitForChild("ItemInfo")
local switchMenu = replicatedStorage:WaitForChild("Modules"):WaitForChild("SwitchMenu")
players.LocalPlayer:WaitForChild("IsLoaded")

function MakeList()
	itemList:ClearAllChildren()
	local ownedArmor = {}
	for _,armor in pairs(players.LocalPlayer.Armor:GetChildren()) do
		if armor.Value == true then
			table.insert(ownedArmor, armor.Name)
		end
	end
	local sorted = {}
	local buttonsPerPage = 10
	local amount = math.clamp(#ownedArmor, buttonsPerPage, math.huge)
	local button = script:WaitForChild("ItemButton")
	itemList.CanvasSize = UDim2.new(0, 0, itemList.Size.Y.Scale + (itemList.Size.Y.Scale * (1 / buttonsPerPage) * (amount - 10)), 0)
	for _,item in pairs(ownedArmor) do -- sort by price in ascending order
		local positionToInsertAt = 1
		for i,sortItem in pairs(sorted) do
			if replicatedStorage.Armor[sortItem].Price.Value < replicatedStorage.Armor[item].Price.Value then
				positionToInsertAt = i + 1
			end
		end
		table.insert(sorted, positionToInsertAt, item)
	end
	for i,item in pairs(sorted) do
		local newButton = button:Clone()
		if i % 2 == 0 then -- This makes button color vary a little, just for style
			newButton.BackgroundColor3 = Color3.fromRGB(82, 76, 115)
		else
			newButton.BackgroundColor3 = Color3.fromRGB(99, 119, 148)
		end
		newButton.Text = item
		newButton.Size = UDim2.new(1, -15, 1 / amount, 0)
		newButton.Position = UDim2.new(0, 0, (i - 1) * (1 / amount), 0)
		newButton.Parent = itemList
		newButton.MouseButton1Click:Connect(function()
			SelectItem(item)
		end)
		if i == 1 then
			SelectItem(item)
		end
	end
end

function SelectItem(itemName)
	local armor = replicatedStorage.Armor[itemName]
	itemNameLabel.Text = itemName
	itemInfo.Text = armor.Defense.Value .. " Defense"
	if players.LocalPlayer.Stats.CurrentArmor.Value == itemName then
		equipButton.Text = "Unequip"
	else
		equipButton.Text = "Equip"
	end
end

script.Parent:WaitForChild("Close").MouseButton1Click:Connect(function()
	require(switchMenu)(true)
end)

script.Parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if script.Parent.Visible == true then
		MakeList()
	end
end)

equipButton.MouseButton1Click:Connect(function()
	if equipButton.Text == "Equip" then
		require(playSoundEffect)("Equip")
		local success = workspace.Remotes.EquipArmor:InvokeServer(itemNameLabel.Text)
		if success then
			SelectItem(itemNameLabel.Text)
		end
	elseif equipButton.Text == "Unequip" then
		require(playSoundEffect)("Unequip")
		local success = workspace.Remotes.EquipArmor:InvokeServer()
		if success then
			SelectItem(itemNameLabel.Text)
		end
	end
end)