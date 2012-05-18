-----------------------------------------------------------------------------------------
--
-- Map Builder USER INTERFACE
--
-----------------------------------------------------------------------------------------
module(..., package.seeall)


function init(engine,builderObjects,viewGroup)

	require ("ui")
	listOfBuilderObjects = builderObjects
	gameEngine = engine
	selectedObject = nil
	objBoxes = {}
	actions = {}
	HUD = viewGroup
	
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
	
	loadToolBox()
	loadActions()
	loadButtons()
	loadHeader()
	
	start()
	
end


function loadHeader()
	--Setup the nav bar 
	local navBar = display.newImageRect("navBar.png",_VW,40)
	navBar.x = display.contentWidth*.5
	navBar.y = math.floor(_VH0 + navBar.height*0.5)
	HUD:insert(navBar)
	
	local navHeader = display.newText("LEVEL BUILDER", 0, 0, native.systemFontBold, 16)
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
	


function loadToolBox()
 --generate the object selector
	borderWidth = #listOfBuilderObjects*90+10
	local border = display.newRoundedRect(_W/2-borderWidth/2,_H-150,borderWidth,100,10)
	border:setFillColor(0,0,0)
	border.alpha = .8
	--border.strokeWidth = 6
	--border:setStrokeColor( 80,10,10)
	HUD:insert(border)
	for i=0,#listOfBuilderObjects-1 do
		local tempBox = display.newRoundedRect(border.x-border.contentWidth/2+10+i*90,border.y-border.contentHeight/2+10,80,80,10)
		tempBox:setFillColor(250,250,250)
		tempBox.alpha = .6
		tempBox:setStrokeColor( 10,140,10)
		tempBox.id = i+1
		local tempObject = gameEngine.getObjectByTag(listOfBuilderObjects[i+1])
		local tempIcon = display.newImageRect(tempObject.img,70,70)
		tempIcon.x = tempBox.x
		tempIcon.y = tempBox.y
		HUD:insert(tempBox)
		HUD:insert(tempIcon)
		table.insert(objBoxes,tempBox)
		tempBox:addEventListener("touch",boxListener)
	end
end

function boxListener(event)
	if event.phase == "ended" then

		if selectedObject ~= nil then
			objBoxes[selectedObject].strokeWidth = 0
			objBoxes[selectedObject].alpha = .6
		end
		event.target.strokeWidth = 6
		event.target.alpha = .8
		selectedObject = event.target.id
	end
	return false
end


function builderClickListener(event)
	if selectedObject~= nil then
		if event.phase == "ended" then
			local cell = gameEngine.getCellByXY(event.x,event.y)
			if cell == false then
				print("clicking outside of the matrix")
				return false
			end
			local obj = gameEngine.getObjectByTag(listOfBuilderObjects[selectedObject])
			if #obj.members < obj.maxMembers or obj.maxMembers == -1 then
				print("clicking "..cell.line..","..cell.column.." placing: "..listOfBuilderObjects[selectedObject])
				gameEngine.placeNewObject({x=cell.column,y=cell.line,object=listOfBuilderObjects[selectedObject]})
			end
		end
	end
end

function loadActions()

	actions["sceneBack"] = function(event)
		print("touched "..tostring(event.id))
		gameEngine.quitGame()
	end	

	actions["saveMapButton"] = function(event)
		print("touched "..tostring(event.id))
		gameEngine.saveJsonMap()
	end	
	
	actions["resetMapButton"] = function(event)
		print("touched "..tostring(event.id))
		gameEngine.cleanMap()
	end	
	
	actions["!!!SAMPLE!!!"] = function(event)
		print("touched "..tostring(event.id))
	end	
	
	actions["carrotButton"] = function(event)
		print("touched "..tostring(event.id))
		if lampButton2Off.isVisible then
			lampButton2Off.isVisible = false
			lampButton2On.isVisible = true
			gameEngine.setPutCarrots(true)
		else
			lampButton2Off.isVisible = true
			lampButton2On.isVisible = false
			gameEngine.setPutCarrots(false)
		end
	end	
	
	actions["objectsOnExits"] = function(event)
		print("touched "..tostring(event.id))
		if closeExitsButOff.isVisible then
			closeExitsButOff.isVisible = false
			closeExitsButOn.isVisible = true
			gameEngine.setEndCellPuttingPermission(true)
		else
			closeExitsButOff.isVisible = true
			closeExitsButOn.isVisible = false
			gameEngine.setEndCellPuttingPermission(false)
		end
	end	
	
	actions["startButton"] = function(event)
		print("touched "..tostring(event.id))
		local starter = gameEngine.startGame() --will return false if there is no start point
		if starter ~= false then
			startButton.isVisible = false
			stopButton.isVisible = true
			saveMapButton.isVisible = false
			clearMapButton.isVisible = false
			Runtime:removeEventListener( "touch", builderClickListener )
		end
	end	
	
	actions["stopButton"] = function(event)
		print("touched "..tostring(event.id))
		gameEngine.stopGame()
		stopButton.isVisible = false
		clearMapButton.isVisible = true
		saveMapButton.isVisible = true
		startButton.isVisible = true
		Runtime:removeEventListener( "touch", builderClickListener )
		Runtime:addEventListener( "touch", builderClickListener )
	end	
	
	buttonHandler = function( event )	-- General function for all buttons (uses "actions" table above)
		if ("release" == event.phase) then
			actions[event.id](event)
		end
		return true  --SO SIMPLE AND SO CONFUSING.... THIS PREVENTS FROM PROPAGATING TO OTHER BUTTONS
	end

end



function loadButtons()	

	startButton = ui.newButton{
		default = "buttonGreen.png",
		over = "buttonGreenOver.png",
		onEvent = buttonHandler,
		id = "startButton",
		text = "START",
		emboss = true
	}
	stopButton = ui.newButton{
		default = "buttonRed.png",
		over = "buttonRedOver.png",
		onEvent = buttonHandler,
		id = "stopButton",
		text = "STOP",
		emboss = true,	
	}
	saveMapButton = ui.newButton{
		default = "buttonOrange.png",
		over = "buttonOrangeOver.png",
		onEvent = buttonHandler,
		id = "saveMapButton",
		text = "SAVE MAP",
		emboss = true
	}
	clearMapButton = ui.newButton{
		default = "buttonOrange.png",
		over = "buttonOrangeOver.png",
		onEvent = buttonHandler,
		id = "resetMapButton",
		text = "CLEAN MAP",
		emboss = true
	}
	closeExitsButOff = ui.newButton{
		default = "lamp-off.png",
		over = "lamp-on.png",
		id = "objectsOnExits",
		onEvent = buttonHandler,
		emboss = true
	}
	closeExitsButOn = ui.newButton{
		default = "lamp-on.png",
		over = "lamp-off.png",
		id = "objectsOnExits",
		onEvent = buttonHandler,
		emboss = true
	}
	lampButton2Off = ui.newButton{
		default = "lamp-off.png",
		over = "lamp-on.png",
		id = "carrotButton",
		onEvent = buttonHandler,
		emboss = true
	}
	lampButton2On = ui.newButton{
		default = "lamp-on.png",
		over = "lamp-off.png",
		id = "carrotButton",
		onEvent = buttonHandler,
		emboss = true
	}
	
	startButton.x = _W/6; startButton.y = 80
	stopButton.x = _W/6; stopButton.y = 80
	stopButton.isVisible = false
	saveMapButton.x = _W/6*3; saveMapButton.y = 80
	clearMapButton.x = _W/6*5; clearMapButton.y = 80
	closeExitsButOff.x = _W/6-50; closeExitsButOff.y = _H-120
	closeExitsButOn.x = _W/6-50; closeExitsButOn.y = _H-120
	closeExitsButOff.xScale = 2; closeExitsButOff.yScale = 2
	closeExitsButOn.xScale = 2; closeExitsButOn.yScale = 2
	closeExitsButOff.isVisible = false
	lampButton2Off.x = _W-70; lampButton2Off.y = _H-120
	lampButton2On.x = _W-70; lampButton2On.y = _H-120
	lampButton2Off.xScale = 2; lampButton2Off.yScale = 2
	lampButton2On.xScale = 2; lampButton2On.yScale = 2
	lampButton2On.isVisible = false

	
	local closeExitsTxt = display.newText( "ALLOW", 0,0, native.systemFont,18)
	closeExitsTxt.x = _W/6-50; closeExitsTxt.y = _H-80
	local closeExitsTxt2 = display.newText( "OBJECTS", 0,0, native.systemFont,18)
	closeExitsTxt2.x = _W/6-50; closeExitsTxt2.y = _H-60
	local closeExitsTxt3 = display.newText( "ON EXITS", 0,0, native.systemFont,18)
	closeExitsTxt3.x = _W/6-50; closeExitsTxt3.y = _H-40
	local carrotTxt = display.newText( "PUT", 0,0, native.systemFont,18)
	carrotTxt.x = _W-70; carrotTxt.y = _H-80
	local carrotTxt2 = display.newText( "CARROT", 0,0, native.systemFont,18)
	carrotTxt2.x = _W-70; carrotTxt2.y = _H-60
	
	
	HUD:insert(startButton)
	HUD:insert(stopButton)
	HUD:insert(saveMapButton)
	HUD:insert(clearMapButton)
	HUD:insert(closeExitsButOff)
	HUD:insert(closeExitsButOn)
	HUD:insert(lampButton2Off)
	HUD:insert(lampButton2On)
	HUD:insert(closeExitsTxt)
	HUD:insert(closeExitsTxt2)
	HUD:insert(closeExitsTxt3)
	HUD:insert(carrotTxt)
	HUD:insert(carrotTxt2)
end


function close()
	Runtime:removeEventListener( "touch", builderClickListener )
end

function start()
	Runtime:addEventListener( "touch", builderClickListener )
end