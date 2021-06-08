local players = game:GetService("Players")
local updateEnvironment = script.Parent:WaitForChild("UpdateEnvironment")
local animationSystem = require(script.Parent:WaitForChild("GetHumanoid"))():WaitForChild("AnimationSystem")
local module = {}

function module.Sword(tool)
	require(animationSystem).PlayAnimation(tool.UseAnimation.Value.Name)
	require(updateEnvironment).PlaySoundInCharacter(tool.UseSound.Value)
	workspace.Remotes.UseItem:FireServer()
	wait(tool.Cooldown.Value)
end

function module.Bow(tool)
	local arrows = players.LocalPlayer.Stats.Arrows.Value
	workspace.Remotes.UseItem:FireServer(players.LocalPlayer:GetMouse().Hit.Position)
	if arrows > 0 then
		require(updateEnvironment).PlaySoundInCharacter(tool.UseSound.Value)
		tool.Handle.Effect.ShootEffect:Emit(5)
		require(animationSystem).PlayAnimation(tool.UseAnimation.Value.Name)
		wait(tool.Cooldown.Value)
	end
end

function module.Staff(tool)
	local mana = players.LocalPlayer.Stats.Mana.Value
	local cost = tool:FindFirstChild("ManaCost")
	workspace.Remotes.UseItem:FireServer(players.LocalPlayer:GetMouse().Hit.Position)
	if not cost or cost and mana >= cost.Value then
		require(updateEnvironment).PlaySoundInCharacter(tool.UseSound.Value)
		tool.Handle.Effect.ShootEffect:Emit(5)
		local effect = Instance.new("Part")
		effect.Anchored = true
		effect.Size = Vector3.new(0, 0, 0)
		effect.CanCollide = false
		effect.Transparency = 1
		effect.CFrame = CFrame.new(tool.Handle.Position)
		effect.Parent = workspace
		local fire = tool.Handle.Effect.Fire:Clone()
		fire.Parent = effect
		fire.Enabled = true
		game:GetService("TweenService"):Create(effect, TweenInfo.new(1, Enum.EasingStyle.Linear), {CFrame = CFrame.new(tool.Handle.Position) + CFrame.new(tool.Handle.Position, players.LocalPlayer:GetMouse().Hit.Position).LookVector * 100}):Play()
		game:GetService("Debris"):AddItem(effect, 0.4)
		require(animationSystem).PlayAnimation(tool.UseAnimation.Value.Name)
		wait(tool.Cooldown.Value)
	end
end

function module.HealthPotion(tool)
	require(updateEnvironment).PlaySoundInCharacter("Slurp")
	workspace.Remotes.UseItem:FireServer()
	require(animationSystem).PlayAnimation(tool.UseAnimation.Value.Name)
	wait(2)
end

function module.ManaPotion(tool)
	require(updateEnvironment).PlaySoundInCharacter("Slurp")
	workspace.Remotes.UseItem:FireServer()
	require(animationSystem).PlayAnimation(tool.UseAnimation.Value.Name)
	wait(2)
end

return module