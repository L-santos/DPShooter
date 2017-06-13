local system = require "system"
local filters = require "game.lib.helpers.filters"

local I = {}

function I.new(posX, posY, speed)
	local item = display.newImageRect("game/assets/img/items/star.png", 30, 30)
	item.active = true
	item.type = "powerUp"
	item.x, item.y = posX, posY
	physics.addBody( item, "kinematic", {isSensor=true, filter = powerUpColFilter})
  	item.myName = "star"
  	item:setLinearVelocity(math.random(-20, 20), math.random(5, 15)+speed)

	function item:hit()
		self.active = false
	end

	function item:destroy()

	end

	return item
end

return I