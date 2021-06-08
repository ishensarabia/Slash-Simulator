function onSit(hit)
	wait(.3)
	script.Parent.Parent.Water.BrickColor = BrickColor.new(226)
end
script.Parent.Touched:connect(onSit)