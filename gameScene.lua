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

	local stdImgW = 50
	local stdImgH = 50
	
	local defaultCellType = { terrainCost = 10, maxMembers = -1,isDynamic = false, isWalkable = true, isExit=false, canPutObjects = true, tag="grass" ,img="gridRoundGreen.png",imgW=stdImgW*.7, imgH=stdImgH*.7 }
	gameEngine.newLevel({defaultCellType = defaultCellType, viewGroup = sceneGroup, storyBoard = storyboard})
	
	
	--appearingWeight: if you stick near a sum of 100 is easier to deal! 
	gameEngine.createNewObject({ terrainCost = 10, maxMembers =  1, isDynamic = false , appearingWeight = 0 , isPlaceable = false, isWalkable = true , isExit=false, isFakeExit=false, canPutObjects = true , tag="startCell",img="gridRoundGreen.png", imgW=stdImgW, imgH=stdImgH })
	gameEngine.createNewObject({ terrainCost = 0 , maxMembers = -1, isDynamic = true , appearingWeight = 0 , isPlaceable = false, isWalkable = true , isExit=true , isFakeExit=false, canPutObjects = false , tag="endCell" ,img="red-grid.png", imgW=stdImgW*1.3, imgH=stdImgH*1.3, isAnimated = true})
--	gameEngine.createNewObject({ terrainCost = 10, maxMembers =  1, isDynamic = false , appearingWeight = 0 , isPlaceable = false, isWalkable = true , isExit=false, isFakeExit=false, canPutObjects = true , tag="startCell",img="startCell.png", imgW=stdImgW*1.4, imgH=stdImgH*1.2, alpha = 0.7 })
--	gameEngine.createNewObject({ terrainCost = 0 , maxMembers = -1, isDynamic = true , appearingWeight = 0 , isPlaceable = false, isWalkable = true , isExit=true , isFakeExit=false, canPutObjects = false , tag="endCell" ,img="gridRed.png", imgW=stdImgW*1.4, imgH=stdImgH*1.2, alpha = 0.5 })
	gameEngine.createNewObject({ terrainCost = 10, maxMembers = -1, isDynamic = false , appearingWeight = 60, isPlaceable = true , isWalkable = false, isExit=false, isFakeExit=false, canPutObjects = false, tag="rock" ,img="pedra2.png", imgW=stdImgW*1.1, imgH=stdImgH*1.1})
	--gameEngine.createNewObject({ terrainCost = 10, maxMembers = -1, isDynamic = false , appearingWeight = 60, isPlaceable = true , isWalkable = false, isExit=false, isFakeExit=false, canPutObjects = false, tag="rock" ,img="pedra2.png", imgW=stdImgW*1.1, imgH=stdImgH*1.1 , clusterEffect = 10})
	gameEngine.createNewObject({ terrainCost = 10, maxMembers = -1, isDynamic = true , appearingWeight = 60, isPlaceable = true , isWalkable = false, isExit=false, isFakeExit=false, canPutObjects = false, tag="rock2" ,img="a.png", imgW=stdImgW*1.1, imgH=stdImgH*1.1 , clusterEffect = 10,hasPerspective = true})
	gameEngine.createNewObject({ terrainCost = 10, maxMembers = -1, isDynamic = true , appearingWeight = 20, isPlaceable = true , isWalkable = false, isExit=false, isFakeExit=false, canPutObjects = false, tag="vase" ,img="water1.png", imgW=stdImgW, imgH=stdImgH , clusterEffect = 10 })
	gameEngine.createNewObject({ terrainCost = 10, maxMembers = -1, isDynamic = true , appearingWeight = 20, isPlaceable = true , isWalkable = false, isExit=false, isFakeExit=false, canPutObjects = false, tag="tree",img="tree.png", imgW=stdImgW*1.3, imgH=stdImgH*2.5 , clusterEffect = 10 })
	gameEngine.createNewObject({ terrainCost = 10, maxMembers = -1, isDynamic = false , appearingWeight = 0 , isPlaceable = false, isWalkable = true , isExit=false, isFakeExit=false, canPutObjects = false, tag="path" ,img="cell5.png", imgW=stdImgW*1.4, imgH=stdImgH })
	gameEngine.createNewObject({ terrainCost = 10, maxMembers =  1, isDynamic = true , appearingWeight = 0 , isPlaceable = true , isWalkable = true , isExit=true , isFakeExit=true , canPutObjects = false, tag="carrot" ,img="carrot.png", imgW=stdImgW, imgH=stdImgH })
	--loadLevel1() --gameEngine.setRabbitSteps(1) --gameEngine.startGame()
	
	
	if storyboard.levelId ~= nil then
		jsonMap = nil
		if storyboard.getFromResources then
			jsonMap = jsonLevels.loadSceneryMap(storyboard.sceneryId,storyboard.levelId,system.ResourceDirectory)
			print("scene: "..storyboard.sceneryId.." level:"..storyboard.levelId)
		else
			jsonMap = jsonLevels.loadSceneryMap(storyboard.sceneryId,storyboard.levelId)
		end
		if jsonMap then
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
	
	blackFadeIn = display.newRect(0,0,_W,_H)
	blackFadeIn:setFillColor(0,0,0)
	sceneGroup:insert(blackFadeIn)
	
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
        local group = self.view
        lastScene = storyboard.getPrevious()
		print("COMING FROM "..tostring(lastScene))
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local sceneGroup = self.view
	storyboard.purgeScene( lastScene )

	soundAmbience = audio.loadStream("stream-scenery1.wav")
	soundJump = audio.loadSound("sound-jump.wav")
	soundCarrot = audio.loadSound("sound-carrot.wav")
	soundPlaceObject = audio.loadSound("sound-objects.wav")
	soundBlocked = audio.loadSound("sound-blocked.wav")
	soundFail = audio.loadSound("sound-fail.mp3")
	soundVictory = audio.loadSound("sound-victory.mp3")
	soundLaugh = audio.loadSound("sound-laugh.wav")
	
	
	
	soundDuration = audio.getDuration(soundAmbience)*.9
	if soundDuration and soundDuration > 1 then
		audio.seek(math.random(soundDuration), soundAmbience)
	end
	if not storyboard.mute then audio.play(soundAmbience,{loops=-1,channel=1}) end	
	
	local FadeInClosure = function(event)
		event:removeSelf()
		event = nil
	end
	
	transition.to(blackFadeIn,{time=400,onComplete=FadeInClosure,alpha=0})
	
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local sceneGroup = self.view
	
	audio.stop()
	audio.dispose(soundAmbience)
	audio.dispose(soundJump)
	audio.dispose(soundCarrot)
	audio.dispose(soundPlaceObject)
	audio.dispose(soundBlocked)
	audio.dispose(soundFail)
	audio.dispose(soundVictory)
	audio.dispose(soundLaugh)

	soundAmbience = nil
	soundJump = nil
	soundCarrot = nil
	soundPlaceObject = nil
	soundBlocked = nil
	soundFail = nil
	soundVictory = nil
	soundLaugh = nil
	
end


-- Called prior to the removal of scene's "view" (display sceneGroup)
function scene:destroyScene( event )
	local sceneGroup = self.view
	
	
end
--main()


---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )
-- "willEnterScene" event is dispatched before scene transition begins
scene:addEventListener( "willEnterScene", scene )
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