-- slideView.lua
-- 
-- Version 1.0 
--
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of 
-- this software and associated documentation files (the "Software"), to deal in the 
-- Software without restriction, including without limitation the rights to use, copy, 
-- modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
-- and to permit persons to whom the Software is furnished to do so, subject to the 
-- following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all copies 
-- or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.

module(..., package.seeall)

local screenW, screenH = display.contentWidth, display.contentHeight
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local _VW, _VH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

local imgNum = nil
local buttons = nil
local touchListener, nextImage, prevImage, cancelMove, initImage
local background
local imageNumberText, imageNumberTextShadow




function new( dataSet, listener, isMute , slideBackground, top, bottom )	
	
	mute = isMute
	local pad = 20
	local top = top or 0 
	local bottom = bottom or 0

	local g = display.newGroup()
		
	if slideBackground then
		background = display.newImage(slideBackground, 0, 0, true)
	else
		background = display.newRect( 0, 0, screenW, screenH-(top+bottom) )
		background:setFillColor(0, 0, 0)
		background.alpha = .01
	end
	g:insert(background)
	buttons = {}

	
	local defaultString = "1 - " .. #dataSet

	local navBar = display.newGroup()
	g:insert(navBar)
	

	imageNumberText = display.newText(defaultString, 0, 0, "Poplar Std", 30)
	imageNumberText:setTextColor(255, 255, 255)
	imageNumberTextShadow = display.newText(defaultString, 0, 0, "Poplar Std", 30)
	imageNumberTextShadow:setTextColor(0, 0, 0)
	navBar:insert(imageNumberTextShadow)
	navBar:insert(imageNumberText)
	imageNumberText.x = _W*.5;							imageNumberText.y = _H/2+250
	imageNumberTextShadow.x = imageNumberText.x + 2;	imageNumberTextShadow.y = imageNumberText.y + 2
	

	imgNum = 1
	
	g.x = 0
	g.y = top + display.screenOriginY
	
	
	
	function touchListener (self, touch) 
		local phase = touch.phase
		--print("slides", phase)
		if ( phase == "began" ) then
            -- Subsequent touch events will target button even if they are outside the contentBounds of button
            display.getCurrentStage():setFocus( self )
            self.isFocus = true
			startPos = touch.x
			prevPos = touch.x
			
	
			buttonClick = true
			buttons[imgNum][1].isVisible = false
			buttons[imgNum][2].isVisible = true
			
			--transition.to( navBar,  { time=200, alpha=math.abs(navBar.alpha-1) } )
		
        elseif( self.isFocus ) then
        
			if ( phase == "moved" ) then
				buttonClick = false
				--transition.to(navBar,  { time=400, alpha=0 } )
				
				if tween then transition.cancel(tween) end
	
				print(imgNum)
				
				local delta = touch.x - prevPos
				prevPos = touch.x
				
				
				buttons[imgNum].x = buttons[imgNum].x + delta

				if (buttons[imgNum-1]) then
					buttons[imgNum-1].x = buttons[imgNum-1].x + delta
				end
				
				if (buttons[imgNum+1]) then
					buttons[imgNum+1].x = buttons[imgNum+1].x + delta
				end

			elseif ( phase == "ended" or phase == "cancelled" ) then

				dragDistance = touch.x - startPos
				print("dragDistance: " .. dragDistance)
				
				if (dragDistance < -40 and imgNum < #buttons) then
					nextImage()
				elseif (dragDistance > 40 and imgNum > 1) then
					prevImage()
				else
					cancelMove()
				end
									
				if ( phase == "cancelled" ) then		
					cancelMove()
				end

				if buttonClick then
					print("clicked button "..imgNum)
					if listener then listener(imgNum) end
				end
				
				buttons[imgNum][1].isVisible = true
				buttons[imgNum][2].isVisible = false
				
                -- Allow touch events to be sent normally to the objects they "hit"
                display.getCurrentStage():setFocus( nil )
                self.isFocus = false
														
			end
		end
					
		return true
		
	end
	local getFromResources = false
	if dataSet.resources then getFromResources = true end
	for i = 1,#dataSet do
		local tempData = dataSet[i]
		local h = viewableScreenH-(top+bottom)
		--[[local p = ui.newButton{
		default = tempData.default,
		over = tempData.over,
		id = i,
		onEvent = buttonHandler,
		}
		p:scale(.3,.3)]]--
		
		local p = display.newGroup()
		--system.DocumentsDirectory
		if getFromResources then
			local pDefault = display.newImageRect(tempData.default, math.floor(655/2),math.floor(789/2))
			p:insert(pDefault)
			local pOver = display.newImageRect(tempData.over,  math.floor(655/2),math.floor(789/2))
			p:insert(pOver)	
		else
			local pDefault = display.newImageRect(tempData.default,system.DocumentsDirectory, math.floor(655/2),math.floor(789/2))
			p:insert(pDefault)
			local pOver = display.newImageRect(tempData.over,system.DocumentsDirectory,  math.floor(655/2),math.floor(789/2))
			p:insert(pOver)
		end
		p[1].x = screenW*.5
		p[1].y = h*.5
		p[2].x = screenW*.5
		p[2].y = h*.5
		p[2].isVisible = false
		p[1].touch = touchListener
		--p[2].touch = touchListener
		p[1]:addEventListener( "touch",p[1] )

		if (i > 1) then
			p.x = screenW + pad -- all images offscreen except the first one
		else 
			p.x = 0
		end
		
		--p.y = h*.5
		g:insert(p)
		buttons[i] = p
	end
	

	

	

	
	function setSlideNumber()
		print("setSlideNumber", imgNum .. " - " .. #buttons)
		imageNumberText.text = imgNum .. " - " .. #buttons
		imageNumberTextShadow.text = imgNum .. " - " .. #buttons
	end
	
	function cancelTween()
		if prevTween then 
			transition.cancel(prevTween)
		end
		prevTween = tween 
	end
	
	function nextImage()
		tween = transition.to( buttons[imgNum], {time=800, x=(screenW + pad)*-1, transition=easing.outExpo } )
		tween = transition.to( buttons[imgNum+1], {time=800, x=0, transition=easing.outExpo } )
		imgNum = imgNum + 1
		initImage(imgNum)
		if not mute and soundSlide then audio.play(soundSlide) end	
	end
	
	function prevImage()
		tween = transition.to( buttons[imgNum], {time=800, x=screenW+pad, transition=easing.outExpo } )
		tween = transition.to( buttons[imgNum-1], {time=800, x=0, transition=easing.outExpo } )
		imgNum = imgNum - 1
		initImage(imgNum)
		if not mute and soundSlide then audio.play(soundSlide) end	
	end
	
	function cancelMove()
		tween = transition.to( buttons[imgNum], {time=800, x=0, transition=easing.outExpo } )
		tween = transition.to( buttons[imgNum-1], {time=800, x=(screenW + pad)*-1, transition=easing.outExpo } )
		tween = transition.to( buttons[imgNum+1], {time=800, x=screenW+pad, transition=easing.outExpo } )
	end
	
	function initImage(num)
		if (num < #buttons) then
			buttons[num+1].x = screenW + pad			
		end
		if (num > 1) then
			buttons[num-1].x = (screenW + pad)*-1
		end
		setSlideNumber()
	end

--	background.touch = touchListener
--	background:addEventListener( "touch", background )

	------------------------
	-- Define public methods
	
	function g:jumpToImage(num)
		local i
		print("jumpToImage")
		print("#buttons", #buttons)
		for i = 1, #buttons do
			if i < num then
				buttons[i].x = -screenW*.5;
			elseif i > num then
				buttons[i].x = screenW*1.5 + pad
			else
				buttons[i].x = screenW*.5 - pad
			end
		end
		imgNum = num
		initImage(imgNum)
	end

	
	function g:jumpTo(where)
		local i
		local num = imgNum + where
		if num <= #buttons and num > 0 then
			print("jumpTo")
			print("#buttons", #buttons)
			for i = 1, #buttons do
				if i < num then
					buttons[i].x = -screenW;
				elseif i > num then
					buttons[i].x = screenW + pad
				else
					buttons[i].x = 0
				end
			end
			imgNum = num
			initImage(imgNum)
		end
	end
	
	function g:page(where)
		local num = imgNum + where
		if num <= #buttons and num > 0 then
			if where == -1 then
				prevImage()
			else
				nextImage()
			end
		end
	end

	function g:cleanUp()
		print("slides cleanUp")
		--background:removeEventListener("touch", touchListener)
	end

	return g	
end

