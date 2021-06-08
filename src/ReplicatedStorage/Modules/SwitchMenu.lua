local playSoundEffect = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("PlaySoundEffect")
local menuSwitchCooldown = false

return function(menuName, forceOpen)
	if menuSwitchCooldown == false or not menuName or menuName == true or forceOpen then -- if menuname is nil, all menus close; if menuname is true, all menus close with no open cooldown
		if menuName then
			if game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Menus.QuestOfferMenu.Visible == true then
				return -- No new menus can be opened while the quest offer is onscreen
			end
			menuSwitchCooldown = true
			if menuName == true then
				require(playSoundEffect)("MenuClose")
			else
				require(playSoundEffect)("MenuOpen")
			end
		else
			require(playSoundEffect)("MenuClose")
		end
		for _,menu in pairs(game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Menus:GetChildren()) do
			if menu.Name == menuName then
				menu.Visible = true
				game:GetService("TweenService"):Create(menu, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = UDim2.new(menu.Open.Value.X, 0, menu.Open.Value.Y, 0)}):Play()
			elseif menu.Visible == true then
				game:GetService("TweenService"):Create(menu, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = UDim2.new(menu.Closed.Value.X, 0, menu.Closed.Value.Y, 0)}):Play()
				coroutine.wrap(function()
					wait(1)
					menu.Visible = false
				end)()
			end
		end
		if not menuName then
			wait(2)
			menuSwitchCooldown = false
		elseif menuName == true then
			wait(1)
			menuSwitchCooldown = false
		end
	end
end