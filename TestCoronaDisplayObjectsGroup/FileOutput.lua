
--
-- lua-TestMore : <http://fperrad.github.com/lua-TestMore/>
--
local io = require 'io'

local assert = assert

-- We need to modify this because Corona doesn't handle subdirectories.
--local tb = require 'Test.Builder':new()
local tb = require 'Builder':new()
local m = getmetatable(tb)
_ENV = nil

function m.init (filename)
	local filehandle = assert(io.open(filename, "w+"))

    tb:output(filehandle)
    tb:failure_output(filehandle)
    tb:todo_output(filehandle)
end

return m
--
-- Copyright (c) 2011 Francois Perrad
--
-- This library is licensed under the terms of the MIT/X11 license,
-- like Lua itself.
--
