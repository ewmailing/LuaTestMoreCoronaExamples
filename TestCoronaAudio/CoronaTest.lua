-- This is a customization script for Lua Test More that configures the test environment to work with our custom needs.
-- This file transparently configures things in Test More such as socket connections and timeouts.
-- This file must be included before calling "require('More')

require 'socket'

local s_tbOriginalDoneTesting = nil
local s_CoronaTimeOutValue = nil

module("CoronaTest", package.seeall) 


local function CoronaTestTimerAppKiller( event )
	print("Corona Test timeout expired (application side)...calling os.exit()")
	note("CoronaTest timeout triggered")
	os.exit()
end


local function GetHostAndPort()
	local host = nil
	local port = nil
	--[[
	local host = "127.0.0.1"
	local port = 12345
	--]]


--	print("GetHostAndPort", GetHostAndPort)
--	print("os.getenv", os.getenv("HOME"))
--	print("os.getenv", os.getenv("HOST"))
	if arg then
		host = arg[1]
		port = arg[2]
	elseif os.getenv("TESTMORE_HOST") and  os.getenv("TESTMORE_PORT") then
		print("Detected environmental variables TESTMORE_HOST & TESTMORE_PORT")
		host =  os.getenv("TESTMORE_HOST")
		port =  os.getenv("TESTMORE_PORT")
		print("Detected environmental variables TESTMORE_HOST & TESTMORE_PORT", host, port)
	else
		local ok = pcall(require, 'TestMoreOutputServerInfo')
		if ok then
			--print("got data from pcall")
			host = TestMoreOutputServerInfo.Host
			port = TestMoreOutputServerInfo.Port
			s_CoronaTimeOutValue = TestMoreOutputServerInfo.TimeOut
		end

	end

	return host, port
end

local function GetOutputFileName()
	local filename = nil
	if arg then
		filename = arg[1]
	elseif os.getenv("TESTMORE_OUTPUT_FILENAME") then
		filename =  os.getenv("TESTMORE_OUTPUT_FILENAME")
		print("Detected environmental variable TESTMORE_OUTPUT_FILENAME", filename)
	else
		local ok = pcall(require, 'TestMoreOutputFileInfo')
		if ok then
			--print("got data from pcall")
			filename = TestMoreOutputFileInfo.FileName
			s_CoronaTimeOutValue = TestMoreOutputFileInfo.TimeOut
		end

	end

	return filename

end


local function SetupFileOrStdout()

	local filename = GetOutputFileName()
	if filename then
		require 'FileOutput'.init(filename)
		require 'More'
		note("App is reporting to file: " .. tostring(filename))
		
	else
		require 'More'
		note("App is reporting to stdout/stderr")
	
	end
end

-- CoronaTest.Init
local function Init()
--	local tb = test_builder()
	
	--[[
	local host = "127.0.0.1"
	local port = 12345
	--]]
	--
	
	-- Override assert to kill the test program
	-- This is not really necessary if we trap lua errors to call exit() for us.
	do
		local old_assert = assert
		assert = function(condition)
			if not condition then
				print("Dectected assertion failure: aborting Corona program")
				return old_assert(condition)
				--os.exit()
			end
			return old_assert(condition)
		end
	end
	
	local host, port = GetHostAndPort()
	if host and port then
		print("Application connecting to host and port", host, port)
		local server = socket.connect(host, port)
		if not server then
			-- Might not want to abort in case we are running the simulator and have a stray host/port file
			note("Failure of app connect to specified host and port: " .. tostring(host) ..":" .. tostring(port) .. ". Maybe you have a stale TestMoreOutputServerInfo.lua file?")

			SetupFileOrStdout()
		else
			require 'SocketOutput'.init(server)
			require 'More'
			note("App successfully connected to server on host and port: " .. tostring(host) ..":" .. tostring(port))
		end
	else
			SetupFileOrStdout()
			note("App is reporting results to local machine")
	end

	-- Override done_testing()
	do
		s_tbOriginalDoneTesting = done_testing
		_G["done_testing"] = function(num_tests)
			note("CoronaTest completed all tests")
			return s_tbOriginalDoneTesting(num_tests)
		end
	end

	-- Capture Test More plan() so our plan function can invoke it 
	s_tbPlan = plan

	-- The timeout was loaded in the TestMoreOutput*Info if set
	if s_CoronaTimeOutValue and type(s_CoronaTimeOutValue) == "number" then
		timer.performWithDelay(s_CoronaTimeOutValue, CoronaTestTimerAppKiller)
	end
end

-- Override the global plan function defined by More.
-- This is the magic that hides all the setup from users.
-- But you must require this file before More.
_G["plan"] = function(plan_args)
	Init()
	-- s_tbPlan was setup in Init(). It is the regular test more plan function.
	s_tbPlan(plan_args)
end

-- Placeholder for done_testing.
-- Should be rewritten during Init()
_G["done_testing"] = function(num_tests)
	print("Assertion error: called done_testing before our custom init (via plan) was invoked")
	assert(false)
end
