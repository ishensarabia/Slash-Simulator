local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local playSoundEffect = replicatedStorage:WaitForChild("Modules"):WaitForChild("PlaySoundEffect")
local updateEnvironment = script:WaitForChild("UpdateEnvironment")
local itemFunctions = script:WaitForChild("ItemFunctions")
local weaponStrongAttacks = script:WaitForChild("WeaponStrongAttacks")
local gameUI = players.LocalPlayer.PlayerGui:WaitForChild("GameUI")
game:GetService("StarterGui"):SetCoreGuiEnabled("Health", false)
game:GetService("StarterGui"):SetCoreGuiEnabled("PlayerList", false)
players.LocalPlayer:WaitForChild("IsLoaded")

local mouse = players.LocalPlayer:GetMouse()
local rightMouseDown = false
local attackCooldown = false
local strongAttackCooldown = false

-- Item usage system
function FindToolInHand()
	if players.LocalPlayer.Character and players.LocalPlayer.Character:FindFirstChild("Humanoid") and players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		return players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
	end
end

function Attack()
	local tool = FindToolInHand()
	if tool and attackCooldown == false then
		if require(itemFunctions)[tool.ItemType.Value] then
			attackCooldown = true
			require(itemFunctions)[tool.ItemType.Value](tool)
			attackCooldown = false
		else
			warn('Tried to use weapon attack "' .. tool.ItemType.Value .. '" but failed to find a matching function in ' .. itemFunctions:GetFullName())
		end
	end
end

function StrongAttack()
	local tool = FindToolInHand()
	if tool and strongAttackCooldown == false and attackCooldown == false then
		if require(weaponStrongAttacks)[tool.ItemType.Value] then
			strongAttackCooldown = true
			require(weaponStrongAttacks)[tool.ItemType.Value](tool)
			strongAttackCooldown = false
		else
			warn('Tried to use weapon strong attack "' .. tool.ItemType.Value .. '" but failed to find a matching function in ' .. weaponStrongAttacks:GetFullName())
		end
	end
end

mouse.Button1Down:Connect(function() -- Left click attack
	if game:GetService("UserInputService").KeyboardEnabled == false then -- Player is probably on mobile
		wait() -- Mobile mouse position takes a frame to update for some reason
		local lastMousePosition = Vector2.new(mouse.X, mouse.Y)
		wait(0.25)
		if math.abs(mouse.X - lastMousePosition.X) > 25 or math.abs(mouse.Y - lastMousePosition.Y) > 25 then -- Return if the touch position didn't stay in relatively the same place
			return
		end
	end
	Attack()
end)

mouse.Button2Down:Connect(function() -- Right click attack
	rightMouseDown = true
	wait(0.15)
	if rightMouseDown == false then -- People use the right mouse button to move the camera, so we need to get hacky to detect a click
		StrongAttack()
	end
end)

mouse.Button2Up:Connect(function()
	rightMouseDown = false
end)

game:GetService("UserInputService").TouchLongPress:Connect(StrongAttack) -- Mobile strong attack
game:GetService("UserInputService").InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.ButtonL2 then
		StrongAttack()
	end
end)

-- Client remotes
replicatedStorage.ClientRemotes.EnemyDied.OnClientEvent:Connect(function(enemy)
	local function GetPlayerRootPart()
		if players.LocalPlayer.Character then
			return players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		end
	end
	wait(0.5)
	for _,part in pairs(enemy:GetDescendants()) do
		if part:IsA("BasePart") or part.ClassName == "Decal" then
			game:GetService("TweenService"):Create(part, TweenInfo.new(1), {Transparency = 1}):Play()
		end
	end
	if enemy:FindFirstChild("LootTags") and enemy.LootTags:FindFirstChild(players.LocalPlayer.Name) and replicatedStorage.ServerSettings.XPCollectEffect.Value == true then
		-- XP effect
		local rootPart = enemy:FindFirstChild("HumanoidRootPart")
		if rootPart then
			local orbs = {}
			for _ = 1,math.random(4,8) do
				local orb = script:WaitForChild("XPOrb"):Clone()
				orb.CFrame = rootPart.CFrame + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))
				orb.Parent = workspace
				table.insert(orbs, orb)
			end
			wait(1)
			for _,orb in pairs(orbs) do
				if orb and orb.Parent then
					local playerRootPart = GetPlayerRootPart()
					if playerRootPart then
						require(playSoundEffect)("XP")
						orb.Anchored = true
						orb.CanCollide = false
						game:GetService("TweenService"):Create(orb, TweenInfo.new(0.1), {CFrame = playerRootPart.CFrame}):Play()
						wait(0.1)
					end
					orb:Destroy()
				end
			end
		end
	end
end)

replicatedStorage.ClientRemotes.DamageDone.OnClientEvent:Connect(function(enemy, damage)
	local tool = FindToolInHand()
	if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("EnemyHumanoid") and tool then
		require(updateEnvironment).PlaySoundInCharacter(tool.DamageSound.Value)
		local indicator = Instance.new("BillboardGui")
		indicator.LightInfluence = 0
		indicator.AlwaysOnTop = true
		indicator.MaxDistance = 30
		indicator.Size = UDim2.new(5, 0, 1, 0)
		indicator.Parent = enemy.HumanoidRootPart
		local label = Instance.new("TextLabel")
		label.Font = Enum.Font.SourceSansBold
		label.BackgroundTransparency = 1
		label.TextScaled = true
		label.Size = UDim2.new(1, 0, 1, 0)
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.Text = damage
		label.Parent = indicator
		if damage > enemy.EnemyHumanoid.MaxHealth / 3 then -- really good damage
			label.TextColor3 = Color3.fromRGB(255, 0, 0)
		elseif damage > enemy.EnemyHumanoid.MaxHealth / 6 then -- pretty good damage
			label.TextColor3 = Color3.fromRGB(255, 255, 0)
		end
		game:GetService("TweenService"):Create(indicator, TweenInfo.new(0.5), {StudsOffset = Vector3.new(0, 1, 0)}):Play()
		local bodyParts = {}
		for _,part in pairs(enemy:GetDescendants()) do
			if part:IsA("BasePart") then
				table.insert(bodyParts, {part, part.Material, part.Color})
				part.Material = Enum.Material.Neon
				part.Color = Color3.fromRGB(255, 0, 0)
			end
		end
		wait(0.2)
		for _,part in pairs(bodyParts) do
			if part[1] and part[1].Parent then
				part[1].Material = part[2]
				part[1].Color = part[3]
			end
		end
		wait(0.3)
		game:GetService("TweenService"):Create(label, TweenInfo.new(1, Enum.EasingStyle.Linear), {TextTransparency = 1}):Play()
		game:GetService("Debris"):AddItem(indicator, 1)
	end
end)

replicatedStorage.ClientRemotes.TeleportToArea.OnClientEvent:Connect(function(areaName)
	require(updateEnvironment).LoadArea(areaName)
end)

-- GUI
local lastHealth = 0
local hud = gameUI:WaitForChild("HUD")
local goldLabel = hud:WaitForChild("GoldLabel")
local goldIncreaseLabel = hud:WaitForChild("GoldIncreaseLabel")
local rankLabel = hud:WaitForChild("Rank"):WaitForChild("Rank")
local defenseLabel = hud:WaitForChild("Defense"):WaitForChild("Defense")
local arrowsLabel = hud:WaitForChild("Arrows"):WaitForChild("Arrows")
local manaLabel = hud:WaitForChild("Mana"):WaitForChild("Mana")
local healthFill = hud:WaitForChild("Health"):WaitForChild("Fill")
healthFill.Parent:WaitForChild("LifeLabel")
healthFill:WaitForChild("UIGradient")
local rankBar = hud:WaitForChild("RankBar"):WaitForChild("FillCutoff")
rankBar:WaitForChild("Fill")
rankBar.Parent:WaitForChild("Label")
local switchMenu = replicatedStorage:WaitForChild("Modules"):WaitForChild("SwitchMenu")

function DamageEffect(originalPercentage, damagePercentage, amount)
	require(playSoundEffect)("Hurt" .. math.random(1,2))
	local effect = Instance.new("Frame")
	effect.BorderSizePixel = 0
	effect.Size = UDim2.new(1, 0, damagePercentage, 0)
	effect.Position = UDim2.new(0, 0, 1 - originalPercentage, 0)
	effect.ZIndex = 3
	effect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	effect.Parent = healthFill.Parent
	game:GetService("TweenService"):Create(effect, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 0, 0), BackgroundTransparency = 1}):Play()
	game:GetService("Debris"):AddItem(effect, 0.5)
	local indicator = Instance.new("TextLabel")
	indicator.Font = Enum.Font.SourceSansBold
	indicator.BackgroundTransparency = 1
	indicator.TextScaled = true
	indicator.TextColor3 = Color3.fromRGB(255, 255, 255)
	indicator.TextStrokeTransparency = 0
	indicator.Text = "-" .. math.floor(amount)
	indicator.TextColor3 = Color3.fromRGB(255, 0, 0)
	indicator.Size = UDim2.new(1, 0, 0.35, 0)
	indicator.Position = UDim2.new(1, 0, 0.325, 0)
	indicator.Parent = healthFill.Parent
	game:GetService("TweenService"):Create(indicator, TweenInfo.new(0.75, Enum.EasingStyle.Linear), {Position = indicator.Position - UDim2.new(0, 0, 0.35, 0), TextTransparency = 1, TextStrokeTransparency = 1}):Play()
	game:GetService("Debris"):AddItem(indicator, 1)
end

function RankUpEffect()
	local rankUpGlow = rankLabel.Parent:WaitForChild("RankUp")
	if rankUpGlow.ImageTransparency == 1 then
		require(playSoundEffect)("RankUp")
		game:GetService("TweenService"):Create(rankUpGlow, TweenInfo.new(0.001), {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0), Rotation = 0}):Play()
		wait()
		game:GetService("TweenService"):Create(rankUpGlow, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {Size = UDim2.new(3, 0, 3, 0), Position = UDim2.new(-1, 0, -1, 0), Rotation = 40, ImageTransparency = 0}):Play()
		wait(0.3)
		game:GetService("TweenService"):Create(rankUpGlow, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {Size = UDim2.new(6, 0, 6, 0), Position = UDim2.new(-2.5, 0, -2.5, 0), Rotation = 80, ImageTransparency = 1}):Play()
	end
end

function XPIncreaseEffect(amount)
	local glow = rankBar.Parent:WaitForChild("Glow")
	local increase = rankBar.Parent:WaitForChild("Increase")
	increase.Text = "+" .. amount
	game:GetService("TweenService"):Create(glow, TweenInfo.new(0.001), {ImageTransparency = 0}):Play()
	game:GetService("TweenService"):Create(increase, TweenInfo.new(0.001), {TextTransparency = 0, TextStrokeTransparency = 0}):Play()
	wait()
	game:GetService("TweenService"):Create(glow, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {ImageTransparency = 1}):Play()
	game:GetService("TweenService"):Create(increase, TweenInfo.new(3, Enum.EasingStyle.Linear), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
end

function GoldIncreaseEffect(amount)
	goldIncreaseLabel.Text = "+" .. amount
	game:GetService("TweenService"):Create(goldIncreaseLabel, TweenInfo.new(0.001), {TextTransparency = 0, TextStrokeTransparency = 0}):Play()
	wait()
	game:GetService("TweenService"):Create(goldIncreaseLabel, TweenInfo.new(3, Enum.EasingStyle.Linear), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
end

function UpdateDefense()
	local armor = replicatedStorage.Armor:FindFirstChild(players.LocalPlayer.Stats.CurrentArmor.Value)
	if armor then
		defenseLabel.Text = armor.Defense.Value
	else
		defenseLabel.Text = "0"
	end
end

hud:WaitForChild("Armor").MouseButton1Click:Connect(function()
	require(switchMenu)("ArmorEquipMenu")
end)

hud:WaitForChild("Attributes").MouseButton1Click:Connect(function()
	require(switchMenu)("AttributesMenu")
end)

hud:WaitForChild("Spawn").MouseButton1Click:Connect(function()
	local areaName = workspace.Remotes.ReturnToSpawn:InvokeServer()
	if areaName then
		require(updateEnvironment).LoadArea(areaName)
	end
end)

hud:WaitForChild("Quests").MouseButton1Click:Connect(function()
	require(switchMenu)("QuestsMenu")
end)

function GetManaCap()
	local serverSettings = game:GetService("ReplicatedStorage").ServerSettings
	return serverSettings.StartingMana.Value + (serverSettings.ManaBoostPerMythicality.Value * players.LocalPlayer.Attributes.Mythicality.Value)
end

local rankCap = game:GetService("ReplicatedStorage").ServerSettings.RankCap
local gold = players.LocalPlayer:WaitForChild("Stats"):WaitForChild("Gold")
local xp = players.LocalPlayer:WaitForChild("Stats"):WaitForChild("XP")
local rank = players.LocalPlayer:WaitForChild("Stats"):WaitForChild("Rank")
local currentArmor = players.LocalPlayer:WaitForChild("Stats"):WaitForChild("CurrentArmor")
local prevGold = gold.Value
local prevXP = xp.Value
local prevRank = rank.Value
gold.Changed:Connect(function()
	if gold.Value > prevGold then
		GoldIncreaseEffect(math.floor(gold.Value - prevGold))
	end
	prevGold = gold.Value
end)
xp.Changed:Connect(function()
	if xp.Value > prevXP then
		XPIncreaseEffect(math.floor(xp.Value - prevXP))
	end
	prevXP = xp.Value
end)
rank.Changed:Connect(function()
	if rank.Value > prevRank then
		RankUpEffect()
	end
	prevRank = rank.Value
end)
UpdateDefense()
currentArmor.Changed:Connect(UpdateDefense)

-- Make triggers transparent
local menuTriggers = workspace:WaitForChild("MenuTriggers", 10) -- Menu triggers for GUI
if menuTriggers then
	for _,trigger in pairs(menuTriggers:GetChildren()) do
		trigger.Transparency = 1
		trigger.Touched:Connect(function(part)
			if players.LocalPlayer.Character and part:IsDescendantOf(players.LocalPlayer.Character) then
				require(switchMenu)(trigger.Name)
			end
		end)
	end
end

-- Quest markers
local questMarkers = {}
local originalQuestMarker = script:WaitForChild("QuestMarker")

function UpdateMarkers()
	for _,trigger in pairs(workspace:WaitForChild("QuestTriggers"):GetChildren()) do
		trigger.Transparency = 1
		if players.LocalPlayer.CompletedQuests:FindFirstChild(trigger.Name) or players.LocalPlayer.Quests:FindFirstChild(trigger.Name) then
			local found = trigger:FindFirstChild("QuestMarker")
			if found then
				found:Destroy()
			end
		elseif not trigger:FindFirstChild("QuestMarker") then
			originalQuestMarker:Clone().Parent = trigger
		end
	end
end

UpdateMarkers()
players.LocalPlayer.Quests.ChildAdded:Connect(UpdateMarkers)
players.LocalPlayer.Quests.ChildRemoved:Connect(UpdateMarkers)
players.LocalPlayer.CompletedQuests.ChildAdded:Connect(UpdateMarkers)
players.LocalPlayer.CompletedQuests.ChildRemoved:Connect(UpdateMarkers)

-- Load default environment
if workspace.Areas:FindFirstChildOfClass("Folder") then
	require(updateEnvironment).LoadArea(workspace.Areas:FindFirstChildOfClass("Folder").Name)
end

game:GetService("RunService"):BindToRenderStep("UI", 50, function() -- Update and animate health UI
	if players.LocalPlayer.Character and players.LocalPlayer.Character:FindFirstChild("Humanoid") then
		if players.LocalPlayer.Character.Humanoid.Health/players.LocalPlayer.Character.Humanoid.MaxHealth >= 0.998 then
			healthFill.UIGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0)})
		elseif players.LocalPlayer.Character.Humanoid.Health/players.LocalPlayer.Character.Humanoid.MaxHealth <= 0.001 then
			healthFill.UIGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 1)})
		else
			healthFill.UIGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(players.LocalPlayer.Character.Humanoid.Health/players.LocalPlayer.Character.Humanoid.MaxHealth, 0), NumberSequenceKeypoint.new(math.clamp((players.LocalPlayer.Character.Humanoid.Health/players.LocalPlayer.Character.Humanoid.MaxHealth)+0.001, (players.LocalPlayer.Character.Humanoid.Health/players.LocalPlayer.Character.Humanoid.MaxHealth)+0.001, 0.999), 1), NumberSequenceKeypoint.new(1, 1)})
		end
		healthFill.Parent.LifeLabel.Text = math.floor(players.LocalPlayer.Character.Humanoid.Health)
		healthFill.UIGradient.Rotation = healthFill.UIGradient.Rotation - 1
		healthFill.Rotation = healthFill.Rotation + 1
		if lastHealth > players.LocalPlayer.Character.Humanoid.Health then
			DamageEffect(lastHealth/players.LocalPlayer.Character.Humanoid.MaxHealth, (lastHealth-players.LocalPlayer.Character.Humanoid.Health)/players.LocalPlayer.Character.Humanoid.MaxHealth, lastHealth-players.LocalPlayer.Character.Humanoid.Health)
		end
		lastHealth = players.LocalPlayer.Character.Humanoid.Health
	end
	-- Update other stuff in UI
	if players.LocalPlayer.Stats.Rank.Value >= rankCap.Value then
		rankLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
	else
		rankLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
	if players.LocalPlayer.Stats.Mana.Value >= GetManaCap() then
		manaLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
	else
		manaLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
	rankLabel.Text = players.LocalPlayer.Stats.Rank.Value
	goldLabel.Text = players.LocalPlayer.Stats.Gold.Value
	arrowsLabel.Text = players.LocalPlayer.Stats.Arrows.Value
	manaLabel.Text = players.LocalPlayer.Stats.Mana.Value
	rankBar.Parent.Label.Text = players.LocalPlayer.Stats.XP.Value .. "/" .. replicatedStorage.ServerSettings.XPPerRank.Value * players.LocalPlayer.Stats.Rank.Value .. " XP"
	rankBar.Position = UDim2.new((players.LocalPlayer.Stats.XP.Value / (replicatedStorage.ServerSettings.XPPerRank.Value * players.LocalPlayer.Stats.Rank.Value)) - 1, 0, 0, 0)
	rankBar.Fill.Position = UDim2.new(1 - players.LocalPlayer.Stats.XP.Value / (replicatedStorage.ServerSettings.XPPerRank.Value * players.LocalPlayer.Stats.Rank.Value), 0, 0, 0)
end)