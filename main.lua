--
-- Abstract: Storyboard Sample
--
-- Version: 1.0
-- 
--
--

-- hide device status bar
display.setStatusBar( display.HiddenStatusBar )



-- require controller module
local storyboard = require "storyboard"

-- load first scene
storyboard.gotoScene( "main-menu", "fade", 400 )