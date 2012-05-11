-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local ui = require("ui")
local gameEngine = require("gameEngine")
--local aStar = require("aStar")
--local mapCreator = require("mapCreator")


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



rabbit = {}
gameRunning = false
levelMap = nil
map_lines = 13
map_cols = 13

--mapColMod = map_cols%2
--create a new lines measure cause we have different axes (not top-down and right-left)
--coordinatedLines = (map_cols-map_cols%2)/2+map_lines-map_cols%2
--SEMPRE TERA DE SER IMPAR -- talvez eu tenha corrigido isso...
--frame = display.newRect( GAMEBOX_FRAME_W0+10, GAMEBOX_FRAME_H0+10, GAMEBOX_FRAME_W-20, GAMEBOX_FRAME_H-20)
--frame:setReferencePoint( TopLeftReferencePoint )




function main()

	mapW = _VW*.9
	mapH = _VW*.9
	--levelMap = mapCreator.createHexMap((_W-mapW)/2 , (_H-mapH)/2+20 , mapW , mapH , map_lines , map_cols, objects)
	local defaultCellType = { terrainCost = 10, maxMembers = -1,isDynamic = false, isWalkable = true, isExit=false, canPutObjects = true, tag="grass" ,img="cell1.png", members = {} }
	gameEngine.newLevel({defaultCellType = defaultCellType})
	--levelMap = mapCreator.createHexMap((_W-mapW)/2 , (_H-mapH)/2 , mapW , mapH , map_lines , map_cols, defaultCellType)
	local stdImgW = 50
	local stdImgH = 50
	--appearingWeight: if you stick near a sum of one is easier to deal!
	gameEngine.createNewObject({ terrainCost = 10, maxMembers =  1, isDynamic = false, appearingWeight = 0 , isPlaceable = false, isWalkable = true, isExit=false, isFakeExit=false, canPutObjects = true, tag="startCell",img="cell2.png", imgW=stdImgW, imgH=stdImgH , members = {} })
	gameEngine.createNewObject({ terrainCost = 10, maxMembers = -1, isDynamic = true , appearingWeight = 0 , isPlaceable = false, isWalkable = true, isExit=true, isFakeExit=false, canPutObjects = true, tag="endCell" ,img="cell3.png", imgW=stdImgW*1.4, imgH=stdImgH , members = {}})
	gameEngine.createNewObject({ terrainCost = 10, maxMembers = -1, isDynamic = true , appearingWeight = 50, isPlaceable = true, isWalkable = false, isExit=false, isFakeExit=false, canPutObjects = false, tag="rock" ,img="pedra.png", imgW=stdImgW, imgH=stdImgH , clusterEffect = 10, members = {} })
	gameEngine.createNewObject({ terrainCost = 10, maxMembers = -1, isDynamic = true , appearingWeight = 10, isPlaceable = true, isWalkable = false, isExit=false, isFakeExit=false, canPutObjects = false, tag="vase" ,img="water1.png", imgW=stdImgW, imgH=stdImgH , clusterEffect = 10, members = {} })
	gameEngine.createNewObject({ terrainCost = 10, maxMembers = -1, isDynamic = true , appearingWeight = 30, isPlaceable = true, isWalkable = false, isExit=false, isFakeExit=false, canPutObjects = false, tag="tree",img="tree.png", imgW=stdImgW*1.3, imgH=stdImgH*2.5 , clusterEffect = 10, members = {} })
	gameEngine.createNewObject({ terrainCost = 10, maxMembers = -1, isDynamic = true , appearingWeight = 0 , isPlaceable = false, isWalkable = true, isExit=false, isFakeExit=false, canPutObjects = false, tag="path" ,img="cell5.png", imgW=stdImgW*1.4, imgH=stdImgH , members = {} })
	gameEngine.createNewObject({ terrainCost = 10, maxMembers = 1 , isDynamic = true , appearingWeight = 10, isPlaceable = true, isWalkable = true, isExit=true, isFakeExit=true, canPutObjects = false, tag="carrot" ,img="carrot.png", imgW=stdImgW, imgH=stdImgH , members = {} })
	loadLevel1()
	gameEngine.setRabbitSteps(1)
	gameEngine.startGame()
end





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






















--[[



buttonHandler = function( event )
	if event.phase == "release" then
		if rabbit.img ~= nil then rabbit.img:removeSelf() rabbit.img = nil end
		startGame(levelMap)
	end
end


button2Handler = function( event )
	if event.phase == "release" then
		if rabbit.img ~= nil then rabbit.img:removeSelf() rabbit.img = nil end
		gameRunning = false
		--stop game
	end
end

resetMapHandler = function( event )
	if event.phase == "release" then
		resetMap(levelMap)
	end
end


local button1 = ui.newButton{
	default = "buttonGreen.png",
	over = "buttonGreenOver.png",
	onEvent = buttonHandler,
	text = "START",
	emboss = true
}
button1.x = _W/4; button1.y = 80

local button2 = ui.newButton{
	default = "buttonOrange.png",
	over = "buttonOrangeOver.png",
	onEvent = button2Handler,
	text = "END GAME",
	emboss = true
}

local button3 = ui.newButton{
	default = "buttonRed.png",
	over = "buttonRedOver.png",
	onEvent = resetMapHandler,
	text = "RESET MAP",
	emboss = true
}

level1Handler = function( event )
	if event.phase == "release" then
		resetMap(levelMap)
		mapCreator.loadLevel1(levelMap)
		drawMap(levelMap)
	end
end

local button4 = ui.newButton{
	default = "buttonRed.png",
	over = "buttonRedOver.png",
	onEvent = level1Handler,
	text = "LEVEL1",
	emboss = true
}
button1.x = _W/4; button1.y = 80
button2.x = _W/4*3; button2.y = 80
button3.x = _W/4*3; button3.y = (_H-_VH)/2+_VH-80
button4.x = _W/4; button4.y = (_H-_VH)/2+_VH-80
]]--


main()