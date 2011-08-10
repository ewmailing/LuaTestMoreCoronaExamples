-----------------------------------------------------------------------------
-- TCP sample: Little program to dump lines received at a given port
-- LuaSocket sample files
-- Author: Diego Nehab
-- RCS ID: $Id: listener.lua,v 1.11 2005/01/02 22:44:00 diego Exp $
-----------------------------------------------------------------------------
-- Example Usage: lua TapSocketLisener.lua "*" 12345 ../test-output/mytest.tap true
-- param IPaddress
-- param port
-- param testoutputfile
-- param echoOn
local socket = require("socket")
require('os')
host = host or "*"
port = port or  12345
destinationFile = "/tmp/LuaTestMore_results.log"
echoOn = true
if arg then
	host = arg[1] or host
	port = arg[2] or port
	destinationFile = arg[3] or destinationFile

	if arg[4] == "false" then
		echoOn = false
	else
		echoOn = true
	end
end
print("opening file", destinationFile)
print("Tap Listener echo is", echoOn)

file = assert(io.open(destinationFile, "w+"))
print("Binding to host '" ..host.. "' and port " ..port.. "...")
file:write("# TapSocketListener started on host " .. tostring(host) .. ":" .. tostring(port) .. " to file: " .. tostring(destinationFile) .. ", echo is: " .. tostring(echoOn) .. "\n")
s = assert(socket.bind(host, port))
i, p   = s:getsockname()
assert(i, p)
print("Waiting connection from talker on " .. i .. ":" .. p .. "...")
c = assert(s:accept())
file:write("# TapSocketListener received connection.\n")
print("Connected. Here is the stuff:")
l, e = c:receive()
while not e do
	if true == echoOn then
		print(l)
	end

	file:write(l)
	file:write("\n")

	if "# CoronaTest timeout triggered" == l then
		print("Timeout notification received...terminating")
		print(e)
		c:close()
		file:close()
		os.exit(1)
		
	elseif "# CoronaTest completed all tests" == l then
		print("Completed notification received...terminating")
		print(e)
		c:close()
		file:close()
		os.exit(0)

	end
	l, e = c:receive()
end
print(e)
file:write("# TapSocketListener was disconnected unexpectedly\n")
file:close()
os.exit(2)

