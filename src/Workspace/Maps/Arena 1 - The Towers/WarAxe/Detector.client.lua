script.Parent.Unequipped:Connect(function()
	script.Parent.LocalScript.Disabled = true
end)

script.Parent.Equipped:Connect(function()
	script.Parent.LocalScript.Disabled = false
end)
