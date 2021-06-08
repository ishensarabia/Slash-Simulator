local sfx = game:GetService("SoundService"):WaitForChild("SFX")

return function(soundEffectName, speed, inPart)
	local soundEffect = sfx:FindFirstChild(soundEffectName)
	if soundEffect then
		if inPart then
			local newSound = soundEffect:Clone()
			if speed then
				newSound.PlaybackSpeed = speed
			end
			newSound.Parent = inPart
			newSound.Playing = true
			game:GetService("Debris"):AddItem(newSound, newSound.TimeLength + 1)
		else
			if speed then
				soundEffect.PlaybackSpeed = speed
			end
			soundEffect:Play()
		end
	else
		warn('Tried to play sound effect "' .. soundEffectName .. '" but failed to find sound object in SFX')
	end
end