local playerFunctions = script.Parent
local replicatedStorage = game:GetService("ReplicatedStorage")
local enemyFunctions = replicatedStorage:WaitForChild("Modules"):WaitForChild("EnemyFunctions")
local allEnemiesFolders = nil -- for the raycast whitelist
local attacks = {}

function FillWhitelist()
	allEnemiesFolders = {}
	for _,enemyFolder in pairs(workspace.Areas:GetChildren()) do
		if enemyFolder:FindFirstChild("Enemies") then
			table.insert(allEnemiesFolders, enemyFolder)
		end
	end
end

function FindEnemyHumanoid(part)
	local searchingIn = part.Parent
	for _ = 1,3 do
		local found = searchingIn:FindFirstChild("EnemyHumanoid")
		if found then
			return found
		elseif searchingIn.Parent then
			searchingIn = searchingIn.Parent
			continue
		end
		return
	end
end

function UseArrow(player)
	if player.Stats.Arrows.Value > 0 then
		player.Stats.Arrows.Value = player.Stats.Arrows.Value - 1
		return true
	else
		replicatedStorage.ClientRemotes.Notification:FireClient(player, "Need more arrows!", Color3.fromRGB(255, 0, 0))
	end
end

function UseMana(player, required)
	if player.Stats.Mana.Value >= required then
		player.Stats.Mana.Value = player.Stats.Mana.Value - required
		return true
	else
		replicatedStorage.ClientRemotes.Notification:FireClient(player, "Need at least " .. required .. " mana!", Color3.fromRGB(255, 0, 0))
	end
end

function attacks.Sword(player, tool)
	local connection = tool.Handle.Touched:Connect(function(part)
		local enemyHumanoid = FindEnemyHumanoid(part)
		if enemyHumanoid then
			require(enemyFunctions).DamageEnemy(player, tool, enemyHumanoid)
		end
	end)
	local cooldown = Instance.new("Model")
	cooldown.Name = player.Name
	cooldown.Parent = script
	game:GetService("Debris"):AddItem(cooldown, replicatedStorage.Items[tool.Name].Cooldown.Value)
	local tag = Instance.new("Model")
	tag.Name = "Damage"
	tag.Parent = tool
	game:GetService("Debris"):AddItem(tag, 0.5)
	wait(0.6)
	connection:Disconnect()
end

function attacks.Bow(player, tool, targetPosition)
	if UseArrow(player) then
		local headPosition = player.Character.Head.Position
		local ray = Ray.new(headPosition, (targetPosition - headPosition).unit * tool.AttackRange.Value)
		local hit = workspace:FindPartOnRayWithWhitelist(ray, allEnemiesFolders)
		if hit then
			local enemyHumanoid = FindEnemyHumanoid(hit)
			if enemyHumanoid then
				local damageMultiplier = nil
				if enemyHumanoid.Parent and enemyHumanoid.Parent:FindFirstChild("Head") and (enemyHumanoid.Parent.Head.Position - targetPosition).magnitude < 2 then -- headshot with bow
					damageMultiplier = 2
				end
				require(enemyFunctions).DamageEnemy(player, tool, enemyHumanoid, damageMultiplier)
			end
		end
	end
end

function attacks.Staff(player, tool, targetPosition)
	local cost = tool:FindFirstChild("ManaCost")
	if not cost or cost and UseMana(player, cost.Value) then
		local playerPositino = player.Character.HumanoidRootPart.Position
		local boxCast = Instance.new("Part") -- some kind of "wide" raycast thing
		boxCast.Anchored = true
		boxCast.CanCollide = false
		boxCast.Transparency = 1
		boxCast.Size = Vector3.new(2, 2, math.clamp((playerPositino - targetPosition).magnitude, tool.AttackRange.Value, tool.AttackRange.Value)) -- forces all boxcasts to be the maximum length
		boxCast.CFrame = CFrame.new(playerPositino + CFrame.new(playerPositino, targetPosition).LookVector * boxCast.Size.Z * 0.5, targetPosition)
		boxCast.Parent = workspace
		boxCast.Touched:Connect(function(part)
			local enemyHumanoid = FindEnemyHumanoid(part)
			if enemyHumanoid then
				require(enemyFunctions).DamageEnemy(player, tool, enemyHumanoid)
			end
		end)
		wait(0.2)
		boxCast:Destroy()
	end
end

function attacks.HealthPotion(player, tool)
	wait(1.5)
	player.Character.Humanoid.Health = math.clamp(player.Character.Humanoid.Health + 50, 50, player.Character.Humanoid.MaxHealth)
	tool:Destroy()
	if player.StarterGear:FindFirstChild(tool.Name) then
		player.StarterGear[tool.Name]:Remove()
	end
end

function attacks.ManaPotion(player, tool)
	wait(1.5)
	player.Stats.Mana.Value = math.clamp(player.Stats.Mana.Value + 50, 50, require(playerFunctions).GetManaCap(player))
	tool:Destroy()
	if player.StarterGear:FindFirstChild(tool.Name) then
		player.StarterGear[tool.Name]:Remove()
	end
end

return function(player, tool, itemType, targetPosition) -- targetPosition should only be sent for ranged weapons
	if not allEnemiesFolders then
		FillWhitelist() -- makes the enemy whitelist if not already done
	end
	if attacks[itemType] then
		attacks[itemType](player, tool, targetPosition)
	else
		warn([[Could not find matching use item function for "]] .. itemType .. [[" in ]] .. script:GetFullName())
	end
end