-- this script just puts the animator in the humanoid

local modules = game:GetService("ReplicatedStorage"):WaitForChild("Modules", 5)
local humanoid = script.Parent:WaitForChild("Humanoid", 5)
if modules and humanoid then
	local animator = modules:WaitForChild("AnimationSystem", 5)
	if animator then
		animator:Clone().Parent = humanoid
		wait(1)
		script:Destroy()
	end
end