local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local playSoundEffect = replicatedStorage:WaitForChild("Modules"):WaitForChild("PlaySoundEffect")
local equipButton = script.Parent:WaitForChild("Equip")
local itemList = script.Parent:WaitForChild("ItemList")
local shopItems = script.Parent:WaitForChild("ShopItems")
local itemNameLabel = script.Parent:WaitForChild("ItemName")
local itemInfo = script.Parent:WaitForChild("ItemInfo")
local price = script.Parent:WaitForChild("Price")
local switchMenu = replicatedStorage:WaitForChild("Modules"):WaitForChild("SwitchMenu")
players.LocalPlayer:WaitForChild("IsLoaded")

function MakeList()
	itemList:ClearAllChildren()
	local sorted = {}
	local buttonsPerPage = 10
	local amount = math.clamp(#shopItems:GetChildren(), buttonsPerPage, math.huge)
	local button = script:WaitForChild("ItemButton")
	itemList.CanvasSize = UDim2.new(0, 0, itemList.Size.Y.Scale + (itemList.Size.Y.Scale * (1 / buttonsPerPage) * (amount - buttonsPerPage)), 0)
	for _,item in pairs(shopItems:GetChildren()) do -- sort by price in ascending order
		local positionToInsertAt = 1
		for i,sortItem in pairs(sorted) do
			if sortItem.ItemType.Value == "Armor" and replicatedStorage.Armor[sortItem.Name].Price.Value < replicatedStorage.Armor[item.Name].Price.Value then
				positionToInsertAt = i + 1
			elseif sortItem.ItemType.Value == "Weapon" and replicatedStorage.Items[sortItem.Name].Price.Value < replicatedStorage.Items[item.Name].Price.Value then
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
		newButton.Text = item.Name
		newButton.TextColor3 = item.TextColor.Value
		newButton.Size = UDim2.new(1, -15, 1 / amount, 0)
		newButton.Position = UDim2.new(0, 0, (i - 1) * (1 / amount), 0)
		newButton.Parent = itemList
		newButton.MouseButton1Click:Connect(function()
			SelectItem(item.Name)
		end)
		if i == 1 then
			SelectItem(item.Name)
		end
	end
end

function SelectItem(itemName)
	itemNameLabel.Text = itemName
	script.Parent:WaitForChild("Description").Text = shopItems[itemName].Description.Value
	if shopItems[itemName].ItemType.Value == "Armor" then
		itemInfo.Text = replicatedStorage.Armor[itemName].Defense.Value .. " Defense"
		if players.LocalPlayer.Armor[itemName].Value == true then
			price.Text = "Already Owned!"
			if players.LocalPlayer.Stats.CurrentArmor.Value == itemName then
				equipButton.Text = "Unequip"
			else
				equipButton.Text = "Equip"
			end
		else
			price.Text = replicatedStorage.Armor[itemName].Price.Value
			equipButton.Text = "Purchase"
		end
	elseif shopItems[itemName].ItemType.Value == "Weapon" then
		itemInfo.Text = replicatedStorage.Items[itemName].MinimumDamage.Value .. " to " .. replicatedStorage.Items[itemName].MaximumDamage.Value .. " Damage"
		if players.LocalPlayer.Backpack:FindFirstChild(itemName) then
			price.Text = "Already Owned!"
			equipButton.Text = "..."
		else
			price.Text = replicatedStorage.Items[itemName].Price.Value
			equipButton.Text = "Purchase"
		end
	elseif shopItems[itemName].ItemType.Value == "Item" then
		itemInfo.Text =  ""
		price.Text = replicatedStorage.Items[itemName].Price.Value
		equipButton.Text = "Purchase"
	end
end

script.Parent:WaitForChild("Close").MouseButton1Click:Connect(function()
	require(switchMenu)()
end)

script.Parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if script.Parent.Visible == true then
		MakeList()
	end
end)

equipButton.MouseButton1Click:Connect(function()
	if equipButton.Text == "Purchase" then
		if shopItems:FindFirstChild(itemNameLabel.Text) then
			require(playSoundEffect)("Coins")
			local success = workspace.Remotes.PurchaseItem:InvokeServer(itemNameLabel.Text)
			if success then
				SelectItem(itemNameLabel.Text)
			end
		end
	end
end)