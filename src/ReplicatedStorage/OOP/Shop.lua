--Copyright Ishen Sarabia, done for Slash Simulator (c) 2021

local Package = script:FindFirstAncestorOfClass("Folder")
local Object = require(Package.BaseRedirect)

--Services
local CollectionService = game:GetService("CollectionService")

--Event
local openShopEvent = game.ReplicatedStorage.Shop.OpenShop

local Shop = Object.new("Shop")
--local Shop = Object.newExtends("Shop",?)

--Collection
local Shops = {}

function Shop.new(interactPart,items)
	local obj = Shop:make()
	--local obj = Shop:super()
	obj.ShopName = interactPart.Name
	obj.InteractPart = interactPart
	obj.MeleeWeapons = items["Melee Weapons"]
	obj.Armor = items.Armor
	obj.InteractPart.Touched:Connect(function(part)
		local player = game.Players:GetPlayerFromCharacter(part.Parent)
		if player then
			obj:OpenShop(player)
		end
	end)
	return obj
end

function Shop:OpenShop(player)
	
	if self.debounce then return end
	print("Opening shop: " .. self.ShopName .. " for player: " .. player.Name)
		if player.PlayerGui.ShopGUI.ShopUI:FindFirstChild("self.ShopName") then
			player.PlayerGui.ShopGUI.ShopUI.self.ShopName.Value = self.ShopName
			openShopEvent:FireClient(player, self.ShopName)
		else
			local shopNamePlayer = Instance.new("StringValue",player.PlayerGui.ShopGUI.ShopUI)
			shopNamePlayer.Value = self.ShopName
			shopNamePlayer.Name = "shopName"
			openShopEvent:FireClient(player, self.ShopName)
		end
end


function Shop.Initialize()
	for index, shop in pairs(CollectionService:GetTagged("Shop")) do
		local newShop = Shop.new(shop,workspace.Shops:FindFirstChild(shop.Name).Items)
		table.insert(Shops,newShop)
	end
end

return Shop