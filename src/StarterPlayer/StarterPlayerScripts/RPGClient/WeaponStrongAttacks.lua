local players = game:GetService("Players")
local updateEnvironment = script.Parent:WaitForChild("UpdateEnvironment")
local animationSystem = require(script.Parent:WaitForChild("GetHumanoid"))():WaitForChild("AnimationSystem")
local module = {}

function module.Sword(tool)
	require(updateEnvironment).PlaySoundInCharacter(tool.UseSound2.Value)
	workspace.Remotes.UseItem:FireServer()
	require(animationSystem).PlayAnimation(tool.UseAnimation2.Value.Name)
	if tool.Name == "Lightning Sword" then -- Lightning effect :O
		local effect = tool.Handle.Effect.LightningEffect:Clone()
		effect.Parent = tool.Handle.Effect
		effect.Enabled = true
		game:GetService("Debris"):AddItem(effect, 0.5)
		require(updateEnvironment).PlaySoundInCharacter("Lightning")
	end
	wait(tool.Cooldown2.Value)
end

-- there's plenty of room for more

return module