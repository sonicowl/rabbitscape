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
	loadHeader()

end



function loadHeader()
	--Setup the nav bar 
	local navBar = display.newImageRect("navBar.png",_VW,40)
	navBar.x = display.contentWidth*.5
	navBar.y = math.floor(_VH0 + navBar.height*0.5)
	HUD:insert(navBar)
	
	local navHeader = display.newText("CATCH THE RABBIT", 0, 0, native.systemFontBold, 16)
	navHeader:setTextColor(255, 255, 255)
	navHeader.x = _W*.5
	navHeader.y = navBar.y
	HUD:insert(navHeader)

	--Setup the back button
	backBtn = ui.newButton{ 
		default = "backButton.png", 
		over = "backButton_over.png", 
		id = "sceneBack",
		onEvent = buttonHandler
	}
	HUD:insert(backBtn)
	backBtn.x = math.floor(backBtn.width/2) +  _VW0 + 10
	backBtn.y = navBar.y 
	backBtn.alpha = 1
end
	
function loadScreenUI()
	if screenUI ~= nil then
		screenUI.alpha = 1
	else
		screenUI = display.newGroup()
		HUD:insert(screenUI)
		
		local Rect = display.newRect(_VW0, _VH0+_VH-90 , _VW, 90)
		Rect:setFillColor(20, 20, 20)
		Rect.alpha = .7
		screenUI:insert(Rect)
		
		timeText = display.newText("0000", 0, 0, native.systemFontBold, 30)
		timeText:setTextColor(255, 255, 255)
		timeText:setReferencePoint(display.CenterLeftReferencePoint);
		screenUI:insert(timeText)	
		
		scoreText = display.newText("0000", 0, 0, native.systemFontBold, 30)
		scoreText:setTextColor(255, 255, 255)
		scoreText:setReferencePoint(display.CenterLeftReferencePoint);
		screenUI:insert(scoreText)		
		
		rocksText = display.newText("0000", 0, 0, native.systemFontBold, 30)
		rocksText:setTextColor(255, 255, 255)
		rocksText:setReferencePoint(display.CenterLeftReferencePoint);
		screenUI:insert(rocksText)
		
		
		local resetButton = ui.newButton{
			default = "restart.png",
			over = "restart.png",
			onEvent = buttonHandler,
			id = "restartGame",
			emboss = true
		}
		resetButton.xScale = .3; resetButton.yScale = .3
		screenUI:insert(resetButton)
		
		
		timeText.x = _VW0 + 20;			timeText.y = _VH0+_VH-20
		scoreText.x = _VW0 + 20;		scoreText.y = _VH0+_VH-60
		rocksText.x = _VW0 + 280;		rocksText.y = _VH0+_VH-60
		resetButton.x = _VW0+_VW - 50; 	resetButton.y = _VH0+_VH-45		
		
		local menuButton = ui.newButton{
			default = "menu1.png",
			over = "menu2.png",
			onEvent = buttonHandler,
			id = "showMenu",
			emboss = true
		}
		screenUI:insert(menuButton)
		
		
		menuButton.x = _VW0+_VW - 100; 	menuButton.y = _VH0+_VH-45
	end
end

function hideScreenUI()
	if screenUI ~= nil then
		screenUI.alpha = 0
	end
end

function updateGameScene(score,seconds,rocks)
	timeText.text = "SECONDS: "..seconds
	scoreText.text = "SCORE: "..score
	rocksText.text = "ROCKS: "..rocks
	timeText:setReferencePoint(display.CenterLeftReferencePoint);
	scoreText:setReferencePoint(display.CenterLeftReferencePoint);
	scoreText.x = _VW0 + 20
	timeText.x = _VW0 + 20
end


function loadActions()


	actions["sceneBack"] = function(event)
		print("touched "..tostring(event.id))
		quitListener()
	end

	actions["restartGame"] = function(event)
		print("touched "..tostring(event.id))
		if endGameScreen~=nil and endGameScreen.numChildren > 0 then
			for i = endGameScreen.numChildren, 1,-1 do
				endGameScreen[i]:removeSelf()
				endGameScreen[i] = nil
			end
		end
		restartListener()
	end	
	
	
	actions["resumeGame"] = function(event)
		print("touched "..tostring(event.id))
		closeMenu()
		resumeGameListener()
	end	
	

	actions["showMenu"] = function(event)
		print("touched "..tostring(event.id))
		pauseListener()
		showMenu()
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




function callEndingScreen(didWon)
	endGameScreen = display.newGroup()
	HUD:insert(endGameScreen)
	local myRect = display.newRect(_W/2-225, _H/2-100 , 450, 200)
	myRect.strokeWidth = 3
	myRect:setFillColor(0, 0, 0)
	myRect.alpha = .6
	myRect:setStrokeColor(255, 255, 255)
	local msg = nil
	if didWon then
		msg = "YOU RESCUED THE BUNNY!"
	else
		msg = "OH NO! BUNNY ESCAPED!"
	end
	local myText = display.newText(msg, 0, 0, native.systemFont, 30)
	myText.x = _W/2
	myText.y = _H/2-50
	myText:setTextColor(255, 255, 255)
	
	local resetButton = ui.newButton{
		default = "buttonRed.png",
		over = "buttonRedOver.png",
		onEvent = buttonHandler,
		id = "restartGame",
		text = "RETRY",
		emboss = true
	}
	resetButton.x = _W/2; resetButton.y = _H/2+40
	endGameScreen:insert(myRect)
	endGameScreen:insert(myText)
	endGameScreen:insert(resetButton)
end





function showMenu()
	menuDialog = display.newGroup()
	HUD:insert(menuDialog)
	local myRect = display.newRect(_W/2-225, _H/2-300 , 450, 600)
	myRect.strokeWidth = 3
	myRect:setFillColor(0, 0, 0)
	myRect.alpha = .6
	myRect:setStrokeColor(255, 255, 255)
	local msg = "PAUSE MENU"
	local myText = display.newText(msg, 0, 0, native.systemFont, 30)
	myText.x = _W/2
	myText.y = myRect.y-myRect.y/2+20
	myText:setTextColor(255, 255, 255)
	
	local objectivesButton = ui.newButton{
		default = "buttonYellow.png",
		over = "buttonYellowOver.png",
		onEvent = buttonHandler,
		id = "",
		text = "OBJECTIVES",
		textColor = { 51, 51, 51, 255 },
		emboss = true
	}
	
	local optionsButton = ui.newButton{
		default = "buttonYellow.png",
		over = "buttonYellowOver.png",
		onEvent = buttonHandler,
		id = "",
		text = "OPTIONS",
		textColor = { 51, 51, 51, 255 },		
		emboss = true
	}

	local scoresButton = ui.newButton{
		default = "buttonYellow.png",
		over = "buttonYellowOver.png",
		onEvent = buttonHandler,
		id = "",
		text = "SCORES",
		textColor = { 51, 51, 51, 255 },
		emboss = true
	}

	local resumeButton = ui.newButton{
		default = "buttonYellow.png",
		over = "buttonYellowOver.png",
		onEvent = buttonHandler,
		id = "resumeGame",
		text = "RESUME",
		textColor = { 51, 51, 51, 255 },
		emboss = true
	}

	local quitButton = ui.newButton{
		default = "buttonYellow.png",
		over = "buttonYellowOver.png",
		onEvent = buttonHandler,
		id = "sceneBack",
		text = "QUIT",
		textColor = { 51, 51, 51, 255 },
		emboss = true
	}
	
	
	objectivesButton.x = _W/2; objectivesButton.y = _H/2-120	
	optionsButton.x = _W/2; optionsButton.y = _H/2-50	
	scoresButton.x = _W/2; scoresButton.y = _H/2+20	
	resumeButton.x = _W/2; resumeButton.y = _H/2+90
	quitButton.x = _W/2; quitButton.y = _H/2+90+70
	




	menuDialog:insert(myRect)
	menuDialog:insert(myText)
	menuDialog:insert(objectivesButton)
	menuDialog:insert(optionsButton)
	menuDialog:insert(scoresButton)
	menuDialog:insert(resumeButton)
	menuDialog:insert(quitButton)
	
end

function closeMenu()
	 for i = #menuDialog,1,-1 do
		menuDialog[i]:removeSelf()
		menuDialog[i] = nil
	 end
	 menuDialog:removeSelf()
	 menuDialog = nil
end
