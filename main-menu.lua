----------------------------------------------------------------------------------
--
-- scenetemplate.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
require("ui")
local dialogsModule = require( "module-dialogs" )

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
hasUpdates = false



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
	lastScene = storyboard.getPrevious()
	print("COMING FROM "..tostring(lastScene))
	dialogsModule.init()

	function checkUpdatedListener(bool)
		if bool then hasUpdates = true end
	end

	local function syncBoxCallback( event )
		if "clicked" == event.action then
			local i = event.index
			if 1 == i then
				jsonLevels.syncLevels(group)
				hasUpdates = false
			else
				sceneDialog = display.newGroup()
				group:insert(sceneDialog)
				dialogsModule.callScenerySelector(sceneDialog,storyboard)
			end
		end
	end

	local function requestSync()
		local alert = native.showAlert("Updates Available", "There are new levels available, do you want to download them now?", 
		{ "OK", "Later" }, syncBoxCallback )
	end
	
	but1handler = function( event )
		if event.phase == "release"  then
			storyboard.gotoScene( "levelsList", "slideLeft", 400 )
		end
	end
	
	but2handler = function( event )
		if event.phase == "release"  then
			--storyboard.gotoScene( "scene-sceneryList", "slideLeft", 400 )
			if hasUpdates then requestSync()
			else
				sceneDialog = display.newGroup()
				group:insert(sceneDialog)
				dialogsModule.callScenerySelector(sceneDialog,storyboard)
			end
		end
	end

	local bg = display.newImageRect("bg1.jpg",_VW,_VH)
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
-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
        local group = self.view
        
        -----------------------------------------------------------------------------
                
        --      This event requires build 2012.782 or later.
        
        -----------------------------------------------------------------------------
        lastScene = storyboard.getPrevious()
		print("COMING FROM "..tostring(lastScene))
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	storyboard.purgeScene( lastScene )
	jsonLevels.checkForUpdates(checkUpdatedListener)
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
-- "willEnterScene" event is dispatched before scene transition begins
scene:addEventListener( "willEnterScene", scene )

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