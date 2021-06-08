local rp = game:GetService("ReplicatedStorage")
local combatevent = script.Parent
local animation = script:WaitForChild("Animations")
local acutalplayer = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local tweenService = game:GetService("TweenService")
local ALIVE_TAG_NAME = "Punch"
local debounce = false



local anims = {
	animation:WaitForChild("Slash1"), --Add more animations here
	animation:WaitForChild("Slash2"),
	animation:WaitForChild("Slash3"),
	animation:WaitForChild("FinalSlash"),
	

}

combatevent.OnServerEvent:Connect(function(player,count,V1)
	print("Recieved event")
	local character = player.Character
	local Hum = character:WaitForChild("Humanoid")

	spawn(function()
		Hum.WalkSpeed = 10
		wait(3)
		Hum.WalkSpeed = 16
	end)


	local clash = Instance.new("BoolValue")
	clash.Name  = "ClashAttack"
	clash.Value = false
	clash.Parent = player.Character
	game.Debris:AddItem(clash,0.4)




	


	local dodge = {5491816196,5491829124,5491834231} --paste animation id here
	local num = math.random(#dodge)
	local chosenanim = dodge[num]
	
	
	

	local attack = Hum:LoadAnimation(anims[count])
	attack:Play()

	combatevent:FireClient(player)
	
	local hiteffectball = function(target,pos)

		local hiteffect = game.ReplicatedStorage.SwordCombat.Thing:Clone()
		hiteffect.CFrame = pos
		hiteffect.CFrame =  CFrame.new(hiteffect.Position, target.Position) 		
		hiteffect.Parent = target
		game.Debris:AddItem(hiteffect,1)



		if count == 4 then
			hiteffect.BrickColor = BrickColor.new("Neon orange")
		end

		tweenService:Create(hiteffect,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{CFrame = hiteffect.CFrame + hiteffect.CFrame.lookVector * -7,Transparency = 1,Size = Vector3.new(0.087, 0.08, 3.35)}):Play()

	end
	
	
	
	
	
	
	local region = Region3.new(V1-Vector3.new(2,2,2),V1+Vector3.new(2,2,2))
	local RTable = workspace:FindPartsInRegion3(region,nil,20)
	
	for i,v in pairs(RTable) do
		if v.Parent:FindFirstChild("Humanoid") and v.Parent:FindFirstChild("Deb") == nil and v.Parent ~= character then
			local deb = Instance.new("BoolValue",v.Parent)
			deb.Name = "Deb"
			game.Debris:AddItem(deb,0.2)
			local closecharacter = v.Parent
			
			if closecharacter:FindFirstChild("Knocked") then return end
			

			if closecharacter.HumanoidRootPart:FindFirstChild("Block") then
				if (closecharacter.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude < 3.5 then
					print("someone is blocking near u")


					local hiteffect = game.ReplicatedStorage.SwordCombat:WaitForChild("HitCollision"):Clone()
					hiteffect.CFrame = closecharacter.HumanoidRootPart.CFrame
					hiteffect.Parent = workspace
					game.Debris:AddItem(hiteffect,0.6)
					
					local Sound = Instance.new("Sound")
					Sound.SoundId = "rbxassetid://5763723309"
					Sound.Parent = closecharacter.HumanoidRootPart
					Sound.PlaybackSpeed = math.random(93,107)/100
					Sound:Play()
					game.Debris:AddItem(Sound,0.5)	


					local info3 = TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)
					local goal3 = {}
					goal3.Size = hiteffect.Size * 12
					goal3.Transparency = 1
					local tween3 = tweenService:Create(hiteffect,info3,goal3)
					tween3:Play()
					print("played3")
					
					-- hes blocking
					if count == 4 then
						closecharacter.BlockBar.Value = closecharacter.BlockBar.Value - 100
						print("block broken")


						local bv = Instance.new("BodyVelocity",closecharacter.HumanoidRootPart)
						bv.MaxForce = Vector3.new(1e8,1e8,1e8)
						bv.Velocity = character.HumanoidRootPart.CFrame.lookVector*20
						game.Debris:AddItem(bv,0.3) 
						print("knock him back")
					end	
					
					

				else
					-- your behind him
					if 	(closecharacter.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude < 7 then
						print("hitting from behind")	
						closecharacter.Humanoid:TakeDamage(5)
						
						

						local hitvalue = Instance.new("BoolValue")
						hitvalue.Name = "Hit"
						hitvalue.Parent = closecharacter
						game.Debris:AddItem(hitvalue,1)
						
						

						local times = 0
				
						
						

						local hiteffect = game.ReplicatedStorage.SwordCombat:WaitForChild("SlashEffect"):Clone()
						hiteffect.CFrame = closecharacter.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(-1.38),math.rad(177.92),math.rad(-123.57))
						hiteffect.Parent = workspace
						game.Debris:AddItem(hiteffect,0.5)
						

						local info3 = TweenInfo.new(0.3,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)
						local goal3 = {}
						goal3.Size = hiteffect.Size * 3
						goal3.Transparency = 1
						local tween3 = tweenService:Create(hiteffect,info3,goal3)
						tween3:Play()
						print("played3")
						print("you both hit at the same time")


						local Sound = Instance.new("Sound")
						Sound.SoundId = "rbxassetid://935843979"
						Sound.Parent = closecharacter.HumanoidRootPart
						Sound.PlaybackSpeed = math.random(93,107)/100
						Sound:Play()
						game.Debris:AddItem(Sound,0.5)	


						if count == 4 then


							local Track11= Instance.new("Animation")
							Track11.AnimationId = "rbxassetid://5402391192"
							local Anim11 = closecharacter.Humanoid:LoadAnimation(Track11)
							Anim11:Play()

							local bv = Instance.new("BodyVelocity",closecharacter.HumanoidRootPart)
							bv.MaxForce = Vector3.new(1e8,1e8,1e8)
							bv.Velocity = character.HumanoidRootPart.CFrame.lookVector*30
							game.Debris:AddItem(bv,0.3) 
							Anim11:Stop()
							

							local Sound = Instance.new("Sound")
							Sound.SoundId = "rbxassetid://3932506183"
							Sound.Parent = closecharacter.HumanoidRootPart
							Sound.PlaybackSpeed = math.random(93,107)/100
							Sound:Play()
							game.Debris:AddItem(Sound,0.5)	

						end
						
						spawn(function()
							closecharacter.Humanoid.WalkSpeed = 1
							closecharacter.Humanoid.JumpPower = 1		
							wait(1.7) 
							closecharacter.Humanoid.WalkSpeed = 16
							closecharacter.Humanoid.JumpPower = 50

						end)

						
				

					end
					
					
				end
				
				
				
			else
-- HAS HAKI ON
				if closecharacter:FindFirstChild("HasHaki") then
					print("he has haki on")
					
					local closeplayer = game.Players:GetPlayerFromCharacter(closecharacter)
					if closeplayer.Data.HakiLevel.Value >0 then

						spawn(function()
							if not debounce then
								debounce = true
								closeplayer.Data.HakiLevel.Value = closeplayer.Data.HakiLevel.Value - 1
								wait(0.6)
								debounce = false
								print("REMOVED ONE VALUE")
							end
						end)

						spawn(function()
							local track = Instance.new("Animation")
							track.AnimationId = "rbxassetid://"..chosenanim
							local anim = closecharacter.Humanoid:LoadAnimation(track)
							anim:Play()
							wait(0.3)
							anim:Stop()


						end)

					end
				else
					-- CLASHING
					if closecharacter:FindFirstChild("ClashAttack") then	
						local sound = Instance.new("Sound")
						sound.SoundId = "rbxassetid://182707266"
						sound.Parent = closecharacter.HumanoidRootPart
						sound:Play()
						game.Debris:AddItem(sound,0.5)
						print("SOUND TESTINGG")

						local hiteffect = game.ReplicatedStorage.SwordCombat:WaitForChild("HitCollision"):Clone()
						hiteffect.CFrame = closecharacter.HumanoidRootPart.CFrame
						hiteffect.BrickColor = BrickColor.new("Daisy orange")
						hiteffect.Parent = workspace
						game.Debris:AddItem(hiteffect,0.6)

						local info3 = TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)
						local goal3 = {}
						goal3.Size = hiteffect.Size * 16
						goal3.Transparency = 1
						local tween3 = tweenService:Create(hiteffect,info3,goal3)
						tween3:Play()
						print("played3")
						print("you both hit at the same time")

						local Track11= Instance.new("Animation")
						Track11.AnimationId = "rbxassetid://5402391192"
						local Anim11 = closecharacter.Humanoid:LoadAnimation(Track11)
						Anim11:Play()

						local bv = Instance.new("BodyVelocity",closecharacter.HumanoidRootPart)
						bv.MaxForce = Vector3.new(1e8,1e8,1e8)
						bv.Velocity = character.HumanoidRootPart.CFrame.lookVector*60
						game.Debris:AddItem(bv,0.3) 
						Anim11:Stop()

						local Track12= Instance.new("Animation")
						Track12.AnimationId = "rbxassetid://5402391192"
						local Anim12 = character.Humanoid:LoadAnimation(Track12)
						Anim12:Play()

						local bv2 = Instance.new("BodyVelocity",character.HumanoidRootPart)
						bv2.MaxForce = Vector3.new(1e8,1e8,1e8)
						bv2.Velocity = character.HumanoidRootPart.CFrame.lookVector*-60
						game.Debris:AddItem(bv2,0.3) 
						Anim12:Stop()
						
			else

			
				-- not blocking at all
				closecharacter.Humanoid:TakeDamage(7)
				print("IF THIS PRINTS")

				
				local times = 0
			



				local hitvalue = Instance.new("BoolValue")
				hitvalue.Name = "Hit"
				hitvalue.Parent = closecharacter
				game.Debris:AddItem(hitvalue,1)
				
			
						local hiteffect = game.ReplicatedStorage.SwordCombat:WaitForChild("SlashEffect"):Clone()
				hiteffect.CFrame = closecharacter.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(-1.38),math.rad(177.92),math.rad(-123.57))
				hiteffect.Parent = workspace
				game.Debris:AddItem(hiteffect,0.5)
					

				local info3 = TweenInfo.new(0.3,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)
				local goal3 = {}
				goal3.Size = hiteffect.Size * 3
				goal3.Transparency = 1
				local tween3 = tweenService:Create(hiteffect,info3,goal3)
				tween3:Play()
				print("played3")
				print("you both hit at the same time")

					

				local Sound = Instance.new("Sound")
					Sound.SoundId = "rbxassetid://935843979"
				Sound.Parent = closecharacter.HumanoidRootPart
				Sound.PlaybackSpeed = math.random(93,107)/100
				Sound:Play()
				game.Debris:AddItem(Sound,0.5)	

				

				if count == 4 then


					local Track11= Instance.new("Animation")
					Track11.AnimationId = "rbxassetid://5402391192"
					local Anim11 = closecharacter.Humanoid:LoadAnimation(Track11)
					Anim11:Play()

					local bv = Instance.new("BodyVelocity",closecharacter.HumanoidRootPart)
					bv.MaxForce = Vector3.new(1e8,1e8,1e8)
					bv.Velocity = character.HumanoidRootPart.CFrame.lookVector*30
					game.Debris:AddItem(bv,0.3) 
					Anim11:Stop()
					

					local sound = Instance.new("Sound")
					sound.SoundId = "rbxassetid://4810749120"
					sound.Parent = closecharacter.HumanoidRootPart
					sound.PlaybackSpeed = math.random(93,107)/100
					sound:Play()
					game.Debris:AddItem(sound,3)

				end


			

				spawn(function()
					closecharacter.Humanoid.WalkSpeed = 1
					closecharacter.Humanoid.JumpPower = 1		
					wait(1.7) 
					closecharacter.Humanoid.WalkSpeed = 16
					closecharacter.Humanoid.JumpPower = 50

						end)
					end
					
				end
			end
		end
	end
		
	

	
end)