local GuiModule = require(game.Players.LocalPlayer.PlayerScripts.Client.Modules.MainClientUI)
local player = game.Players.LocalPlayer
local playerGui = game.Players.LocalPlayer.PlayerGui;



GuiModule.Initialize()

--Detect changes in values
player.leaderstats.Coins.Changed:Connect(GuiModule.UpdateGUIValues)
player.leaderstats.Coins.Changed:Connect(GuiModule.UpdateGUIValues)


playerGui:WaitForChild("StartMenu").MainFrame.PlayButton.MouseButton1Click:Connect(GuiModule.PlayButton)
playerGui:WaitForChild("StartMenu").MainFrame.StoryButton.MouseButton1Click:Connect(GuiModule.StoryButton)
playerGui:WaitForChild("MainGUI").JoinButton.MouseButton1Click:Connect(GuiModule.JoinButton)
playerGui:WaitForChild("MainGUI").Prestiges.Background.TextButton.MouseButton1Click:Connect(GuiModule.ShowPrestiges)
playerGui:WaitForChild("LevelGUI").Prestiges.CloseButton.MouseButton1Click:Connect(GuiModule.HidePrestiges)