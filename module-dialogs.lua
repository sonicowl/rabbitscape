-----------------------------------------
-- module-dialogs.lua
-- Version 1.0
-- Author: Thiago Ramos
-- Functions:
--		
-----------------------------------------


module(..., package.seeall)

function init()
	require ("ui")
	slideView = require("slideView")
	jsonLevels = require ("jsonLevels")
	jsonLevels.init()
	require("ice")
	gameData = ice:loadBox( "gameData" )
	storeModule = require("module-store")
	storeModule.init()
end

function callScenerySelector(viewGroup,storyboard,closeListener)	
	
	local holdingClickBg = display.newRect(0,0,_W,_H)
	viewGroup:insert(holdingClickBg)
	holdingClickBg.alpha = 0.01
	local touchClosure = function(event) return true end
	holdingClickBg:addEventListener("touch", touchClosure)
	
	local board = display.newImageRect("board-2.png", math.floor(1053/2),math.floor(1683/2))
	board.x = _W/2; board.y = _H/2
	viewGroup:insert(board)

	local boardIcon = display.newImageRect("title-levelselect.png", math.floor(362/2),math.floor(312/2))
	boardIcon.x = _W/2; boardIcon.y = _H/2-board.contentHeight/2+20
	viewGroup:insert(boardIcon)

	local pickTextShadow = display.newText("PICK  A  STAGE", 0, 0, "Poplar Std", 50)
	pickTextShadow:setTextColor(0, 0, 0)
	local pickText = display.newText("PICK  A  STAGE", 0, 0, "Poplar Std", 50)
	pickText:setTextColor(255, 255, 255)
	viewGroup:insert(pickTextShadow)
	viewGroup:insert(pickText)
	pickText.x = _W*.5;					pickText.y = _H/2-220
	pickTextShadow.x = pickText.x + 2;	pickTextShadow.y = pickText.y + 2

	sceneryList = jsonLevels.loadSceneryTable()
	
	function buttonHandler(event)
		print(event.phase)
		if event.phase == "release"  then
			print("touched "..tostring(event.id))
			slider:page(event.id)
		end
		return true
	end
	
	
	function closeButHandler(event)
		if event.phase == "release"  then
			local closeClosure = function(event) if closeListener then closeListener() end event:removeSelf(); event = nil; end
			transition.to(viewGroup,{time=800,y=-display.contentHeight,transition = easing.inExpo,onComplete = closeClosure})
		end
		return true
	end
	
	function listener(imgNum)
		print( "USER CLICKED LEVEL "..imgNum)
		if sceneryList.resources then 
			storyboard.getFromResources = true
		else
			storyboard.getFromResources = false
		end
		storyboard.sceneryId = sceneryList[imgNum].id
		storyboard.gotoScene( "levelsList2", "slideUp", 400 )
	end

	local closeBut = ui.newButton{
		default = "close-off.png",
		over = "close-on.png",
		onEvent = closeButHandler,
	}
	
	local leftArrow = ui.newButton{
		default = "left-off.png",
		over = "left-on.png",
		id = -1,
		onEvent = buttonHandler,
	}

	local rightArrow = ui.newButton{
		default = "right-off.png",
		over = "right-on.png",
		id = 1,
		onEvent = buttonHandler,
	}

	leftArrow:scale(.5,.5)
	rightArrow:scale(.5,.5)
	closeBut:scale(.5,.5)

	leftArrow.x = _W/4-15;		leftArrow.y = _H/2+20
	rightArrow.x = _W/4*3+15;	rightArrow.y = _H/2+20
	closeBut.x = board.x+board.contentWidth/2-10	closeBut.y = board.y - board.contentHeight/2+10
	viewGroup:insert(leftArrow)
	viewGroup:insert(rightArrow)
	viewGroup:insert(closeBut)



	local buttonData = {
		{default = "stage1-off.png",over = "stage1-on.png"},
		{default = "stage2-off.png",over = "stage2-on.png"},
		{default = "stage3-off.png",over = "stage3-on.png"},
		{default = "stage4-off.png",over = "stage4-on.png"}
	}	
	slider = slideView.new( sceneryList,listener )
	slider.y = slider.y + 50
	viewGroup:insert(slider)
	viewGroup.y = -display.contentHeight
	transition.to(viewGroup,{time=800,y=0,transition = easing.outExpo})
end

function callHowToPlay(viewGroup,listener)	
	
	local holdingClickBg = display.newRect(0,0,_W,_H)
	viewGroup:insert(holdingClickBg)
	holdingClickBg.alpha = 0.01
	local touchClosure = function(event) return true end
	holdingClickBg:addEventListener("touch", touchClosure)
	
	local board = display.newImageRect("board-2.png", math.floor(1053/2),math.floor(1683/2))
	board.x = _W/2; board.y = _H/2
	viewGroup:insert(board)

	local boardIcon = display.newImageRect("title-howtoplay.png", math.floor(362/2),math.floor(312/2))
	boardIcon.x = _W/2; boardIcon.y = _H/2-board.contentHeight/2+20
	viewGroup:insert(boardIcon)

	local content = display.newImageRect("content-howtoplay.png", math.floor(854/2),math.floor(1350/2))
	content.x = _W/2; content.y = _H/2+20
	viewGroup:insert(content)
	
	function closeButHandler(event)
		if event.phase == "release"  then
			local closeClosure = function(event)
				if listener then listener() end
				event:removeSelf(); 
				event = nil; 
			end
			transition.to(viewGroup,{time=800,y=-display.contentHeight,transition = easing.inExpo,onComplete = closeClosure})
		end
		return true
	end

	local closeBut = ui.newButton{
		default = "close-off.png",
		over = "close-on.png",
		onEvent = closeButHandler,
	}
	closeBut:scale(.5,.5)
	closeBut.x = board.x+board.contentWidth/2-10
	closeBut.y = board.y - board.contentHeight/2+10
	viewGroup:insert(closeBut)
	
	viewGroup.y = -display.contentHeight
	transition.to(viewGroup,{time=800,y=0,transition = easing.outExpo})
end





function callOptions(viewGroup,listener,storyboard)	
	
	local holdingClickBg = display.newRect(0,0,_W,_H)
	viewGroup:insert(holdingClickBg)
	holdingClickBg.alpha = 0.01
	local touchClosure = function(event) return true end
	holdingClickBg:addEventListener("touch", touchClosure)
	
	local board = display.newImageRect("board-2.png", math.floor(1053/2),math.floor(1683/2))
	board.x = _W/2; board.y = _H/2
	viewGroup:insert(board)

	local boardIcon = display.newImageRect("title-options.png", math.floor(362/2),math.floor(312/2))
	boardIcon.x = _W/2; boardIcon.y = _H/2-board.contentHeight/2+20
	viewGroup:insert(boardIcon)

	--local content = display.newImageRect("content-howtoplay.png", math.floor(854/2),math.floor(1350/2))
	--content.x = _W/2; content.y = _H/2+20
	--viewGroup:insert(content)

	local soundText = display.newText("SOUND", 0, 0, "Poplar Std", 50)
	soundText:setTextColor(255, 255, 255)
	soundText.x = _W*.5-100;					soundText.y = _H/2-220
	viewGroup:insert(soundText)
	
	local soundButOff = display.newImageRect("bt-2-off.png",243/2,148/2)
	local soundButOn = display.newImageRect("bt-2-on.png",243/2,148/2)
	local function soundButListener(event)
		print("evennt"..event.phase)
		if event.phase == "began" then
			if not event.target.id then
				soundButOff.alpha = 0
				soundButOn.alpha = 1
				storyboard.mute = false
				gameData:store("mute", false )
				gameData:save()
			else
				print("heeere")
				soundButOff.alpha = 1
				soundButOn.alpha = 0				
				storyboard.mute = true
				gameData:store( "mute", true )
				gameData:save()
			end
		end
	end
	
	soundButOff.x = _W*.5+160;	soundButOff.y = _H/2-220
	soundButOn.x = _W*.5+160;	soundButOn.y = _H/2-220
	soundButOff.alpha = 0
	soundButOn.id = true
	soundButOff.id = false
	soundButOn:addEventListener("touch",soundButListener)
	soundButOff:addEventListener("touch",soundButListener)
	viewGroup:insert(soundButOff)
	viewGroup:insert(soundButOn)
	
	function buyCarrotsHandler(event)
		if event.phase == "release"  then
			storeModule.sellingDialog("carrots")
		end
		return true
	end

	local buyCarrots = ui.newButton{
		default = "buttonYellow.png",
		over = "buttonYellowOver.png",
		onEvent = buyCarrotsHandler,
		text = "BUY CARROTS BASKET",
		textColor = { 51, 51, 51, 255 },
	}
	--buyCarrots:scale(.5,.5)
	buyCarrots.x = _W/2
	buyCarrots.y = _H/2+200
	viewGroup:insert(buyCarrots)

	
	function unlockAllHandler(event)
		if event.phase == "release"  then
			storeModule.sellingDialog("pro")
		end
		return true
	end

	local unlockAll = ui.newButton{
		default = "buttonYellow.png",
		over = "buttonYellowOver.png",
		onEvent = unlockAllHandler,
		text = "UNLOCK ALL LEVELS",
		textColor = { 51, 51, 51, 255 },
	}
	--unlockAll:scale(.5,.5)
	unlockAll.x = _W/2
	unlockAll.y = _H/2+300
	viewGroup:insert(unlockAll)

	
	function closeButHandler(event)
		if event.phase == "release"  then
			local closeClosure = function(event)
				if listener then listener() end
				event:removeSelf(); 
				event = nil; 
			end
			transition.to(viewGroup,{time=800,y=-display.contentHeight,transition = easing.inExpo,onComplete = closeClosure})
		end
		return true
	end

	local closeBut = ui.newButton{
		default = "close-off.png",
		over = "close-on.png",
		onEvent = closeButHandler,
	}
	closeBut:scale(.5,.5)
	closeBut.x = board.x+board.contentWidth/2-10
	closeBut.y = board.y - board.contentHeight/2+10
	viewGroup:insert(closeBut)
	
	viewGroup.y = -display.contentHeight
	transition.to(viewGroup,{time=800,y=0,transition = easing.outExpo})
end



