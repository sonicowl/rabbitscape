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




---------------------------------------------------------
--#####################################################--
--	newLevel() 
--  *Creates a new blank level with only the default object type
--	  and no objects placed.
--
--	PARAMETERS
--	params.storyBoard	:	scene storyboard
--	params.viewGroup	:	the scene view group
--
--#####################################################--
---------------------------------------------------------
function newLevel(params)
	require "sprite"
	require("ice")
	HUD = require("HUD")
	aStar = require("aStar")
	mapCreator = require("mapCreator")
	jsonLevels = require("jsonLevels")
	rabbitModule = require("module-rabbit")
	dialogsModule = require("module-dialogs")
	jsonLevels.init()
	storyboard = params.storyBoard
	sceneGroup = params.viewGroup
	bgGroup = display.newGroup()
	sceneGroup:insert(bgGroup)

	gameData = ice:loadBox( "gameData" )
	storeData = ice:loadBox("storeData")
	gameData:storeIfNew( storyboard.sceneryId.."-"..storyboard.levelId, 0 )
	gameData:save()
	
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
	
	--GAME VARS
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
	msPerFrame = 80
	usedCarrot = false
	
	-- MAP VARS
	levelMap = nil
	local map_lines = 13
	local map_cols = 13
	local mapW = _VW*.93
	local mapH = _VW*1.05	

	if storyboard.getCurrentSceneName() == "levelBuilder" then
		mapW = _VW*.90
		mapH = _VW*.9
		print("CHANGING MAP W H")
	end
	--local defaultCellType = params.defaultCellType
	levelMap = mapCreator.createHexMap((_W-mapW)/2+5 , (_H-mapH)/2-30 , mapW , mapH , map_lines , map_cols, params.defaultCellType,sceneGroup)
	
	sceneAnimationGroup =  display.newGroup()
	sceneGroup:insert(sceneAnimationGroup)	
	
	rabbitsGroup = display.newGroup()
	sceneGroup:insert(rabbitsGroup)
	rabbitModule.init(rabbitsGroup,storyboard)
	
	overLayGroup = display.newGroup()
	sceneGroup:insert(overLayGroup)	
		
	HUD.init(sceneGroup,storyboard,{restart = restartListener, quit = quitGame, resume = resumeGame, pause = stopGame,continue = goToNextLevel, levelSelect = backToLevelSelect})
	
end




---------------------------------------------------------
--#####################################################--
--	updateScore(event) 
--  *Calculator for the score based on the timer and the
--	  running flag
--
--	PARAMETERS
--	event		: the event param sent by the "enterFrame"
--				   listener
--
--#####################################################--
---------------------------------------------------------
function updateScore(event)
	if system.getTimer() > lastLoopTime + 100  and gameRunning then
			gameScore = gameScore - gameScore*.0001
			local millisPlaying = system.getTimer() - gameStartTime
			secsPlaying = math.floor((millisPlaying-millisPlaying%1000)/1000)
			lastLoopTime = system.getTimer()
			HUD.updateGameScene(math.ceil(gameScore),secsPlaying,rocksPut)
	end
end



---------------------------------------------------------
--#####################################################--
--	insertBg(file) 
--  *Insert a new image on the background group of
--	  the scene
--
--	PARAMETERS
--	file		:	the fileName of the background
--
--#####################################################--
---------------------------------------------------------
function insertBg(file)
	local bg = nil
	if storyboard.getFromResources then 
		bg = display.newImageRect(file,_VW,_VW/_W*1024)
	else
		bg = display.newImageRect(file,system.DocumentsDirectory,_VW,_VW/_W*1024)
	end
	bg.x = _W/2
	bg.y = _H/2
	bgGroup:insert(bg)

end



---------------------------------------------------------
--#####################################################--
--	insertOverLay(file) 
--  *Insert a new image on the overlay group of
--	  the scene
--
--	PARAMETERS
--	file		:	the fileName of the overlay
--
--#####################################################--
---------------------------------------------------------
function insertOverLay(file)
	local bg = nil
	if storyboard.getFromResources or file == "vignete.png" then 
		bg = display.newImageRect(file,_VW,_VW/_W*1024)
	else
		bg = display.newImageRect(file,system.DocumentsDirectory,_VW,_VW/_W*1024)
	end
	bg.x = _W/2
	bg.y = _H/2
	overLayGroup:insert(bg)

end




---------------------------------------------------------
--#####################################################--
--	createNewObject() 
--  *Creates a new object type on the level to be used
--	  later. No placing happens here
--
--	PARAMETERS
--	params		:	the params required from mapCreator
--		... to be described better
--
--#####################################################--
---------------------------------------------------------
function createNewObject(params)
	mapCreator.createNewObject(levelMap,params) --directly to mapCreator, everything on celltypeparams
end







---------------------------------------------------------
--#####################################################--
--	placeNewObject(params)
--  *Place an object on the specified x,y position of the
--	  level. Remember that creating the object with the 
--	  referred tag BEFORE the placing is needed.
--
--	PARAMETERS
--	params.x		:	column position of the object
--	params.y		:	line position of the object
--	params.object	:	tag of a created object with
--							createNewObject(params)
--
--#####################################################--
---------------------------------------------------------
function placeNewObject(params)
	mapCreator.placeObject(levelMap[params.x][params.y], params.object)
end





---------------------------------------------------------
--#####################################################--
--	setRabbitSteps(steps)
--  *Sets the rabbit steps per turn.  At this time
--		setting the steps for "x" will result on rabbit
--		walking 1,x,1,x,1...
--
--	PARAMETERS
--	params.x		:	column position of the object
--	params.y		:	line position of the object
--	params.object	:	tag of a created object with
--							createNewObject(params)
--
--#####################################################--
---------------------------------------------------------
function setRabbitSteps(steps)
	if steps > 0 then
		rabbit.steps = steps
	else
		print("negative steps are not allowed")
	end
end






---------------------------------------------------------
--#####################################################--
--	gameClickListener(event)
--  *This is the main game updater. It listens to the
--	 	screen touches, get the cell based on the event x
--		and y, and if it's a "blank" space, put an object
--		and makes the rabbit run
--
--	PARAMETERS
--	event		: the event param sent by the "enterFrame"
--				   listener
--
--#####################################################--
---------------------------------------------------------
function gameClickListener(event)
	if event.phase == "ended" and gameRunning then
		local cell = mapCreator.getCellByXY(event.x,event.y,levelMap)
		if cell == false then
			print("clicking outside of the matrix")
			return false
		end


		rabbitModule.cutIfMoving()

		if cell.line == rabbit.y and cell.column == rabbit.x then 
			print("clicking over the rabbit!")
			return false
		end
		if cell.mapRef.objects[cell.id].canPutObjects then
			print("clicking "..cell.line..","..cell.column)			
			local objTag = "rock2"
			
			rocksPut = rocksPut + 1
			gameScore = gameScore - gameScore*.01
			mapCreator.placeObject(cell, objTag)
			mapCreator.updateHexGrid(levelMap)
			if not storyboard.mute then audio.play(soundPlaceObject) end
			if eatingCarrot then
				eatingCarrot = false
				return false
			else
				timer.performWithDelay(100, moveRabbit )
			end
		else
			if not storyboard.mute then audio.play(soundBlocked) end
			print("clicking "..cell.line..","..cell.column.." cant put objects here")
		end
	end
	return true
end


---------------------------------------------------------
--#####################################################--
--	moveRabbit()
--  *A function that makes the rabbit walk to an exit or
--		randomly, if there is no exit.
--
--#####################################################--
---------------------------------------------------------
function moveRabbit()
	for i=1,rabbit.actualSteps do
		if gameRunning == true then
			path = findShorterExit(rabbit.x,rabbit.y)
			if path == false then
				path = aStar.pathWithoutExit(rabbit.x,rabbit.y,levelMap)
				if path == false then
					print("YOU GOT THE RABBIT")
					stopGame()
					local highScore = gameData:retrieve(storyboard.sceneryId.."-"..storyboard.levelId)
					if gameScore > highScore then
						gameData:store( storyboard.sceneryId.."-"..storyboard.levelId, gameScore )
						gameData:save()
						social.setGCHighScore(gameScore,storyboard.levelId)
						highScore = gameScore
					end
					unlockNextLevel()
					timer.performWithDelay(1000,function() HUD.callEndingScreen(true,gameScore,highScore,usedCarrot,secsPlaying,rocksPut) end)
					if not storyboard.mute then audio.play(soundVictory) end
					return false
				end
			end
			local tempX = path[table.getn(path)-1].x
			local tempY = path[table.getn(path)-1].y
			local realX = levelMap[tempX][tempY].hexX
			local realY = levelMap[tempX][tempY].hexY
			rabbit.x = tempX
			rabbit.y = tempY
			rabbitModule.moveRabbitTo(realX,realY)
			
			if not storyboard.mute then timer.performWithDelay(150,function() audio.play(soundJump) end) end
			
			--CHECK IF IT ARRIVED ON A EXIT CELL
			if levelMap.objects[levelMap[rabbit.x][rabbit.y].id].tag == "endCell" then 
				stopGame()
				print("YOU LOOSE")
				HUD.callEndingScreen(false)
				if not storyboard.mute then audio.play(soundLaugh) end
				if not storyboard.mute then audio.play(soundFail) end
			end
			
			--AQUI VAI TE UM ESQUEMA PRA TRES PULINHOS!
			nearExit = findAround(rabbit.x,rabbit.y,"endCell")
			if nearExit then
				stopGame()
				print("YOU LOOSE")
				if not storyboard.mute then audio.play(soundLaugh) end
				if not storyboard.mute then audio.play(soundFail) end

				local endingClosure = function() 
					HUD.callEndingScreen(false)
				end
				local realX = levelMap[nearExit.x][nearExit.y].hexX
				local realY = levelMap[nearExit.x][nearExit.y].hexY
				rabbitModule.escapeRabbit(realX,realY, endingClosure)

				return false
			end
			--BELOW AN IMPLEMENTATION FOR THE FAKE EXITS(E.G. CARROT)
			if levelMap.objects[levelMap[rabbit.x][rabbit.y].id].isFakeExit then 
				placeNewObject({x=rabbit.x,y=rabbit.y,object="grass"})
			end
		end
	end
	rabbit.actualSteps = rabbit.actualSteps%rabbit.steps+1
end



function findAround(x,y,objTag)
	for i=1, 6 do
		--RUN NODE UPDATE FOR 6 NEIGHBOURIN TILES
		local node_x = 0
		local node_y = 0
		if i==1 then
			node_x = x-1
			node_y = y
		elseif i==2 then
			node_x = x
			node_y = y-1
		elseif i==3 then
			node_x = x+1
			node_y = y-1
		elseif i==4 then
			node_x = x+1
			node_y = y
		elseif i==5 then
			node_x = x
			node_y = y+1
		elseif i==6 then
			node_x = x-1
			node_y = y+1
		end	
		if levelMap[node_x] and levelMap[node_x][node_y] and levelMap.objects[levelMap[node_x][node_y].id].tag == objTag then
			return {x = node_x , y = node_y}
		end
	end
	return false
end




---------------------------------------------------------
--#####################################################--
--	findShorterExit(x0,y0)
--  *Based on a x and y position, it uses the aStar to find
--		on all possible exits, the shorter or less risky one.
--		It has a little random implementation to prevent
--		users from using walkthroughs
--
--#####################################################--
---------------------------------------------------------
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
		local realX = levelMap[rabbit.x][rabbit.y].hexX
		local realY = levelMap[rabbit.x][rabbit.y].hexY
		
		rabbitModule.start(realX,realY)

		HUD.loadScreenUI()
		mapCreator.updateHexGrid(levelMap)
		
		if gameData:retrieve("neverPlayed") then
			local dialogGroup = display.newGroup()
			sceneGroup:insert(dialogGroup)
			local menuClosure = function(event)
				Runtime:addEventListener( "touch", gameClickListener )
				Runtime:addEventListener("enterFrame",updateScore)
				gameStartTime = system.getTimer()
			end
			dialogsModule.callHowToPlay(dialogGroup,menuClosure)
			gameData:store("neverPlayed", false)
			gameData:save()
		else
			Runtime:addEventListener( "touch", gameClickListener )
			Runtime:addEventListener("enterFrame",updateScore)
			gameStartTime = system.getTimer()
		end
	else
		print("no start point")
		return false
	end
end


function restartListener()
	reloadMap()
	restartGame()
end

function unlockNextLevel()
	local nextLevel = nil
	if storyboard.getFromResources then
		nextLevel = jsonLevels.getNextLevel(storyboard.sceneryId,storyboard.levelId,system.ResourceDirectory)
	else
		nextLevel = jsonLevels.getNextLevel(storyboard.sceneryId,storyboard.levelId)		
	end
	if nextLevel then
			gameData:store( "unlocked-"..nextLevel.scenery.."-"..nextLevel.level,true)
			gameData:save()
	end
end



function goToNextLevel()
	rabbitModule.stop()
	-- getNextLevel returns a table with level and scenery
	nextLevel = nil
	if storyboard.getFromResources then
		nextLevel = jsonLevels.getNextLevel(storyboard.sceneryId,storyboard.levelId,system.ResourceDirectory)
	else
		nextLevel = jsonLevels.getNextLevel(storyboard.sceneryId,storyboard.levelId)		
	end
	if nextLevel then
	
		local nextLevelListener = function()
			storyboard.sceneryId = nextLevel.scenery
			storyboard.levelId = nextLevel.level
			storyboard.gotoScene( "scene-lvlTransitionHelper", "fade", 500 )
		end
		
		if (gameData:retrieve("free-"..nextLevel.scenery.."-"..nextLevel.level) or storeData:retrieve("proPurchased")) then
			nextLevelListener()
		else
			---here is the implementation needed
			HUD.callUnlockDialog(nextLevelListener)
		end
	else
		storyboard.gotoScene( "scene-main", "fade", 1000 )
		storyboard.gameComplete = true
	end
end


function eatCarrot()
	--START BUNNY ANIMATION OF EATING CARROT
	print("nhac nhac nhac nhac")
	--HUD.toast("nhac nhac nhac nhac")
	if not storyboard.mute then audio.play(soundCarrot) end
	eatingCarrot = true
	usedCarrot = true
end

function restartGame()
	
	rabbitModule.stop()
	
	eatingCarrot = false
	usedCarrot = false
	gameScore = gameStartScore
	rocksPut = 0
	gameStartTime = system.getTimer()
	HUD.reloadCarrotsButton()
	Runtime:removeEventListener( "touch", gameClickListener )
	Runtime:removeEventListener("enterFrame",updateScore)
	return startGame()
end

function stopGame()
	gameRunning = false
	Runtime:removeEventListener( "touch", gameClickListener )
	Runtime:removeEventListener("enterFrame",updateScore)
end

function resumeGame()
	gameRunning = true
	HUD.loadScreenUI()
	Runtime:addEventListener( "touch", gameClickListener )
	Runtime:addEventListener("enterFrame",updateScore)
end

function quitGame()
	if gameRunning then stopGame() end
	rabbitModule.stop()
	storyboard.gotoScene( "scene-main", "fade", 400 )
end

function backToLevelSelect()
	if gameRunning then stopGame() end
	rabbitModule.stop()
	storyboard.gotoScene( "scene-level-select", "fade", 400 )
end


function setGrid()
	mapCreator.setHexGrid(levelMap)
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

function hideGameUI()
	HUD.hideScreenUI()
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




function newSceneAnimation(params)
	otherGroup = display.newGroup()
	sceneAnimationGroup:insert(otherGroup)
	sceneAnimationGroup.alpha = .2
	if params.mask then 			 
		print(params.mask)
		local mask = graphics.newMask(params.mask)
		otherGroup:setMask(mask)
		 
		-- Center the mask over the Display Group
		--otherGroup:setReferencePoint( display.CenterReferencePoint )
		otherGroup.maskX = _W/2
		otherGroup.maskY = _H/2
	end
	for i=1 , #params.objects do
		local listObj = params.objects[i]
		local tempObject1 = nil
		if storyboard.getFromResources then 
			tempObject1 = display.newImageRect(listObj.img,listObj.w,listObj.h)
		else
			tempObject1 = display.newImageRect(listObj.img,system.DocumentsDirectory,listObj.w,listObj.h)
		end
		tempObject1.x = listObj.x0
		tempObject1.y = listObj.y0
		tempObject1.params = listObj
		otherGroup:insert(tempObject1)
		objectClosure = function(event)
			local listObj = event.params
			print(listObj.x0)
			local tempObject = nil
			if storyboard.getFromResources then 
				tempObject = display.newImageRect(listObj.img,listObj.w,listObj.h)
			else
				tempObject = display.newImageRect(listObj.img,system.DocumentsDirectory,listObj.w,listObj.h)
			end
			local transitionTime = listObj.time
			if listObj.continue then 
				tempObject.x = listObj.x0-listObj.w
				transitionTime = transitionTime*2
			else
				tempObject.x = listObj.x0
			end
			tempObject.y = listObj.y0
			tempObject.params = listObj
			if otherGroup and tempoObject then
				otherGroup:insert(tempObject)
				transition.to(tempObject,{x=listObj.x,y=listObj.y,time=transitionTime,onComplete=objectClosure})
			end
			if event.x then
				event:removeSelf()
				event = nil
				print("removing "..listObj.img)
			end
		end
		transition.to(tempObject1,{x=listObj.x,y=listObj.y,time=listObj.time,onComplete=objectClosure})
		local event = {params = listObj}
		if listObj.continue then 
			objectClosure(event)
		end
	end
end



---------------------------------------------------------
--#####################################################--
--	deepcopy(object)
--  *A pure lua function that makes a deep copy of a table
--		returning instead of a pointer to the same table,
--		a completely new one.
--
--	PARAMETERS
--
--	object		:		the desired table to be copied
--
--	RETURNS
--
--	table		:		A copy of the sent table
--
--#####################################################--
---------------------------------------------------------
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