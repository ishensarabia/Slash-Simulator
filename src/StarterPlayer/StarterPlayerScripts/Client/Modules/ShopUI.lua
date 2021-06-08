local shopUI = {}

local shopSlot = 1

function shopUI.OpenShop(Category)
    	--Sets up the shop on the first slot
	shopSlot = 1

	shopCategory = category
	blackScreenTween:Play()
	GuiSounds["Click"]:Play()
	wait(0.35) --Half the tween time
	shopName = game.Players.LocalPlayer.PlayerGui.MainGui.ShopUI:WaitForChild("shopName")
	shop =  workspace.Shops:WaitForChild(shopName.Value)
	-- Set the color Gui for the shop
	for index, children in pairs(shopUI:GetChildren()) do
		if children:IsA("GuiObject") then	
			children.BackgroundColor3 = shop.Color.Value
		end
	end


	shopItems = shop.items[category]
	shopFrame.Visible = false
	
	
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = shop.Camera.CFrame
	shopUI.Product.Text = shopItems[shopSlot].Product.Value
	shopUI.Description.Text = shopItems[shopSlot].Description.Value
	
	shopUI.Visible =  true
	
	adjustSlot()
end

return shopUI