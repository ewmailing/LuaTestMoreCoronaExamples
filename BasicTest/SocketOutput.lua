
--
-- lua-TestMore : <http://fperrad.github.com/lua-TestMore/>
--

--[[
    require 'socket'
    local conn = socket.connect(host, port)
    require 'Test.Builder.Socket'.init(conn)
    require 'Test.More'  -- now, as usual

    plan(...)
    ...
--]]

local assert = assert

-- We need to modify this because Corona doesn't handle subdirectories.
--local tb = require 'Test.Builder':new()
local tb = require 'Builder':new()
local m = getmetatable(tb)
_ENV = nil

function m.init (sock)
    tb:output(sock)
    tb:failure_output(sock)
    tb:todo_output(sock)
end

function m.puts (sock, str)
    assert(sock:send(str))
end

return m
--
-- Copyright (c) 2011 Francois Perrad
--
-- This library is licensed under the terms of the MIT/X11 license,
-- like Lua itself.
--
