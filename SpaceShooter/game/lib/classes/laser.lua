local system = require "system"
local filters = require "game.lib.helpers.filters"

local L = {}

function L.new (color, group)
  --print("Laser ".. caller)
  local laser
  if color == "blue" then
    laser = display.newImageRect(group, "game/assets/img/lasers/laserBlue.png", 10, 33)
    physics.addBody( laser, "dynamic", { isSensor=true, filter = playerLaserColFilter } )
    laser.myName =  "playerLaser"
  elseif color == "red" then
    laser = display.newImageRect(group, "game/assets/img/lasers/laserRed.png", 10, 33)
    physics.addBody( laser, "dynamic", { isSensor=true, filter = botLaserColFilter } )
    laser.myName = "botLaser"
  end
  --laser:toBack()
  --laser.x, laser.y, laser.isBullet  = x, y, true

  function laser:hit()
    laser:removeSelf()
  end

  return laser
end

return L
