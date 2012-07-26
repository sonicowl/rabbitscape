-----------------------------------------
-- module-rabbit.lua
-- Version 1.0
-- Author: Thiago Ramos
-- Functions:
-----------------------------------------


module(..., package.seeall)

function init(viewGroup,storyb)
	mapModule = require("mapCreator")
	bunny = {}
	movingRabbit = false
	bunnySets = {}
	bunnyInstances = {}
	storyboard = storyb
	bunnyGroup = viewGroup
	loadRabbitSprites()
	
end

function start(x0,y0)	
	bunny = {x=x0,y=y0}
	for i = 1 , 4 do
		bunnyInstances[i] = sprite.newSprite(bunnySets[i])
		bunnyGroup:insert(bunnyInstances[i])
		bunnyInstances[i].xScale = .5
		bunnyInstances[i].yScale = .5
		bunnyInstances[i].x = x0+5
		bunnyInstances[i].y = y0+10
		bunnyInstances[i]:prepare("runNW")
		bunnyInstances[i].currentFrame = 4
		if i > 1 then bunnyInstances[i].alpha = 0 end
	end
end

function stop()
	print("stop called")
	if bunnyInstances[1] then
		print("removing instances")
		for i = #bunnyInstances , 1 , -1 do
			bunnyInstances[i]:removeSelf()
			bunnyInstances[i] = nil
		end
	end
end


--rabbitsGroup
function loadRabbitSprites()
	for i = 1 , 4 do
		local tempSheet = sprite.newSpriteSheetFromData( i..".png", require(i).getSpriteSheetData() )
		bunnySets[i] = sprite.newSpriteSet(tempSheet,1,42)
		sprite.add(bunnySets[i],"runS",1,4,6*80,1)
		sprite.add(bunnySets[i],"runSW",8,4,6*80,1)
		sprite.add(bunnySets[i],"runN",15,4,6*80,1)
		sprite.add(bunnySets[i],"runNW",22,4,6*80,1)
		sprite.add(bunnySets[i],"runNE",29,4,6*80,1)
		sprite.add(bunnySets[i],"runSE",36,4,6*80,1)
	end
end



function moveRabbitTo(x,y,endListener)

	local cardinalDirec = getMovingDirection(bunny.x,bunny.y,x+5,y+10)
	print("RUNNING RABBIT TO "..cardinalDirec)
	bunny.x = x+5
	bunny.y = y+10
	
	if cardinalDirec then
		local tempClosure = function(event) 
			if event.phase == "end" then
				if endListener then endListener() end
				movingRabbit = false
			end
		end
		
		local perspBlock = mapCreator.getPerspectiveBlock(x,y)
		for i = 1 , 4 do
			if i == perspBlock then
				bunnyInstances[i]:prepare("run"..cardinalDirec)
				bunnyInstances[i]:play()
				bunnyInstances[i].alpha = 1
				bunnyInstances[i]:addEventListener("sprite", tempClosure)
				rabbitTransition = transition.to(bunnyInstances[i],{x=bunny.x, y=bunny.y ,time=4*80})
			else
				bunnyInstances[i].alpha = 0
				bunnyInstances[i].x = bunny.x
				bunnyInstances[i].y = bunny.y
			end
		end
		movingRabbit = true
		if not storyboard.mute then timer.performWithDelay(150,function() audio.play(soundJump) end) end	
	else
		print("WRONG CARDINAL DIRECTION")
	end
end




---NEEDS TEST
--- WORK WITH REAL X,Y COORDS
function getMovingDirection(x0,y0,x,y)

	local deltaX = x-x0
	local deltaY = y-y0
	
	if     deltaY < 0 and deltaX == 0 then return "N"
	elseif deltaY < 0 and deltaX < 0 then return "NW"
	elseif deltaY > 0 and deltaX < 0 then return "SW"
	elseif deltaY > 0 and deltaX == 0 then return "S"
	elseif deltaY > 0 and deltaX > 0 then return "SE"
	elseif deltaY < 0 and deltaX > 0 then return "NE"
	end
	return false
end

function cutIfMoving()
	if movingRabbit then
		transition.cancel(rabbitTransition)
		for i = 1, #bunnyInstances do
			bunnyInstances[i].x = bunny.x
			bunnyInstances[i].y = bunny.y
		end
	end
end



function escapeRabbit(nextX,nextY,endingListener)
	
	deltaX = nextX - bunny.x
	deltaY = nextY - bunny.y

	timer.performWithDelay(5*80, function() moveRabbitTo(nextX,nextY) end )
	timer.performWithDelay(10*80, function() moveRabbitTo(nextX+deltaX,nextY+deltaY,endingListener) end)

end