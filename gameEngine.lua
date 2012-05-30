-----------------------------------------
-- gameEngine.lua
-- Version 1.0
-- Author: Thiago Ramos
-- Functions:
--		
-- RoadMap: missing the check of maxMembers
--
-----------------------------------------


module(..., package.seeall)

--newLevel params: sceneBg, overlayBg, hasCarrot,defaultCellType?...
function newLevel(params)
	HUD = require("HUD")
	aStar = require("aStar")
	mapCreator = require("mapCreator")
	jsonLevels = require("jsonLevels")
	jsonLevels.init()
	storyboard = params.storyBoard
	lastScene = params.lastScene
	sceneGroup = params.viewGroup
	bgGroup = display.newGroup()
	sceneGroup:insert(bgGroup)
	
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
	putCarrot = false
	rabbit.steps = 1
	rabbit.actualSteps = 1
	gameRunning = false
	gameStartTime = system.getTimer()
	lastLoopTime = system.getTimer()
	gameScore = 10000
	gameStartScore = 10000
	rocksPut = 0
	secsPlaying = 0
	
	
	-- MAP VARS
	levelMap = nil
	local map_lines = 13
	local map_cols = 13
	local mapW = _VW*.93
	local mapH = _VW*1.05	

	--[[if storyboard.getCurrentSceneName() == "levelBuilder" then
		mapW = _VW*.90
		mapH = _VW*.9
		print("CHANGING MAP W H")
	end]]--
	--local defaultCellType = params.defaultCellType
	levelMap = mapCreator.createHexMap((_W-mapW)/2+5 , (_H-mapH)/2-30 , mapW , mapH , map_lines , map_cols, params.defaultCellType,sceneGroup)
	
	rabbitsGroup = display.newGroup()
	sceneGroup:insert(rabbitsGroup)
	
	overLayGroup = display.newGroup()
	sceneGroup:insert(overLayGroup)	
	
	
	HUD.init(sceneGroup,{restart = restartListener, quit = quitGame, resume = resumeGame, pause = stopGame})
	

end


function updateScore(event)
	if system.getTimer() > lastLoopTime + 100  and gameRunning then
			gameScore = gameScore - gameScore*.0001
			local millisPlaying = system.getTimer() - gameStartTime
			secsPlaying = math.floor((millisPlaying-millisPlaying%1000)/1000)
			lastLoopTime = system.getTimer()
			HUD.updateGameScene(math.ceil(gameScore),secsPlaying,rocksPut)
	end
end


function insertBg(file)

	local bg = display.newImageRect(file,_VW,_VH)
	bg.x = _W/2
	bg.y = _H/2
	bgGroup:insert(bg)

end

function insertOverLay(file)

	local bg = display.newImageRect(file,_VW,_VH)
	bg.x = _W/2
	bg.y = _H/2
	overLayGroup:insert(bg)

end

function createNewObject(params)
	mapCreator.createNewObject(levelMap,params) --directly to mapCreator, everything on celltypeparams
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
			local objTag = nil
			if putCarrot then
				objTag = "carrot"
			else
				--objTag = mapCreator.getRandomPlaceableObject(levelMap)
				if storyboard.getPrevious() == "levelBuilder" then
					objTag = "rock"
				else
					objTag = "rock2"
				end
			end
			rocksPut = rocksPut + 1
			gameScore = gameScore - gameScore*.01
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
					print("YOU GOT THE RABBIT")
					stopGame()
					HUD.callEndingScreen(true)
					return false
				end
			end
			tempX = path[table.getn(path)-1].x
			tempY = path[table.getn(path)-1].y
			rabbit.x = tempX
			rabbit.y = tempY
			transition.to(rabbit.img,{x=levelMap[tempX][tempY].hexX+5, y= levelMap[tempX][tempY].hexY+10,time=500})
			
			--CHECK IF IT ARRIVED ON A EXIT CELL
			if levelMap.objects[levelMap[rabbit.x][rabbit.y].id].tag == "endCell" then 
				stopGame()
				print("YOU LOOSE")
				HUD.callEndingScreen(false)
			end		
			--BELOW AN IMPLEMENTATION FOR THE FAKE EXITS(E.G. CARROT)
			if levelMap.objects[levelMap[rabbit.x][rabbit.y].id].isFakeExit then 
				placeNewObject({x=rabbit.x,y=rabbit.y,object="grass"})
			end
		end
	end
	rabbit.actualSteps = rabbit.actualSteps%rabbit.steps+1
end




function findShorterExit(x0,y0)
	local possibleExits = {}
	for i=1, #levelMap.objects do	
		if levelMap.objects[i].isExit then
			for j=1, #levelMap.objects[i].members do
				table.insert(possibleExits, deepcopy(levelMap.objects[i].members[j]))
			end
		end
	end
	local possiblePaths = aStar.findMultiplePaths( x0, y0 , possibleExits, levelMap)
	
	if possiblePaths ~= false then
		local pathToGo = possiblePaths[1]
		--IMPLEMENT A RANDOM ERROR FOR THE RABBIT
		if #possiblePaths > 2 and possiblePaths[1].totalCost > 50 then
			local randomNum = math.random(100)
			if randomNum < 85 then
				pathToGo = possiblePaths[1]
			elseif randomNum < 95 then
				pathToGo = possiblePaths[2]
			else
				pathToGo = possiblePaths[3]
			end
		end
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
	local startCellType = mapCreator.getCellTypeByTag(levelMap,"startCell")
	--save the first state of the level
	if  startCellType ~= false  and #startCellType.members > 0 then
		saveMap(levelMap)
		gameRunning = true
		local x = startCellType.members[1].x
		local y = startCellType.members[1].y
		rabbit.x = x
		rabbit.y = y
		rabbit.img = display.newImageRect("rabbit-1.png" , levelMap[x][y].hexW, levelMap[x][y].hexH*1.1)
		rabbit.img.x = levelMap[x][y].hexX+5
		rabbit.img.y = levelMap[x][y].hexY+10
		rabbitsGroup:insert(rabbit.img)
		HUD.loadScreenUI()
		local closure = function() Runtime:addEventListener( "touch", gameClickListener ) end
		timer.performWithDelay(150,closure)
		Runtime:addEventListener("enterFrame",updateScore)
	else
		print("no start point")
		return false
	end
end


function restartListener()
	reloadMap()
	restartGame()
end

function restartGame()
	gameScore = gameStartScore
	rocksPut = 0
	gameStartTime = system.getTimer()
	return startGame()
end

function stopGame()
	gameRunning = false
	HUD.hideScreenUI()
	Runtime:removeEventListener( "touch", gameClickListener )
	Runtime:removeEventListener("enterFrame",updateScore)
end

function resumeGame()
	gameRunning = true
	HUD.loadScreenUI()
	Runtime:addEventListener( "touch", gameClickListener )
	Runtime:addEventListener("enterFrame",updateScore)
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
					placeNewObject({x=j,y=i,object=tag})
				end
			end
		end
	end
	
	if gameRunning then gameRunning = false end
	--dontforget the rabbit
	if rabbit.img ~= nil then rabbit.img:removeSelf() rabbit.img = nil end
end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
---------FOR THE LEVEL BUILDER
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------

function getMap()
	return levelMap
end

function cleanMap()
	--if gameRunning then stopGame() end
	--clean everything
	for j=1,table.getn(levelMap) do
		if levelMap[j] ~= nil then
			for i=1,table.getn(levelMap[j]) do
				if levelMap[j][i] ~= nil then
					placeNewObject({x=j,y=i,object="grass"})
				end
			end
		end
	end
	--dontforget the rabbit
	if rabbit.img ~= nil then rabbit.img:removeSelf() rabbit.img = nil end
end

function setEndCellPuttingPermission(bool)
  local cell = mapCreator.getCellTypeByTag(levelMap,"endCell")
  cell.canPutObjects = bool
end

function getObjectByTag(tag)
	return mapCreator.getCellTypeByTag(levelMap,tag)
end

function getCellByXY(x,y)
	return mapCreator.getCellByXY(x,y,levelMap)
end

function setPutCarrots(bool)
	if bool then
		putCarrot = true
	else
		putCarrot = false
	end
end

function saveJsonMap()
	jsonLevels.saveMap(levelMap)
	HUD.toast("Map saved successfully")
end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------


function quitGame()
	if gameRunning then stopGame() end
	print("going to "..lastScene)
	storyboard.gotoScene( lastScene, "slideRight", 400 )
end



function saveMap(map)
	startingMap =  deepcopy(map)
	for j=1,#startingMap do
		if startingMap[j] ~= nil then
			for i=1,#startingMap do
				if startingMap[j][i] ~= nil then
					startingMap[j][i].obj = nil
				end
			end
		end
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