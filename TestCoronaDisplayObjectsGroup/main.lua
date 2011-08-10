-- Test Code Project: display_objects-group
--
-- Date: February 9, 2011
--
-- Version: 1.0
--
-- File name: main.lua
--
-- Author: Tom Newman
--
-- Tests: Display groups APIs and textMemory with images
--
-- File dependencies: automated test files
--
-- Target devices: Simulator (results in Console)
--
-- Limitations:

-- Update History:
--	ver 1.0		2/9/10		Initial test
--
-- Tests Performed:
--
--	1. Start
--  2. Create group
--	3. Insert image 1
--	4. Insert Image 2
--	5. Insert Image 3
--	6. object:toBack
--	7. object:toFront
--  8. re-insert object (moving it front)
--	9. remove image 1
--	10. remove testGroup (automatically removes image 2 and image 3)
--	11. remove all text messages (textureMemory should be 0)
--	12. done
--
--		The state is incremented every 30 frames
--		The testing of memory and group is displayed every 30 frames
--
--
-- APIs Tested
--	display.newGroup
--	group:insert
--	object:toBack
--	object:toFront
--	object:removeSelf
--	system.getInfo("textureMemoryUsed")
--
-- Comments: 

---------------------------------------------------------------------------------

require('CoronaTest')

local number_of_tests = 31

function Quit()
--	print("Number of Display-1 tests run", numberOfTests)
	done_testing(numberOfTests)
	os.exit()
end

print(); print( "Testing Display Objects - Groups" )
print("Expected number of Display tests", number_of_tests)
plan(number_of_tests)

--------------------------------------------------
-- Test coding starts here --
--------------------------------------------------

-----------------------------------------------------------
-- Add Commas to whole numbers
--
-- Enter:	number = number to format
-- 			maxPos = maximum common position: 3, 6, 9, 12
--
-- Returns: formatted number string
-----------------------------------------------------------
--
local function AddCommas( number, maxPos )
	
	local s = tostring( number )
	local len = string.len( s )
	
	if len > maxPos then
		-- Add comma to the string
		local s2 = string.sub( s, -maxPos )		
		local s1 = string.sub( s, 1, len - maxPos )		
		s = (s1 .. "," .. s2)
	end
	
	maxPos = maxPos - 3		-- next comma position
	
	if maxPos > 0 then
		return AddCommas( s, maxPos )
	else
		return s
	end

end

-----------------------------------------------------------
-- Verify objects in Group
--
-- Enter:	group = pointer to group
-- 			items = lua table of objects expected in group
--
-- Returns: true if items are in group and in correct order
--			false if any item missing or out of order
-----------------------------------------------------------
--
local function verifyGroup( group, items )
--t	print( #items, group, tostring( items[1] ), tostring( items[2] ), group[1] )	-- debug
	
	for i = 1, #items do
		if group[i] ~= items[i] then
			return false
		end
	end
	
	return true			-- all items found and match
	
end


display.setStatusBar( display.HiddenStatusBar )		-- hide status bar

print( "TextureMemory: " .. AddCommas( system.getInfo("textureMemoryUsed"), 9 ) .. " bytes" )
print()

-- Displays text message in center of screen
txtMsg1 = display.newText( "See Console for Test Results", 55, 200, "Verdana-Bold", 14 )
txtMsg1:setTextColor( 255, 255, 0 )

-- Displays text message in center of screen
txtMsg2 = display.newText( "Touch screen for each state", 55, 400, "Verdana-Bold", 14 )
txtMsg2:setTextColor( 255, 255, 255, 128 ) 

--------------------------------
-- Code Execution Start Here
--------------------------------

-- Forward references
--
local image1, image2, image3, testGrp

local nextState = false


local frame = 0
local state = 1

function render(event)

-- Comment out the next line to run automated (no touch required)
--	if not nextState then return end

    frame=frame+1

-- Display information at frame 10
-- Action performed at frame 1
--				
	if frame == 1 then
        
		-- Create / destroys objects based on current state
		--
		if 1 == state then
			print(">>> Starting" )
			
		-- Create a test group
		--
		elseif 2 == state then
			print(">>> Creating testGroup" )
			testGroup = display.newGroup()
			
		elseif 3 == state then
			print(">>> Creating & Inserting Image1" )
			image1 = display.newImage( "Image1.png" )
			image1.name = "image1"        			
			testGroup:insert( image1 )
		
		elseif 4 == state then
			print(">>> Creating & Inserting Image2" )
			image2 = display.newImage( "Image2.jpg" )
			image2.name = "image2"
			testGroup:insert( image2 )
			
		elseif 5 == state then
			print(">>> Creating & Inserting Image3" )
			image3 = display.newImage( "Image3.jpg" )
			image3.name = "image3"        			
			testGroup:insert( image3 )
			
		elseif 6 == state then
			print(">>> toBack: Image3" )
			image3:toBack()

		elseif 7 == state then
			print(">>> toFront: Image1" )
			image1:toFront()		
		
		elseif 8 == state then
			print(">>> re-insert: Image2" )
			testGroup:insert(image2)

		elseif 9 == state then			
			print(">>> Removing Image1" )
			image1:removeSelf()
		
		elseif 10 == state then
			print(">>> Remove testGroup" )
			testGroup:removeSelf()

		elseif 11 == state then
			print(">>> Deleting txtMsg1 & txtMsg2 (text messages)" )
			txtMsg1:removeSelf()
			txtMsg2:removeSelf()
		
		elseif 12 == state then
			-- End the looping
			--
			-- Remove the listener and references to the objects
			--
			image1 = nil
			image2 = nil
			image3 = nil
			testGroup = nil
			txtMsg1 = nil
			txtMsg2 = nil
			
			Runtime:removeEventListener( "enterFrame", render)
			Runtime:removeEventListener( "touch", screenTouch ) 
			
			--------------------------------------------------
			-- Testing Done
			--------------------------------------------------
			Quit()
			
		end


	-- Display status information about the objects/group
	--
	elseif frame == 5 then
		
		print( "State: " .. state )
		
		if 1 == state then
			-- Starting
			is( system.getInfo("textureMemoryUsed"), 16384, "starting: textureMemoryUsed" )
			
		elseif 2 == state then
			-- Creating testGroup
			isnt( testGroup, "testGroup created" )
			is( testGroup.numChildren, 0, "numChildren" )
			is( system.getInfo("textureMemoryUsed"), 16384, "textureMemoryUsed" )
		
		elseif 3 == state then
			-- Added Image1
			is( testGroup.numChildren, 1, "numChildren" )
			is( system.getInfo("textureMemoryUsed"), 1064960, "textureMemoryUsed" )
			ok( verifyGroup( testGroup, {image1} ), "Image1 in Group" )

		elseif 4 == state then
			-- Added Image2
			is( testGroup.numChildren, 2, "numChildren" )
			is( system.getInfo("textureMemoryUsed"), 2113536, "textureMemoryUsed" )	
			ok( verifyGroup( testGroup, {image1, image2} ), "Image1, Image2 in Group" )
		
		elseif 5 == state then
			-- Added Image3
			is( testGroup.numChildren, 3, "numChildren" )
			is( system.getInfo("textureMemoryUsed"), 3162112, "textureMemoryUsed" )	
			ok( verifyGroup( testGroup, {image1, image2, image3} ), "Image1, Image2, Image3 in Group" )
--			print( "+++ testGroup: " .. testGroup[1].name .. ", " .. testGroup[2].name .. ", " .. testGroup[3].name )	-- debug

		elseif 6 == state then
			-- toBack Image3
			is( testGroup.numChildren, 3, "numChildren" )
			is( system.getInfo("textureMemoryUsed"), 3162112, "textureMemoryUsed" )	
			ok( verifyGroup( testGroup, {image3, image1, image2} ), "image3:toBack: Image3, Image1, Image2" )
--			print( "+++ testGroup: " .. testGroup[1].name .. ", " .. testGroup[2].name .. ", " .. testGroup[3].name )	-- debug

		elseif 7 == state then
			-- toBack Image1
			is( testGroup.numChildren, 3, "numChildren" )
			is( system.getInfo("textureMemoryUsed"), 3162112, "textureMemoryUsed" )	
			ok( verifyGroup( testGroup, {image3, image2, image1} ), "image1:toFront: Image3, Image2, Image1" )
--			print( "+++ testGroup: " .. testGroup[1].name .. ", " .. testGroup[2].name .. ", " .. testGroup[3].name )	-- debug

		elseif 8 == state then
			-- re-insert Image2
			is( testGroup.numChildren, 3, "numChildren" )
			is( system.getInfo("textureMemoryUsed"), 3162112, "textureMemoryUsed" )	
			ok( verifyGroup( testGroup, {image3, image1, image2} ), "re-insert image2: Image3, Image1, Image2" )
--			print( "+++ testGroup: " .. testGroup[1].name .. ", " .. testGroup[2].name .. ", " .. testGroup[3].name )	-- debug

		elseif 9 == state then
			-- remove Image1
			is( testGroup.numChildren, 2, "numChildren" )
			is( system.getInfo("textureMemoryUsed"), 2113536, "textureMemoryUsed" )	
			ok( verifyGroup( testGroup, {image3, image2} ), "removeSelf image1: Image3, Image2" )
--			print( "+++ testGroup: " .. testGroup[1].name .. ", " .. testGroup[2].name )	-- debug

		elseif 10 == state then
			-- remove testGroup
			is( system.getInfo("textureMemoryUsed"), 16384, "textureMemoryUsed" )	

			-- This verifies that the Display Object properties have been removed
			nok( testGroup.numChildren, "remove testGroup: numChildren" )
			nok( image1.x, "remove testGroup: image1.x" )
			nok( image2.x, "remove testGroup: image2.x" )
			nok( image3.x, "remove testGroup: image3.x" )

		elseif 11 == state then
			-- remove all text messages
			is( system.getInfo("textureMemoryUsed"), 0, "text msgs removed: textureMemoryUsed" )	

		end	-- end of state
			
		state = state + 1			-- next state
		
		print()

	-- Reset frame count and pause until the next screen touch
	--
	elseif frame == 6 then
		frame = 0
		nextState = false		-- reset our flag

	end

end

-- Set nextState flag when user touches the screen
--
local function screenTouch( event )
	if "ended" == event.phase then
		nextState = true
	end
end

Runtime:addEventListener( "touch", screenTouch )     
Runtime:addEventListener( "enterFrame", render )
