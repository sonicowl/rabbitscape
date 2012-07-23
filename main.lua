--
-- Abstract: Storyboard Sample
--
-- Version: 1.0
-- 
--
--

-- hide device status bar
display.setStatusBar( display.HiddenStatusBar )

io.output():setvbuf('no')

-- require controller module
local storyboard = require "storyboard"

-- load first scene
storyboard.gotoScene( "scene-main", "fade", 400 )