-----------------------------------------
-- HUD.lua
-- Version 1.0
-- Author: Thiago Ramos
-- Functions:
--		hexDistance
--		hex_accessible
--		findPath
-----------------------------------------


module(..., package.seeall)

function init(viewGroup,listenersTable)
	actions = {}
	HUD = display.newGroup()
	viewGroup:insert(HUD)
	restartListener = listenersTable.restart
	quitListener = listenersTable.quit
	resumeGameListener = listenersTable.resume
	pauseListener = listenersTable.pause
	nextLevelListener = listenersTable.continue
	
	--POSITION VARS
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
	screenUI=nil
	loadActions()

end

	
function loadScreenUI()
	if screenUI ~= nil then
		transition.to(screenUI,{y=0,time=200,transition=easing.outExpo})
		--screenUI.alpha = 1
	else
		screenUI = display.newGroup()
		HUD:insert(screenUI)
		
		local bar = display.newImageRect("menubg.png",_VW,100)
		screenUI:insert(bar)
		

		local objectsTag = display.newImageRect("objects-tag.png",416/2,133/2)
		screenUI:insert(objectsTag)

		local timeTag = display.newImageRect("time-tag.png",426/2,135/2)
		screenUI:insert(timeTag)

		timeText = display.newText("0000", 0, 0, "Poplar Std", 30)
		timeText:setTextColor(255, 255, 255)
		timeText:setReferencePoint(display.CenterLeftReferencePoint);
		screenUI:insert(timeText)	
		
--[[		scoreText = display.newText("0000", 0, 0, native.systemFontBold, 30)
		scoreText:setTextColor(255, 255, 255)
		scoreText:setReferencePoint(display.CenterLeftReferencePoint);
		screenUI:insert(scoreText)]]--		
		
		rocksText = display.newText("0000", 0, 0, "Poplar Std", 30)
		rocksText:setTextColor(255, 255, 255)
		rocksText:setReferencePoint(display.CenterLeftReferencePoint);
		screenUI:insert(rocksText)
		
	

		
		local resetButton = ui.newButton{
			default = "reset-off.png",
			over = "reset-on.png",
			onEvent = buttonHandler,
			id = "restartGame",
			emboss = true
		}
		
		resetButton.xScale = .5; resetButton.yScale = .5
		screenUI:insert(resetButton)
	
	
		bar.x = _VW/2					bar.y = _VH0+_VH-50
		objectsTag.x = _VW0+130;		objectsTag.y = _VH0+_VH-45;	
		timeTag.x = _VW0+_VW-130;			timeTag.y = _VH0+_VH-45;	
		timeText.x = _VW0 + 20;			timeText.y = _VH0+_VH-42
--		scoreText.x = _VW0 + 20;		scoreText.y = _VH0+_VH-60
		rocksText.x = _VW0 + 30;		rocksText.y = _VH0+_VH-45
		resetButton.x =_W/2-110; 		resetButton.y = _VH0+_VH-45		
		
		menuButton = ui.newButton{
			default = "menu-off.png",
			over = "menu-on.png",
			onEvent = buttonHandler,
			id = "showMenu",
			emboss = true
		}
		screenUI:insert(menuButton)
		
		menuButton:scale(.5,.5)
		menuButton.x = _W/2; 	menuButton.y = _VH0+_VH-45
	
	
	

		gridButton = ui.newButton{
			default = "grid-off.png",
			over = "grid-on.png",
			id = "gridButton",
			onEvent = buttonHandler,
			emboss = true
		}
		
		gridButton.x = _W/2+110; gridButton.y = _H-50
		gridButton:scale(.5,.5)
		

		screenUI:insert(gridButton)
	

	end
end

function hideScreenUI()
	if screenUI ~= nil then
		transition.to(screenUI,{y=200,time=200,delay=150,transition=easing.outExpo})
		print("HIDING UI")
		--screenUI.alpha = 0	
	end
end

function updateGameScene(score,seconds,rocks)
	if timeText then
		local secs = seconds%60
		local minutes = (seconds-secs)/60
		local secsText = secs..""
		local minutesText = minutes..""
		if minutes<10 then minutesText = "0"..minutesText end
		if secs<10 then secsText = "0"..secsText end
		
		timeText.text = minutesText..":"..secsText
		timeText:setReferencePoint(display.CenterLeftReferencePoint);
		timeText.x = _VW0+_VW - 60-50		
	end
--[[	if scoreText then
		scoreText.text = "SCORE: "..score
		scoreText:setReferencePoint(display.CenterLeftReferencePoint);
		scoreText.x = _VW0 + 20
	end]]--
	if rocksText then
		rocksText.text = rocks
		rocksText.x = _VW0+30
	end
end


function loadActions()


	actions["sceneBack"] = function(event)
		print("touched "..tostring(event.id))
		closeMenu(true)
		quitListener()
	end

	actions["restartGame"] = function(event)
		print("touched "..tostring(event.id))
		if endGameScreen~=nil and endGameScreen.numChildren ~= nil and endGameScreen.numChildren > 0 then
			for i = endGameScreen.numChildren, 1,-1 do
				endGameScreen[i]:removeSelf()
				endGameScreen[i] = nil
			end
			endGameScreen:removeSelf()
			endGameScreen = nil
		end
		restartListener()
	end	
	
	actions["nextLevel"] = function(event)
		print("touched "..tostring(event.id))
		if endGameScreen~=nil and endGameScreen.numChildren ~= nil and endGameScreen.numChildren > 0 then
			for i = endGameScreen.numChildren, 1,-1 do
				endGameScreen[i]:removeSelf()
				endGameScreen[i] = nil
			end
			endGameScreen:removeSelf()
			endGameScreen = nil
		end
		nextLevelListener()
	end	
	
	
	actions["resumeGame"] = function(event)
		print("touched "..tostring(event.id))
		closeMenu()
		resumeGameListener()
	end	
	

	actions["showMenu"] = function(event)
		if menuDialog == nil then
			print("touched "..tostring(event.id))
			pauseListener()
			showMenu()
		else
			actions["resumeGame"](event)
		end
	end	

	actions["gridButton"] = function (event)
		print("touched "..tostring(event.id))
		gameEngine.setGrid()
	end	
	
	buttonHandler = function( event )	-- General function for all buttons (uses "actions" table above)
		if ("release" == event.phase) then
			actions[event.id](event)
		end
		return true  --SO SIMPLE AND SO CONFUSING.... THIS PREVENTS FROM PROPAGATING TO OTHER BUTTONS
	end
end


--TODO: IMPLEMENT DYNAMIC BOX SIZE DEPENDING ON TEXT LENGTH
function toast(message)
	print("TOASTING: "..message)
	toastScreen = display.newGroup()
	toastScreen.alpha = 0
	HUD:insert(toastScreen)
	
	local roundedRect = display.newRoundedRect(_W/2-175, _VH0+_VH-300 , 350, 50, 12)
	roundedRect:setFillColor(20, 20, 20)
	roundedRect.alpha = .7
	toastScreen:insert(roundedRect)

	local myText = display.newText(message, 0, 0, native.systemFont, 20)
	myText.x = _W/2
	myText.y = roundedRect.y
	myText:setTextColor(255, 255, 255)
	toastScreen:insert(myText)
	
	local transitionClosure2 = function(obj) obj:removeSelf() obj = nil end
	local transitionClosure = function(obj) transition.to(obj,{onComplete = transitionClosure2, alpha = 0, time = 500, delay = 1000}) end
	transition.to(toastScreen,{onComplete = transitionClosure, alpha = 1, time = 500})
	
end




function callEndingScreen(didWon,score)

	endGameScreen = display.newGroup()
	HUD:insert(endGameScreen)

	local blackAlpha = display.newRect(0,0 , _W, _H)
	blackAlpha:setFillColor(0, 0, 0)
	blackAlpha.alpha = 0
	
	local myRect2 = display.newRect(_W/2-225, _H/2-100 , 450, 200)
	myRect2.strokeWidth = 3
	myRect2:setFillColor(0, 0, 0)
	myRect2.alpha = 0.6
	myRect2:setStrokeColor(255, 255, 255)
	
	local msg = nil
	local scoreMsg = ""
	if didWon then
		msg = "YOU CATCHED THE BUNNY!"
		scoreMsg = "SCORE: "..score.." POINTS"
	else
		msg = "OH NO! BUNNY ESCAPED!"
	end
	
	local myText = display.newText(msg, 0, 0, "Poplar Std", 30)
	myText:setTextColor(255, 255, 255)
	local scoreText = display.newText(scoreMsg, 0, 0, "Poplar Std", 30)
	myText:setTextColor(255, 255, 255)
	
	
	local resetButton = ui.newButton{
		default = "buttonRed.png",
		over = "buttonRedOver.png",
		onEvent = buttonHandler,
		id = "restartGame",
		text = "RETRY",
		emboss = true
	}	
	
	
	local nextLevelButton = ui.newButton{
		default = "buttonGreen.png",
		over = "buttonGreenOver.png",
		onEvent = buttonHandler,
		id = "nextLevel",
		text = "CONTINUE",
		emboss = true
	}
	
	
	
	
	myText.x = _W/2;		myText.y = _H/2-70
	scoreText.x = _W/2;		scoreText.y = _H/2-40
	resetButton.x = _W/2-10-resetButton.contentWidth/2; 	resetButton.y = _H/2+40
	nextLevelButton.x = _W/2+10+nextLevelButton.contentWidth/2; 	nextLevelButton.y = _H/2+40
	
	
	endGameScreen:insert(blackAlpha)
	endGameScreen:insert(myRect2)
	endGameScreen:insert(myText)
	endGameScreen:insert(scoreText)
	endGameScreen:insert(resetButton)
	endGameScreen:insert(nextLevelButton)
	
	transition.to(screenUI,{time=200,y=200,delay=100})
	transition.to(blackAlpha,{time=300,alpha=.4})
end





function showMenu()
	menuDialog = display.newGroup()
	HUD:insert(menuDialog)
	local myRect = display.newRect(0, -_H , _W, _H*2)
	myRect:setFillColor(0, 0, 0)
	myRect.alpha = .0


	
	local objectivesButton = ui.newButton{
		default = "objectives-off.png",
		over = "objectives-on.png",
		onEvent = buttonHandler,
		id = "",
		textColor = { 51, 51, 51, 255 },
		emboss = true
	}

	local levelSelectButton = ui.newButton{
		default = "level-select-off.png",
		over = "level-select-on.png",
		onEvent = buttonHandler,
		id = "",
		textColor = { 51, 51, 51, 255 },
		emboss = true
	}
	
	local optionsButton = ui.newButton{
		default = "options-off.png",
		over = "options-on.png",
		onEvent = buttonHandler,
		id = "",
		textColor = { 51, 51, 51, 255 },		
		emboss = true
	}

	local scoresButton = ui.newButton{
		default = "scores-off.png",
		over = "scores-on.png",
		onEvent = buttonHandler,
		id = "",
		textColor = { 51, 51, 51, 255 },
		emboss = true
	}

	local resumeButton = ui.newButton{
		default = "resume-off.png",
		over = "resume-on.png",
		onEvent = buttonHandler,
		id = "resumeGame",
		textColor = { 51, 51, 51, 255 },
		emboss = true
	}

	local quitButton = ui.newButton{
		default = "quit-off.png",
		over = "quit-on.png",
		onEvent = buttonHandler,
		id = "sceneBack",
		textColor = { 51, 51, 51, 255 },
		emboss = true
	}
	
	
	objectivesButton.x = _W/2; objectivesButton.y = _VH0+_VH-50-350
	levelSelectButton.x = _W/2; levelSelectButton.y = _VH0+_VH-50-280
	optionsButton.x = _W/2; optionsButton.y = _VH0+_VH-50-210
	scoresButton.x = _W/2; scoresButton.y = _VH0+_VH-50-140
	quitButton.x = _W/2; quitButton.y = _VH0+_VH- 50-70
	resumeButton.x = _W/2; resumeButton.y = _VH0+_VH-50
	
	levelSelectButton:scale(.5,.5)
	objectivesButton:scale(.5,.5)
	scoresButton:scale(.5,.5)
	optionsButton:scale(.5,.5)
	resumeButton:scale(.5,.5)
	quitButton:scale(.5,.5)
	
	
	menuDialog:insert(myRect)
	menuDialog:insert(levelSelectButton)
	menuDialog:insert(objectivesButton)
	menuDialog:insert(optionsButton)
	menuDialog:insert(scoresButton)
	menuDialog:insert(resumeButton)
	menuDialog:insert(quitButton)
	
	menuDialog.y = 450
	HUD:insert(menuButton)	
	transition.to(menuButton,{time=300,y=menuButton.y-450,transition=easing.outExpo})
	transition.to(menuDialog,{time=300,y=0,transition=easing.outExpo})
	transition.to(myRect,{time=300,alpha=.4,transition=easing.outExpo})

end

function closeMenu(quickClose)
	local closure = function()
	 	for i = #menuDialog,1,-1 do
			menuDialog[i]:removeSelf()
			menuDialog[i] = nil
		end
		menuDialog:removeSelf()
		menuDialog = nil	
		screenUI:insert(menuButton)	
			
	end
	if quickClose then	
		closure()
		return
	end
	transition.to(menuButton,{time=300,y=menuButton.y+450,transition=easing.outExpo})
	transition.to(menuDialog,{time=300,y=450,transition=easing.outExpo,onComplete=closure})
	transition.to(menuDialog[1],{time=300,alpha=0,transition=easing.outExpo,onComplete=closure})
end
