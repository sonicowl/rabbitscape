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


function loadMap(row,fileName)
	if row ~= nil then
		print("loading map on row "..row)
		local path = nil
		if fileName ~=nil then
			path = system.pathForFile( fileName, system.ResourceDirectory )
		else
			path = system.pathForFile( "levels.txt", system.DocumentsDirectory )
		end
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
 

 
function loadLevelsTable(fileName)
	local levelsTable = {}
	local path = nil
	if fileName ~=nil then
		if fileName == "downloadedLevels.txt" then path = system.pathForFile( fileName, system.DocumentsDirectory )
		else path = system.pathForFile( fileName, system.ResourceDirectory ) end
		print("loading map from "..fileName)
	else
		path = system.pathForFile( "levels.txt", system.DocumentsDirectory )
		print("loading map from levels.txt")
	end
	local file = io.open( path )
	--io.open opens a file at path. returns nil if no file found
	if file then
		-- read all contents of file into a string
		for line in file:lines() do
			local tempTable = json.decode(line)
			if tempTable then
				table.insert(levelsTable, tempTable.levelId)
			end
		end
		io.close( file )
		return levelsTable
	else
		print("file not found")
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


function syncLevels(listener)

	--DOWNLOAD THE JSONS txt
	--CREATE A TABLE WITH ALL THE FILES!
	filesToDownload = {}
	--CHECK EACH FILE IF ITS ALREADY ON THE SYSTEM AND IF NOT DOWNLOAD IT
	syncPhase = 1
	onComplete = listener
	Runtime:addEventListener("enterFrame", downloadingAssets)
	
	--AFTER CHECKING EVERY FILE RECHECK AGAIN TO CONFIRM THE DOWNLOAD WAS SUCCESSFUL
	--SUBSTITUTE THE DOWNLOADED JSON WITH THE OFFICIAL ONE
	--RETURN TRUE
	loadingRect = display.newRect(_VW0,_VH0+_VH-50,400,50)
	loadingRect:setFillColor(0,0,0)
	loadingRect.alpha = .5
	loadingText = display.newText("LOADING LEVELS...", 0, 0, "Poplar Std", 30)
	loadingText:setReferencePoint(display.CenterLeftReferencePoint);
	loadingText.x = _VW0+10; loadingText.y = loadingRect.y
	group:insert(loadingRect)
	group:insert(loadingText)
end


function downloadingAssets(event)
	print("downloading Assets")
	if syncPhase == 1 then
		downloadingFile = true
		download("serverLevels.txt")
		table.insert(filesToDownload,"serverLevels.txt")
		syncPhase = 2
	end
	if syncPhase == 2 then
		if not downloadingFile then
			local path = system.pathForFile( "serverLevels.txt", system.DocumentsDirectory )
			local levelsFile = io.open( path )
			if levelsFile then
				for line in levelsFile:lines() do
					local tempTable = json.decode(line)
					if tempTable then
						--GET THE BGS
						for i=1, #tempTable.backgrounds do
							table.insert(filesToDownload,tempTable.backgrounds[i])
						end
						--GET THE OVERLAYS
						for i=1, #tempTable.overlays do
							table.insert(filesToDownload,tempTable.overlays[i])
						end
						--GET THE ANIMATIONS
						if tempTable.sceneAnim then
							if tempTable.sceneAnim.mask then table.insert(filesToDownload , tempTable.sceneAnim.mask) end
							for i=1, #tempTable.sceneAnim.objects do
								table.insert(filesToDownload,tempTable.sceneAnim.objects[i].img)
							end
						end
					end
				end
				io.close( levelsFile )
				syncPhase = 3
			else
				--TODO: DO SOMETHING WHEN DOWNLOAD THE TABLES WENT WRONG
				print("levelsFile not found")
			end
		end
	end
	if syncPhase == 3 then
		if not downloadingFile and #filesToDownload > 0 then
			if checkIfFileExists(filesToDownload[1]) then
				removeFileFromTable(filesToDownload, filesToDownload[1])
			else
				download(filesToDownload[1])
			end
		elseif #filesToDownload == 0 then
			syncPhase = 4
		end
	end
	if syncPhase == 4 then
		copyFromFile("serverLevels.txt","downloadedLevels.txt")
		Runtime:removeEventListener("enterFrame", downloadingAssets)
		loadingRect:removeSelf()
		loadingRect = nil
		loadingText:removeSelf()
		loadingText = nil
		
		onComplete()
	end
end



function checkIfFileExists(fileName)
	local path = system.pathForFile( fileName, system.DocumentsDirectory )
	local testFile = io.open(path)
	if testFile then 
		io.close(testFile)
		return true; 
	end
	return false
end





function copyFromFile(fromFile,toFile)
	
	local tempPath = system.pathForFile( toFile, system.DocumentsDirectory )
	local tempToFile = io.open( tempPath, "w" )
	
	--COPY THE LEVELS TO A TEMP LEVEL WITHOUT THE REMOVED LEVEL
	local path = system.pathForFile( fromFile, system.DocumentsDirectory )
	local tempFromFile = io.open( path, "r" )
	local lineHelper = 1
	local level = nil
	if tempFromFile then
		for line in tempFromFile:lines() do
			tempToFile:write(line.."\n")
			lineHelper = lineHelper +1
		end
		io.close( tempFromFile )
	end
	io.close( tempToFile )
	return true
end




function networkListener( event )
	if ( event.isError ) then
		print ( "Network error - download of "..event.response.." failed" )
	else
		removeFileFromTable(filesToDownload, event.response)
		print ( "Download of " .. event.response.." completed!" )
	end
	downloadingFile = false
end


function download(file)
	downloadingFile = true
	network.download( 
		"http://www.sonicowl.com/gameassets/"..file, 
		"GET", 
		networkListener, 
		file, 
		system.DocumentsDirectory )

end


function removeFileFromTable(tableRef, file)
	for i = 1 , #tableRef do
		if file == tableRef[i] then
			table.remove(tableRef,i)
			return true
		end
	end
	return false
end
