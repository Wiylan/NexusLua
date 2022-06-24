--[[
-------------------
---- Nexus.lua ----
---- by Wiylan ----
-------------------
--]]

util.keep_running()
util.log("Nexus.lua is now running.")
util.require_natives("natives-1651208000")
menu.divider(menu.my_root(), "-- Nexus --")

--[[
--------------------
--- Self Options ---
--------------------
--]]

local selfMenu <const> = menu.list(menu.my_root(), "Self", {}, "")
menu.divider(selfMenu, "-- Self --")

menu.toggle(selfMenu, "No Knockout", {"noknockout"}, "Prevents the knockout animation from playing on your ped.", function(toggle)
	noKnockoutToggle = toggle
	if noKnockoutToggle then
		util.toast("Note that this will prevent you from joining new sessions and giving yourself weapons. :)")
	end
	while noKnockoutToggle do
		PED.SET_PED_CONFIG_FLAG(players.user_ped(), 71, true)
		util.yield()
	end
	PED.SET_PED_CONFIG_FLAG(players.user_ped(), 71, false)
	noKnockoutToggle = nil
end)
