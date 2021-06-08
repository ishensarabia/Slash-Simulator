function OnClicked()
if script.Value.Value == false then
script.Value.Value = true
for i = 1,16 do
script.Parent.CFrame = script.Parent.CFrame * CFrame.new(0, -0.1, 0) * CFrame.fromEulerAnglesXYZ(0.1, 0, 0) 
wait(0.01) 
end
else	
if script.Value.Value == true then
script.Value.Value = false
for i = 1,16 do
script.Parent.CFrame = script.Parent.CFrame * CFrame.fromEulerAnglesXYZ(-0.1, 0, 0)  * CFrame.new(0, 0.1, 0) 
wait(0.01) 	
end
end
end
end
script.Parent.ClickDetector.MouseClick:connect(OnClicked)