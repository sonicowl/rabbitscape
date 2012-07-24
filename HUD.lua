-----------------------------------------
-- HUD.lua
-- Version 1.0
-- Author: Thiago Ramos
-- Functions:
--		
-----------------------------------------


module(..., package.seeall)

function init(viewGroup,storyBoard,listenersTable)
	actions = {}
	storyboard = storyBoard
	dialogsModule = require("module-dialogs")
	dialogsModule.init()
	storeModule = require("module-store")

	require("ice")
	gameData = ice:loadBox("gameData")
	storeData = ice:loadBox( "storeData" )
	HUD = display.newGroup()
	viewGroup:insert(HUD)
	restartListener = listenersTable.restart
	quitListener = listenersTable.quit
	resumeGameListener = listenersTable.resume
	pauseListener = listenersTable.pause
	nextLevelListener = listenersTable.continue
	levelSelectListener = listenersTable.levelSelect
	
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
	transitioning = false
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
		timeText.x = _VW0 + 20;			timeText.y = _VH0+_VH-45
		rocksText.x = _VW0 + 30;		rocksText.y = _VH0+_VH-40
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

		carrotsPurchased = storeData:retrieve("carrotsPurchased")
		local loadCarrotButs = function()
			if carrotUsedBut then carrotUsedBut = nil end
			carrotButton = ui.newButton{
				default = "carrot-off.png",
				over = "carrot-on.png",
				id = "carrotButton",
				onEvent = buttonHandler,
				emboss = true
			}
			carrotButton.x = _W/2+110; carrotButton.y = _H-50
			carrotButton:scale(.5,.5)
			screenUI:insert(carrotButton)
		end
		if carrotsPurchased then
			loadCarrotButs()
		else
			carrotUsedBut = display.newImageRect("carrot-used.png", 139/2, 139/2)
			carrotUsedBut.x = _W/2+110; carrotUsedBut.y = _H-50
			local function carrotStoreListener(event)
				if event.phase == "began" then			
					storeModule.init(loadCarrotButs)
					storeModule.sellingDialog("carrots")
				end
			end
			carrotUsedBut:addEventListener("touch", carrotStoreListener)
			screenUI:insert(carrotUsedBut)
		end
	end
end

function reloadCarrotsButton()

	storeData = ice:loadBox( "storeData" )
	carrotsPurchased = storeData:retrieve("carrotsPurchased")
	print("reloading Carrots BUTTON. CarrotsPurchased: "..tostring(carrotsPurchased))
	local loadCarrotButs = function()
		if carrotUsedBut then print("removing carrotusedBut") carrotUsedBut:removeSelf() carrotUsedBut = nil end
		carrotButton = ui.newButton{
			default = "carrot-off.png",
			over = "carrot-on.png",
			id = "carrotButton",
			onEvent = buttonHandler,
			emboss = true
		}
		carrotButton.x = _W/2+110; carrotButton.y = _H-50
		carrotButton:scale(.5,.5)
		screenUI:insert(carrotButton)
	end
	if carrotsPurchased then
		print("CARROTS PURCHASED, LOADING NORMAL BUTTON")
		if not carrotButton then print("no button yet, putting now")loadCarrotButs() end
	elseif not carrotUsedBut then
		print("CARROTS NOT PURCHASED AND NO BUTTON YET")
		carrotUsedBut = display.newImageRect("carrot-used.png", 139/2, 139/2)
		carrotUsedBut.x = _W/2+110; carrotUsedBut.y = _H-50
		local function carrotStoreListener(event)
			if event.phase == "began" then			
				storeModule.init(loadCarrotButs)
				storeModule.sellingDialog("carrots")
			end
		end
		carrotUsedBut:addEventListener("touch", carrotStoreListener)
		screenUI:insert(carrotUsedBut)
	else
		print("carrots not purchased and button already there")
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
	if rocksText then
		rocksText.text = rocks
		rocksText.x = _VW0+30
	end
end


function loadActions()


	actions["sceneBack"] = function(event)
		print("touched "..tostring(event.id))
		
		local dialogGroup = display.newGroup()
		HUD:insert(dialogGroup)
		local menuClosure = function(option) if option then quitListener() else showMenu() end end
		dialogsModule.callQuitGame(dialogGroup,menuClosure)
		closeMenu()
	end

	actions["restartGame"] = function(event)
		print("touched "..tostring(event.id))
		if endGameScreen~=nil and endGameScreen.numChildren ~= nil and endGameScreen.numChildren > 0 then
			restartListener()
			pauseListener()
			closeGroup(endGameScreen,resumeGameListener)
			return true
		end
		restartListener()
	end	
	
	actions["nextLevel"] = function(event)
		print("touched "..tostring(event.id))
		closeGroup(endGameScreen,nextLevelListener)
	end	
	
		
	actions["endToMenu"] = function (event)
		print("touched "..tostring(event.id))
		restartListener()
		pauseListener()
		local transitionClosure = function(event) actions["showMenu"](); resumeGameListener(); end
		closeGroup(endGameScreen,actions["showMenu"])
	end
	
	actions["resumeGame"] = function(event)
		--print("touched "..tostring(event.id))
		closeMenu()
		gridBefore = gameData:retrieve("gridVisible")
		gameData = ice:loadBox("gameData")
		gridAfter = gameData:retrieve("gridVisible")
		print("gridBefore:"..tostring(gridBefore).." gridAfter:"..tostring(gridAfter))
		if gridBefore ~= gridAfter then
			gameEngine.setGrid()
		end
		resumeGameListener()
	end	
	

	actions["showMenu"] = function(event)
		if not transitioning then
			if menuDialog == nil then
				--print("touched "..tostring(event.id))
				pauseListener()
				showMenu()
			else
				actions["resumeGame"]()
			end
		end
	end	

	actions["carrotButton"] = function (event)
		print("touched "..tostring(event.id))
		gameEngine.eatCarrot()
		carrotUsedBut = display.newImageRect("carrot-used.png", 139/2, 139/2)
		carrotUsedBut.x = carrotButton.x	carrotUsedBut.y = carrotButton.y
		carrotButton.parent:insert(carrotUsedBut)
		carrotButton:removeSelf()
		carrotButton = nil
	end
	
	actions["levelSelect"] = function (event)
		print("touched "..tostring(event.id))
		closeMenu(true)
		levelSelectListener()
	end
	
	actions["options"] = function (event)
		print("touched "..tostring(event.id))
		local optionsCloseListener = function() 
			if not audio.isChannelPlaying(1) and not storyboard.mute then 
				audio.play(soundAmbience,{loops=-1,channel=1}) 
			end
		end
		sceneDialog = display.newGroup()
		HUD:insert(sceneDialog)
		dialogsModule.callOptions(sceneDialog,optionsCloseListener,storyboard)
	end
	
	actions["scores"] = function (event)
		print("touched "..tostring(event.id))
		social.showGCPopup()
	end
	
	actions["howtoplay"] = function (event)
		print("touched "..tostring(event.id))
		local dialogGroup = display.newGroup()
		HUD:insert(dialogGroup)
		local menuClosure = function(event) showMenu() print("calling listener") end
		dialogsModule.callHowToPlay(dialogGroup,menuClosure)
		closeMenu()
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

function closeGroup(group, listener)
	local closeClosure = function(event)
		if listener then listener() end
		event:removeSelf(); 
		event = nil;
		blackAlpha:removeSelf(); 
		blackAlpha = nil; 
	end
	transition.to(group,{time=1000,y=-display.contentHeight,transition = easing.inOutExpo,onComplete = closeClosure})
	transition.to(blackAlpha,{time=900,alpha = 0,transition = easing.inOutExpo})
end


function callEndingScreen(didWon,score,high,usedCarrot,gameTime,objectsUsed)	

	blackAlpha = display.newRect(0,0 , _W, _H)
	blackAlpha:setFillColor(0, 0,	0)
	blackAlpha.alpha = 0
	HUD:insert(blackAlpha)

	endGameScreen = display.newGroup()
	HUD:insert(endGameScreen)
		
	
	
	local holdingClickBg = display.newRect(0,0,_W,_H)
	endGameScreen:insert(holdingClickBg)
	holdingClickBg.alpha = 0.01
	local touchClosure = function(event) return true end
	holdingClickBg:addEventListener("touch", touchClosure)
	
	local board = display.newImageRect("board-2.png", math.floor(1053/2),math.floor(1683/2))
	board.x = _W/2; board.y = _H/2
	endGameScreen:insert(board)

	
	local resetButton = ui.newButton{
		default = "replay-off.png",
		over = "replay-on.png",
		onEvent = buttonHandler,
		id = "restartGame",
	}	
	
	
	local menuButton = ui.newButton{
		default = "menu-end-off.png",
		over = "menu-end-on.png",
		onEvent = buttonHandler,
		id = "endToMenu",
	}
	
	local nextLevelButton = nil
	if didWon then
		nextLevelButton = ui.newButton{
			default = "next-off.png",
			over = "next-on.png",
			onEvent = buttonHandler,
			id = "nextLevel",
		}
		local title2 = display.newImageRect("bunny.png",1032/2,989/2)
		title2.x = _W/2	title2.y = _H/2-180
		endGameScreen:insert(title2)
		local title = display.newImageRect("bunny.png",1032/2,989/2)
		title.x = _W/2	title.y = _H/2-180
		endGameScreen:insert(title)
		local tween2
		local tween1 = function(event) transition.to(event,{time=500,alpha =1,onComplete=tween2}) end
		tween2 = function(event) transition.to(event,{time=500,alpha=0,onComplete=tween1}) end
		tween2(title2)
		
		local content1 = display.newImageRect("scores.png",424/2,360/2)
		content1.x = _W/2-80 content1.y = _H/2+120
		endGameScreen:insert(content1)	
		local line1 = display.newImageRect("line.png",705/2,10/2)
		line1.x = _W/2	line1.y = content1.y-content1.contentHeight/2-10
		endGameScreen:insert(line1)
		local line2 = display.newImageRect("line.png",705/2,10/2)
		line2.x = _W/2	line2.y = content1.y+content1.contentHeight/2+10
		endGameScreen:insert(line2)
		if high == score then 
			local highButton = display.newImageRect("new-high.png",104/2,110/2)
			highButton.x =_W/2+170 	highButton.y = _H/2+190
			endGameScreen:insert(highButton)
			highButton.alpha = 0
			transition.to(highButton,{time=1000,delay=1000,alpha=1})
		end
		local secs = gameTime%60
		local minutes = (gameTime-secs)/60
		local secsText = secs..""
		local minutesText = minutes..""
		if minutes<10 then minutesText = "0"..minutesText end
		if secs<10 then secsText = "0"..secsText end
		timeEndText = minutesText..":"..secsText
		
		local objectsText = display.newText(objectsUsed, 0, 0, "Poplar Std", 30)	
		objectsText:setTextColor(197,240,132)	

		local totalTimeText = display.newText(timeEndText, 0, 0, "Poplar Std", 30)	
		totalTimeText:setTextColor(197,240,132)
		
		--local carrotsMsg = "NO"
		--if usedCarrot then carrotsMsg = "YES" end
		--local carrotsText = display.newText(carrotsMsg, 0, 0, "Poplar Std", 30)	
		--carrotsText:setTextColor(197,240,132)	
		
		local scoreText = display.newText(math.floor(score), 0, 0, "Poplar Std", 50)
		scoreText:setTextColor(253,222,59)
		
		local highText = display.newText(math.floor(high), 0, 0, "Poplar Std", 30)	
		highText:setTextColor(197,240,132)

		objectsText:setReferencePoint(display.CenterLeftReferencePoint);
		totalTimeText:setReferencePoint(display.CenterLeftReferencePoint);
		--carrotsText:setReferencePoint(display.CenterLeftReferencePoint);
		scoreText:setReferencePoint(display.CenterLeftReferencePoint);
		highText:setReferencePoint(display.CenterLeftReferencePoint);
		
		objectsText.x = _W/2+80 	objectsText.y = _H/2+50
		totalTimeText.x = _W/2+80 		totalTimeText.y = _H/2+80
		--carrotsText.x = _W/2+80	carrotsText.y = _H/2+110
		scoreText.x = _W/2+80 		scoreText.y = _H/2+165
		highText.x = _W/2+80 		highText.y = _H/2+205
		endGameScreen:insert(objectsText)
		endGameScreen:insert(totalTimeText)
		--endGameScreen:insert(carrotsText)
		endGameScreen:insert(scoreText)
		endGameScreen:insert(highText)

	else
		nextLevelButton = display.newImageRect("next-disabled.png",198,283)

		local title = display.newImageRect("bunny-escaped.png",691/2,814/2)
		title.x = _W/2+25	title.y = _H/2-180
		endGameScreen:insert(title)
		
		local content1 = display.newImageRect("tryagain-ad.png",973/2,449/2)
		content1.x = _W/2 content1.y = _H/2+130
		endGameScreen:insert(content1)
		
		local carrotBoxButton = display.newRect((_W/2) , (_H/2+130-content1.contentHeight/2) , content1.contentWidth/2 , (content1.contentHeight))
		carrotBoxButton.alpha = .01
		endGameScreen:insert(carrotBoxButton)
		local function carrotStoreListener(event)
			if event.phase == "began" then
				storeModule.init(loadCarrotButs)
				storeModule.sellingDialog("carrots")
			end
		end
		carrotBoxButton:addEventListener("touch", carrotStoreListener)
	end
	
	resetButton.x = _W/2-130		resetButton.y = _H/2+300
	menuButton.x = _W/2				menuButton.y = _H/2+300
	nextLevelButton.x = _W/2+130	nextLevelButton.y = _H/2+300

	resetButton:scale(.5,.5)
	nextLevelButton:scale(.5,.5)
	menuButton:scale(.5,.5)
	
	
	endGameScreen:insert(resetButton)
	endGameScreen:insert(nextLevelButton)
	endGameScreen:insert(menuButton)
	
	
	
	endGameScreen.y = -display.contentHeight
	transition.to(endGameScreen,{time=1000,y=0,transition = easing.inOutExpo})
	transition.to(blackAlpha,{time=900,alpha = .7,transition = easing.inOutExpo})
end

function callUnlockDialog(callBackListener)

	local holdingClickBg = display.newRect(0,0,_W,_H)
	HUD:insert(holdingClickBg)
	holdingClickBg.alpha = 0.01
	local touchClosure = function(event) return true end
	holdingClickBg:addEventListener("touch", touchClosure)

	local function purchaseItCallBack( event )
		if "clicked" == event.action then
				local i = event.index
				if 1 == i then
					storeModule.init(callBackListener)
					storeModule.sellingDialog("pro")
				elseif 2 == i then
					print('dont want to buy it now!')
					storyboard.gotoScene( "scene-main", "fade", 1000 )
					storyboard.gameComplete = true
				end
		end
	end
	
	local alert = native.showAlert( "Unlock extra levels!", "Upgrade to the pro version to play all levels!", 
		{ "Buy it!", "Not now!" }, purchaseItCallBack )
end




function showMenu()
	menuDialog = display.newGroup()
	HUD:insert(menuDialog)
	local myRect = display.newRect(0, -_H , _W, _H*2)
	myRect:setFillColor(0, 0, 0)
	myRect.alpha = .0


	
	local objectivesButton = ui.newButton{
		default = "howtoplay-off.png",
		over = "howtoplay-on.png",
		onEvent = buttonHandler,
		id = "howtoplay",
		textColor = { 51, 51, 51, 255 },
		emboss = true
	}

	local levelSelectButton = ui.newButton{
		default = "level-select-off.png",
		over = "level-select-on.png",
		onEvent = buttonHandler,
		id = "levelSelect",
		textColor = { 51, 51, 51, 255 },
		emboss = true
	}
	
	local optionsButton = ui.newButton{
		default = "options-off.png",
		over = "options-on.png",
		onEvent = buttonHandler,
		id = "options",
		textColor = { 51, 51, 51, 255 },		
		emboss = true
	}

	local scoresButton = ui.newButton{
		default = "scores-off.png",
		over = "scores-on.png",
		onEvent = buttonHandler,
		id = "scores",
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
	local menuTweenClosure = function() transitioning = false end
	transition.to(menuButton,{time=300,y=menuButton.y-450,transition=easing.outExpo})
	transition.to(menuDialog,{time=300,y=0,transition=easing.outExpo})
	transition.to(myRect,{time=300,alpha=.4,transition=easing.outExpo})
	transitioning = true
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
		transitioning = false		
	end
	transitioning = true
	if quickClose then	
		closure()
		return
	end
	transition.to(menuButton,{time=400,y=menuButton.y+450,transition=easing.outExpo})
	transition.to(menuDialog,{time=400,y=450,transition=easing.outExpo,onComplete=closure})
	transition.to(menuDialog[1],{time=250,alpha=0,transition=easing.outExpo})
end
