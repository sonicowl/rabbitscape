----------------------------------------------------------------------------------
--
-- scenetemplate.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
require("ui")

_W = display.contentWidth;
_H = display.contentHeight;
_VW = display.viewableContentWidth
_VH = display.viewableContentHeight
_VH0 = (_H-_VH)/2
_VW0 = (_W-_VW)/2
GAMEBOX_FRAME_W = _VW 
GAMEBOX_FRAME_H = _VW*1.3
GAMEBOX_FRAME_W0 = (_W-GAMEBOX_FRAME_W)/2
GAMEBOX_FRAME_H0 = (_H-GAMEBOX_FRAME_H)/2
----------------------------------------------------------------------------------
-- 
--	NOTE:
--	
--	Code outside of listener functions (below) will only be executed once,
--	unless storyboard.removeScene() is called.
-- 
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	

	
	but1handler = function( event )
		if event.phase == "release"  then
			storyboard.gotoScene( "levelsList", "slideLeft", 400 )
		end
	end
	
	but2handler = function( event )
		if event.phase == "release"  then
			storyboard.gotoScene( "levelsList2", "slideLeft", 400 )
		end
	end

	local bg = display.newImageRect("carbonfiber.jpg",_VW,_VH)
	bg.x = _W/2
	bg.y = _H/2
	group:insert(bg)
	
	gameButton = ui.newButton{
		default = "buttonYellow.png",
		over = "buttonYellowOver.png",
		onEvent = but2handler,
		text = "PLAY GAME",
		textColor = { 51, 51, 51, 255 },
		emboss = true,
		size = 22
	}
	gameButton.x = display.contentWidth/2
	gameButton.y = display.contentHeight/2-100
	gameButton.xScale = 2
	gameButton.yScale = 2
	
	group:insert(gameButton)
	

	lvlBuilderButton = ui.newButton{
		default = "buttonYellow.png",
		over = "buttonYellowOver.png",
		onEvent = but1handler,
		text = "LEVEL BUILDER",
		textColor = { 51, 51, 51, 255 },
		emboss = true,
		size = 22
	}
	lvlBuilderButton.x = display.contentWidth/2
	lvlBuilderButton.y = display.contentHeight/2+100
	lvlBuilderButton.xScale = 2
	lvlBuilderButton.yScale = 2
	
	group:insert(lvlBuilderButton)
	
	
	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
		
	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	
	-----------------------------------------------------------------------------
	
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
	
	-----------------------------------------------------------------------------
	
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. remove listeners, widgets, save state, etc.)
	
	-----------------------------------------------------------------------------
	
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------

return scene