local playerGui = game.Players.LocalPlayer.PlayerGui;
local player = game.Players.LocalPlayer
local GuiModule = {};
--Display module
local scoreDisplayModule = require(game.ReplicatedStorage.Modules.Gui.DisplayNumbers)
function GuiModule:Initialize()

    local inMenu = Instance.new("BoolValue",player)
    inMenu.Name = "inMenu"
    inMenu.Value = true;
    playerGui:WaitForChild("StartMenu").MainFrame.Visible = true;
    GuiModule.UpdateGUIValues()
end

function GuiModule.UpdateGUIValues()
    playerGui.MainGUI:WaitForChild("Diamonds").DiamondsAmount.Text = scoreDisplayModule.DealWithPoints(player:WaitForChild("leaderstats").Diamonds.Value)
    playerGui.MainGUI:WaitForChild("Coins").CoinsAmount.Text = scoreDisplayModule.DealWithPoints(player.leaderstats.Coins.Value)
end

function GuiModule.PlayButton()

    local tween = require(playerGui:WaitForChild("StartMenu").Animator).PlayButton
    tween:Play()
    tween.DonePlaying.Event:Connect(function()

            playerGui.StartMenu.MainFrame.Visible = false
            player.inMenu.Value = false
        
    end)

    
end

function GuiModule.StoryButton()

    local tween = require(playerGui:WaitForChild("StartMenu").Animator).StoryButton
    tween:Play()
    tween.DonePlaying.Event:Connect(function()

        playerGui.StartMenu.MainFrame.Visible = false

    
    end)
    
end

function GuiModule.JoinButton()

    local tween = require(playerGui:WaitForChild("MainGUI").Animator).JoinButton
    tween:Play()

end

function GuiModule.ShowPrestiges()
    local tween = require(playerGui:WaitForChild("LevelGUI").Animator).OpenPrestiges
    tween:Play()
end

function GuiModule.HidePrestiges()
    local tween = require(playerGui:WaitForChild("LevelGUI").Animator).ClosePrestiges
    tween:Play()
end


return GuiModule;