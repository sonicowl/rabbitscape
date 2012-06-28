----------------------------------------------------------------------------------
--
-- scenetemplate.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
require("ui")
local dialogsModule = require( "module-dialogs" )
local gameStore = require("module-store")
social = require("module-social")


_W = display.contentWidth;
_H = display.contentHeight;
_VW = display.viewableContentWidth
_VH = display.viewableContentHeight
_VH0 = (_H-_VH)/2
_VW0 = (_W-_VW)/2
hasUpdates = false


function checkUpdatedListener(bool)
	if bool then hasUpdates = true end
end

function syncBoxCallback( event )
	if "clicked" == event.action then
		local i = event.index
		if 1 == i then
			local loadingGroup = display.newGroup()
			menuGroup:insert(loadingGroup)
			jsonLevels.syncLevels(loadingGroup)
			hasUpdates = false
		else
			sceneDialog = display.newGroup()
			menuGroup:insert(sceneDialog)
			dialogsModule.callScenerySelector(sceneDialog,storyboard)
		end
	end
end

function requestSync()
	local alert = native.showAlert("Updates Available", "There are new levels available, do you want to download them now?", 
	{ "OK", "Later" }, syncBoxCallback )
end

function loadActions()

	actions["play"] = function(event)
		print("touched "..tostring(event.id))
		--storyboard.gotoScene( "scene-sceneryList", "slideLeft", 400 )
		if hasUpdates then requestSync()
		else
			sceneDialog = display.newGroup()
			menuGroup:insert(sceneDialog)
			dialogsModule.callScenerySelector(sceneDialog,storyboard)
		end
	end
	
	actions["help"] = function(event)
		print("touched "..tostring(event.id))
		
	end	
	
	actions["options"] = function(event)
		print("touched "..tostring(event.id))
		
	end	
	
	actions["openfeint"] = function(event)
		print("touched "..tostring(event.id))
		
	end	
	
	actions["licensing"] = function(event)
		print("touched "..tostring(event.id))
		
	end
	
	buttonHandler = function( event )	-- General function for all buttons (uses "actions" table above)
		if ("release" == event.phase) then
			actions[event.id](event)
		end
		return true  --SO SIMPLE AND SO CONFUSING.... THIS PREVENTS FROM PROPAGATING TO OTHER BUTTONS
	end
end

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	menuGroup = group
	lastScene = storyboard.getPrevious()
	print("COMING FROM "..tostring(lastScene))
	social.init()
	dialogsModule.init()
	gameStore.init()
	
	actions = {}
	loadActions()


	local bg = display.newImageRect("bg1.jpg",_VW,_VH)
	bg.x = _W/2;	bg.y = _H/2
	group:insert(bg)
	
	playButton = ui.newButton{
		default = "buttonYellow.png",
		over = "buttonYellowOver.png",
		onEvent = buttonHandler,
		id = "play",
		text = "PLAY GAME",
		textColor = { 51, 51, 51, 255 },
		emboss = true,
		size = 22
	}

	helpButton = ui.newButton{
		default = "buttonYellow.png",
		over = "buttonYellowOver.png",
		onEvent = buttonHandler,
		id = "help",
		text = "HELP",
		textColor = { 51, 51, 51, 255 },
		emboss = true,
		size = 22
	}
	
	optionsButton = ui.newButton{
		default = "buttonYellow.png",
		over = "buttonYellowOver.png",
		onEvent = buttonHandler,
		id = "options",
		text = "OPTIONS",
		textColor = { 51, 51, 51, 255 },
		emboss = true,
		size = 22
	}
	
	ofButton= ui.newButton{
		default = "buttonYellow.png",
		over = "buttonYellowOver.png",
		onEvent = buttonHandler,
		id = "openfeint",
		text = "OPENFEINT",
		textColor = { 51, 51, 51, 255 },
		emboss = true,
		size = 22
	}
	
	playButton.x = _W/2;	playButton.y = _H/2-225
	helpButton.x = _W/2;	helpButton.y = _H/2-75
	optionsButton.x = _W/2;	optionsButton.y = _H/2+75
	ofButton.x = _W/2;		ofButton.y = _H/2+225
	
	playButton:scale(2,2)
	helpButton:scale(2,2)
	optionsButton:scale(2,2)
	ofButton:scale(2,2)

	
	group:insert(playButton)
	group:insert(helpButton)
	group:insert(optionsButton)
	group:insert(ofButton)
	
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