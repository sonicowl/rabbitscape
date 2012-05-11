-----------------------------------------
-- aStar.lua
-- Version 1.0
-- Author: Thiago Ramos
-- Functions:
--		hexDistance
--		hex_accessible
--		findPath
-----------------------------------------


module(..., package.seeall)




---------------------------------------------------------
--#####################################################--
--
--	hexDistance() PARAMETERS
--
--	x1			- a cell column
--	y1			- a cell line
--	x2			- a cell column
--	y2			- a cell line
--
--
--	hexDistance() RETURNS
--
--	distance	- the hypotenuse of dx and dy
--
--#####################################################--
---------------------------------------------------------

function hexDistance(x1,y1,x2,y2)
	dx = math.abs(x1-x2)
	dy = math.abs(y2-y1)
	--local dis = dx+dy
	local dis = math.sqrt((dx*dx)+(dy*dy))
	return dis
end



---------------------------------------------------------
--#####################################################--
--
--	hex_accessible() PARAMETERS
--
--	x			- column of starting cell
--	y			- line of starting cell
--	mapArray	- 2D table with:
--					cells containing .terrainCost info
--
--
--	hex_accessible() RETURNS
--
--	true		- if the cell exists and has cost ~= 1
--	false		- otherwise
--
--#####################################################--
---------------------------------------------------------

function hex_accessible(x,y,mapArray)
	if mapArray[x] == nil then return false
	elseif mapArray[x][y] == nil then return false
	elseif not mapArray.objects[mapArray[x][y].id].isWalkable then return false
	end
	return true
end



function newBlankMatrix2(iCols,iRows)
	local a = {}
	for i=1, iCols do
		a[i] = {}
		for j=1,iRows do
			a[i][j] = {}
		end
	end
	return a
end



---------------------------------------------------------
--#####################################################--
--
--	findPath() PARAMETERS
--
--	start_x		- column of starting cell
--	start_y		- line of starting cell
--	end_x 		- column of target cell
--	end_y		- line of target cell
--	mapArray	- 2D table with:
--					cells containing .terrainCost info
--					quantity of lines (mapArray.lines)
--					quantity of columns (mapArray.columns)
--
--
--	findPath() RETURNS
--
--	shortestPath	- a table containing the "steps"
--				  	of the shortest path
--
--#####################################################--
---------------------------------------------------------

function findPath(start_x, start_y, end_x, end_y,mapArray)
	--print("starting path x0:"..start_x.." y0:"..start_y.." x:"..end_x.." y:"..end_y)
	local timer = system.getTimer()
	
	--CHECK CASES PATH IS IMPOSSIBLE TO START
	if not hex_accessible(start_x,start_y,mapArray) then print("startCell error"..start_x..start_y) return false
	elseif not hex_accessible(end_x,end_y,mapArray) then print("endCell error"..end_x..end_y) return false end
	
	--GOOD TO GO! START IT
	
	--CREATE A NEW MAP WITH BLANK INFO FOR A* ALG
	local aMap = newBlankMatrix2(mapArray.columns,mapArray.lines)
	
	--CREATE AN OPEN LIST WHERE WILL BE THE CELL THAT ARE POSSIBLE PATHS
	local openList = {}
	
	--CREATE A PATH TABLE TO SEND BACK AS A RETURN
	local shortestPath = {}
	
	
	--DECLARE FLAGS AND VARS
	local targetFound = false
	local selected_id = 0
	local select_x = 0
	local select_y = 0
	local node_x = 0
	local node_y = 0
	
	--ADD START COORDINATES TO OPENLIST
	local tempCell = {}
	tempCell.state = true
	tempCell.x = start_x
	tempCell.y = start_y
	table.insert(openList,tempCell)
	
	--ADD SOME DUMB G,H,F FOR STARTING CELL
	aMap[start_x][start_y].g = 0
	aMap[start_x][start_y].h = 0
	aMap[start_x][start_y].f = 0
	aMap[start_x][start_y].state = true
	
	
	--TRY TO FIND PATH UNTIL THE TARGET IS FOUND
	while not targetFound do
		set_first = true
		
		--FIND LOWEST F IN OPENLIST
		local lowest_x = nil
		local lowest_y = nil
		local lowest_found = nil
		for var,val in pairs(openList) do
			select_x = val.x
			select_y = val.y
			if set_first == true then
				lowest_found = aMap[select_x][select_y].f
				set_first = false
			end
			if aMap[select_x][select_y].f <= lowest_found then
				lowest_found = aMap[select_x][select_y].f
				lowest_x = val.x
				lowest_y = val.y
				selected_id = var
			end
		end
		if set_first==true then
			-- OPEN LIST IS EMPTY, MEANS THAT TARGET IS NOT ACCESSIBLE AND ALL CELLS WERE CHECKED.
			--print("No route found!")
			return false
		end
		
		--SET THE LOWEST F CELL AS CLOSED AND REMOVE FROM OPENLIST
		aMap[lowest_x][lowest_y].state=2
		table.remove(openList,selected_id)
		
		--IF THE LOWEST CELL IS THE LAST ONE, WE WILL STILL CHECK FOR A SHORTER NEIGHBOUR BELOW
		--BUT SET THE TARGET AS FOUND TO END THE SEARCH AT THE END OF THIS LOOP.
		if end_x == lowest_x and end_y == lowest_y then
			targetFound = true
		end
		
		--ADD CONNECTED NODES TO THE OPENLIST
		for i=1, 6 do
			--RUN NODE UPDATE FOR 6 NEIGHBOURIN TILES
			if i==1 then
				node_x = lowest_x-1
				node_y = lowest_y
			elseif i==2 then
				node_x = lowest_x
				node_y = lowest_y-1
			elseif i==3 then
				node_x = lowest_x+1
				node_y = lowest_y-1
			elseif i==4 then
				node_x = lowest_x+1
				node_y = lowest_y
			elseif i==5 then
				node_x = lowest_x
				node_y = lowest_y+1
			elseif i==6 then
				node_x = lowest_x-1
				node_y = lowest_y+1
			end				
			
			--CHECK IF THE NODE IS ACCESSIBLE (EXISTS ON THE MAP AND IS WALKABLE)
			if hex_accessible(node_x,node_y,mapArray) then
				if aMap[node_x][node_y].state == true then --its on the openlist, check if this path is shorter
					if aMap[node_x][node_y].g + mapArray[lowest_x][lowest_y].terrainCost < aMap[lowest_x][lowest_y].g then
						aMap[lowest_x][lowest_y].parent_x = node_x
						aMap[lowest_x][lowest_y].parent_y = node_y
						aMap[lowest_x][lowest_y].g = aMap[node_x][node_y].g + mapArray[lowest_x][lowest_y].terrainCost
						aMap[lowest_x][lowest_y].f = aMap[lowest_x][lowest_y].g + aMap[lowest_x][lowest_y].h
						--print("Checking node: "..node_x..","..node_y.." from parent: "..lowest_x..","..lowest_y.." ITS ON OPENLIST AND IS SHORTER")
					--else
						--print("Checking node: "..node_x..","..node_y.." from parent: "..lowest_x..","..lowest_y.." ITS ON OPENLIST BUT NOT SHORTER")
					end
				elseif aMap[node_x][node_y].state == 2 then --ON CLOSED LIST BUT CHECK AGAIN, MAYBE IS A SHORTER PATH
					if aMap[node_x][node_y].g + mapArray[lowest_x][lowest_y].terrainCost < aMap[lowest_x][lowest_y].g then
						aMap[lowest_x][lowest_y].parent_x = node_x
						aMap[lowest_x][lowest_y].parent_y = node_y
						aMap[lowest_x][lowest_y].g = aMap[node_x][node_y].g + mapArray[lowest_x][lowest_y].terrainCost
						aMap[lowest_x][lowest_y].f = aMap[lowest_x][lowest_y].g + aMap[lowest_x][lowest_y].h
						--print("Checking node: "..node_x..","..node_y.." from parent: "..lowest_x..","..lowest_y.." ITS ON CLOSED LIST BUT IS SHORTER")
					--else
						--print("Checking node: "..node_x..","..node_y.." from parent: "..lowest_x..","..lowest_y.." ITS ON CLOSED LIST")		
					end
				else -- NOT ON THE OPENLIST NEITHER ON THE CLOSEDLIST, ITS A NEW NODE, RUN THE UPDATE FOR THE CELL AND ADD TO OPENLIST
					--add to open list
					local tempCell = {}
					tempCell.x = node_x
					tempCell.y = node_y
					table.insert(openList,tempCell)
					aMap[node_x][node_y].state = true
					--set parent
					aMap[node_x][node_y].parent_x = lowest_x
					aMap[node_x][node_y].parent_y = lowest_y
					--update H,G,F
					aMap[node_x][node_y].h = hexDistance(node_x,node_y,end_x,end_y)*mapArray.objects[1].terrainCost
					aMap[node_x][node_y].g = aMap[lowest_x][lowest_y].g + mapArray[lowest_x][lowest_y].terrainCost
					aMap[node_x][node_y].f = aMap[node_x][node_y].g + aMap[node_x][node_y].h
					--print("Checking node: "..node_x..","..node_y.." from parent: "..lowest_x..","..lowest_y.." NEW NODE")
				end
			end	
		end
	end
	--END OF WHILE
	
	--IF WE GOT HERE, WE HAVE A PATH, SO GET THE PATH
	local temp_x = end_x
	local temp_y = end_y
	local totalCost = mapArray[end_x][end_y].terrainCost
	while temp_x ~= start_x or temp_y ~= start_y do
		--print("step- x="..temp_x.." y="..temp_y)
		local tempPath = {}
		tempPath.x = temp_x
		tempPath.y = temp_y
		totalCost = totalCost + mapArray[temp_x][temp_y].terrainCost
		table.insert(shortestPath,tempPath)
		temp_x = aMap[tempPath.x][tempPath.y].parent_x
		temp_y = aMap[tempPath.x][tempPath.y].parent_y
	end
	--print("step- x="..start_x.." y="..start_y)
	local tempPath = {}
	tempPath.x = start_x
	tempPath.y = start_y
	table.insert(shortestPath,tempPath)
	shortestPath.totalCost = totalCost
	shortestPath.steps = table.getn(shortestPath)
	
	return shortestPath
end

--return an array ordered from shortest to longest
function findMultiplePaths(start_x,start_y,endArray,mapArray)
	local pathsArray = {}
	
	if not (table.getn(endArray) > 0) then return false end
	--find paths
	for i=1, table.getn(endArray) do
		--print("CHECKING TARGET "..i.." - "..endArray[i].x.. " " .. endArray[i].y )
		local tempPath = findPath(start_x, start_y, endArray[i].x, endArray[i].y , mapArray)
		--find his position and go sorting
		if tempPath ~= false then
			local pathPosition = 1
			for i=1, table.getn(pathsArray) do
				if tempPath.totalCost > pathsArray[i].totalCost then pathPosition = pathPosition + 1 end
			end
			table.insert(pathsArray,pathPosition,tempPath)
		end
	end
	if table.getn(pathsArray) > 0 then
		--for loop to debug
		for i=1, table.getn(pathsArray) do
			--print("PATH N."..i.." - "..pathsArray[i].steps.." STEPS, COST: "..pathsArray[i].totalCost)
		end
		return pathsArray
	else
		return false
	end
end


function pathWithoutExit(x0,y0,map)
	local steps = 0
	local path = {}
	local node_x = x0
	local node_y = y0
	local wayFound = false
	--while steps < 4 do
	testedDirections = {}
	
	while not wayFound and table.getn(testedDirections) < 6 do
		local directionTested = true
		while directionTested do
			i = math.random(1,6)
			local foundEqual = false
			for j = 1 ,table.getn(testedDirections) do
				if testedDirections[j] == i then 
					foundEqual = true 
				end
			end
			if foundEqual == false then 
				directionTested = false 
				table.insert(testedDirections,i)
			else
				break
			end
		end
		if i==1 then
			node_x = x0-1
			node_y = y0
		elseif i==2 then
			node_x = x0
			node_y = y0-1
		elseif i==3 then
			node_x = x0+1
			node_y = y0-1
		elseif i==4 then
			node_x = x0+1
			node_y = y0
		elseif i==5 then
			node_x = x0
			node_y = y0+1
		elseif i==6 then
			node_x = x0-1
			node_y = y0+1
		end
		if hex_accessible(node_x,node_y,map) then
			table.insert(path, {x = node_x,y=node_y})
			wayFound = true
		end
	end
	if wayFound == true then
		steps = steps+1
		--end
		path.steps = 2
		table.insert(path, {x = x0,y=y0})
		return path
	else
		return false
	end
end
