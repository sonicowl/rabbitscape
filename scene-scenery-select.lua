----------------------------------------------------------------------------------
--
-- scenetemplate.lua
--
----------------------------------------------------------------------------------
 
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local dialogsModule = require( "module-dialogs" )
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
 
 
function closeStageListener()
	local closeClosure = function() storyboard.gotoScene("scene-main",{time=100}) end
	timer.performWithDelay(150,closeClosure)
end
 
 
 
 
 
-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	lastScene = storyboard.getPrevious()

	dialogsModule.init(storyboard)
	loadActions()
	
	local bg = display.newImageRect("bg3.jpg",_VW,_VH)
	bg.x = _W/2
	bg.y = _H/2
	group:insert(bg)
	

	
	
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
	actions = {}

	sceneDialog = display.newGroup()
	group:insert(sceneDialog)
	dialogsModule.callScenerySelector(sceneDialog,storyboard,closeStageListener)
	
	soundSlide = audio.loadSound("sound-slide.wav")
	
	if not storyboard.bgMusic then
		storyboard.bgMusic = audio.loadStream("comical_game.mp3")
	end
	if not audio.isChannelPlaying(1) and not storyboard.mute then 
		audio.play(storyboard.bgMusic,{loops=-1,channel = 1}) 
	end
	
end
 
 
-- Called when scene is about to move offscreen:
function scene:exitScene( event )
        local group = self.view
        
        -----------------------------------------------------------------------------
        
        --      INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
        
        -----------------------------------------------------------------------------
	--audio.stop()
	--audio.dispose(soundSceneries)
	audio.dispose(soundSlide)
	--soundSceneries = nil
	soundSlide = nil
end
 
-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
        local group = self.view
        
        -----------------------------------------------------------------------------
                
        --      This event requires build 2012.782 or later.
        
        -----------------------------------------------------------------------------
        
end
 
 
-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
        local group = self.view
        
        -----------------------------------------------------------------------------
        
        --      INSERT code here (e.g. remove listeners, widgets, save state, etc.)
        
        -----------------------------------------------------------------------------
        
end
 
-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
        local group = self.view
        local overlay_scene = event.sceneName  -- overlay scene name
        
        -----------------------------------------------------------------------------
                
        --      This event requires build 2012.797 or later.
        
        -----------------------------------------------------------------------------
        
end
 
-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
        local group = self.view
        local overlay_scene = event.sceneName  -- overlay scene name
 
        -----------------------------------------------------------------------------
                
        --      This event requires build 2012.797 or later.
        
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
 
-- "didExitScene" event is dispatched after scene has finished transitioning out
scene:addEventListener( "didExitScene", scene )
 
-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )
 
-- "overlayBegan" event is dispatched when an overlay scene is shown
scene:addEventListener( "overlayBegan", scene )
 
-- "overlayEnded" event is dispatched when an overlay scene is hidden/removed
scene:addEventListener( "overlayEnded", scene )
 
---------------------------------------------------------------------------------
 
return scene
