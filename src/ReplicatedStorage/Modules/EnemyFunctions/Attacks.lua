local players = game:GetService("Players")
local enemyFunctions = require(script.Parent)
local attacks = {}

function attacks.Regular(enemy) -- Feel free to add more and make use of the EnemyFunctions module
	local player = enemyFunctions.FindClosestPlayer(enemy)
	if player then
		require(enemy.EnemyHumanoid.AnimationSystem).PlayAnimation("R6Attack")
		player.Character.Humanoid:TakeDamage(enemyFunctions.CalculatePlayerDamage(player, enemy.Stats.MinimumDamage.Value, enemy.Stats.MaximumDamage.Value))
	end
end

function attacks.Archer(enemy)
	local player = enemyFunctions.FindClosestPlayer(enemy)
	if player then
		require(enemy.EnemyHumanoid.AnimationSystem).PlayAnimation("R6BowShoot")
		enemy.EnemyHumanoid.AutoRotate = false
		enemy.HumanoidRootPart.CFrame = CFrame.new(enemy.HumanoidRootPart.Position, Vector3.new(player.Character.HumanoidRootPart.Position.X, enemy.HumanoidRootPart.Position.Y, player.Character.HumanoidRootPart.Position.Z))
		wait(0.4)
		enemy.HumanoidRootPart.Ability.Playing = true
		enemy.HumanoidRootPart.Beam.Enabled = true
		enemy.HumanoidRootPart.Beam.Width0 = 0.3
		enemy.HumanoidRootPart.Beam.Width1 = 0.3
		game:GetService("TweenService"):Create(enemy.HumanoidRootPart.Beam, TweenInfo.new(0.4), {Width0 = 0, Width1 = 0}):Play()
		local ray = Ray.new(enemy.HumanoidRootPart.Position, (player.Character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).unit * enemy.Stats.AttackRange.Value)
		local hit = workspace:FindPartOnRayWithWhitelist(ray, enemyFunctions.GetAllPlayerCharacters())
		if hit and hit:IsDescendantOf(player.Character) then
			player.Character.Humanoid:TakeDamage(enemyFunctions.CalculatePlayerDamage(player, enemy.Stats.MinimumDamage.Value, enemy.Stats.MaximumDamage.Value))
		end
		wait(0.4)
		enemy.EnemyHumanoid.AutoRotate = true
		enemy.HumanoidRootPart.Beam.Enabled = false
	end
end

function attacks.FireMage(enemy)
	local player = enemyFunctions.FindClosestPlayer(enemy)
	if player then
		require(enemy.EnemyHumanoid.AnimationSystem).PlayAnimation("R6StaffUse")
		local walkSpeed = enemy.EnemyHumanoid.WalkSpeed
		enemy.EnemyHumanoid.WalkSpeed = 0
		enemy.EnemyHumanoid.AutoRotate = false
		enemy.HumanoidRootPart.Fire.Enabled = true
		enemy.HumanoidRootPart.Ability.Playing = true
		enemy.HumanoidRootPart.CFrame = CFrame.new(enemy.HumanoidRootPart.Position, Vector3.new(player.Character.HumanoidRootPart.Position.X, enemy.HumanoidRootPart.Position.Y, player.Character.HumanoidRootPart.Position.Z))
		for _ = 1,5 do
			wait(0.2)
			for _,player in pairs(enemyFunctions.FindPlayersInRadius(enemy.HumanoidRootPart.Position + (enemy.HumanoidRootPart.CFrame.LookVector * 6), 10) or {}) do
				player.Character.Humanoid:TakeDamage(enemyFunctions.CalculatePlayerDamage(player, enemy.Stats.MinimumDamage.Value, enemy.Stats.MaximumDamage.Value))
			end
		end
		enemy.EnemyHumanoid.WalkSpeed = walkSpeed
		enemy.EnemyHumanoid.AutoRotate = true
		enemy.HumanoidRootPart.Fire.Enabled = false
	end
end

function attacks.SandElemental(enemy)
	local player = enemyFunctions.FindClosestPlayer(enemy)
	if player then
		local walkSpeed = enemy.EnemyHumanoid.WalkSpeed
		enemy.EnemyHumanoid.WalkSpeed = 0
		require(enemy.EnemyHumanoid.AnimationSystem).PlayAnimation("R6SandElementalSpin")
		enemy.HumanoidRootPart.Circle1.Enabled = true
		enemy.HumanoidRootPart.Circle2.Enabled = true
		enemy.HumanoidRootPart.Beam1.Enabled = true
		enemy.HumanoidRootPart.Beam2.Enabled = true
		enemy.HumanoidRootPart.Beam3.Enabled = true
		enemy.HumanoidRootPart.Ability.Playing = true
		for _ = 1,8 do
			if enemy:FindFirstChild("HumanoidRootPart") then
				for i = 1,3 do
					local ray = Ray.new(enemy.HumanoidRootPart.Position, (enemy.Torso["Orb" .. i].WorldPosition - enemy.HumanoidRootPart.Position).unit * 15)
					local hit = workspace:FindPartOnRayWithWhitelist(ray, enemyFunctions.GetAllPlayerCharacters())
					if hit then
						if hit.Parent:FindFirstChild("Humanoid") then
							hit = hit.Parent
						elseif hit.Parent.Parent:FindFirstChild("Humanoid") then
							hit = hit.Parent.Parent
						elseif hit.Parent.Parent.Parent:FindFirstChild("Humanoid") then
							hit = hit.Parent.Parent.Parent
						else
							hit = nil
						end
						if hit and players:FindFirstChild(hit.Name) then
							hit.Humanoid:TakeDamage(enemyFunctions.CalculatePlayerDamage(players[hit.Name], enemy.Stats.MinimumDamage.Value, enemy.Stats.MaximumDamage.Value))
						end
					end
				end
				wait(0.25)
			else
				break
			end
		end
		if enemy:FindFirstChild("HumanoidRootPart") then
			enemy.HumanoidRootPart.Circle1.Enabled = false
			enemy.HumanoidRootPart.Circle2.Enabled = false
			enemy.HumanoidRootPart.Beam1.Enabled = false
			enemy.HumanoidRootPart.Beam2.Enabled = false
			enemy.HumanoidRootPart.Beam3.Enabled = false
		end
		if enemy:FindFirstChild("EnemyHumanoid") then
			enemy.EnemyHumanoid.WalkSpeed = walkSpeed
		end
	end
end

function attacks.LavaBoss(enemy)
	local players = enemyFunctions.FindPlayersInRadius(enemy.HumanoidRootPart.Position, 20)
	if players then
		local attack = math.random(1,2)
		if attack == 1 then
			local walkSpeed = enemy.EnemyHumanoid.WalkSpeed
			enemy.EnemyHumanoid.WalkSpeed = 0
			require(enemy.EnemyHumanoid.AnimationSystem).PlayAnimation("R6Slam")
			wait(0.7)
			for _,player in pairs(enemyFunctions.FindPlayersInRadius(enemy.HumanoidRootPart.Position, 15) or {}) do
				player.Character.Humanoid:TakeDamage(enemyFunctions.CalculatePlayerDamage(player, enemy.Stats.MinimumDamage.Value, enemy.Stats.MaximumDamage.Value))
			end
			if enemy:FindFirstChild("HumanoidRootPart") then
				enemy.HumanoidRootPart.Slam.Playing = true
			end
			wait(1)
			if enemy:FindFirstChild("EnemyHumanoid") then
				enemy.EnemyHumanoid.WalkSpeed = walkSpeed
			end
		elseif attack == 2 then
			local walkSpeed = enemy.EnemyHumanoid.WalkSpeed
			enemy.EnemyHumanoid.WalkSpeed = 0
			require(enemy.EnemyHumanoid.AnimationSystem).PlayAnimation("R6FireBreath")
			wait(0.5)
			if enemy:FindFirstChild("Head") then
				enemy.Head.Effect.Fire.Enabled = true
			end
			if enemy:FindFirstChild("HumanoidRootPart") then
				enemy.HumanoidRootPart.Fire.Playing = true
			end
			for _ = 1,5 do
				if enemy:FindFirstChild("HumanoidRootPart") then
					for _,player in pairs(enemyFunctions.FindPlayersInRadius(enemy.HumanoidRootPart.Position + (enemy.HumanoidRootPart.CFrame.LookVector * 10), 10) or {}) do
						player.Character.Humanoid:TakeDamage(enemyFunctions.CalculatePlayerDamage(player, enemy.Stats.MinimumDamage.Value, enemy.Stats.MaximumDamage.Value))
					end
					wait(0.2)
				else
					break
				end
			end
			if enemy:FindFirstChild("Head") then
				enemy.Head.Effect.Fire.Enabled = false
			end
			wait(0.5)
			if enemy:FindFirstChild("EnemyHumanoid") then
				enemy.EnemyHumanoid.WalkSpeed = walkSpeed
			end
		end
	end
end

--[[ Psst! If you want to use a space in the name of a function, here's an example of how you could do that:

attacks["Cool Enemy"] = function()
	-- cool code here
end

]]

return attacks