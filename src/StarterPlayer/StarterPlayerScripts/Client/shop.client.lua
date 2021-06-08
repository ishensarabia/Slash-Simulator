--Services
local TweenService = game:GetService("TweenService")
--Modules
local scoreDisplayModule = require(game.ReplicatedStorage.Modules.Gui.DisplayNumbers)
-- local tweenAnimator = require(script.Parent.Parent.ShopUI.Animator)
local tweenAnimatorShop = require(game.Players.LocalPlayer.PlayerGui:WaitForChild("ShopGUI").Animator)


--UI Variables
local camera = workspace.Camera
local closeButton = game.Players.LocalPlayer.PlayerGui.ShopGUI.Shop.Close
local shopFrame = game.Players.LocalPlayer.PlayerGui.ShopGUI.Shop
local shopUI = game.Players.LocalPlayer.PlayerGui.ShopGUI.ShopUI
local currencyUI = shopUI.Currency
local fadeScreen = game.Players.LocalPlayer.PlayerGui:WaitForChild("MainGUI").FadeScreen
local localPlayer = game.Players.LocalPlayer
local shopDebounce = false
local shopCategory
local shopName
local shop
local shopItems
local shopSlot = 1

local items = game.ReplicatedStorage.Items:GetDescendants()

--Sounds
local GuiSounds = game.SoundService.GuiFX

--Events
local buyItemFunction = game.ReplicatedStorage.Shop.BuyItem
local equipItemEvent = game.ReplicatedStorage.Shop.EquipItem
local openShopEvent = game.ReplicatedStorage.Shop.OpenShop
-- local refreshGuiEvent = game.ReplicatedStorage.Gui.RefreshValues

--Fadescreen tween
local blackScreenTween = TweenService:Create(fadeScreen,TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,true,0),{BackgroundTransparency = 0})

---------------------------------------------------------------FUNCTIONS--------------------------------------
local function openShopGui (shopName) 
	if shopDebounce then return end
	print("Opening shop")
	shopDebounce = true
	shopFrame.Visible = true
	tweenAnimatorShop.OpenShop:Play()
end

local function FindItem(itemName)
	for index, child in pairs(items) do
		if child.Name == itemName then
			return child
		end
	end
end

local function adjustSlot ()
	print("Adjusting slot:" .. shopSlot .. " for category: " .. shopCategory)
	local itemName = shopItems[shopSlot].Product.Value
	local itemDescription = shopItems[shopSlot].Description.Value
	local item = FindItem(itemName)

	if localPlayer:WaitForChild(shopCategory):FindFirstChild(itemName).Value then 
		currencyUI.Visible = false
		shopUI.BuyOrEquip.TextButton.Text = "Equip"
		if 	localPlayer:FindFirstChild(shopCategory).Equipped.Value == shopItems[shopSlot].Product.Value then
			shopUI.BuyOrEquip.TextButton.Text = "Equipped"
		end		
	else
		currencyUI.Visible = true
		shopUI.BuyOrEquip.TextButton.Text = scoreDisplayModule.DealWithPoints(item.Price.Value) 
	end
	
	local tweenCameraForSlot = TweenService:Create(camera,TweenInfo.new(1.5),{CFrame =  shopItems[shopSlot].Camera.CFrame})
	tweenCameraForSlot:Play()
	
	shopUI.Product.TextLabel.Text = itemName
	shopUI.Description.TextLabel.Text = itemDescription
	
end

local function openShop(category)

	--Sets up the shop on the first slot
	shopSlot = 1

	shopCategory = category
	blackScreenTween:Play()
	GuiSounds["Click"]:Play()
	wait(0.35) --Half the tween time
	shopName = game.Players.LocalPlayer.PlayerGui.ShopGUI.ShopUI:WaitForChild("shopName")
	shop =  workspace.Shops:WaitForChild(shopName.Value)
	-- Set the color Gui for the shop
	-- for index, children in pairs(shopUI:GetChildren()) do
	-- 	if children:IsA("GuiObject") then	
	-- 		children.BackgroundColor3 = shop.Color.Value
	-- 	end
	-- end


	shopItems = shop.Items[category]
	tweenAnimatorShop.CloseShop:Play()
	tweenAnimatorShop.CloseShop.DonePlaying.Event:Connect(function()
		shopFrame.Visible = false
	end)
	
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = shop.Camera.CFrame
	shopUI.Product.TextLabel.Text = shopItems[shopSlot].Product.Value
	shopUI.Description.TextLabel.Text = shopItems[shopSlot].Description.Value
	
	shopUI.Visible =  true
	
	adjustSlot()
end

-------------------------------------------------------------CONNECTING EVENTS----------------------------------------------
openShopEvent.OnClientEvent:Connect(openShopGui)

closeButton.Close.MouseButton1Click:Connect(function()
	GuiSounds["Click"]:Play()
	tweenAnimatorShop.CloseShop:Play()
	tweenAnimatorShop.CloseShop.DonePlaying.Event:Connect(function()
		shopDebounce = false
	end)
end)

shopFrame.MeleeWeaponsFrame.MeleeWeapons.MouseButton1Click:Connect(function()
	
	openShop("Melee Weapons")
	
end)



shopUI.Next.Next.MouseButton1Click:Connect(function()
	
	if shopSlot < #shopItems:GetChildren() then
		GuiSounds["Click"]:Play()
		tweenAnimatorShop.Next:Play()
		shopSlot += 1
	end
	
	adjustSlot()
end)

shopUI.Previous.Previous.MouseButton1Click:Connect(function()
	
	if shopSlot >= 2 then
		
		GuiSounds["Click"]:Play()
		tweenAnimatorShop.Previous:Play()
		shopSlot -=1
		
	end
	
	adjustSlot()
end)

shopUI.BuyOrEquip.TextButton.MouseButton1Click:Connect(function()
	local item = shopItems[shopSlot].Product.Value
	print("Buying: " .. item)
	if localPlayer:FindFirstChild(shopCategory):FindFirstChild(item).Value then
		local didEquip = equipItemEvent:InvokeServer(item)
		if didEquip then
			GuiSounds["Click"]:Play()
			adjustSlot()
		end
	else
		local didBuy = buyItemFunction:InvokeServer(item)
		if didBuy then
			GuiSounds["Purchase"]:Play()
			-- refreshGuiEvent:Fire()
			tweenAnimatorShop.PurchaseCompleted:Play()
			adjustSlot()
		else
			tweenAnimatorShop.PurchaseDenied:Play()
			GuiSounds["Error"]:Play()
		end
	end
	adjustSlot()
end)


local closeConnect = shopUI.Close.Close.MouseButton1Click:Connect(function()
	GuiSounds["Click"]:Play()
	blackScreenTween:Play()
	wait(0.35) -- Half the tween time
	shopUI.Visible = false
	shopDebounce = false
	camera.CameraType = Enum.CameraType.Custom
end)