local system = require "system"
local filters = require "game.lib.helpers.filters"

local A = {}

function A.new (posX, posY, speed, color)
  local asteroid = display.newImageRect("game/assets/img/meteor/meteor_"..color..".png", 40, 40)
  asteroid.active = true
  asteroid.x, asteroid.y = posX, posY
  asteroid.type = METEOR_MYNAME
  physics.addBody( asteroid, "kinematic", {isSensor=true, filter = obstacleColFilter})
  asteroid.myName = "asteroid"
  asteroid:setLinearVelocity(math.random(-20, 20), math.random(10, 30)+(speed*2))
  asteroid:applyTorque(math.random(-10, 10))

  function asteroid:destroy()

  end

  function asteroid:hit()
    self.active = false
  end

  return asteroid
end

return A
