on=true

function click()
if on then
script.Parent.ClickLight.CFrame=script.Parent.Back.CFrame*CFrame.new(-0.025,-0.025,0)*CFrame.Angles(math.rad(0),math.rad(0),math.rad(-20))
else
script.Parent.ClickLight.CFrame=script.Parent.Back.CFrame*CFrame.new(0.025,-0.025,0)*CFrame.Angles(math.rad(0),math.rad(0),math.rad(20))
end
on=not on
end

script.Parent.ClickLight.ClickDetector.MouseClick:connect(click)
