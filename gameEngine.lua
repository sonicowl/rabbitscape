-----------------------------------------
-- gameEngine.lua
-- Version 1.0
-- Author: Thiago Ramos
-- Functions:
--		
-----------------------------------------


module(..., package.seeall)

--newLevel params: sceneBg, overlayBg, hasCarrot,defaultCellType?...
function newLevel(params)
	HUD = require("HUD")
	aStar = require("aStar")
	mapCreator = require("mapCreator")
	
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
	
	--GAME FLAGS
	rabbit = {}
	rabbit.steps = 1
	rabbit.actualSteps = 1
	gameRunning = false
	
	-- MAP VARS
	levelMap = nil
	local map_lines = 13
	local map_cols = 13
	local mapW = _VW*.9
	local mapH = _VW*.9
	
	
	local defaultCellType = params.defaultCellType
	levelMap = mapCreator.createHexMap((_W-mapW)/2 , (_H-mapH)/2 , mapW , mapH , map_lines , map_cols, defaultCellType)
	
	if params.sceneBg ~= nil then
		--display new image... blablabla
	end	
	
	if params.overlayBg ~= nil then
		--display new image... blablabla
	end
	
	
	
	HUD.init(restartGame)
	
	
	--updateScene()
end



--mapCreator.createNewObject(levelMap,{ terrainCost = 10, maxMembers = -1, isWalkable = false, canPutObjects = false, tag="rock" ,img="cell4.png", clusterEffect = 5, members = {} })
--addNewObject params: isDynamic, img, correctionX, correctionY, cellTypeParams, xScale, yScale

function createNewObject(params)
	mapCreator.createNewObject(levelMap,params) --directly to mapCreator, everything on celltypeparams
end



function objectListener(event,cell)
	print("listening event of cell "..cell.line.." "..cell.column)
end


--TODO: VIEW LISTENER PART
function placeNewObject(params)
	mapCreator.placeObject(levelMap[params.x][params.y], params.object)
end

function setRabbitSteps(steps)
	if steps > 0 then
		rabbit.steps = steps
	else
		print("negative steps are not allowed")
	end
end





--on clicks
function gameClickListener(event)
	if event.phase == "ended" and gameRunning then
		local cell = mapCreator.getCellByXY(event.x,event.y,levelMap)
		if cell == false then
			print("clicking outside of the matrix")
			return false
		end
		if cell.line == rabbit.y and cell.column == rabbit.x then 
			print("clicking over the rabbit!")
			return false
		end
		if cell.mapRef.objects[cell.id].canPutObjects then
			print("clicking "..cell.line..","..cell.column)
			local objTag = mapCreator.getRandomPlaceableObject(levelMap)
			mapCreator.placeObject(cell, objTag)
			mapCreator.updateHexGrid(levelMap)
			timer.performWithDelay(100, moveRabbit )
		else
			print("cant put objects here")
		end
	end
	return true
end


function moveRabbit()
	for i=1,rabbit.actualSteps do
		if gameRunning == true then
			path = findShorterExit(rabbit.x,rabbit.y)
			if path == false then
				path = aStar.pathWithoutExit(rabbit.x,rabbit.y,levelMap)
				if path == false then
					print("You got the rabbit")
					gameRunning = false
					HUD.callEndingScreen(true)
					return false
				end
			end
			tempX = path[table.getn(path)-1].x
			tempY = path[table.getn(path)-1].y
			rabbit.x = tempX
			rabbit.y = tempY
			transition.to(rabbit.img,{x=levelMap[tempX][tempY].hexX, y= levelMap[tempX][tempY].hexY,time=500})
			if levelMap.objects[levelMap[rabbit.x][rabbit.y].id].tag == "endCell" then 
				gameRunning = false
				print("YOU LOOSE")
				HUD.callEndingScreen(false)
			end	
			if levelMap.objects[levelMap[rabbit.x][rabbit.y].id].isFakeExit then 
				placeNewObject({x=rabbit.x,y=rabbit.y,object="grass"})
			end
		end
	end
	rabbit.actualSteps = rabbit.actualSteps%rabbit.steps+1
end




function findShorterExit(x0,y0)
	endMembers = {}
	for i=1, #levelMap.objects do	
		if levelMap.objects[i].isExit then
			for j=1, #levelMap.objects[i].members do
				table.insert(endMembers, deepcopy(levelMap.objects[i].members[j]))
			end
		end
	end
--	local endCellType = mapCreator.getCellTypeByTag(levelMap,"endCell")
--	local possiblePaths = aStar.findMultiplePaths( x0, y0 , endCellType.members, levelMap)
	local possiblePaths = aStar.findMultiplePaths( x0, y0 , endMembers, levelMap)
	if possiblePaths ~= false then
		local pathToGo = possiblePaths[1]
		if pathToGo ~= false then
			return pathToGo
		end
	else
		print("NO POSSIBLE EXITS")
		return false
	end
end





--get the start position
--draw rabbit
function startGame()
	--save the first state of the level
	saveMap(levelMap)
	local startCellType = mapCreator.getCellTypeByTag(levelMap,"startCell")
	if startCellType ~= false then
		gameRunning = true
		local x = startCellType.members[1].x
		local y = startCellType.members[1].y
		rabbit.x = x
		rabbit.y = y
		rabbit.img = display.newImageRect("rabbit.png" , levelMap[x][y].hexW*.8, levelMap[x][y].hexH*.8)
		rabbit.img.x = levelMap[x][y].hexX
		rabbit.img.y = levelMap[x][y].hexY
		Runtime:addEventListener( "touch", gameClickListener )
	else
		print("no start point")
	end
end


function restartGame()
	reloadMap()
	startGame()
end


function reloadMap()
	--clean everything
	for j=1,table.getn(levelMap) do
		if levelMap[j] ~= nil then
			for i=1,table.getn(levelMap[j]) do
				if levelMap[j][i] ~= nil then
					if levelMap[j][i].obj ~= nil then levelMap[j][i].obj:removeSelf() levelMap[j][i].obj = nil end
					--placeNewObject({x=j,y=i,object="grass"})
				end
			end
		end
	end
	--load startingMap
	print("cleaned everything")
	levelMap = deepcopy(startingMap)
	for j=1,table.getn(levelMap) do
		if levelMap[j] ~= nil then
			for i=1,table.getn(levelMap[j]) do
				if levelMap[j][i] ~= nil then
					local tag = levelMap.objects[levelMap[j][i].id].tag
					--placeNewObject(j,i,"grass")
					placeNewObject({x=j,y=i,object=tag})
				end
			end
		end
	end
	
	if gameRunning then gameRunning = false end
	--dontforget the rabbit
	if rabbit.img ~= nil then rabbit.img:removeSelf() rabbit.img = nil end
end


function saveMap(map)
	startingMap =  deepcopy(map)
	for j=1,#startingMap do
		if startingMap[j] ~= nil then
			for i=1,#startingMap do
				if startingMap[j][i] ~= nil then
					startingMap[j][i].obj = nil
					--placeNewObject({x=j,y=i,object="grass"})
				end
			end
		end
	end
--[[	for j=1,table.getn(map) do
		if map[j] ~= nil then
			startingMap[j] = {}
			for i=1,table.getn(map[j]) do
				if map[j][i] ~= nil then
					local startingMap[j][i] = map[j][i]
					
				end
			end
		end
	end]]--

end

function loadSavedMap()
	if startingMap ~= nil then
		
	end
end

function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end