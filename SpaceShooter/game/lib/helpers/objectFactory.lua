local system = require "system"
local filters = require "game.lib.helpers.filters"
local enemy = require "game.lib.classes.enemy"
local asteroid = require "game.lib.classes.asteroid"
local bolt = require "game.lib.classes.items.bolt"
local pill = require "game.lib.classes.items.pill"
local shield = require "game.lib.classes.items.shield"
local star = require "game.lib.classes.items.star"


local O = {}

local powerUpLock --bloqueia powerups
local enemyShipCount
local objCount 
local MAX_OBJECTS --Número máximo de objetos que podem estar na tela ao mesmo tempo
local MAX_ENEMY_SHIP 
local MIN_POWERUP_SPAWN_INTERVAL
local MAX_POWERUP_SPAWN_INTERVAL
local spawnArea
local ship_colors
local meteor_colors

function O.init()
 powerUpLock = false --bloqueia powerups
 enemyShipCount = 0
 objCount = 0
 MAX_OBJECTS = 15 --Número máximo de objetos que podem estar na tela ao mesmo tempo
 MAX_ENEMY_SHIP = 2
 MIN_POWERUP_SPAWN_INTERVAL = 12000
 MAX_POWERUP_SPAWN_INTERVAL = 30000
end

function O.new(speed)
  ship_colors = {"red", "grey", "red"}
  meteor_colors = {"brown", "grey"}
  return newObject(speed)
end

function O.removeObjectCount (ammount, ammount_enemy) -- numero a ser removido do contador de objetos
  objCount = objCount + ammount
  enemyShipCount = enemyShipCount + ammount_enemy
end

function setSpawnPos ()
  -- sorteia pos.x do objeto
    local lastSpawnArea = spawnArea
    spawnArea = math.random(1, 3)
    if spawnArea == lastSpawnArea then spawnArea = spawnArea + 1 end

    local spawnPos
    if(spawnArea == 1 or spawnArea == 4) then --caso o 3 esteja repetido sera adicionado 1 no spawnArea
      spawnPos = math.random(10, display.contentCenterX - 45)
    elseif(spawnArea == 2) then
      spawnPos = display.contentCenterX
    else
      spawnPos = math.random(display.contentCenterX + 50, display.contentWidth - 5)
    end
    return spawnPos
end

function newObject(speed)
  local nextObj = math.random(0, 100) -- random do próximo objeto a aparecer na tela
  local obj = false
  -- Lógica simples para seleção de objetos
  if(nextObj > 34 and nextObj < 49 and powerUpLock == false) then
    --if(nextObj > 1 and nextObj < 100) then --teste
  
  --   -- adiciona um powerUp
    local tmp = math.random(0, 9)
    local spawnX = setSpawnPos()

    if (tmp < 4) then
      --spawn Shield
      obj = shield.new(spawnX, -70, speed)
    elseif (tmp >= 4 and tmp < 7) then
      --spawn Bolt
      obj = bolt.new(spawnX, -70, speed)
    else
        --spawn pill
        obj = pill.new(spawnX, -70, speed)
    end
    powerUpLock = true
    -- determina o tempo para a aparição do próximo powerUp
    powerUpTimer = timer.performWithDelay( math.random(MIN_POWERUP_SPAWN_INTERVAL, MAX_POWERUP_SPAWN_INTERVAL), function()
      powerUpLock = false
    end ,1 )
  --elseif(nextObj > 50 and nextObj < 65) then
    --obj = star.new(spawnX, -70, speed)
  elseif objCount <= MAX_OBJECTS then
    --- logica para adicionar meteoros/Inimigos
    local tmp = math.random(0, 5)
    local spawnX = setSpawnPos()
    if(tmp <= 2 and enemyShipCount <= MAX_ENEMY_SHIP) then
      local color = math.random(1, #ship_colors)
      obj = enemy.new(spawnX, 40, speed, ship_colors[color])
      enemyShipCount = enemyShipCount + 1
    else
      local color = math.random(1, #meteor_colors)
      obj = asteroid.new(spawnX, -60, speed, meteor_colors[color])
    end
    objCount = objCount + 1
  end
  return obj
end

return O


--- logica para seleção do proximo objeto ---
--[[
  Tipos de objetos:
    ----Inimigos 55%
    *Naves - se movem e atiram contra o jogador
    *Meteoro - estático

    ----PowerUps 15%
    *Shield - deixa o jogador imune por x segundos
    *Pills - adicionam vida ao jogador
    *Bolt - destroi todos os objetos na tela

    -----Outros 30%
    *Estrelas - Aumentam os pontos do jogador
]]
