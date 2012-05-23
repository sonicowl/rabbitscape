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
	




function loadActions()


	actions["sceneBack"] = function(event)
		print("touched "..tostring(event.id))
		quitListener()
	end

	actions["restartGame"] = function(event)
		print("touched "..tostring(event.id))
		if endGameScreen.numChildren > 0 then
			for i = endGameScreen.numChildren, 1,-1 do
				endGameScreen[i]:removeSelf()
				endGameScreen[i] = nil
			end
		end
		restartListener()
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
