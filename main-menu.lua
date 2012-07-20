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
transitioning = true

gameData = ice:loadBox( "gameData" )
gameData:storeIfNew( "mute", false )
gameData:storeIfNew( "unlocked-".."The Park".."-".."1", true )
gameData:storeIfNew( "free-".."The Park".."-".."1", true )
gameData:storeIfNew( "free-".."The Park".."-".."2", true )
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

function goOutAnimation(listener)
	local goOutClosure = function(event) timer.performWithDelay(100,listener) transitioning = false end
	transition.to(littleSigns,{time=150,alpha=0,transition=easing.inExpo})
	transition.to(ofButton,{delay=100,time=250,y=ofButton.y+300,transition=easing.inExpo})	
	transition.to(helpButton,{delay=150,time=250,y=helpButton.y+300,transition=easing.inExpo})
	transition.to(optionsButton,{delay=200,time=250,y=optionsButton.y+300,transition=easing.inExpo})
	transition.to(playButton,{delay=250, time=250,y=playButton.y+300,transition=easing.inExpo})
	transition.to(mainSign,{delay=300, time=250,y=mainSign.y-_H/2,transition=easing.inExpo})
	transition.to(mainBunny,{delay = 400, time=500,x=mainBunny.x-170,y=mainBunny.y-300,alpha=0,rotation=-30,xScale=.2,yScale=.2,transition=easing.inExpo})
	transition.to(circleGroup,{delay=900,time=250,x=-_W,transition=easing.inExpo,onComplete=goOutClosure})
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
			local butClosure = function(event)	storyboard.gotoScene( "scene-scenery-select", {time=100} ) end
			goOutAnimation(butClosure)
			transitioning = true
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
			local butClosure = function(event)	storyboard.gotoScene( "scene-scenery-select", {time=100} ) end
			goOutAnimation(butClosure)
			transitioning = true
		end
	end
	
	actions["help"] = function(event)
		print("touched "..tostring(event.id))
		local butClosure = function(event)	storyboard.gotoScene( "scene-help", {time=100} ) end
		goOutAnimation(butClosure)
		transitioning = true
	end	
	
	actions["credits"] = function(event)
		print("touched "..tostring(event.id))
		local butClosure = function(event)	storyboard.gotoScene( "scene-credits", {time=100} ) end
		goOutAnimation(butClosure)
		transitioning = true
	end	
	
	actions["options"] = function(event)
		print("touched "..tostring(event.id))
		local butClosure = function(event)	storyboard.gotoScene( "scene-options", {time=100} ) end
		goOutAnimation(butClosure)
		transitioning = true
	end	
	
	actions["GameCenter"] = function(event)
		print("touched "..tostring(event.id))
		social.showGCPopup()
	end	
	
	buttonHandler = function( event )	-- General function for all buttons (uses "actions" table above)
		if ("release" == event.phase) and not transitioning then
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
	
	creditsButton = ui.newButton{
		default = "licensing-bt-off.png",
		over = "licensing-bt-on.png",
		onEvent = buttonHandler,
		id = "credits",
	}


	mainBg = display.newImageRect("bg3.jpg",_VW,_VH)
	--bg.x = _W/2;	bg.y = _H/2
	mainBg.x = _W/2;	mainBg.y = _H/2
	group:insert(mainBg)

	circleGroup = display.newGroup()

	cityCircle = display.newImageRect("main-hole.png",1002/2,996/2)
	--cityCircle.x = _W/2;	cityCircle.y = _H/2-30
	cityCircle.x = _W/2;	cityCircle.y = _H/2-30
	circleGroup:insert(cityCircle)
	
	mainSign = display.newImageRect("main-sign.png",1094/2,674/2)
	--mainSign.x = _W/2+20;	mainSign.y = _H/2-280
	mainSign.x = _W/2+20;	mainSign.y = _H/2-280-_H/2
	circleGroup:insert(mainSign)	

	buildingOL = display.newImageRect("main-building.png",133/2,207/2)
	--buildingOL.x = _W/2+80;	buildingOL.y = _H/2-130
	buildingOL.x = _W/2+80;	buildingOL.y = _H/2-130
	circleGroup:insert(buildingOL)
	
	littleSigns = display.newImageRect("main-texts.png",500/2,302/2)
	--littleSigns.x = _W/4;	littleSigns.y = _H/2+180
	littleSigns.x = _W/4;	littleSigns.y = _H/2+180
	littleSigns.alpha = 0
	circleGroup:insert(littleSigns)

	mainBunny = display.newImageRect("main-bunny.png",1193/2,823/2)
	--mainBunny.x = _W/2+90;	mainBunny.y = _H/2+215
	mainBunny.x = _W/2+90-170;	mainBunny.y = _H/2+215-300
	mainBunny:scale(.2,.2)
	mainBunny.alpha = 0
	mainBunny:setReferencePoint(display.BottomCenterReferencePoint);
	mainBunny.rotation = -30
	circleGroup:insert(mainBunny)
	
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
	
	creditsButton.x = _W/4*3+100;	creditsButton.y = _VH0+25
	playButton.x = _W/4;	playButton.y = _H/2+300+300
	helpButton.x = _W/2+15;	helpButton.y = _H/2+410+300
	optionsButton.x = _W/4;	optionsButton.y = _H/2+410+300
	ofButton.x = _W/4*3+30;		ofButton.y = _H/2+410+300
	
	creditsButton:scale(.5,.5)
	playButton:scale(.5,.5)
	helpButton:scale(.5,.5)
	optionsButton:scale(.5,.5)
	ofButton:scale(.5,.5)

	
	group:insert(creditsButton)
	group:insert(playButton)
	group:insert(helpButton)
	group:insert(optionsButton)
	group:insert(ofButton)
	group:insert(circleGroup)
	circleGroup.x = -_W
	
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
	

	soundIntro = audio.loadStream("stream-intro.wav")
	soundElementIn = audio.loadSound("sound-element-in.wav")
	soundWee = audio.loadSound("sound-wee.wav")

	
	local audioClosure1 = function() if not storyboard.mute then audio.play(soundElementIn) end end
	local audioClosure2 = function() if not storyboard.mute then audio.play(soundWee) end end
	
	
	
	if not storyboard.mute then audio.play(soundIntro,{loops=-1}) end	
	
	local startClosure2 = function(event)
		transition.to(mainSign,{time=500/2,y=mainSign.y+_H/2,transition=easing.outExpo,onStart=audioClosure1})
		transition.to(playButton,{delay=200/2, time=500/2,y=playButton.y-300,transition=easing.outExpo,onStart=audioClosure1})
		transition.to(optionsButton,{delay=300/2,time=500/2,y=optionsButton.y-300,transition=easing.outExpo,onStart=audioClosure1})
		transition.to(helpButton,{delay=400/2,time=500/2,y=helpButton.y-300,transition=easing.outExpo,onStart=audioClosure1})
		transition.to(ofButton,{delay=500/2,time=500/2,y=ofButton.y-300,transition=easing.outExpo,onStart=audioClosure1})	
		transition.to(littleSigns,{delay=700/2,time=300/2,alpha=1,transition=easing.inExpo,onStart=audioClosure1})
		timer.performWithDelay(700, function() transitioning = false end)
	end
	local startClosure1 = function(event) transition.to(mainBunny,{time=800,x=mainBunny.x+170,y=mainBunny.y+300,alpha=1,rotation=0,xScale=1,yScale=1,transition=easing.outExpo,onStart=audioClosure2,onComplete=startClosure2})  end
	transition.to(circleGroup,{time=500/2,x=0,transition=easing.outExpo,onComplete=startClosure1,onStart=audioClosure1})
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
	audio.stop()
	audio.dispose(soundIntro)
	audio.dispose(soundElementIn)
	audio.dispose(soundWee)

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