-- this script makes keeping track of loaded animations easy; goes inside of humanoids

local loadedAnimations = {}
local module = {}

function module.StopAnimation(animationName)
	local animation = loadedAnimations[animationName]
	if animation then
		animation:Stop()
	end
end

function module.PlayAnimation(animationName)
	local animation = loadedAnimations[animationName]
	if animation then
		if animation.IsPlaying == false then
			animation:Play()
		end
	else
		animation = game:GetService("ReplicatedStorage"):WaitForChild("Animations"):FindFirstChild(animationName)
		if animation then
			animation = script.Parent:LoadAnimation(animation)
			animation:Play()
			loadedAnimations[animationName] = animation
		end
	end
end

return module