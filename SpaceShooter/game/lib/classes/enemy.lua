local system = require "system"
local filters = require "game.lib.helpers.filters"
local laser = require "game.lib.helpers.laserFacade"

local E = {}
--local fireTimer

function E.new (posX, posY, speed, color)
  local enemy = display.newImageRect("game/assets/img/enemy/enemy_"..color..".png", 47, 34)
  enemy.lives = 2
  enemy.active = true
  enemy.x, enemy.y = posX, posY - 100
  physics.addBody( enemy, "kinematic", {isSensor=true, filter = obstacleColFilter})
  enemy.myName = "enemy"
  enemy:setLinearVelocity(math.random(-20, 20), math.random(5, 15)+speed)

  function enemy:fire()
        audio.play("game.assets.sfx_laser2.ogg")
        local tmp_laser = laser.newLaser("red")
        tmp_laser.x = self.x
        tmp_laser.y = self.y
        --tmp_laser:toBack()
        transition.to( tmp_laser, { y=math.random(500, 800), time= (math.random(9, 15) * 100),
          onComplete = function() display.remove( tmp_laser ) end
        })
    end

    enemy.fireTimer = timer.performWithDelay( (math.random(15, 25) * 100), function() enemy:fire() end , 0)

    function enemy:hit()
      self.lives = self.lives - 1
      if self.lives <= 0 then
        self.active = false
      end
    end

    function enemy:destroy()
      timer.cancel(self.fireTimer)
    end

  return enemy
end

function E.dispose()
  package.loaded.laser = nil
end

return E
