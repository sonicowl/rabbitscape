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
require("ice")

gameData = ice:loadBox( "gameData" )
gameData:storeIfNew( "mute", false )
gameData:save()

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
			storyboard.gotoScene( "scene-scenery-select", "fade", 400 )
			--sceneDialog = display.newGroup()
			--menuGroup:insert(sceneDialog)
			--dialogsModule.callScenerySelector(sceneDialog,storyboard)
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
		if hasUpdates then requestSync()
		else
			storyboard.gotoScene( "scene-scenery-select", "fade", 400 )
			--sceneDialog = display.newGroup()
			--menuGroup:insert(sceneDialog)
			--dialogsModule.callScenerySelector(sceneDialog,storyboard)
		end
	end
	
	actions["help"] = function(event)
		print("touched "..tostring(event.id))
		storyboard.gotoScene( "scene-help", "fade", 400 )
	end	
	
	actions["options"] = function(event)
		print("touched "..tostring(event.id))
		storyboard.gotoScene( "scene-options", "fade", 400 )
	end	
	
	actions["GameCenter"] = function(event)
		print("touched "..tostring(event.id))
		social.showGCPopup()
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


	local bg = display.newImageRect("bg3.jpg",_VW,_VH)
	bg.x = _W/2;	bg.y = _H/2
	group:insert(bg)
	
	local cityCircle = display.newImageRect("main-hole.png",1002/2,996/2)
	cityCircle.x = _W/2;	cityCircle.y = _H/2-30
	group:insert(cityCircle)
	
	local mainSign = display.newImageRect("main-sign.png",1094/2,674/2)
	mainSign.x = _W/2+20;	mainSign.y = _H/2-280
	group:insert(mainSign)	

	local buildingOL = display.newImageRect("main-building.png",133/2,207/2)
	buildingOL.x = _W/2+80;	buildingOL.y = _H/2-130
	group:insert(buildingOL)
	
	local littleSigns = display.newImageRect("main-texts.png",500/2,302/2)
	littleSigns.x = _W/4;	littleSigns.y = _H/2+180
	group:insert(littleSigns)


	
	playButton = ui.newButton{
		default = "main-play-off.png",
		over = "main-play-on.png",
		onEvent = buttonHandler,
		id = "play",
	}

	helpButton = ui.newButton{
		default = "main-help-off.png",
		over = "main-help-on.png",
		onEvent = buttonHandler,
		id = "help",
	}
	
	optionsButton = ui.newButton{
		default = "main-options-off.png",
		over = "main-options-on.png",
		onEvent = buttonHandler,
		id = "options",
	}
	
	ofButton= ui.newButton{
		default = "main-ranking-off.png",
		over = "main-ranking-on.png",
		onEvent = buttonHandler,
		id = "GameCenter",
	}
	
	playButton.x = _W/4;	playButton.y = _H/2+300
	helpButton.x = _W/2+15;	helpButton.y = _H/2+410
	optionsButton.x = _W/4;	optionsButton.y = _H/2+410
	ofButton.x = _W/4*3+30;		ofButton.y = _H/2+410
	
	playButton:scale(.5,.5)
	helpButton:scale(.5,.5)
	optionsButton:scale(.5,.5)
	ofButton:scale(.5,.5)

	
	group:insert(playButton)
	group:insert(helpButton)
	group:insert(optionsButton)
	group:insert(ofButton)
	
	local mainBunny = display.newImageRect("main-bunny.png",1193/2,823/2)
	mainBunny.x = _W/2+90;	mainBunny.y = _H/2+215
	group:insert(mainBunny)
	
	storyboard.mute = gameData:retrieve("mute")
	
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