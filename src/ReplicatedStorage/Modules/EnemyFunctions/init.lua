local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")
local animationSystem = replicatedStorage:WaitForChild("Modules"):WaitForChild("AnimationSystem")
local attacks = script:WaitForChild("Attacks")
local questSystem = replicatedStorage:WaitForChild("Modules"):WaitForChild("QuestSystem")
local serverSettings = replicatedStorage:WaitForChild("ServerSettings")
local module = {}

function module.SpawnEnemy(enemyName, position, folder)
	if replicatedStorage.EnemyTypes[serverStorage.Enemies[enemyName].Stats.EnemyType.Value] then
		local enemy = serverStorage.Enemies[enemyName]:Clone()
		for _,stat in pairs(replicatedStorage.EnemyTypes[enemy.Stats.EnemyType.Value]:GetChildren()) do
			stat:Clone().Parent = enemy.Stats
		end
		enemy.EnemyHumanoid.Health = enemy.EnemyHumanoid.MaxHealth -- just in case someone forgot to set health
		local rankTag = Instance.new("NumberValue")
		rankTag.Value = enemy.Stats.Rank.Value
		rankTag.Name = "Rank"
		rankTag.Parent = enemy.Stats
		local originalPosition = Instance.new("Vector3Value")
		originalPosition.Value = position
		originalPosition.Name = "OriginalPosition"
		originalPosition.Parent = enemy.Stats
		enemy:SetPrimaryPartCFrame(CFrame.new(position) * CFrame.Angles(0, math.rad(math.random(-360, 360)), 0))
		enemy.Parent = folder
		local nametag = game:GetService("ServerScriptService").RPGSystem.Nametag:Clone()
		nametag.Parent = enemy.Head
		nametag.NameLabel.Text = enemy.Name .. " [" .. enemy.Stats.Rank.Value .. "]"
		if enemy.Stats.Defense.Value > 0 and serverSettings.EnemiesShowDefense.Value == true then
			nametag.Defense.Visible = true
			nametag.Defense.Label.Text = enemy.Stats.Defense.Value
		end
		local newAnimationSystem = animationSystem:Clone()
		newAnimationSystem.Parent = enemy.EnemyHumanoid
		require(newAnimationSystem).PlayAnimation(enemy.Stats.IdleAnimation.Value.Name)
		enemy.EnemyHumanoid.Running:Connect(function(speed)
			if speed > 0.1 then
				require(newAnimationSystem).PlayAnimation(enemy.Stats.WalkAnimation.Value.Name)
			else
				require(newAnimationSystem).StopAnimation(enemy.Stats.WalkAnimation.Value.Name)
			end
		end)
		enemy.EnemyHumanoid.HealthChanged:Connect(function()
			local function Loot()
				local alreadyGotLoot = {}
				for _,tag in pairs(enemy.LootTags:GetChildren()) do
					if not table.find(alreadyGotLoot, tag.Name) then
						table.insert(alreadyGotLoot, tag.Name)
						local player = players:FindFirstChild(tag.Name)
						if player then
							if enemy.Stats:FindFirstChild("Drops") then -- Loot drops
								for _,itemDrop in pairs(enemy.Stats.Drops:GetChildren()) do
									if math.random(1,100) <= itemDrop.DropChance.Value then
										if not itemDrop:FindFirstChild("DropType") or itemDrop.DropType.Value == "Item" then
											replicatedStorage.Items[itemDrop.Name]:Clone().Parent = player.StarterGear
											replicatedStorage.Items[itemDrop.Name]:Clone().Parent = player.Backpack
											if replicatedStorage.ServerSettings.LootNotifications.Value == true then
												replicatedStorage.ClientRemotes.Notification:FireClient(player, "Got " .. itemDrop.Name .. "!", Color3.fromRGB(255, 255, 0))
											end
										elseif itemDrop.DropType.Value == "Stat" then
											player.Stats[itemDrop.Name].Value = player.Stats[itemDrop.Name].Value + itemDrop.Amount.Value
											if replicatedStorage.ServerSettings.LootNotifications.Value == true then
												replicatedStorage.ClientRemotes.Notification:FireClient(player, "+" .. itemDrop.Amount.Value .. " " .. itemDrop.Name, Color3.fromRGB(0, 255, 255))
											end
										elseif itemDrop.DropType.Value == "Armor" then
											if player.Armor[itemDrop.Name].Value == false then
												player.Armor[itemDrop.Name].Value = true
												if replicatedStorage.ServerSettings.LootNotifications.Value == true then
													replicatedStorage.ClientRemotes.Notification:FireClient(player, "Got " .. itemDrop.Name .. "!", Color3.fromRGB(255, 150, 0))
												end
											end
										else
											warn('Item drop type named"' .. itemDrop.DropType.Value .. '" does not match any existing drop types; enemy: ' .. enemy.Name)
										end
									end
								end
							end
							-- XP and Gold drops
							player.Stats.XP.Value = player.Stats.XP.Value + enemy.Stats.XP.Value
							player.Stats.Gold.Value =player.Stats.Gold.Value + enemy.Stats.Gold.Value
							-- Quest stuff
							require(questSystem).PlayerDefeatedEnemy(player, enemy.Name)
						end
					end
				end
			end
			if enemy.EnemyHumanoid.Health >= enemy.EnemyHumanoid.MaxHealth then
				nametag.Bar.Visible = false
			else
				nametag.Bar.Fill.Position = UDim2.new(1-(enemy.EnemyHumanoid.Health/enemy.EnemyHumanoid.MaxHealth), 0, 0, 0)
				nametag.Bar.Visible = true
			end
			if enemy.EnemyHumanoid.Health == 0 and nametag.Parent then
				Loot()
				nametag:Destroy()
				replicatedStorage.ClientRemotes.EnemyDied:FireAllClients(enemy)
				game:GetService("Debris"):AddItem(enemy, 2)
			end
		end)
	else
		warn("Tried to spawn " .. enemyName .. " but couldn't find a matching folder in EnemyTypes")
	end
end

function module.CalculateEnemyDamage(enemy, min, max)
	return math.clamp(math.random(min, max) - enemy.Stats.Defense.Value, 1, math.huge)
end

function module.CalculatePlayerDamage(player, min, max)
	local defense = 0
	if replicatedStorage.Armor:FindFirstChild(player.Stats.CurrentArmor.Value) then
		defense = replicatedStorage.Armor[player.Stats.CurrentArmor.Value].Defense.Value
	end
	return math.clamp(math.random(min, max) - defense, 1, math.huge)
end

function module.DamageEnemy(player, item, enemyHumanoid, damageMultiplier)
	if enemyHumanoid.Health > 0 and not enemyHumanoid:FindFirstChild(player.Name) then
		local function TagEnemy(seconds)
			if not enemyHumanoid.Parent:FindFirstChild("LootTags") then
				local lootTags = Instance.new("Folder")
				lootTags.Name = "LootTags"
				lootTags.Parent = enemyHumanoid.Parent
			end
			local tag = Instance.new("Model")
			tag.Name = player.Name
			tag.Parent = enemyHumanoid
			game:GetService("Debris"):AddItem(tag, seconds)
			local lootTag = Instance.new("Model")
			lootTag.Name = player.Name
			lootTag.Parent = enemyHumanoid.Parent.LootTags
			game:GetService("Debris"):AddItem(lootTag, 20)
		end
		local function LerpNumber(minimum, maximum, percentage)
		    return (percentage * (maximum - minimum)) + minimum
		end
		TagEnemy(item.Cooldown.Value)
		if not damageMultiplier then
			damageMultiplier = 1
		end
		local minimum = item.MinimumDamage.Value
		local maximum = item.MaximumDamage.Value
		minimum = LerpNumber(minimum, maximum, player.Attributes.Power.Value / serverSettings.PowerCap.Value) -- The minumum increases with more power; max power is only maximum damage
		local damage = math.floor(module.CalculateEnemyDamage(enemyHumanoid.Parent, minimum, maximum) * damageMultiplier)
		enemyHumanoid.Health = enemyHumanoid.Health - damage
		replicatedStorage.ClientRemotes.DamageDone:FireClient(player, enemyHumanoid.Parent, damage)
	end
end

function module.FindClosestPlayer(enemy, useChaseRange) -- Returns closest player in the AttackRange or nil if none are found
	local range = enemy.Stats.AttackRange.Value
	if useChaseRange then
		range = enemy.Stats.ChaseRange.Value
	end
	local closest = nil
	for _,player in pairs(players:GetChildren()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
			if not closest or (player.Character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).magnitude < (closest.Character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).magnitude then
				if (player.Character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).magnitude < range then
					closest = player
				end
			end
		end
	end
	return closest
end

function module.FindPlayersInRadius(position, radius) -- Returns a table of players in the AttackRange or nil if none are found
	local inRange = nil
	for _,player in pairs(players:GetChildren()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
			if (player.Character.HumanoidRootPart.Position - position).magnitude < radius then
				if not inRange then
					inRange = {}
				end
				table.insert(inRange, player)
			end
		end
	end
	return inRange
end

function module.GetAllPlayerCharacters() -- Returns a table of all player characters, useful for whitelists
	local characters = {}
	for _,player in pairs(players:GetChildren()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			table.insert(characters, player.Character)
		end
	end
	return characters
end

function module.Attack(enemy)
	if enemy:FindFirstChild("EnemyHumanoid") and enemy.EnemyHumanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Stats") and not enemy:FindFirstChild("AttackCooldown") then
		local enemyType = enemy.Stats.EnemyType.Value
		if require(attacks)[enemyType] then
			local tag = Instance.new("Model") -- Does not let the enemy attack until the set AttackCooldown is over
			tag.Name = "AttackCooldown"
			tag.Parent = enemy
			require(attacks)[enemyType](enemy)
			wait(replicatedStorage.EnemyTypes[enemyType].AttackCooldown.Value)
			tag:Destroy()
		else
			warn(enemy.Name .. [[ tried to attack but the Attacks module didn't have an attack that matches the enemy type "]] .. enemyType .. [["]])
		end
	end
end

function module.Follow(enemy, targetPart)
	local chaseRange = enemy.Stats.ChaseRange.Value -- How many studs away a player must be before the enemy decides to start chasing
	local closestRange = enemy.Stats.ClosestRange.Value -- The minumum distance the enemy can be from the player
	local attackRange = enemy.Stats.AttackRange.Value -- How many studs away the enemy will try to attack a player
	if (targetPart.Position - enemy.HumanoidRootPart.Position).magnitude <= chaseRange then
		local pointToSeek = targetPart.Position+(CFrame.new(targetPart.Position, enemy.HumanoidRootPart.Position).LookVector*closestRange)
		enemy.EnemyHumanoid:MoveTo(pointToSeek)
		if (targetPart.Position - enemy.HumanoidRootPart.Position).magnitude <= attackRange then
			module.Attack(enemy)
		end
	elseif (targetPart.Position - enemy.Stats.OriginalPosition.Value).magnitude > 10 then
		enemy.EnemyHumanoid:MoveTo(enemy.Stats.OriginalPosition.Value)
	end
end

return module