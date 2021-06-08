local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local playSoundEffect = replicatedStorage:WaitForChild("Modules"):WaitForChild("PlaySoundEffect")
local itemList = script.Parent:WaitForChild("ItemList")
local itemNameLabel = script.Parent:WaitForChild("ItemName")
local itemInfo = script.Parent:WaitForChild("ItemInfo")
local price = script.Parent:WaitForChild("Price")
local switchMenu = replicatedStorage:WaitForChild("Modules"):WaitForChild("SwitchMenu")
local sellCooldown = false
players.LocalPlayer:WaitForChild("IsLoaded")

function SelectItem(itemName)
	itemNameLabel.Text = itemName
	itemInfo.Text = "Sell this item?"
	price.Text = replicatedStorage.Items[itemName].Price.Value
end

-- Set up item list
function MakeList()
	itemList:ClearAllChildren()
	local buttonsPerPage = 10
	local items = {}
	local sorted = {}
	for _,item in pairs(players.LocalPlayer.Backpack:GetChildren()) do -- sort by price in ascending order
		if item:FindFirstChild("Price") then
			table.insert(items, item)
			local positionToInsertAt = 1
			for i,sortItem in pairs(sorted) do
				if replicatedStorage.Items[sortItem].Price.Value < replicatedStorage.Items[item.Name].Price.Value then
					positionToInsertAt = i + 1
				end
			end
			table.insert(sorted, positionToInsertAt, item.Name)
		end
	end
	local amount = math.clamp(#items, buttonsPerPage, math.huge)
	local button = script:WaitForChild("ItemButton")
	itemList.CanvasSize = UDim2.new(0, 0, itemList.Size.Y.Scale + (itemList.Size.Y.Scale * (1 / buttonsPerPage) * (amount - buttonsPerPage)), 0)
	for i,item in pairs(sorted) do
		local newButton = button:Clone()
		if i % 2 == 0 then
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
	if #sorted == 0 then
		itemNameLabel.Text = "No items to sell"
		price.Text = ""
		itemInfo.Text = ""
	end
end

script.Parent:WaitForChild("Close").MouseButton1Click:Connect(function()
	require(switchMenu)()
end)

script.Parent:WaitForChild("Sell").MouseButton1Click:Connect(function()
	if sellCooldown == false then
		sellCooldown = true
		require(playSoundEffect)("Coins")
		workspace.Remotes.SellItem:InvokeServer(itemNameLabel.Text) -- Uses RemoteFunction to yield until action is complete
		MakeList()
		sellCooldown = false
	end
end)

script.Parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if script.Parent.Visible == true then
		MakeList()
	end
end)