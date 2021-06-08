local UIS = game:GetService("UserInputService")
local debounce = false
local Player = game.Players.LocalPlayer
repeat wait() until Player.Character
Character = Player.Character
local cd = .6
local count = 0
local currTime = 0
local prevTime = 0
local combat = script:WaitForChild("RemoteEvent")
local debounce2 = false
local tool = script.Parent
local tweenService = game:GetService("TweenService")
local punch2 = script:WaitForChild("Punch2Player")


script.Parent.Activated:Connect(function(isTyping)
	if isTyping then return end
	
	if Player.Character:FindFirstChild("Hit") then return end
	if Player.Character:FindFirstChild("Blocking") then return end
	
	
	if debounce ==  false then
			debounce = true
			currTime = tick()
			
			
			local passedTime = currTime - prevTime
			if passedTime < 1 then
				print("its less that one")
				count = count + 1
				print(count)
				if count > 4 then -- Make sure to change number based on the amount of animatons you have
  					
				count = 1
					
				end
			else
				count = 1
				
			end
			
			
			
			
		combat:FireServer(count,Character.HumanoidRootPart.CFrame*CFrame.new(0,0,-3).p)
			print("fired")
			
			
			
		
			
	end
	
	
end)


combat.OnClientEvent:Connect(function()
	
	prevTime = currTime
	
	if count == 4 then -- change number based on amount of animations you have
			wait(2)
		debounce = false
	else
		wait(0.5) -- Change speed of the time between punches
		debounce = false
		
		end
	
end)




tool.Equipped:Connect(function(Mouse)
	Mouse.Button2Down:Connect(function()
		
	if Player.Character:FindFirstChild("Hit") then return end
	if Player.Character:FindFirstChild("Blocking") then return end
		
		repeat wait() until Player.Character
		local Character2 = Player.Character
		local head = Character2:WaitForChild("HumanoidRootPart")
		
		print(Character2.Name)
	
		
		
		if not debounce2 then
			debounce2 = true
			
			local effect = game.ReplicatedStorage.SwordCombat:WaitForChild("RMAttack"):Clone()
			effect.CFrame = head.CFrame
			effect.Parent = workspace
			game.Debris:AddItem(effect,0.7)
			
			local info3 = TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)
			local goal3 = {}
			goal3.Size = effect.Size * 0.5
			goal3.Transparency = 1
			local tween3 = tweenService:Create(effect,info3,goal3)
			tween3:Play()
			print("played3")
			
			print("activated m2 ")
			
			
			
			
			
			
			punch2:FireServer(Character.HumanoidRootPart.CFrame*CFrame.new(0,0,-3).p)
			
			wait(3)
			debounce2 = false
		end
	end)
end)