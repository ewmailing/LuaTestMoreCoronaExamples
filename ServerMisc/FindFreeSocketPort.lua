require('socket')

local my_socket = socket.bind(arg[1] or "*", 0)
local ipaddress, port = my_socket:getsockname()
my_socket:close()
print(port)

