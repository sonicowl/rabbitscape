----------------------------------------------------------------------------------
--
-- scenetemplate.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
--import the table view library
local tableView = require("tableView")
require("ui")
jsonLevels = require("jsonLevels")
jsonLevels.init()
--initial values
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

local myList, backBtn, detailScreenText

--setup functions to execute on touch of the list view items
local function listButtonRelease( event )
	self = event.target
	print("selected level "..self.id)
	local id = self.id
	
	storyboard.levelId = id
	storyboard.gotoScene( "gameScene", "slideLeft", 400 )
	
end

local function drawTableView(group)
		-- setup the data
	removeButtons = {}
	data = jsonLevels.loadLevelsTable("levelsList.txt")
	local bottomBoundary = display.screenOriginY + 0

	if data ~= false then
		local levelHelper = 1
		-- Create a list with no background, allowing the background image to show through 
		myList = tableView.newList{
			data=data,
			default="listItemBg_white.png",
			over="listItemBg_over.png",
			onRelease=listButtonRelease,
			top=_VH0+40,
			bottom=bottomBoundary,
			callback=function(row) 
					rowGroup = display.newGroup()
					local t = display.newText(row, 0, 0, native.systemFontBold, 40)
					t:setTextColor(255, 255, 255)
					t.x = math.floor(t.width/2) + 12
					t.y = 46 
					rowGroup:insert(t)
					group:insert(rowGroup)
					return rowGroup

				end
		}
		group:insert(myList)
	end

end

local function removeTableView()
	if myList ~= nil then
		myList:removeSelf()
		myList = nil
	end
end




local function loadActions()

	actions["sceneBack"] = function(event)
		print("touched "..tostring(event.id))
		storyboard.gotoScene( "main-menu", "slideRight", 400 )
	end	

	buttonHandler = function( event )	-- General function for all buttons (uses "actions" table above)
		if ("release" == event.phase) then
			actions[event.id](event)
		end
		return true  --SO SIMPLE AND SO CONFUSING.... THIS PREVENTS FROM PROPAGATING TO OTHER BUTTONS
	end

end






---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	group = self.view
	lastScene = storyboard.getPrevious()
	actions = {}
	local bg = display.newImageRect("ground.jpg",_VW,_VH)
	bg.x = _W/2; bg.y = _H/2
	group:insert(bg)
	



	
	
	--Setup the nav bar 
	local navBar = display.newImageRect("navBar.png",_VW,40)
	navBar.x = display.contentWidth*.5
	navBar.y = math.floor(display.screenOriginY + navBar.height*0.5)
	group:insert(navBar)
	
	local navHeader = display.newText("LEVEL SELECT", 0, 0, native.systemFontBold, 16)
	navHeader:setTextColor(255, 255, 255)
	navHeader.x = display.contentWidth*.5
	navHeader.y = navBar.y
	group:insert(navHeader)
	loadActions()
	
	
	--Setup the back button
	backBtn = ui.newButton{ 
		default = "backButton.png", 
		over = "backButton_over.png", 
		id = "sceneBack",
		onEvent = buttonHandler,
	}
	group:insert(backBtn)
	backBtn.x = math.floor(backBtn.width/2) + screenOffsetW+10
	backBtn.y = navBar.y 
	backBtn.alpha = 1

	
	drawTableView(group)

	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	storyboard.purgeScene( lastScene )
	-----------------------------------------------------------------------------
		
	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	
	-----------------------------------------------------------------------------
	

	
	
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
	
	-----------------------------------------------------------------------------
	
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
	removeTableView()
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. remove listeners, widgets, save state, etc.)
	
	-----------------------------------------------------------------------------
	
end

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