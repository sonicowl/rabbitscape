-----------------------------------------------------------------------------------------
--
-- Map Builder Engine
--
-----------------------------------------------------------------------------------------
require ("ui")

local gameEngine = require("gameEngine")

local selectedObject = nil
local objBoxes = {}
local HUD = display.newGroup()

	
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


function main()

	
	local stdImgW = 50
	local stdImgH = 50
	
	local defaultCellType = { terrainCost = 10, maxMembers = -1,isDynamic = false, isWalkable = true, isExit=false, canPutObjects = true, tag="grass" ,img="cell1.png",imgW=stdImgW*1.4, imgH=stdImgH }
	gameEngine.newLevel({defaultCellType = defaultCellType})

	
	--appearingWeight: if you stick near a sum of 100 is easier to deal! 
	gameEngine.createNewObject({ terrainCost = 10, maxMembers =  1, isDynamic = true , appearingWeight = 0 , isPlaceable = false, isWalkable = true , isExit=false, isFakeExit=false, canPutObjects = true , tag="startCell",img="cell2.png", imgW=stdImgW*1.4, imgH=stdImgH })
	gameEngine.createNewObject({ terrainCost = 10, maxMembers = -1, isDynamic = true , appearingWeight = 0 , isPlaceable = false, isWalkable = true , isExit=true , isFakeExit=false, canPutObjects = true , tag="endCell" ,img="cell3.png", imgW=stdImgW*1.4, imgH=stdImgH })
	gameEngine.createNewObject({ terrainCost = 10, maxMembers = -1, isDynamic = true , appearingWeight = 60, isPlaceable = true , isWalkable = false, isExit=false, isFakeExit=false, canPutObjects = false, tag="rock" ,img="pedra.png", imgW=stdImgW, imgH=stdImgH , clusterEffect = 10})
	gameEngine.createNewObject({ terrainCost = 10, maxMembers = -1, isDynamic = true , appearingWeight = 20, isPlaceable = true , isWalkable = false, isExit=false, isFakeExit=false, canPutObjects = false, tag="vase" ,img="water1.png", imgW=stdImgW, imgH=stdImgH , clusterEffect = 10 })
	gameEngine.createNewObject({ terrainCost = 10, maxMembers = -1, isDynamic = true , appearingWeight = 20, isPlaceable = true , isWalkable = false, isExit=false, isFakeExit=false, canPutObjects = false, tag="tree",img="tree.png", imgW=stdImgW*1.3, imgH=stdImgH*2.5 , clusterEffect = 10 })
	gameEngine.createNewObject({ terrainCost = 10, maxMembers = -1, isDynamic = true , appearingWeight = 0 , isPlaceable = false, isWalkable = true , isExit=false, isFakeExit=false, canPutObjects = false, tag="path" ,img="cell5.png", imgW=stdImgW*1.4, imgH=stdImgH })
	gameEngine.createNewObject({ terrainCost = 10, maxMembers =  1, isDynamic = true , appearingWeight = 0 , isPlaceable = true , isWalkable = true , isExit=true , isFakeExit=true , canPutObjects = false, tag="carrot" ,img="carrot.png", imgW=stdImgW, imgH=stdImgH })
	--loadLevel1()
	--gameEngine.setRabbitSteps(1)
	--gameEngine.startGame()
	listOfBuilderObjects = {"rock","startCell","endCell","path","grass"}
	startLevelBuilder()
end

function startLevelBuilder()
 --generate the object selector
	borderWidth = #listOfBuilderObjects*100
	print(#listOfBuilderObjects)
	local border = display.newRect(_W/2-borderWidth/2,_H-150,borderWidth,100)
	HUD:insert(border)
	for i=0,#listOfBuilderObjects-1 do
		local tempBox = display.newRect(border.x-border.contentWidth/2+10+i*100,border.y-border.contentHeight/2+10,80,80)
		tempBox:setFillColor(140,10,10)
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
	loadButtons()

end

function boxListener(event)
	if event.phase == "ended" then

		if selectedObject ~= nil then
			objBoxes[selectedObject].strokeWidth = 0
		end
		event.target.strokeWidth = 6
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




function loadButtons()

	startButHandler = function( event )
		if event.phase == "release" then
			local starter = gameEngine.startGame()
			if starter ~= false then
				startButton.isVisible = false
				stopButton.isVisible = true
				saveMapButton.isVisible = false
				clearMapButton.isVisible = false
				Runtime:removeEventListener( "touch", builderClickListener )
			end
		end
		return true
	end

	stopGameHandler = function( event )
		if event.phase == "release" and gameEngine.gameRunning then
			gameEngine.stopGame()
			stopButton.isVisible = false
			clearMapButton.isVisible = true
			saveMapButton.isVisible = true
			startButton.isVisible = true
			Runtime:removeEventListener( "touch", builderClickListener )
			Runtime:addEventListener( "touch", builderClickListener )
		end
		return true
	end

	lampButtonHandler = function( event )
		if event.phase == "release" then
			if lampButtonOff.isVisible then
				lampButtonOff.isVisible = false
				lampButtonOn.isVisible = true
				gameEngine.setEndCellPuttingPermission(true)
			else
				lampButtonOff.isVisible = true
				lampButtonOn.isVisible = false
				gameEngine.setEndCellPuttingPermission(false)
			end
		end
	end
	
	lampButton2Handler = function( event )
		if event.phase == "release" then
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
	end

	saveMapHandler = function( event )
		if event.phase == "release" then

			--stop game
		end
	end

	resetMapHandler = function( event )
		if event.phase == "release"  then
			gameEngine.cleanMap()
		end
	end


	startButton = ui.newButton{
		default = "buttonGreen.png",
		over = "buttonGreenOver.png",
		onEvent = startButHandler,
		text = "START",
		emboss = true
	}
	stopButton = ui.newButton{
		default = "buttonRed.png",
		over = "buttonRedOver.png",
		onEvent = stopGameHandler,
		text = "STOP",
		emboss = true,	
	}
	saveMapButton = ui.newButton{
		default = "buttonOrange.png",
		over = "buttonOrangeOver.png",
		onEvent = saveMapHandler,
		text = "SAVE MAP",
		emboss = true
	}
	clearMapButton = ui.newButton{
		default = "buttonOrange.png",
		over = "buttonOrangeOver.png",
		onEvent = resetMapHandler,
		text = "CLEAN MAP",
		emboss = true
	}

	startButton.x = _W/6; startButton.y = 80
	stopButton.x = _W/6; stopButton.y = 80
	saveMapButton.x = _W/6*3; saveMapButton.y = 80
	clearMapButton.x = _W/6*5; clearMapButton.y = 80
	stopButton.isVisible = false

	lampButtonOff = ui.newButton{
		default = "lamp-off.png",
		over = "lamp-on.png",
		onEvent = lampButtonHandler,
		emboss = true
	}
	lampButtonOn = ui.newButton{
		default = "lamp-on.png",
		over = "lamp-off.png",
		onEvent = lampButtonHandler,
		emboss = true
	}
	lampButtonOff.x = _W/6-50; lampButtonOff.y = _H-120
	lampButtonOn.x = _W/6-50; lampButtonOn.y = _H-120
	lampButtonOff.xScale = 2; lampButtonOff.yScale = 2
	lampButtonOn.xScale = 2; lampButtonOn.yScale = 2
	lampButtonOff.isVisible = false

	local lampText = display.newText( "ALLOW", 0,0, native.systemFont,18)
	lampText.x = _W/6-50; lampText.y = _H-80
	local lampText2 = display.newText( "OBJECTS", 0,0, native.systemFont,18)
	lampText2.x = _W/6-50; lampText2.y = _H-60
	local lampText3 = display.newText( "ON EXITS", 0,0, native.systemFont,18)
	lampText3.x = _W/6-50; lampText3.y = _H-40
	
	
	lampButton2Off = ui.newButton{
		default = "lamp-off.png",
		over = "lamp-on.png",
		onEvent = lampButton2Handler,
		emboss = true
	}
	lampButton2On = ui.newButton{
		default = "lamp-on.png",
		over = "lamp-off.png",
		onEvent = lampButton2Handler,
		emboss = true
	}
	lampButton2Off.x = _W-70; lampButton2Off.y = _H-120
	lampButton2On.x = _W-70; lampButton2On.y = _H-120
	lampButton2Off.xScale = 2; lampButton2Off.yScale = 2
	lampButton2On.xScale = 2; lampButton2On.yScale = 2
	lampButton2On.isVisible = false

	local lampText = display.newText( "PUT", 0,0, native.systemFont,18)
	lampText.x = _W-70; lampText.y = _H-80
	local lampText2 = display.newText( "CARROT", 0,0, native.systemFont,18)
	lampText2.x = _W-70; lampText2.y = _H-60
	
end








Runtime:addEventListener( "touch", builderClickListener )
--getCellByXY





function loadLevel1()

	for i = 7 , 18 do
		gameEngine.placeNewObject({x=1,y=i,object="endCell"})
		gameEngine.placeNewObject({x=13,y=i-6,object="endCell"})
	end
	local lineHelper = 19
	for i = 1,13 do
		if i%2==1 then lineHelper = lineHelper-1 end
		gameEngine.placeNewObject({x=i,y=lineHelper,object="endCell"})
	end

	gameEngine.placeNewObject({x=4,y=8,object="rock"})
	gameEngine.placeNewObject({x=4,y=9,object="vase"})
	gameEngine.placeNewObject({x=5,y=8,object="rock"})
	gameEngine.placeNewObject({x=6,y=7,object="rock"})
	gameEngine.placeNewObject({x=5,y=7,object="rock"})
	
	gameEngine.placeNewObject({x=11,y=12,object="rock"})
	gameEngine.placeNewObject({x=10,y=11,object="vase"})
	gameEngine.placeNewObject({x=10,y=12,object="rock"})
	gameEngine.placeNewObject({x=9,y=13,object="vase"})
	gameEngine.placeNewObject({x=9,y=12,object="rock"})
	gameEngine.placeNewObject({x=10,y=13,object="vase"})
	gameEngine.placeNewObject({x=9,y=14,object="rock"})
	gameEngine.placeNewObject({x=10,y=14,object="rock"})
	
	gameEngine.placeNewObject({x=13,y=4,object="rock"})
	gameEngine.placeNewObject({x=13,y=4,object="rock"})
	gameEngine.placeNewObject({x=13,y=5,object="rock"})
	gameEngine.placeNewObject({x=13,y=6,object="vase"})
	
	gameEngine.placeNewObject({y=12,x=6,object="path"})
	gameEngine.placeNewObject({y=12,x=5,object="path"})
	gameEngine.placeNewObject({y=13,x=5,object="path"})
	gameEngine.placeNewObject({y=13,x=4,object="path"})
	gameEngine.placeNewObject({y=14,x=4,object="path"})
	gameEngine.placeNewObject({y=14,x=5,object="path"})
	gameEngine.placeNewObject({y=13,x=6,object="path"})
	gameEngine.placeNewObject({y=13,x=7,object="path"})
	gameEngine.placeNewObject({y=12,x=7,object="path"})
	gameEngine.placeNewObject({y=14,x=6,object="path"})
	gameEngine.placeNewObject({y=15,x=4,object="path"})
	gameEngine.placeNewObject({y=15,x=3,object="path"})
	gameEngine.placeNewObject({y=14,x=3,object="path"})
	gameEngine.placeNewObject({y=13,x=3,object="path"})

	gameEngine.placeNewObject({x=7,y=9,object="startCell"})
end





main()