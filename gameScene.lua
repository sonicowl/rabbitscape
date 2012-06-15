-----------------------------------------------------------------------------------------
--
-- Map Builder Engine
--
-----------------------------------------------------------------------------------------
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local gameEngine = require("gameEngine")
local jsonLevels = require("jsonLevels")
--local levelBuilderUI = require ("levelBuilderUI")





---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local sceneGroup = self.view
	


	-----------------------------------------------------------------------------
		
	--	CREATE display objects and add them to 'sceneGroup' here.
	--	Example use-case: Restore 'sceneGroup' from previously saved state.
	
	-----------------------------------------------------------------------------
--[[
	listOfObjects = {
		{ terrainCost = 10, maxMembers = -1, isDynamic = false, appearingWeight = 0 , isPlaceable = false, isWalkable = true , isExit=false, isFakeExit=false, canPutObjects = true , tag="grass" 		,img="cell1.png" , imgW=stdImgW*1.4, imgH=stdImgH }
		{ terrainCost = 10, maxMembers =  1, isDynamic = true , appearingWeight = 0 , isPlaceable = false, isWalkable = true , isExit=false, isFakeExit=false, canPutObjects = true , tag="startCell"	,img="cell2.png" , imgW=stdImgW*1.4, imgH=stdImgH }
		{ terrainCost = 10, maxMembers = -1, isDynamic = true , appearingWeight = 0 , isPlaceable = false, isWalkable = true , isExit=true , isFakeExit=false, canPutObjects = true , tag="endCell" 	,img="exits.png" , imgW=stdImgW*1.4, imgH=stdImgH }
		{ terrainCost = 10, maxMembers = -1, isDynamic = true , appearingWeight = 60, isPlaceable = true , isWalkable = false, isExit=false, isFakeExit=false, canPutObjects = false, tag="rock" 		,img="pedra.png" , imgW=stdImgW    , imgH=stdImgH , clusterEffect = 10}
		{ terrainCost = 10, maxMembers = -1, isDynamic = true , appearingWeight = 20, isPlaceable = true , isWalkable = false, isExit=false, isFakeExit=false, canPutObjects = false, tag="vase" 		,img="water1.png", imgW=stdImgW    , imgH=stdImgH , clusterEffect = 10 }
		{ terrainCost = 10, maxMembers = -1, isDynamic = true , appearingWeight = 20, isPlaceable = true , isWalkable = false, isExit=false, isFakeExit=false, canPutObjects = false, tag="tree"		,img="tree.png"  , imgW=stdImgW*1.3, imgH=stdImgH*2.5 , clusterEffect = 10 }
		{ terrainCost = 10, maxMembers = -1, isDynamic = true , appearingWeight = 0 , isPlaceable = false, isWalkable = true , isExit=false, isFakeExit=false, canPutObjects = false, tag="path" 		,img="cell5.png" , imgW=stdImgW*1.4, imgH=stdImgH }
		{ terrainCost = 10, maxMembers =  1, isDynamic = true , appearingWeight = 0 , isPlaceable = true , isWalkable = true , isExit=true , isFakeExit=true , canPutObjects = false, tag="carrot" 		,img="carrot.png", imgW=stdImgW    , imgH=stdImgH }
	}
]]--
	local stdImgW = 50
	local stdImgH = 50
	
	local defaultCellType = { terrainCost = 10, maxMembers = -1,isDynamic = false, isWalkable = true, isExit=false, canPutObjects = true, tag="grass" ,img="gridLightGreen.png",imgW=stdImgW*1.4, imgH=stdImgH, alpha = 0.1 }
	lastScene = "scene-sceneryList"
	gameEngine.newLevel({defaultCellType = defaultCellType, viewGroup = sceneGroup, storyBoard = storyboard, lastScene = lastScene})
	
	
	--appearingWeight: if you stick near a sum of 100 is easier to deal! 
	gameEngine.createNewObject({ terrainCost = 10, maxMembers =  1, isDynamic = false , appearingWeight = 0 , isPlaceable = false, isWalkable = true , isExit=false, isFakeExit=false, canPutObjects = true , tag="startCell",img="gridRoundGreen.png", imgW=stdImgW, imgH=stdImgH })
	gameEngine.createNewObject({ terrainCost = 0 , maxMembers = -1, isDynamic = true , appearingWeight = 0 , isPlaceable = false, isWalkable = true , isExit=true , isFakeExit=false, canPutObjects = false , tag="endCell" ,img="gridRoundRed.png", imgW=stdImgW, imgH=stdImgH })
--	gameEngine.createNewObject({ terrainCost = 10, maxMembers =  1, isDynamic = false , appearingWeight = 0 , isPlaceable = false, isWalkable = true , isExit=false, isFakeExit=false, canPutObjects = true , tag="startCell",img="startCell.png", imgW=stdImgW*1.4, imgH=stdImgH*1.2, alpha = 0.7 })
--	gameEngine.createNewObject({ terrainCost = 0 , maxMembers = -1, isDynamic = true , appearingWeight = 0 , isPlaceable = false, isWalkable = true , isExit=true , isFakeExit=false, canPutObjects = false , tag="endCell" ,img="gridRed.png", imgW=stdImgW*1.4, imgH=stdImgH*1.2, alpha = 0.5 })
	gameEngine.createNewObject({ terrainCost = 10, maxMembers = -1, isDynamic = false , appearingWeight = 60, isPlaceable = true , isWalkable = false, isExit=false, isFakeExit=false, canPutObjects = false, tag="rock" ,img="pedra2.png", imgW=stdImgW*1.1, imgH=stdImgH*1.1})
	--gameEngine.createNewObject({ terrainCost = 10, maxMembers = -1, isDynamic = false , appearingWeight = 60, isPlaceable = true , isWalkable = false, isExit=false, isFakeExit=false, canPutObjects = false, tag="rock" ,img="pedra2.png", imgW=stdImgW*1.1, imgH=stdImgH*1.1 , clusterEffect = 10})
	gameEngine.createNewObject({ terrainCost = 10, maxMembers = -1, isDynamic = true , appearingWeight = 60, isPlaceable = true , isWalkable = false, isExit=false, isFakeExit=false, canPutObjects = false, tag="rock2" ,img="pedra2.png", imgW=stdImgW*1.1, imgH=stdImgH*1.1 , clusterEffect = 10})
	gameEngine.createNewObject({ terrainCost = 10, maxMembers = -1, isDynamic = true , appearingWeight = 20, isPlaceable = true , isWalkable = false, isExit=false, isFakeExit=false, canPutObjects = false, tag="vase" ,img="water1.png", imgW=stdImgW, imgH=stdImgH , clusterEffect = 10 })
	gameEngine.createNewObject({ terrainCost = 10, maxMembers = -1, isDynamic = true , appearingWeight = 20, isPlaceable = true , isWalkable = false, isExit=false, isFakeExit=false, canPutObjects = false, tag="tree",img="tree.png", imgW=stdImgW*1.3, imgH=stdImgH*2.5 , clusterEffect = 10 })
	gameEngine.createNewObject({ terrainCost = 10, maxMembers = -1, isDynamic = false , appearingWeight = 0 , isPlaceable = false, isWalkable = true , isExit=false, isFakeExit=false, canPutObjects = false, tag="path" ,img="cell5.png", imgW=stdImgW*1.4, imgH=stdImgH })
	gameEngine.createNewObject({ terrainCost = 10, maxMembers =  1, isDynamic = true , appearingWeight = 0 , isPlaceable = true , isWalkable = true , isExit=true , isFakeExit=true , canPutObjects = false, tag="carrot" ,img="carrot.png", imgW=stdImgW, imgH=stdImgH })
	--loadLevel1() --gameEngine.setRabbitSteps(1) --gameEngine.startGame()
	
	
	if storyboard.levelId ~= nil then
		local jsonMap = jsonLevels.loadSceneryMap(storyboard.sceneryId,storyboard.levelId)
		if jsonMap ~= false then
			for i=1, #jsonMap.backgrounds do gameEngine.insertBg(jsonMap.backgrounds[i]) end
			for i=1, #jsonMap.overlays do gameEngine.insertOverLay(jsonMap.overlays[i]) end
			gameEngine.insertOverLay("vignete.png")
			if jsonMap.sceneAnim then
				gameEngine.newSceneAnimation(jsonMap.sceneAnim)
			end
			jsonMap = jsonMap.coords
			for j=1,#jsonMap do
				if jsonMap[j] ~= nil then
					for i=1,#jsonMap[j] do
						if jsonMap[j][i] ~= nil then
							local cell = jsonMap[j][i]
							gameEngine.placeNewObject({x=cell.x,y=cell.y,object=cell.object})
						end
					end
				end
			end
		end
	end
	
	gameEngine.startGame()
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local sceneGroup = self.view
	--levelBuilderUI.start()
	--print("purging "..lastScene)
	storyboard.purgeScene( lastScene )
	-----------------------------------------------------------------------------
		
	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	
	-----------------------------------------------------------------------------
	
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local sceneGroup = self.view
	--levelBuilderUI.close()
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
	
	-----------------------------------------------------------------------------
	
end


-- Called prior to the removal of scene's "view" (display sceneGroup)
function scene:destroyScene( event )
	local sceneGroup = self.view
	
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. remove listeners, widgets, save state, etc.)
	
	-----------------------------------------------------------------------------
	
end
--main()


---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------

return scene