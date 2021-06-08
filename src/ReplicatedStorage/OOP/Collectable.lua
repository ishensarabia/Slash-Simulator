--Copyright Ishen Sarabia, done for Slash Simulator (c) 2021

local Package = script:FindFirstAncestorOfClass("Folder")
local Object = require(Package.BaseRedirect)
--Services
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Collectable = Object.new("Collectable")
--local Collectable = Object.newExtends("Collectable",?)

--Collection
local Collectables = {}

function Collectable.new(model, collectableType, amountToGive, respawnTime)
	local obj = Collectable:make()
	-- local obj = Collectable:super()
	obj.Model = model
	obj.Type = collectableType
	obj.AmountToGive = amountToGive
	obj.Obtainable = true
	obj.RespawnTime =respawnTime
	obj.XPToGive = amountToGive * 1.3
	obj.Model.Touched:Connect(function(part)
		local player = game.Players:GetPlayerFromCharacter(part.Parent)
		if player and obj.Obtainable and RunService:IsServer() then
			obj:OnTouch(player)
		end
	end)

	return obj
end

function Collectable:GetType()
	return self.Type
end

function Collectable:OnTouch(player)
	--Request DataManager only on the server
	local DataManager = require(game.ServerScriptService.Server.Data.DataManager)

	local collectableType = self.Type
	local data = DataManager:Get(player)

    if data then
		data.TotalXP += self.XPToGive
		player:SetAttribute("TotalXP", data.TotalXP)
        data[collectableType] += self.AmountToGive
        player.leaderstats:FindFirstChild(collectableType).Value = data[collectableType]
    end

    self.Model.Transparency = 1
    self.Obtainable = false
    wait(self.RespawnTime)
    self.Obtainable = true
    self.Model.Transparency = 0
end

function Collectable:GetModel()
	return self.Model
end

function Collectable:Initialize()
	for index, collectable in pairs(CollectionService:GetTagged("Collectable")) do
		local newCollectable = Collectable.new(collectable, collectable:GetAttribute("CollectableType"), collectable:GetAttribute("AmountToGive"), collectable:GetAttribute("RespawnTime"))
		table.insert(Collectables,newCollectable)
	end
end

function Collectable:Spin()
	if RunService:IsClient() then
		local player = game.Players.LocalPlayer
		for index, collectable in pairs(Collectables) do
			if player:DistanceFromCharacter(collectable:GetModel().Position) <= 50 then
				collectable:GetModel().CFrame *= CFrame.Angles(math.rad(10),0,0)
			end	
		end
	end
end

return Collectable