-----------------------------------------
-- social.lua
-- Version 1.1
-- Author: Thiago Ramos
-- Functions:
--		POST TO FACEBOOK
--		SEND AN E-MAIL
--		POST TO TWITTER
--		OPENFEINT INTEGRATION
-----------------------------------------



module(..., package.seeall)

function init()
	-- INITIALIZERS
	require("ice")
	facebook = require "facebook"
	gameNetwork = require "gameNetwork"
	local loggedIntoGC = false
	gameData = ice:loadBox( "gameData" )
	gameData:storeIfNew( alreadyRated, false )
	--deployType = gameData:retrieve( "deployType" )

	----------------------------------------------
	-- OPENFEINT CONFIG
	----------------------------------------------

	--local of_product_key = "NpS5MHDAFh0RUFiLDAA"
	--local of_product_secret = "k6p6UzGD1H4ZsrU4TLoqhydD507kdHnHvmT4CX4DbI"
	--local of_app_id = "463522"
	--local displayName = "Color Matrix"

	if gameNetwork then
		print("initiating gamecenter")
		gameNetwork.init( "gamecenter", initCallback )
	else
		native.showAlert( "gameNetwork", "Library not found!", { "OK" } )
	end


end

-- called after the "init" request has completed
function initCallback( event )
    if event.data then
        loggedIntoGC = true
        --native.showAlert( "Success!", "User has logged into Game Center", { "OK" } )
    else
        loggedIntoGC = false
        native.showAlert( "Fail", "User is not logged into Game Center", { "OK" } )
    end
end


---------------------------------------------------
-- SHOW OPENFEINT 
---------------------------------------------------

function showGCPopup()
	gameNetwork.show( "leaderboards", { leaderboard = {timeScope="Week"}, listener=dismissCallback } )
	--FOR OPENFEINT
	--gameNetwork.show( "leaderboards" )
end

---------------------------------------------------
-- SETS OPENFEINT SCORE
---------------------------------------------------

function setGCHighScore(score,level)
	print("sending highScore to gamecenter "..score.." level:"..level)
	gameNetwork.request( "setHighScore",
	{
			localPlayerScore = { category="level_"..level, value=score },
			listener=requestCallback
	})

	--FOR OPENFEINT
	--local leaderID = ""
	--if level =="e" then
	--	if matrixSize == 6 then leaderID = "1117297"
	--	elseif matrixSize == 9 then leaderID = "1117317" end
	--else
	--	if matrixSize == 6 then leaderID = "1117307"
	--	elseif matrixSize == 9 then leaderID = "1117327" end
	--end
	--gameNetwork.request( "setHighScore", { leaderboardID=leaderID, score=score, displayText=score.." points" } )	
end



---------------------------------------------------
-- SEND SCORE THROUGH EMAIL
---------------------------------------------------

function sendEmail(score)
	print("social module: sendEmail score:"..score)
	local msg = "Hey, I just scored "..score.." playing Catch the Bunny for Ipad! Check it out on the Appstore or at catchthebunny.sonicowl.com"
	local options =
	{
		to = "",
		subject = "My High Score on Catch the Bunny",
		body = msg,
	}
   --attachment = { baseDir=system.DocumentsDirectory, filename="Screenshot.png", type="image" },
	native.showPopup("mail", options)
end



---------------------------------------------------
-- POST SCORE ON FACEBOOK
---------------------------------------------------

function postToFacebook(score)
	
	local appId = "269313563145048"

	
	-- Code to Post Status to Facebook (don't forget the 'require "facebook"' line at top of module)
	-- The Code below is fully functional as long as you replace the fbAppID var with valid app ID.
	
	local facebookListener = function( event )
		if ( "session" == event.type ) then
			-- upon successful login, update their status
			if ( "login" == event.phase ) then

				local statusUpdate = "Hey, I just scored "..score.." playing Catch the Bunny for Ipad! Check it out on the Appstore"

				facebook.request( "me/feed", "POST", {
					message=statusUpdate,
					name="Download Catch the Bunny to Compete with Me!",
					caption="Catch the Bunny - A exciting game for Ipad made by Sonic Owl" ,
					link="http://catchthebunny.sonicowl.com"
					--picture="http://www.yoursite.com/link-to-90x90-image.png" 
					} )
			end
		end
		if event.isError then
				local firstRecordText = display.newRetinaText(event.response, 0, 0, native.systemFont, 12 )
				firstRecordText.x = _W/2
				firstRecordText.y = _H/2
		end
	end
	facebook.login( appId, facebookListener, { "publish_stream" } )
end



---------------------------------------------------
-- POST SCORE ON TWITTER
---------------------------------------------------

function postToTwitter(score)
	system.openURL("http://twitter.com/home?status=Hey,+I+just+scored+"..score.."+playing+#CatchTheBunny+for+Ipad!+Check+it+out+on+the+Appstore+or+at+http://catchthebunny.sonicowl.com")
end



---------------------------------------------------
-- CALLS A DIALOG TO RATE THE APP
---------------------------------------------------

local function rateItCallBack( event )
	if "clicked" == event.action then
			local i = event.index
			if 1 == i then
			--TODO: GET STORE LINKS
				--[[if deployType == "android_odissey" then system.openURL("market://details?id=com.sonicowl.colorodissey")
				elseif deployType == "android_free" then system.openURL("market://details?id=com.sonicowl.colorfree")
				elseif deployType == "android_pro" then system.openURL("market://details?id=com.sonicowl.colorpro")
				elseif deployType == "iOS" then	
					--system.openURL( "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=XXXXXXXXXXXX" )
					print("not rating cause we dont have it on the appstore yet")
				end]]--
				
				gameData:store( "alreadyRated", true)
				gameData:save()
			elseif 2 == i then
				print('dont want to rate it now!')
			end
	end
end

function rateItDialog()
	local alert = native.showAlert( "Rate our game!", "Like our game? Please tell the others!", 
	{ "Rate it!", "Not now!" }, rateItCallBack )
end