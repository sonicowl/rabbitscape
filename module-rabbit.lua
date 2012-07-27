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
	bunnyAnimating = false
	bunnySets = {}
	bunnyInstances = {}
	storyboard = storyb
	bunnyGroup = viewGroup
	loadRabbitSprites()
	bunnyAnimations = {"lookAround", "lookingUp", "ear1", "cleaning", "ear2"}
end

function start(x0,y0)	
	bunny = {x=x0,y=y0}
	for i = 1 , 4 do
		bunnyInstances[i] = sprite.newSprite(bunnySets[i])
		bunnyGroup:insert(bunnyInstances[i])
		bunnyInstances[i].xScale = .7
		bunnyInstances[i].yScale = .7
		bunnyInstances[i].x = x0+5
		bunnyInstances[i].y = y0+5
		cardinalDirec = "NW"
		bunnyInstances[i]:prepare("breathingNW")
		bunnyInstances[i]:play()
		bunnyInstances[i]:addEventListener("sprite", bunnySpriteListener)
		--bunnyInstances[i].currentFrame = 4
		if i > 1 then bunnyInstances[i].alpha = 0 end
	end
	
	Runtime:addEventListener("enterFrame",bunnyAnimation)
	
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
	Runtime:removeEventListener("enterFrame",bunnyAnimation)
end


--rabbitsGroup
function loadRabbitSprites()
	for i = 1 , 4 do
		print("persp"..i)
		local tempSheet = sprite.newSpriteSheetFromData( i..".png", require(i).getSpriteSheetData() )
		
		bunnySets[i] = sprite.newSpriteSet(tempSheet,1,348)
		sprite.add(bunnySets[i],"runS",			1,7,3*80,1)
		sprite.add(bunnySets[i],"runSW",		8,7,3*80,1)
		sprite.add(bunnySets[i],"runN",			15,7,3*80,1)
		sprite.add(bunnySets[i],"runNW",		22,7,3*80,1)
		sprite.add(bunnySets[i],"runNE",		29,7,3*80,1)
		sprite.add(bunnySets[i],"runSE",		36,7,3*80,1)
		
		sprite.add(bunnySets[i],"lookAroundS",	43 + 51*0 +0  ,12		,3*80,-1)
		sprite.add(bunnySets[i],"lookingUpS",	43 + 51*0 +12 ,8		,3*80,1)
		sprite.add(bunnySets[i],"breathingS",	43 + 51*0 +20 ,2		,3*80,-2)
		sprite.add(bunnySets[i],"ear1S",		43 + 51*0 +22 ,7		,3*80,2)
		sprite.add(bunnySets[i],"cleaningS",	43 + 51*0 +29 ,7		,3*80,2)
		sprite.add(bunnySets[i],"ear2S",		43 + 51*0 +36 ,13		,3*80,1)
		sprite.add(bunnySets[i],"eatingS",		43 + 51*0 +49 ,2		,3*80,20)
		
		sprite.add(bunnySets[i],"lookAroundSW",	43 + 51*1 +0  ,12		,3*80,-1)
		sprite.add(bunnySets[i],"lookingUpSW",	43 + 51*1 +12 ,8		,3*80,1)
		sprite.add(bunnySets[i],"breathingSW",	43 + 51*1 +20 ,2		,3*80,-2)
		sprite.add(bunnySets[i],"ear1SW",		43 + 51*1 +22 ,7		,3*80,2)
		sprite.add(bunnySets[i],"cleaningSW",	43 + 51*1 +29 ,7		,3*80,2)
		sprite.add(bunnySets[i],"ear2SW",		43 + 51*1 +36 ,13		,3*80,1)
		sprite.add(bunnySets[i],"eatingSW",		43 + 51*1 +49 ,2		,3*80,20)
		
		sprite.add(bunnySets[i],"lookAroundN",	43 + 51*2 +0  ,12		,3*80,-1)
		sprite.add(bunnySets[i],"lookingUpN",	43 + 51*2 +12 ,8		,3*80,1)
		sprite.add(bunnySets[i],"breathingN",	43 + 51*2 +20 ,2		,3*80,-2)
		sprite.add(bunnySets[i],"ear1N",		43 + 51*2 +22 ,7		,3*80,2)
		sprite.add(bunnySets[i],"cleaningN",	43 + 51*2 +29 ,7		,3*80,2)
		sprite.add(bunnySets[i],"ear2N",		43 + 51*2 +36 ,13		,3*80,1)
		sprite.add(bunnySets[i],"eatingN",		43 + 51*2 +49 ,2		,3*80,20)
		
		sprite.add(bunnySets[i],"lookAroundNW",	43 + 51*3 +0  ,12		,3*80,-1)
		sprite.add(bunnySets[i],"lookingUpNW",	43 + 51*3 +12 ,8		,3*80,1)
		sprite.add(bunnySets[i],"breathingNW",	43 + 51*3 +20 ,2		,3*80,-2)
		sprite.add(bunnySets[i],"ear1NW",		43 + 51*3 +22 ,7		,3*80,2)
		sprite.add(bunnySets[i],"cleaningNW",	43 + 51*3 +29 ,7		,3*80,2)
		sprite.add(bunnySets[i],"ear2NW",		43 + 51*3 +36 ,13		,3*80,1)
		sprite.add(bunnySets[i],"eatingNW",		43 + 51*3 +49 ,2		,3*80,20)
		
		sprite.add(bunnySets[i],"lookAroundNE",	43 + 51*4 +0  ,12		,3*80,-1)
		sprite.add(bunnySets[i],"lookingUpNE",	43 + 51*4 +12 ,8		,3*80,1)
		sprite.add(bunnySets[i],"breathingNE",	43 + 51*4 +20 ,2		,3*80,-2)
		sprite.add(bunnySets[i],"ear1NE",		43 + 51*4 +22 ,7		,3*80,2)
		sprite.add(bunnySets[i],"cleaningNE",	43 + 51*4 +29 ,7		,3*80,2)
		sprite.add(bunnySets[i],"ear2NE",		43 + 51*4 +36 ,13		,3*80,1)
		sprite.add(bunnySets[i],"eatingNE",		43 + 51*4 +49 ,2		,3*80,20)
		
		sprite.add(bunnySets[i],"lookAroundSE",	43 + 51*5 +0  ,12		,3*80,-1)
		sprite.add(bunnySets[i],"lookingUpSE",	43 + 51*5 +12 ,8		,3*80,1)
		sprite.add(bunnySets[i],"breathingSE",	43 + 51*5 +20 ,2		,3*80,-2)
		sprite.add(bunnySets[i],"ear1SE",		43 + 51*5 +22 ,7		,3*80,2)
		sprite.add(bunnySets[i],"cleaningSE",	43 + 51*5 +29 ,7		,3*80,2)
		sprite.add(bunnySets[i],"ear2SE",		43 + 51*5 +36 ,13		,3*80,1)
		sprite.add(bunnySets[i],"eatingSE",		43 + 51*5 +49 ,2		,3*80,20)
	
	end
end

function bunnySpriteListener(event)
	print("event: "..event.phase)
	if event.phase == "end" then
		event.target:prepare("breathing"..cardinalDirec)
		event.target:play()
		if movingRabbit then movingRabbit = false end
	end
end

function bunnyAnimation(event)
	if not lastLoop then lastLoop = event.time end
	deltaT = event.time - lastLoop
	if deltaT > 5000 and not movingRabbit then
		local perspBlock = mapCreator.getPerspectiveBlock(bunny.x,bunny.y)
		local randChoice = math.random(#bunnyAnimations)
		bunnyInstances[perspBlock]:prepare(bunnyAnimations[randChoice]..cardinalDirec)
		bunnyInstances[perspBlock]:play()
		lastLoop = event.time
	end
end



function moveRabbitTo(x,y,endListener)

	cardinalDirec = getMovingDirection(bunny.x,bunny.y,x+5,y+10)
	print("RUNNING RABBIT TO "..cardinalDirec)
	bunny.x = x+5
	bunny.y = y+10
	if endListener then 
		Runtime:removeEventListener("enterFrame",bunnyAnimation)
		timer.performWithDelay(600,endListener)
	end
	if cardinalDirec then
		local perspBlock = mapCreator.getPerspectiveBlock(x,y)
		for i = 1 , 4 do
			if i == perspBlock then
				bunnyInstances[i]:prepare("run"..cardinalDirec)
				bunnyInstances[i]:play()
				bunnyInstances[i].alpha = 1
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