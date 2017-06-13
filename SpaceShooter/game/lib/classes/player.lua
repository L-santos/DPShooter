local system = require "system"
local laser = require "game.lib.helpers.laserFacade"
local filters = require "game.lib.helpers.filters"

local S = {}
local colors = {"red", "blue", "orange", "green"}

function S.new()
  local color = math.random(1, #colors)
  print(colors[color])
  local box = {
    halfWidth = 7,
    halfHeight = 10,
    x = 6
  }
  local ship = display.newImageRect("game/assets/img/player/player_"..colors[math.random(1, #colors)]..".png", 39, 31)
  local lifeChanged = { name="lifeChanged", target=ship }
  ship.x, ship.y = display.contentCenterX, display.contentCenterY + 180
  physics.addBody( ship, {isSensor=true, filter = playerColFilter, box = box})
  ship.myName = "ship"
  ship.lives = 3
  ship.active = true
  ship.invencible = false

  ship.shipShield = display.newImageRect("game/assets/img/items/shield_eff.png", 55, 55)
  ship.shipShield.x, ship.shipShield.y, ship.shipShield.isVisible = ship.x, ship.y, false

  function ship:moveLeft (event)
    if event.phase == "began" then
      transition.to( ship, {x = 0, time = 1000, tag="moveLeft"})
      transition.to( self.shipShield, {x = 0, time = 1000, tag="moveLeft"})
    elseif event.phase == "ended" then
      transition.cancel("moveLeft")
    end
    return true
  end

  function ship:moveRigth(event)
    if event.phase == "began" then
      transition.to( ship, {x = display.contentWidth, time = 1000, tag="moveRigth"})
      transition.to( self.shipShield, {x = display.contentWidth, time = 1000, tag="moveRigth"})
    elseif event.phase == "ended" then
      transition.cancel("moveRigth")
    end
    return true
  end

  function ship:fire()
  	  audio.play("game/assets/sfx/sfx_laser1.ogg")
      local tmp_laser = laser.newLaser("blue")
      tmp_laser.x = self.x 
      tmp_laser.y = self.y
    	transition.to( tmp_laser, { y=-40, time=500,
    		onComplete = function() display.remove( tmp_laser ) end
    	} )
    return true
  end

  function ship:destroy()
    print("player destroyed")
  end

  function ship:addLife()
    if(self.lives <= 9) then
      self.lives = self.lives + 1
      ship:dispatchEvent(lifeChanged)
    end
  end
  function ship:hit()
    if (self.invencible == false) then
      self.lives = self.lives - 1
      ship:dispatchEvent(lifeChanged)
      print("Player: "..self.lives)
      if self.lives <= 0 then
        self.active = false
      end
    end
  end
  return ship
end

return S
