-----------------------------------------
-- jonLevels.lua
-- Version 1.0
-- Author: Thiago Ramos
-- Functions:
--		
--
-----------------------------------------


module(..., package.seeall)

function init()
	json = require "json"
end

function saveMap(map)
	local id = linesCount("levels.txt")+1
	jsonLevel = {["coords"]={},["levelId"]="levelName "..id}
	
	--varre o mapa!
	for j=1,#map do
		if map[j] ~= nil then
			jsonLevel.coords[j] = {}
			for i=1,#map[j] do
				if map[j][i] ~= nil then
					local cell = map[j][i]
					--jsonLevel.coords[j][i] = {x = map[j][i].column,y=map[j][i].line,object=map.objects[map[j][i].id].tag}					
					jsonLevel.coords[j][i] = {x = j,y=i,object=map.objects[map[j][i].id].tag}					
				end
			end
		end
	end
	
	local jsonBlob = json.encode(jsonLevel)
	--print(jsonBlob)

	local path = system.pathForFile( "levels.txt", system.DocumentsDirectory )
	
   -- create file b/c it doesn't exist yet
   local file = io.open( path, "a" )
   
   file:write(jsonBlob.."\n")
   
   io.close( file )
	
end

function removeLevel(row)
	
	if row ~= nil then
		local tempPath = system.pathForFile( "templevels.txt", system.DocumentsDirectory )
		local tempLevelsFile = io.open( tempPath, "w" )


		print("removing row "..row)
		
		--COPY THE LEVELS TO A TEMP LEVEL WITHOUT THE REMOVED LEVEL
		local path = system.pathForFile( "levels.txt", system.DocumentsDirectory )
		local levelsFile = io.open( path, "r" )
		local lineHelper = 1
		local level = nil
		if levelsFile then
			for line in levelsFile:lines() do
				if lineHelper ~= row then
					tempLevelsFile:write(line.."\n")
				end
				lineHelper = lineHelper +1
			end
			io.close( levelsFile )
			io.close( tempLevelsFile )
			--NOW COPY IT BACK TO THE ORIGINAL LEVELS FILE
			tempLevelsFile = io.open( tempPath, "r" )
			levelsFile = io.open( path, "w" )
			
			for line in tempLevelsFile:lines() do
				levelsFile:write(line.."\n")
			end
			io.close( levelsFile )
		end
		io.close( tempLevelsFile )
		
		
	else
		print("sended a nil row")
	end
	
	--
	
	

end


function loadMap(row)
	if row ~= nil then
		print("loading map on row "..row)
		local path = system.pathForFile( "levels.txt", system.DocumentsDirectory )
		local file = io.open( path, "r" )
		local lineHelper = 1
		local level = nil
		if file then
			for line in file:lines() do
				if lineHelper == row then
					level = json.decode(line)
					break
				end
				lineHelper = lineHelper +1
			end
			io.close( file )
			if level ~= nil then
				return level
			end
		end
	end
	return false
end
 
--[[
function loadMap()
	local path = system.pathForFile( "levels.txt", system.DocumentsDirectory ) 
	local file = io.open( path, "r" )
	if file then
		local contents = file:read( )
		io.close( file )
		return json.decode(contents)
	end
	return false
end
 ]]--
 
function loadLevelsTable()
	local levelsTable = {}
	local path = system.pathForFile( "levels.txt", system.DocumentsDirectory )
	 
	--io.open opens a file at path. returns nil if no file found
	local file = io.open( path )
	if file then
		-- read all contents of file into a string
		for line in file:lines() do
			local tempTable = json.decode(line)
			table.insert(levelsTable, tempTable.levelId)
		end
		io.close( file )
		return levelsTable
	end
	return false
end



function linesCount(file)
	local count = 0
	local path = system.pathForFile( file, system.DocumentsDirectory  )
	local fh = io.open( path )
	if fh then
		for line in fh:lines() do
			count = count+1
		end
		
		fh:close()
	end
	return count
end
 
 --[[ Lua script:
 local t = { 
    ["name1"] = "value1",
    ["name2"] = {1, false, true, 23.54, "a \021 string"},
    name3 = json.null() 
 }
 
 local jsonBlob = json.encode (t)
 print (jsonBlob)  --> {"name1":"value1","name3":null,"name2":[1,false,true,23.54,"a \u0015 string"]}
 
 local t = json.decode(jsonBlob)
 print(t.name2[4])  --> 23.54]]--
 
 
 