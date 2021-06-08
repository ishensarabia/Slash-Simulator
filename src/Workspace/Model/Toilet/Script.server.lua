-- Credit by BrandonSJ96
Blah = true

function Clicked()
if Blah == true then
script.Parent.handle.Button1.Transparency = 1
script.Parent.handle.h.Button2.Transparency = 0
wait(.05)
script.Parent.handle.h.Button2.Transparency = 1
script.Parent.handle.h.Button3.Transparency = 0
wait(.05)
Blah = false
script.Parent.Water.flush:play()
script.Parent.handle.h.Button2.Transparency = 0
script.Parent.handle.h.Button3.Transparency = 1
wait(.05)
script.Parent.handle.Button1.Transparency = 0
script.Parent.handle.h.Button2.Transparency = 1
wait(.05)
script.Parent.Water.Mesh.Scale = Vector3.new(1.7,3.05,2.5)
wait(.1)
script.Parent.Water.Mesh.Scale = Vector3.new(1.7,2.05,2.5)
wait(.1)
script.Parent.Water.Mesh.Scale = Vector3.new(1.7,1.05,2.5)
wait(.1)
script.Parent.Water.Mesh.Scale = Vector3.new(1.7,0.05,2.5)
wait(.1)
script.Parent.Water.Transparency = .25
wait(.1)
script.Parent.Water.Transparency = .3
wait(.1)
script.Parent.Water.Transparency = .35
wait(.1)
script.Parent.Water.Transparency = .4
wait(.1)
script.Parent.Water.Transparency = .45
wait(.1)
script.Parent.Water.Transparency = .5
wait(.1)
script.Parent.Water.Transparency = .55
wait(.1)
script.Parent.Water.Transparency = .6
wait(.1)
script.Parent.Water.Transparency = .65
wait(.1)
script.Parent.Water.Transparency = .7
wait(.1)
script.Parent.Water.Transparency = .75
wait(.1)
script.Parent.Water.Transparency = .8
wait(.1)
script.Parent.Water.Transparency = .85
wait(.1)
script.Parent.Water.Transparency = .9
wait(.1)
script.Parent.Water.Transparency = .95
wait(.1)
script.Parent.Water.Transparency = 1
wait(1)
script.Parent.Water.BrickColor = BrickColor.new("Medium blue")
wait(.2)
script.Parent.Water.Transparency = .95
wait(.2)
script.Parent.Water.Transparency = .9
wait(.2)
script.Parent.Water.Transparency = .85
wait(.2)
script.Parent.Water.Transparency = .8
wait(.2)
script.Parent.Water.Transparency = .75
wait(.2)
script.Parent.Water.Transparency = .7
wait(.2)
script.Parent.Water.Transparency = .65
wait(.2)
script.Parent.Water.Transparency = .6
wait(.2)
script.Parent.Water.Transparency = .55
wait(.2)
script.Parent.Water.Transparency = .5
wait(.2)
script.Parent.Water.Transparency = .45
wait(.2)
script.Parent.Water.Mesh.Scale = Vector3.new(1.7,1.05,2.5)
wait(.1)
script.Parent.Water.Transparency = .4
wait(.2)
script.Parent.Water.Mesh.Scale = Vector3.new(1.7,2.05,2.5)
wait(.1)
script.Parent.Water.Transparency = .35
wait(.2)
script.Parent.Water.Mesh.Scale = Vector3.new(1.7,3.05,2.5)
wait(.1)
script.Parent.Water.Transparency = .3
wait(.2)
script.Parent.Water.Mesh.Scale = Vector3.new(1.7,4.05,2.5)
wait(.1)
script.Parent.Water.Transparency = .25
wait(.2)
script.Parent.Water.Transparency = .2
wait(.2)
Blah = true
end
end

script.Parent.handle.ClickDetector.MouseClick:connect(Clicked)