-- This is only for our slightly modified scripts.
-- Use require('Test.More') if you use the official lua-TestMore files
require('More')
-- Specify the number of tests you plan to run. 
plan(2) 
local someValue = 1
local test_count = 0

-- This function verifies parameter 1 is equal to parameter 2
is(someValue, 1, "someValue should be equal to 1")
test_count = test_count + 1

-- This function verifies parameter 1 is not equal to parameter 2
isnt(someValue, nil)
test_count = test_count + 1

-- declare you are done testing and the number of tests you have run
done_testing(test_count) 
--os.exit() -- convenient to have to make sure the process completely ends.

