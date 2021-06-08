--Settings values
local rotateCollectables = true
--Classes
local CollectableClass = require(game.ReplicatedStorage.OOP.Collectable)

--Wait until character is loaded
game.Players.LocalPlayer.CharacterAdded:Wait()


--Run the effects with settings value
CollectableClass:Initialize()
repeat
    CollectableClass:Spin()
    wait()
until not rotateCollectables 


