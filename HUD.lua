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

function init(restartListener)
	actions = {}
	HUD = display.newGroup()
	endGameScreen = display.newGroup()
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

function callEndingScreen(didWon)
	
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
