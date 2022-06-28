--[[
-------------------
---- Nexus.lua ----
---- by Wiylan ----
-------------------

----- Credits -----
-------------------
----- Nowiry ------
----- Jackz -------
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

menu.toggle(selfMenu, "Undead OTR", {"undeadotr"}, "Better Off The Radar.\nCan get detected by some menus.", function(toggle)
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

	if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
		util.toast("You need to be inside/on a Vehicle. :/")
		menu.trigger_command(sportmode, "off")
		return
	end

	ENTITY.SET_ENTITY_ROTATION(vehicle, camPos.x, camPos.y, camPos.z, 1, true)
	VEHICLE.SET_VEHICLE_GRAVITY(vehicle, false)
	ENTITY.SET_ENTITY_COLLISION(vehicle, not noclipVehicle, true)

	if PAD.IS_CONTROL_PRESSED(0, 61) then
		speed *= 2
	end
	if PAD.IS_CONTROL_PRESSED(0, 71) then
		if noGravity then
			ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0, sportmodeSpeed, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1)
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
			ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0, 0 - (lsp), 0, 0, 0, 0, 0, 1, 1, 1, 0, 1)
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
			ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, (lsp), 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1)
		else
			ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0 - (speed), 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1)
		end
	end
	if PAD.IS_CONTROL_PRESSED(0, 64) then
		local lsp = sportmodeSpeed
		if not PAD.IS_CONTROL_PRESSED(0, 61) then
			lsp = sportmodeSpeed * 2
		end
		if noGravity then
			ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, lsp, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1)
		else
			ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, speed, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1)
		end
	end
	if not noGravity and not PAD.IS_CONTROL_PRESSED(0, 71) and not PAD.IS_CONTROL_PRESSED(0, 72) then
		VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, 0)
	end
	if TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 2) then
		menu.trigger_command(sportmode, "off")
		if stopOnExit then
			VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, 0)
		end
	end
end, function()
	local vehicle <const> = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
	if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
		VEHICLE.SET_VEHICLE_GRAVITY(vehicle, true)
		ENTITY.SET_ENTITY_COLLISION(vehicle, true, true)
	end
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

menu.divider(vehicleMenu, "")
local nitroMenu <const> = menu.list(vehicleMenu, "Nitro", {}, "")

local duration = 2500
local recharge = 1000
local power = 1
local sound = true

menu.toggle_loop(nitroMenu, "Nitro", {"nitro"}, "Activate with X.", function()
	local vehicle <const> = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
	if PAD.IS_CONTROL_JUST_PRESSED(0, 73) and NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
		STREAMING.REQUEST_NAMED_PTFX_ASSET("veh_xs_vehicle_mods")
		VEHICLE._SET_VEHICLE_NITRO_ENABLED(vehicle, true, duration / 1000, power, 10000000, not sound)
		util.yield(duration)
		VEHICLE._SET_VEHICLE_NITRO_ENABLED(vehicle, false, 1, 1, 1, false)
		util.yield(recharge)
	end
end, function()
	local vehicle <const> = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
	if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
		VEHICLE._SET_VEHICLE_NITRO_ENABLED(vehicle, false, 1, 1, 1, false)
	end
end)

menu.slider(nitroMenu, "Duration", {}, "How long the boost lasts.\nIn ms.", 1, 10000000, 2500, 100, function(change)
	duration = change
end)
menu.slider(nitroMenu, "Recharge Time", {}, "How long the boost recharges.\nIn ms.", 0, 10000000, 1000, 100, function(change)
	recharge = change
end)
menu.slider(nitroMenu, "Power", {}, "How much force the boost applies.", 0, 50, 1, 1, function(change)
	power = change
end)
menu.toggle(nitroMenu, "Sound", {}, "Whether the boost should make sound.", function(toggle)
	sound = toggle
end, true)

menu.toggle_loop(vehicleMenu, "Low Traction", {"driftmode"}, "Ideal for drifting.\nSetting a hotkey is recommended.", function()
	local vehicle <const> = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
	if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
		VEHICLE.SET_VEHICLE_REDUCE_GRIP(vehicle, true)
		--VEHICLE._SET_VEHICLE_REDUCE_TRACTION(vehicle, 0)
		if TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 2) then
			VEHICLE.SET_VEHICLE_REDUCE_GRIP(vehicle, false)
		end
	end
end, function()
	local vehicle <const> = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
	if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
		VEHICLE.SET_VEHICLE_REDUCE_GRIP(vehicle, false)
	end
end)

--[[
----------------------
--- Player Options ---
----------------------
--]]

function controlVehicle(pid)
	local pos <const> = players.get_position(players.user())
	local targetPos <const> = players.get_position(pid)
	local distance <const> = SYSTEM.VDIST2(targetPos.x, targetPos.y, 0, pos.x, pos.y, 0)
	local targetVehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(pid), true)
	local spectate <const> = menu.ref_by_rel_path(menu.player_root(pid), "Spectate>Ninja Method")
	local spectating <const> = menu.get_value(spectate)

	if targetVehicle == 0 and distance > 340000 then
		local timeout <const> = os.time() + 3
		menu.trigger_command(spectate, "on")
		while targetVehicle == 0 and timeout > os.time() do
			targetVehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(pid), true)
			util.yield(100)
		end
	end
	if targetVehicle > 0 then
		if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(targetVehicle) then
			return targetVehicle
		end
		NETWORK.SET_NETWORK_ID_CAN_MIGRATE(NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(targetVehicle), true)
		local hasControl = false
		local loop = 15
		while not hasControl and loop > 0 do
			hasControl = NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(targetVehicle)
			loop -= 1
			util.yield(15)
		end
	end
	if not spectating then
		menu.trigger_command(spectate, "off")
	end
	if targetVehicle == 0 then
		util.toast(players.get_name(pid) .. " isn't in a vehicle. :/")
	end
	return targetVehicle
end

function playerRoot(pid)
	menu.divider(menu.player_root(pid), "-- Nexus --")

	local playerVehicleMenu <const> = menu.list(menu.player_root(pid), "Vehicle", {}, "Functionality depends on network conditions.")
	menu.divider(playerVehicleMenu, "-- Vehicle --")

	menu.action(playerVehicleMenu, "Fix", {}, "", function()
		local vehicle <const> = controlVehicle(pid)
		VEHICLE.SET_VEHICLE_FIXED(vehicle)
		VEHICLE.SET_VEHICLE_DEFORMATION_FIXED(vehicle)
		VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, 0)
	end)
	menu.action(playerVehicleMenu, "Tune", {}, "", function()
		local vehicle <const> = controlVehicle(pid)
		VEHICLE.SET_VEHICLE_MOD_KIT(vehicle, 0)
		for i = 0, 50 do
			VEHICLE.SET_VEHICLE_MOD(vehicle, i, VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i) - 1, false)
		end
	end)
	menu.action(playerVehicleMenu, "Kill Engine", {}, "", function()
		local vehicle <const> = controlVehicle(pid)
		VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, -4000)
	end)
	menu.action(playerVehicleMenu, "Burst Tires", {}, "", function()
		local vehicle <const> = controlVehicle(pid)
		VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, true)
		for i = 0, 7 do
			VEHICLE.SET_VEHICLE_TYRE_BURST(vehicle, i, true, 1000)
		end
	end)
	menu.action(playerVehicleMenu, "Boost Forward", {}, "May not sync.", function()
		local vehicle <const> = controlVehicle(pid)
		if vehicle != 0 then
			local force <const> = ENTITY.GET_ENTITY_FORWARD_VECTOR(vehicle)
			force:mul(40)
			--AUDIO.SET_VEHICLE_BOOST_ACTIVE(vehicle, true)
			ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, force.x, force.y, force.z, 0, 0, 0, 1, false, true, true, true, true)
			--AUDIO.SET_VEHICLE_BOOST_ACTIVE(vehicle, false)
		end
	end)
	menu.action(playerVehicleMenu, "Catapult", {}, "May not sync.", function()
		local vehicle <const> = controlVehicle(pid)
		if vehicle != 0 then
			--AUDIO.SET_VEHICLE_BOOST_ACTIVE(vehicle, true)
			ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0, 0, 9999, 0, 0, 0, 1, false, true, true, true, true)
			--AUDIO.SET_VEHICLE_BOOST_ACTIVE(vehicle, false)
		end
	end)
	menu.action(playerVehicleMenu, "Delete", {}, "", function()
		local vehicle <const> = controlVehicle(pid)
		entities.delete_by_handle(vehicle)
	end)

	menu.action(menu.player_root(pid), "Send to Beach", {}, "Summons them to Del Perro Beach", function()
		util.trigger_script_event(1 << pid, {1463943751, 1, 0, 0, 4, 0})
	end)
end

players.on_join(playerRoot)
players.dispatch_on_join()
