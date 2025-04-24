-- by https://t.me/loveka2 | CtataPolka

require 'addon'
local http = require("socket.http")

local function ping()
	local server_ip = getServerAddress():match("(.+):.+")

	local req = "http://" .. server_ip .. ":80"
	local _, code, _, _ = http.request(req)

	code = tonumber(code) or 0

    print(string.format('Server ping %s (code: %d)', (code ~= 200 and code ~= 404) and '\x1b[1;31mfailed\x1b[0m' or '\x1b[1;32msuccessfull\x1b[0m', code))
end

newTask(function ()
	while true do
		if not isBotConnected() then
			ping()
		end
		wait(60000)
	end
end)