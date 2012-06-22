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
end

function callScenerySelector(viewGroup,storyboard)	

	local board = display.newImageRect("board-2.png", math.floor(1053/2),math.floor(1683/2))
	board.x = _W/2; board.y = _H/2
	viewGroup:insert(board)

	local boardIcon = display.newImageRect("title-levelselect.png", math.floor(362/2),math.floor(312/2))
	boardIcon.x = _W/2; boardIcon.y = _H/2-board.contentHeight/2+20
	viewGroup:insert(boardIcon)

	local pickText = display.newText("PICK  A  STAGE", 0, 0, "Poplar Std", 50)
	pickText:setTextColor(255, 255, 255)
	local pickTextShadow = display.newText("PICK  A  STAGE", 0, 0, "Poplar Std", 50)
	pickTextShadow:setTextColor(0, 0, 0)
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

	leftArrow.x = _W/4-15;		leftArrow.y = _H/2+20
	rightArrow.x = _W/4*3+15;	rightArrow.y = _H/2+20
	viewGroup:insert(leftArrow)
	viewGroup:insert(rightArrow)



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
	transition.to(viewGroup,{time=1000,y=0,transition = easing.inOutExpo})

end