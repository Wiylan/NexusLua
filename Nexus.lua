--[[
-------------------
---- Nexus.lua ----
---- by Wiylan ----
-------------------

----- Credits -----
-------------------
----- Jayphen -----
----- Sapphire ----
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

menu.toggle(selfMenu, "Undead OTR", {"undeadotr"}, "Better Off The Radar. Can get detected by some menus.", function(toggle)
	undeadOtrToggle = toggle
	local maxHealth <const> = ENTITY.GET_ENTITY_MAX_HEALTH(players.user_ped())
	while undeadOtrToggle do
		ENTITY.SET_ENTITY_MAX_HEALTH(players.user_ped(), 0)
		util.yield()
	end
	ENTITY.SET_ENTITY_MAX_HEALTH(players.user_ped(), maxHealth)
	undeadOtrToggle = nil
end)

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

--[[
-----------------------
--- Vehicle Options ---
-----------------------
--]]

local vehicleMenu <const> = menu.list(menu.my_root(), "Vehicle", {}, "")
menu.divider(vehicleMenu, "-- Vehicle --")

local sportmodeSpeed = 10
local noGravity = false
local noclipVehicle = false
local stopOnExit = false

sportmode = menu.toggle_loop(vehicleMenu, "Sportmode", {"sportmode"}, "Makes your vehicle fly.", function()
	local vehicle <const> = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
	local camPos <const> = CAM.GET_GAMEPLAY_CAM_ROT(0)
	local speed = sportmodeSpeed * 10

	if vehicle == 0 or not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
		util.toast("You need to be inside/on a Vehicle. :/")
		menu.trigger_command(sportmode, "off")
		return
	end

	ENTITY.SET_ENTITY_ROTATION(vehicle, camPos.x, camPos.y, camPos.z, 1, true)
	VEHICLE.SET_VEHICLE_GRAVITY(vehicle, false)
	if noclipVehicle then
		ENTITY.SET_ENTITY_COLLISION(vehicle, false, true)
	end

	if PAD.IS_CONTROL_PRESSED(0, 61) then
		speed *= 2
	end
	if PAD.IS_CONTROL_PRESSED(0, 71) then
		if noGravity then
			ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0.0, sportmodeSpeed, 0.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
		else
			VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, speed)
		end
	end
	if PAD.IS_CONTROL_PRESSED(0, 72) then
		local lsp = sportmodeSpeed
		if not PAD.IS_CONTROL_PRESSED(0, 61) then
			lsp = sportmodeSpeed * 2
		end
		if noGravity then
			ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0.0, 0 - (lsp), 0.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
		else
			VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, 0 - (speed))
		end
	end
	if PAD.IS_CONTROL_PRESSED(0, 63) then
		local lsp = (0 - sportmodeSpeed) * 2
		if not PAD.IS_CONTROL_PRESSED(0, 61) then
			lsp = 0 - sportmodeSpeed
		end
		if noGravity then
			ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, (lsp), 0.0, 0.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
		else
			ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0 - (speed), 0.0, 0.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
		end
	end
	if PAD.IS_CONTROL_PRESSED(0, 64) then
		local lsp = sportmodeSpeed
		if not PAD.IS_CONTROL_PRESSED(0, 61) then
			lsp = sportmodeSpeed * 2
		end
		if noGravity then
			ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, lsp, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
		else
			ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, speed, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
		end
	end
	if not noGravity and not PAD.IS_CONTROL_PRESSED(0, 71) and not PAD.IS_CONTROL_PRESSED(0, 72) then
		VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, 0.0)
	end
	if TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 2) then
		menu.trigger_command(sportmode, "off")
		if stopOnExit then
			VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, 0.0)
		end
	end
end, function()
	local vehicle <const> = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
	VEHICLE.SET_VEHICLE_GRAVITY(vehicle, true)
	ENTITY.SET_ENTITY_COLLISION(vehicle, true, true)
end)

local sportmodeMenu <const> = menu.list(vehicleMenu, "Sportmode Settings", {}, "Configure Sportmode.")

menu.slider(sportmodeMenu, "Speed", {}, "", 0, 100, 10, 10, function(change)
	sportmodeSpeed = change
end)
menu.action(sportmodeMenu, "Speed Limit", {}, "Command: speedlimit [0 to 10000]", function()
	menu.show_command_box("speedlimit " .. menu.get_value(menu.ref_by_command_name("speedlimit")))
end)
menu.toggle(sportmodeMenu, "No Gravity", {}, "", function(toggle)
	noGravity = toggle
end)
menu.toggle(sportmodeMenu, "No Collision", {}, "", function(toggle)
	noclipVehicle = toggle
end)
menu.toggle(sportmodeMenu, "Stop on Exit", {}, "", function(toggle)
	stopOnExit = toggle
end)

menu.divider(vehicleMenu, "-- Miscellaneous --")

menu.toggle_loop(vehicleMenu, "Low Traction", {"driftmode"}, "Ideal for drifting.\nSetting a hotkey is recommended.", function()
	local vehicle <const> = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
	if vehicle and NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
		VEHICLE.SET_VEHICLE_REDUCE_GRIP(vehicle, true)
		--VEHICLE._SET_VEHICLE_REDUCE_TRACTION(vehicle, 0.0)
	end
	if TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 2) and NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
		VEHICLE.SET_VEHICLE_REDUCE_GRIP(vehicle, false)
	end
end, function()
	local vehicle <const> = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
	VEHICLE.SET_VEHICLE_REDUCE_GRIP(vehicle, false)
end)
