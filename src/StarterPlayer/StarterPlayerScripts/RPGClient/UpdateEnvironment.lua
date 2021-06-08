local players = game:GetService("Players")
local lighting = game:GetService("Lighting")
local replicatedStorage = game:GetService("ReplicatedStorage")
local serverSettings = replicatedStorage:WaitForChild("ServerSettings")
local playSoundEffect = replicatedStorage:WaitForChild("Modules"):WaitForChild("PlaySoundEffect")
local music = game:GetService("SoundService"):WaitForChild("Music")
local defaultMusicVolume = music.Volume
local unloadedAreas = replicatedStorage:WaitForChild("UnloadedAreas")
local gameUI = players.LocalPlayer.PlayerGui:WaitForChild("GameUI")
local module = {}

function module.PlaySoundInCharacter(soundName)
	if players.LocalPlayer.Character and players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		require(playSoundEffect)(soundName, math.random(70,130) / 100, players.LocalPlayer.Character.HumanoidRootPart)
	end
end

function module.PlaySong(songName)
	game:GetService("TweenService"):Create(music, TweenInfo.new(0.5), {Volume = 0}):Play()
	wait(0.5)
	for _,song in pairs(music:GetChildren()) do
		if song.Playing == true then
			song.Playing = false
		end
	end
	local songToPlay = music:FindFirstChild(songName)
	if songToPlay then
		songToPlay.TimePosition = 0
		songToPlay.Playing = true
		game:GetService("TweenService"):Create(music, TweenInfo.new(0.5), {Volume = defaultMusicVolume}):Play()
		return true
	end
end

function module.LoadArea(areaName)
	local area = workspace.Areas:FindFirstChild(areaName)
	if not area then
		area = unloadedAreas:FindFirstChild(areaName)
	end
	game:GetService("TweenService"):Create(gameUI.Fade, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
	require(playSoundEffect)("MenuClose")
	wait(0.5)
	local humanoidRootPart = nil
	if players.LocalPlayer.Character then
		humanoidRootPart = players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	end
	if area then
		if humanoidRootPart then
			humanoidRootPart.Anchored = true
		end
		if area:FindFirstChild("SpawnRegions") then -- these get in the way of the mouse and throw off raycasts
			area.SpawnRegions:Destroy()
		end
		if serverSettings.UnloadAreas.Value == true then
			for _,otherArea in pairs(workspace.Areas:GetChildren()) do
				if otherArea ~= area then
					otherArea.Parent = unloadedAreas
				end
			end
		end
		if area.Parent == unloadedAreas then
			area.Parent = workspace.Areas
		end
		local playingSong = module.PlaySong(area.Music.Value)
		if not playingSong then
			warn("No music found for " .. area.Name)
		end
		lighting.OutdoorAmbient = area.LightingSettings.OutdoorAmbient.Value
		lighting.Ambient = area.LightingSettings.Ambient.Value
		lighting.FogColor = area.LightingSettings.FogColor.Value
		lighting.ColorShift_Bottom = area.LightingSettings.ColorShift_Bottom.Value
		lighting.ColorShift_Top = area.LightingSettings.ColorShift_Top.Value
		lighting.FogStart = area.LightingSettings.FogStart.Value
		lighting.FogEnd = area.LightingSettings.FogEnd.Value
		lighting.ColorCorrection.Brightness = area.LightingSettings.ColorCorrection.Brightness.Value
		lighting.ColorCorrection.Contrast = area.LightingSettings.ColorCorrection.Contrast.Value
		lighting.ColorCorrection.Saturation = area.LightingSettings.ColorCorrection.Saturation.Value
		lighting.ColorCorrection.TintColor = area.LightingSettings.ColorCorrection.TintColor.Value
	else
		warn('Tried to load area "' .. areaName .. '" but failed to find area in the Areas folder')
	end
	wait(0.5)
	if area and humanoidRootPart then
		humanoidRootPart.Anchored = false
		humanoidRootPart.CFrame = area.Spawn.CFrame + Vector3.new(0, 3, 0)
	end
	require(playSoundEffect)("MenuOpen")
	game:GetService("TweenService"):Create(gameUI.Fade, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
end

return module