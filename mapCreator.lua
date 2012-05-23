-----------------------------------------
-- mapCreator.lua
-- Version 1.0
-- Author: Thiago Ramos
-- Functions:
--		hexDistance
--		hex_accessible
--		findPath
-----------------------------------------


module(..., package.seeall)





function createHexMap(x,y,w,h,lines,columns,defaultCellType,viewGroup)
	
	-------------- DISPLAY GROUPS
	hexGroup = display.newGroup()
	rabbitGroup = display.newGroup()
	objectsGroup = display.newGroup()
	numbersGroup = display.newGroup()
	viewGroup:insert(hexGroup)
	viewGroup:insert(rabbitGroup)
	viewGroup:insert(objectsGroup)
	viewGroup:insert(numbersGroup)
	displayTexts = false

	local coordinatedLines = (columns-columns%2)/2+lines-columns%2
	local levelMap = newBlankMatrix(coordinatedLines)
	levelMap.lines = coordinatedLines
	levelMap.columns = columns
	
	--create the default cell type
	levelMap.objects = {}
	defaultCellType.members = {}
	table.insert(levelMap.objects,defaultCellType)
	
	local cell_h = h/lines
	local cell_w = w/columns
	levelMap.cellH = cell_h
	levelMap.cellW = cell_w

	local lineHelper = (columns-1)/2
	for i = 1,columns do
		local linesToDraw = lines
		local yCorrection = 0
		if i % 2 == 1 then
			linesToDraw = linesToDraw-1
			yCorrection = cell_h/2
		end
		if i%2 == 0 then lineHelper = lineHelper-1 end
		for j=1,linesToDraw do
			local tempColumn = i-1+1
			local tempLine = j-1+lineHelper+1
			levelMap[tempColumn][tempLine] = {} -- here is where it will read the levelMap in the near future
			levelMap[tempColumn][tempLine].hexX = x+cell_w*(i-1)+cell_w/2
			levelMap[tempColumn][tempLine].hexY = y+cell_h*(j-1)+cell_h/2+yCorrection
			levelMap[tempColumn][tempLine].hexW = cell_w*1.4
			levelMap[tempColumn][tempLine].hexH = cell_h*1.05
			levelMap[tempColumn][tempLine].column = tempColumn
			levelMap[tempColumn][tempLine].line = tempLine
			levelMap[tempColumn][tempLine].id = 1
			levelMap[tempColumn][tempLine].terrainCost = defaultCellType.terrainCost
			levelMap[tempColumn][tempLine].mapRef = levelMap
		end
	end
	createHexGrid(levelMap,hexGroup) 
	return levelMap
end



function newBlankMatrix(iRows)
	local a = {}
	for i=1, iRows do
		a[i] = {}
	end
	return a
end


--TODO: missing work with isExit
function createNewObject(map, params)
	params.members = {}
	table.insert(map.objects,params)
end



function getCellTypeByTag(map,tag)
	for i=1,#map.objects do
		if map.objects[i].tag == tag then return map.objects[i] end
	end
	return false
end


function getCellTypeIdByTag(map,tag)
	for i=1,#map.objects do
		if map.objects[i].tag == tag then return i end
	end
	return false
end




function setClusterEffect(cell,isCreate)
	local x0 = cell.column
	local y0 = cell.line
	local cellId = cell.id
	local node_x = x0
	local node_y = y0
	local clusterEffect = cell.mapRef.objects[cell.id].clusterEffect
	if clusterEffect ~= nil then
		for i=1, 6 do
			--RUN NODE UPDATE FOR 6 NEIGHBOURIN TILES
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
			--CHECK IF THE NODE IS ACCESSIBLE (EXISTS ON THE MAP AND IS WALKABLE)
			if hex_exists(node_x,node_y,cell.mapRef) then
				if isCreate then
					cell.mapRef[node_x][node_y].terrainCost = cell.mapRef[node_x][node_y].terrainCost + clusterEffect
				else
					cell.mapRef[node_x][node_y].terrainCost = cell.mapRef[node_x][node_y].terrainCost - clusterEffect
				end
			end
		end
	else
		return false
	end
end


function hex_exists(x,y,mapArray)
	if mapArray[x] == nil then return false
	elseif mapArray[x][y] == nil then return false
	end
	return true
end


---O CHECK DE UNIQUE CELL VAI TER QUE SER MAIN?
function changeCell(cell,toId)
	--print("changing x:"..cell.column.." y:"..cell.line)
	--add new info to members
	local actualTerrainCost = cell.terrainCost
	local terrainClusterCost = cell.terrainCost - cell.mapRef.objects[cell.id].terrainCost
	local idMember = { x = cell.column, y = cell.line }
	--print("toId "..toId)
	table.insert(cell.mapRef.objects[toId].members,idMember)
	
	--clean old info from members
	if cell.mapRef.objects[cell.id].clusterEffect ~= nil then
		setClusterEffect(cell,false)
	end
	for i=1 , table.getn(cell.mapRef.objects[cell.id].members) do
		if cell.mapRef.objects[cell.id].members[i].x ==  cell.column and cell.mapRef.objects[cell.id].members[i].y ==  cell.line then
			table.remove(cell.mapRef.objects[cell.id].members,i)
			break
		end
	end
	cell.id = toId
	if cell.mapRef.objects[toId].clusterEffect ~= nil then
		setClusterEffect(cell,true)
	end
	cell.terrainCost = cell.mapRef.objects[toId].terrainCost + terrainClusterCost
end





---will deal only with the images!
function placeObject(cell, object,listener)
	--clean last images
	if cell.obj ~= nil then
		cell.obj:removeSelf()
		cell.obj = nil
	end
	--print(object.." placing")
	local objectId = getCellTypeIdByTag(cell.mapRef,object)
	changeCell(cell,objectId)
	local objectType = cell.mapRef.objects[cell.id]
	if objectType.isDynamic then
		local tempObject = display.newImageRect(objectType.img,objectType.imgW,objectType.imgH)
		tempObject.x = cell.hexX
		tempObject.y = cell.hexY
		if objectType.alpha ~= nil then tempObject.alpha = objectType.alpha end
		hexGroup:insert(tempObject)
		cell.obj = tempObject
		--add a listener
		if listener ~= nil then
			local hexClosure = function(event)
				listener(event,cell)
				return true 
			end
			cell.obj:addEventListener("touch",hexClosure)
		end
	end
	
	
end






function createHexGrid(map,displayGroup) 
	for j=1,table.getn(map) do
		if map[j] ~= nil then
			for i=1,table.getn(map[j]) do
				if map[j][i] ~= nil then
					local hexCell = map[j][i]
					local tempHexagon = display.newImageRect("gridLightGreen.png",hexCell.hexW,hexCell.hexH)
					tempHexagon.x = hexCell.hexX
					tempHexagon.y = hexCell.hexY
					tempHexagon.alpha = .1
					displayGroup:insert(tempHexagon)
					
					--add a label
					if displayTexts then
						if hexCell.text == nil then	hexCell.text = display.newText("",hexCell.hexX,hexCell.hexY,native.systemFont,22) end
						hexCell.text.text = hexCell.terrainCost
						numbersGroup:insert(hexCell.text)
					end
				end
			end
		end
	end
end

function updateHexGrid(map)
	if displayTexts then
		for j=1,table.getn(map) do
			if map[j] ~= nil then
				for i=1,table.getn(map[j]) do
					if map[j][i] ~= nil then
						local hexCell = map[j][i]	
						if hexCell.text == nil then	
							hexCell.text = display.newText("",hexCell.hexX,hexCell.hexY,native.systemFont,22) 
							numbersGroup:insert(hexCell.text)
						end
						hexCell.text.text = hexCell.terrainCost
					end
				end
			end
		end
	end
end


function getRandomPlaceableObject(map)
	possibleObjects = {}
	local weightSum = 0
	for i=1,#map.objects do
		if map.objects[i].isPlaceable then 
			table.insert(possibleObjects,i) 
			weightSum = weightSum + map.objects[i].appearingWeight 
		end
	end
	local randObjectId = nil
	local randWeight = math.random(1,weightSum)
	print("GETTING RANDOM OBJECT: "..randWeight)
	for i=1,#possibleObjects do
		local thisAppearingWeight = map.objects[possibleObjects[i]].appearingWeight
		if randWeight <= weightSum and randWeight >= weightSum - thisAppearingWeight then
			randObjectId = possibleObjects[i]
			print("got random object id "..randObjectId)
			break
		end
		weightSum = weightSum - thisAppearingWeight
	end
--	local randObjectId = math.random(1,#possibleObjects)
	return map.objects[randObjectId].tag
end



function getCellByXY(x,y,map)
	for j=1,table.getn(map) do
		if map[j] ~= nil then
			for i=1,table.getn(map[j]) do
				if map[j][i] ~= nil then
					local cell = map[j][i]
					if x > cell.hexX-cell.hexW/2 and x < cell.hexX+cell.hexW/2 and y > cell.hexY-cell.hexH/2 and y < cell.hexY+cell.hexH/2  then
						return cell
					end
				end
			end
		end
	end
	return false
end
