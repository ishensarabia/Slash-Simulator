local Package = script:FindFirstAncestorOfClass("Folder")
local Object = require(Package.BaseRedirect)
--Services
local CollectionService = game:GetService("CollectionService")

--Data
local DataManager = require(game.ServerScriptService.Server.Data.DataManager)

local CollectableClass = require(Package.Collectable)
-- local Coin = Object.new("Coin")
local Coin = Object.newExtends("Coin",CollectableClass)

--Collection of class
local Coins = {}

function Coin.new(model)
	local obj = Coin:make()
	-- local obj = Coin:super()
    obj.Model = model
    obj.RespawnTime = 10
    obj.Obtainable  = true

    model.Touched:Connect(function(part)
        local player = game.Players:GetPlayerFromCharacter(part.Parent)
        if player and obj.Obtainable then
            obj:GiveCoinToPlayer(player)
        end
    end)
	return obj
end

function Coin:GiveCoinToPlayer(player)
    local data = DataManager:Get(player)
    if data then
        data.Coins += 1
        player.leaderstats:FindFirstChild("Coins").Value = data.Coins
    end

    self.Model.Transparency = 1
    self.Obtainable = false
    wait(self.RespawnTime)
    self.Obtainable = true
    self.Model.Transparency = 0
end

function Coin:GetCoin()
    for index, coin in pairs(Coins) do
        if self:GetID() == coin:GetID() then
            return coin
        end    
    end
end

function Coin:Initialize()
    for index, coin in pairs(CollectionService:GetTagged("Coin")) do
        local newCoin = Coin.new(coin)
        table.insert(Coins,newCoin)
        print(newCoin:GetCoin())
    end
end


return Coin