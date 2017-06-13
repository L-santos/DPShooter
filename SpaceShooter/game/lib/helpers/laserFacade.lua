local laser = require "game.lib.classes.laser"
local L = {}


local laserGroup

function L.setGroup(groupName)
	laserGroup = groupName
end

function L.newLaser(color)
	return laser.new(color, laserGroup)
end

return L

