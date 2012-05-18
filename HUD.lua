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

function init(restartlistener,viewGroup)
	actions = {}
	HUD = display.newGroup()
	viewGroup:insert(HUD)
	restartListener = restartlistener
	
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


end





function loadActions()

	actions["restartGame"] = function(event)
		print("touched "..tostring(event.id))
		if endGameScreen.numChildren > 0 then
			for i = endGameScreen.numChildren, 1,-1 do
				endGameScreen[i]:removeSelf()
				endGameScreen[i] = nil
			end
		end
		restartListener()
		touchHandled = false
	end	
	
	buttonHandler = function( event )	-- General function for all buttons (uses "actions" table above)
		if ("release" == event.phase) and not touchHandled then
			touchHandled = true
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
	local myRoundedRect = display.newRoundedRect(_W/2-175, _H/2-100 , 350, 200, 12)
	myRoundedRect.strokeWidth = 3
	myRoundedRect:setFillColor(140, 140, 140)
	myRoundedRect:setStrokeColor(180, 180, 180)
	local msg = nil
	if didWon then
		msg = "YOU WIN!"
	else
		msg = "YOU LOOSE!"
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
	resetButton.x = _W/2; resetButton.y = _H/2+50
	endGameScreen:insert(myRoundedRect)
	endGameScreen:insert(myText)
	endGameScreen:insert(resetButton)
end
