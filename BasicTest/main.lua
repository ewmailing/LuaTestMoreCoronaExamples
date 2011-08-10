require('More')
plan(2) -- Specify the number of tests you plan to run. 
local nothing = nil
local test_count = 0
is(someValue, 1, "someValue should be equal to 1") -- This function verifies parameter 1 is equal to parameter 2
test_count = test_count + 1
isnt(someValue, nil) -- This function verifies parameter 1 is not equal to parameter 2
test_count = test_count + 1
done_testing(test_count) -- declare you are done testing and the number of tests you have run
--os.exit() -- convenient to have to make sure the process completely ends.

