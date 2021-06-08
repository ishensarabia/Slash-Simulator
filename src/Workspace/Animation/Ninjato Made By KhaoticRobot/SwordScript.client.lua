-------- OMG HAX

r = game:service("RunService")


local damage = 100


local slash_damage = 100


sword = script.Parent.Handle
Tool = script.Parent


local SlashSound = Instance.new("Sound")
SlashSound.SoundId = "http://www.roblox.com/asset/?id=28104389"
SlashSound.Parent = sword
SlashSound.Volume = .5

local secondSlashSound = Instance.new("Sound")
secondSlashSound.SoundId = "http://www.roblox.com/asset/?id=28104543"
secondSlashSound.Parent = sword
secondSlashSound.Volume = 1

local debounce = false
function blow(hit)
	local humanoid = hit.Parent:findFirstChild("Humanoid")
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	local hum = vCharacter:findFirstChild("Humanoid") -- non-nil if tool held by a character
	if humanoid~=nil and humanoid ~= hum and hum ~= nil then
	-- final check, make sure sword is in-hand
	if debounce == false then
		debounce = true
		local right_arm = vCharacter:FindFirstChild("Right Arm")
		if (right_arm ~= nil) then
			local joint = right_arm:FindFirstChild("RightGrip")
			if (joint ~= nil and (joint.Part0 == sword or joint.Part1 == sword)) then
				tagHumanoid(humanoid, vPlayer)
					zomghit = 4
					humanoid:TakeDamage(zomghit)
				untagHumanoid(humanoid)
			end
		debounce = false
		end
	end


	end
end


function tagHumanoid(humanoid, player)
	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = player
	creator_tag.Name = "creator"
	creator_tag.Parent = humanoid
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then
		local tag = humanoid:findFirstChild("creator")
		if tag ~= nil then
			tag.Parent = nil
		end
	end
end


function attack()
	damage = slash_damage
	SlashSound:play()
	local vCharacter = Tool.Parent
	local hum = vCharacter:findFirstChild("Humanoid")
	blah = hum:LoadAnimation(script.Parent.Slash)
	blah:Play()
	hum.WalkSpeed = 23
	wait(.8)
	secondSlashSound:play()
	wait(.8)
	hum.WalkSpeed = 23
end

Tool.Enabled = true

function onActivated()

	if not Tool.Enabled then
		return
	end

	Tool.Enabled = false

	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	attack()

	wait(.2)

	Tool.Enabled = true
end


function onEquipped()
	if Tool.Handle.UnsheathSound.isPlaying == false then
		Tool.Handle.UnsheathSound:play()
	end
end

function onUnequipped()

	Tool.Handle.UnsheathSound:stop()

end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)

connection = sword.Touched:connect(blow)


