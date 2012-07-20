-----------------------------------------
-- module-store.lua
-- Version 1.0
-- Author: Thiago Ramos
-- Functions:
--		
-----------------------------------------


module(..., package.seeall)

function init(listener)
	if listener then moduleListener = listener end
	local store = require("store")
	store.init("apple", storeTransaction )
	require("ice")
	storeData = ice:loadBox( "storeData" )
	storeData:storeIfNew( "proPurchased", false )
	storeData:storeIfNew( "carrotsPurchased", false )
	storeData:save()
end


function storeTransaction( event )

	-- Handler that gets notified when the alert closes
	local onAgree = function( event )
	    if "clicked" == event.action then
	    end
	end

	local transaction = event.transaction
	if transaction.state == "purchased" then
			-- If store.purchase() was successful, you should end up in here for each product you buy.
			print("Transaction succuessful!")
			print("productIdentifier", transaction.productIdentifier)
			print("receipt", transaction.receipt)
			print("transactionIdentifier", transaction.identifier)
			print("date", transaction.date)
			if  transaction.productIdentifier == "extra_levels" then
				storeData:store( "proPurchased", false )
				storeData:save()
				if moduleListener then moduleListener() end
			elseif transaction.productIdentifier == "carrot_basket" then
				storeData:store( "carrotsPurchased", false )
				storeData:save()
				if moduleListener then moduleListener() end
			end
	elseif  transaction.state == "restored" then
			print("Transaction restored (from previous session)")
			print("productIdentifier", transaction.productIdentifier)
			if  transaction.productIdentifier == "extra_levels" then
				storeData:store( "proPurchased", false )
				storeData:save()
				if moduleListener then moduleListener() end
			elseif transaction.productIdentifier == "carrot_basket" then
				storeData:store( "carrotsPurchased", false )
				storeData:save()
				if moduleListener then moduleListener() end
			end
	elseif transaction.state == "cancelled" then
			print("User cancelled transaction")
	elseif transaction.state == "failed" then
			print("Transaction failed, type:", transaction.errorType, transaction.errorString)
			local alert = native.showAlert("Failed", "There was an error with the transaction. Please try again", { "OK" }, onAgree )
	else
			print("unknown event")
	end
	isSellingNow = false
	-- Once we are done with a transaction, call this to tell the store
	-- we are done with the transaction.
	-- If you are providing downloadable content, wait to call this until
	-- after the download completes.
	store.finishTransaction( transaction )
end


function sellingDialog(product)
	if not isSellingNow then
		local platform = system.getInfo("platformName")
		if product == "pro" then
			if platform == "iPhone OS" then
				isSellingNow = true
				store.purchase( {"extra_levels"} )
			else
				--system.openURL("market://details?id=com.sonicowl.colorpro")
				print("open store website")
			end
		elseif product == "carrots" then
			if platform == "iPhone OS" then
				isSellingNow = true
				store.purchase( {"carrot_basket"} )
				print("purchasing carrots")
			else
				--system.openURL("market://details?id=com.sonicowl.colorodissey")
				print("open store website")
			end	
		end
	end
end