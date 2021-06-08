local isOn = true

function on()
 isOn = true
 script.Parent.Parent.LightLight.PointLight.Enabled = true
end

function off()
 isOn = false
 script.Parent.Parent.LightLight.PointLight.Enabled = false
end

function onClicked()
 
 if isOn == true then off() else on() end

end

script.Parent.ClickDetector.MouseClick:connect(onClicked)

on()















































--[[~-?Somebody121?-~]]--

--I do this to make sure no one copys. :D