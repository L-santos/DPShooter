local composer = require "composer"
local widget = require "widget"
local system = require "system"
local physics = require "physics"
local handler = require "game.lib.helpers.objectFactory"
local filters = require "game.lib.helpers.filters"
local player = require "game.lib.classes.player"
local enemy = require "game.lib.classes.enemy"
local lasers = require "game.lib.helpers.laserFacade"

local scene = composer.newScene()

----- Display Objects -----
local ship
local objectsTable = {} -- armazena todos os display objects
local background = {}

----- Audio -------
local sfx = {}

----- Váriaveis do Game ------
----------- timers ---------------
      local gameLoopTimer
      local difficultTimer
      local playerFireLoop 
------------------------------------
----------- myNames ---------------
local PLAYER_MYNAME = "ship"
local ENEMY_SHIP_MYNAME = "enemy"
local METEOR_MYNAME = "meteor"
local POWER_UP_MYNAME = "powerUp"
local PLAYER_LASER_MYNAME = "playerLaser"
local BOT_LASER_MYNAME = "botLaser"

-------- powerUps pNames -------
local BOLT_PNAME = "bolt"
local PILL_PNAME = "pill"
local SHIELD_PNAME = "shield"
local STAR_MYNAME = "star"

----------- dificuldade --------------
local speed
local start_speed = 25
local spawSpeed 
local INCREASE_DIFFICULT_TIMER
local INCREASE_DIFFICULT_FACTOR
local LASER_SPAWN_INTERVAL

----- UI -----
local points, pointsTxt, livesTxt, btRight, btLeft, collectedStars

local mainGroup, laserGroup, uiGroup, backGroup

local function scroll()
  background[1].y = background[1].y + (speed / 10)
  background[2].y = background[2].y + (speed / 10)
  
  if background[1].y > display.contentHeight then
    background[1]:translate(0, -background[1].contentHeight * 2) 
  end

  if (background[2].y - display.contentHeight/2) > display.actualContentHeight then
    background[2]:translate(0, -background[2].contentHeight * 2) 
  end
end

local function checkObjects()
   for i=#objectsTable,1,-1 do
     if(objectsTable[i] ~= nil) then
      local tmp = objectsTable[i]
      if(tmp.active == false or tmp.y > display.contentHeight or tmp.x < -10 or tmp.x > display.contentWidth + 5) then
        table.remove(objectsTable, i)
        if(tmp.myName == ENEMY_SHIP_MYNAME) then
          handler.removeObjectCount(-1, -1)
        else
          handler.removeObjectCount(-1, 0)
        end
        if tmp.active == false then points = points + 10 end
        tmp:destroy()
        display.remove( tmp )
      end
    end
  end
  if (ship.active == false) then
    audio.play(sfx["sfx_lose"])
    Runtime:removeEventListener("enterFrame", checkObjects)
    timer.cancel( gameLoopTimer )
    timer.cancel(difficultTimer)
    timer.cancel(playerFireLoop)
    package.loaded.handler = nil
    package.loaded.lasers = nil
    display:remove(ship)
    physics:pause()
    for i=#objectsTable,1,-1 do
      objectsTable[i]:destroy()
      display.remove( objectsTable[i] )
    end
    timer.performWithDelay(500, 
      function()
        composer.removeScene( "game.scenes.gameover")
        composer.gotoScene("game.scenes.gameover")
      end
    )
  end
end

local function usePowerUp(powerUp)
  if powerUp.myName == BOLT_PNAME then
    print("bolt")
    audio.play(sfx["sfx_zap"])
    for i in pairs(objectsTable) do
        objectsTable[i].active = false
    end
    powerUp.active = false
  elseif powerUp.myName == SHIELD_PNAME then
      print("shield")
      ship.invencible = true
      ship.shipShield.isVisible = true
      audio.play(sfx["sfx_shieldUp"])
      transition.to(ship, {time = 3000, alpha = 0.3, onComplete = 
        function(_ship)
          transition.to(_ship, {time = 3000, alpha = 1.0})
        end
        })
      timer.performWithDelay(6000, function() 
        ship.invencible, ship.shipShield.isVisible  = false, false 
        audio.play(sfx["sfx_shieldDown"])
        end)
    powerUp.active = false
  elseif powerUp.myName == PILL_PNAME then
      print("pill")
      audio.play(sfx["sfx_zap"])
      ship:addLife()
      powerUp.active = false
  elseif powerUp.myName == STAR_MYNAME then
      print("star")
      audio.play(sfx["sfx_zap"])
      points = points + 50
      if collectedStars >= 50 then ship.lives = ship.lives + 1 end
  end
end

local function onGlobalCollision(event)
  local object1 = event.object1
  local object2 = event.object2
  if(event.phase == "began") then
    if(object1.type == POWER_UP_MYNAME) then
      usePowerUp(object1)
    elseif(object2.type == POWER_UP_MYNAME) then
      usePowerUp(object2)
    else
      object1:hit(object2)
      object2:hit(object1)
    end
  end -- endbegan
end

local function onKeyPressed (event)
  if(event.keyName == "back") then
    composer.gotoScene("menu")
  end
  return true
end
--------
----------
----------- C-O-M-P-O-S-E-R--L-I-F-E-C-Y-C-L-E --------------
function scene:create(event)

  local sceneGroup = self.view
  backGroup = display.newGroup()
  laserGroup = display.newGroup()
  mainGroup = display.newGroup()
  uiGroup = display.newGroup()

  sceneGroup:insert(backGroup)
  sceneGroup:insert(laserGroup)
  sceneGroup:insert(mainGroup)
  sceneGroup:insert(uiGroup)

  physics.start()
  physics.pause()

  collectedStars = 0

  speed = start_speed
  spawSpeed = start_speed * 30
  INCREASE_DIFFICULT_TIMER = spawSpeed * 30
  INCREASE_DIFFICULT_FACTOR = 5
  LASER_SPAWN_INTERVAL = 500
  powerUpLock = false

  ship = player.new()
  mainGroup:insert(ship)

  sfx = {
    shieldDown = audio.loadSound("game/assets/sfx/sfx_shieldDown.ogg"),
    shieldUp = audio.loadSound("game/assets/sfx/sfx_shieldUp.ogg"),
    lose = audio.loadSound("game/assets/sfx/sfx_lose.ogg"),
    zap = audio.loadSound("game/assets/sfx/sfx_zap.ogg")
  }

  points = 0
  pointsTxt = display.newText(uiGroup, "Pontos: 0", display.contentWidth - 50, 80)
  livesTxt = display.newText(uiGroup, "Vidas: 3", display.contentWidth - 50, 100)
  background[1] = display.newImageRect( backGroup, "game/assets/img/backgrounds/back1.png", display.actualContentWidth, display.actualContentHeight )
  background[1].anchorX = 0
  background[1].anchorY = 0
  background[1].x = 0 + display.screenOriginX
  background[1].y = 0 + display.screenOriginY
  background[2] = display.newImageRect( backGroup, "game/assets/img/backgrounds/back1.png", display.actualContentWidth, display.actualContentHeight )
  background[2].anchorX = 0
  background[2].x = 0 + display.screenOriginX
  background[2].y = display.contentCenterY - display.actualContentHeight

  --============== UI =====================
    btLeft = widget.newButton( {
    width = display.contentWidth/2.1,
    height = display.contentHeight/1.1,
    shape = "rect",
    fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
    strokeColor = { default={ 0, 0, 0 }, over={ 0.4, 0.1, 0.2 } }
  } )
  backGroup:insert(btLeft)
  btLeft:toBack()

  btRight = widget.newButton( {
    width = display.contentWidth/2.1,
    height = display.contentHeight/1.1,
    shape = "rect",
    fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
    strokeColor = { default={ 0, 0, 0 }, over={ 0.4, 0.1, 0.2 } }
  } )
  backGroup:insert(btRight)
  btRight:toBack()

  btLeft.y = display.contentCenterY
  btRight.x = display.contentWidth - btRight.contentWidth /2
  btRight.y = display.contentCenterY
  btLeft.alpha = 0.1
  btRight.alpha = 0.1

  btLeft:addEventListener("touch", function(event) ship:moveLeft(event) end)
  btRight:addEventListener("touch", function(event) ship:moveRigth(event) end)
end

function scene:show(event)
  local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then

	elseif phase == "did" then
    handler.init()
    lasers.setGroup(laserGroup)
    physics.start()
    print("physics started")
    physics.setGravity( 0, 0 )

    Runtime:addEventListener("collision", onGlobalCollision)
    Runtime:addEventListener("key", onKeyPressed)
    Runtime:addEventListener("enterFrame", checkObjects)
    Runtime:addEventListener("enterFrame", scroll)

    --- Roda o gameLoop e inicializa timers---
    gameLoopTimer = timer.performWithDelay( spawSpeed,
    function()
      points = points + 1
      pointsTxt.text, livesTxt.text = "Pontos: "..points, "Vidas: "..ship.lives
      local tmp_obj = handler.new(speed)
      if tmp_obj then
        table.insert(objectsTable, tmp_obj)
      else
        print("No obj returned from handler.new()")
      end
    end, 0 )

    difficultTimer = timer.performWithDelay(INCREASE_DIFFICULT_TIMER, function()
      if(speed <= 200) then
        speed = speed + INCREASE_DIFFICULT_FACTOR
      end
      if(spawSpeed > 100) then
        spawSpeed = spawSpeed - 20
      end
      print("speed: "..speed.." spawn: "..spawSpeed)
    end, 0)
    playerFireLoop = timer.performWithDelay( LASER_SPAWN_INTERVAL, function() ship:fire() end, 0 )
    ---
	end
end

function scene:hide( event )
	local sceneGroup = self.view

	local phase = event.phase

	if event.phase == "will" then
    physics.stop()
    audio.stop( laserSound )
    audio.dispose(laserSound)
    audio.stop( stop )
    audio.dispose(enemyLaserSound)
    Runtime:removeEventListener("collision", onGlobalCollision)
    Runtime:removeEventListener("key", onKeyPressed)
    Runtime:removeEventListener("enterFrame", scroll)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end

end

function scene:destroy( event )

	local sceneGroup = self.view

end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
