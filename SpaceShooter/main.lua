system.activate( "multitouch" )
local composer = require("composer")

display.setStatusBar( display.HiddenStatusBar )

math.randomseed(os.time())

composer.gotoScene("game.scenes.menu")
