--[[
-------------------
---- Nexus.lua ----
---- by Wiylan ----
-------------------

----- Credits -----
-------------------
----- Jackz -------
----- Jayphen -----
----- Lance -------
----- Nowiry ------
----- Prism -------
----- Sapphire ----
-------------------
--]]

-- Source: https://github.com/Wiylan/NexusLua/

util.keep_running()
util.log("Nexus.lua is being loaded.")

async_http.init("raw.githubusercontent.com", "/Wiylan/NexusLua/main/Nexus.lua", function(data)
	util.create_thread(load(data))
	util.yield()
end, function()
	util.toast("Failed to load github content. :/\nMake sure you are connected to the internet and stand isn't blocking internet access.")
	util.log("Nexus.lua failed to load.")
	util.stop_script()
end)
async_http.dispatch()
