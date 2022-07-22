--[[
-------------------
---- Nexus.lua ----
---- by Wiylan ----
-------------------

----- Credits -----
-------------------
----- Jackz -------
----- Jayphen -----
----- Nowiry ------
----- Prism -------
----- Sapphire ----
-------------------
--]]

util.keep_running()
util.log("Nexus.lua is now running.")
util.require_natives("natives-1651208000")

--[[
--------------------
--- Self Options ---
--------------------
--]]

local selfMenu <const> = menu.list(menu.my_root(), "Self", {}, "")

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

local sportmodeSpeed = 10
local sportmodeNoGravity = false
local sportmodeNoclipVehicle = false
local sportmodeStopOnExit = false

local sportmode <const> = menu.toggle_loop(vehicleMenu, "Sportmode", {"sportmode"}, "Makes your vehicle fly.", function()
	vehicleFly()
end, function()
	local vehicle <const> = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
	if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
		VEHICLE.SET_VEHICLE_GRAVITY(vehicle, true)
		ENTITY.SET_ENTITY_COLLISION(vehicle, true, true)
	end
end)

function vehicleFly()
	local vehicle <const> = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
	local camPos <const> = CAM.GET_GAMEPLAY_CAM_ROT(0)
	local speed = sportmodeSpeed * 10

	if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
		util.toast("You need to be inside/on a Vehicle. :/")
		menu.set_value(sportmode, false)
		return
	end

	ENTITY.SET_ENTITY_ROTATION(vehicle, camPos.x, camPos.y, camPos.z, 1, true)
	VEHICLE.SET_VEHICLE_GRAVITY(vehicle, false)
	ENTITY.SET_ENTITY_COLLISION(vehicle, not sportmodeNoclipVehicle, true)

	if PAD.IS_CONTROL_PRESSED(0, 61) then
		speed *= 2
	end
	if PAD.IS_CONTROL_PRESSED(0, 71) then
		if sportmodeNoGravity then
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
		if sportmodeNoGravity then
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
		if sportmodeNoGravity then
			ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, lsp, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1)
		else
			ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0 - (speed), 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1)
		end
	end
	if PAD.IS_CONTROL_PRESSED(0, 64) then
		local lsp = sportmodeSpeed
		if not PAD.IS_CONTROL_PRESSED(0, 61) then
			lsp = sportmodeSpeed * 2
		end
		if sportmodeNoGravity then
			ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, lsp, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1)
		else
			ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, speed, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1)
		end
	end
	if not sportmodeNoGravity and not PAD.IS_CONTROL_PRESSED(0, 71) and not PAD.IS_CONTROL_PRESSED(0, 72) then
		VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, 0)
	end
	if TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 2) then
		menu.set_value(sportmode, false)
		if sportmodeStopOnExit then
			VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, 0)
		end
	end
end

local sportmodeMenu <const> = menu.list(vehicleMenu, "Sportmode Settings", {}, "Configure Sportmode.")

menu.slider(sportmodeMenu, "Speed", {}, "", 0, 100, 10, 10, function(change)
	sportmodeSpeed = change
end)
menu.action(sportmodeMenu, "Speed Limit", {}, "Command: speedlimit [0 to 10000]", function()
	menu.show_command_box("speedlimit " .. menu.get_value(menu.ref_by_command_name("speedlimit")))
end)
menu.toggle(sportmodeMenu, "No Gravity", {}, "", function(toggle)
	sportmodeNoGravity = toggle
end)
menu.toggle(sportmodeMenu, "No Collision", {}, "", function(toggle)
	sportmodeNoclipVehicle = toggle
end)
menu.toggle(sportmodeMenu, "Stop on Exit", {}, "", function(toggle)
	sportmodeStopOnExit = toggle
end)

menu.divider(vehicleMenu, "")
local nitroMenu <const> = menu.list(vehicleMenu, "Nitro", {}, "")

local nitroDuration = 2500
local nitroRecharge = 1000
local nitroPower = 1
local nitroSound = true

menu.toggle_loop(nitroMenu, "Nitro", {"nitro"}, "Activate with X.", function()
	local vehicle <const> = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
	if PAD.IS_CONTROL_JUST_PRESSED(0, 73) and NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
		STREAMING.REQUEST_NAMED_PTFX_ASSET("veh_xs_vehicle_mods")
		VEHICLE._SET_VEHICLE_NITRO_ENABLED(vehicle, true, nitroDuration / 1000, nitroPower, 10000000, not nitroSound)
		util.yield(nitroDuration)
		VEHICLE._SET_VEHICLE_NITRO_ENABLED(vehicle, false, 1, 1, 1, false)
		util.yield(nitroRecharge)
	end
end, function()
	local vehicle <const> = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
	if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
		VEHICLE._SET_VEHICLE_NITRO_ENABLED(vehicle, false, 1, 1, 1, false)
	end
end)

menu.slider(nitroMenu, "Duration", {}, "How long the boost lasts.\nIn ms.", 1, 10000000, 2500, 100, function(change)
	nitroDuration = change
end)
menu.slider(nitroMenu, "Recharge Time", {}, "How long the boost recharges.\nIn ms.", 0, 10000000, 1000, 100, function(change)
	nitroRecharge = change
end)
menu.slider(nitroMenu, "Power", {}, "How much force the boost applies.", 0, 50, 1, 1, function(change)
	nitroPower = change
end)
menu.toggle(nitroMenu, "Sound", {}, "Whether the boost should make sound.", function(toggle)
	nitroSound = toggle
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
---------------------------------
--- Language Reaction Options ---
---------------------------------
--]]

local languages = {
	{ language = "English", toggle = false },
	{ language = "French", toggle = false },
	{ language = "German", toggle = false },
	{ language = "Italian", toggle = false },
	{ language = "Spanish", toggle = false },
	{ language = "Brazilian", toggle = false },
	{ language = "Polish", toggle = false },
	{ language = "Russian", toggle = false },
	{ language = "Korean", toggle = false },
	{ language = "Chinese Traditional", toggle = false },
	{ language = "Japanese", toggle = false },
	{ language = "Mexican", toggle = false },
	{ language = "Chinese Simplified", toggle = false }
}

local languageMenu <const> = menu.list(menu.my_root(), "Language Reactions", {}, "")
local languageSelectMenu <const> = menu.list(languageMenu, "Languages", {}, "")

local languageNotification = true
local languageLog = false
local languageChat = false
local languageTeamChat = false
local languageKick = false
local languageCrash = false

for i, v in ipairs(languages) do
	menu.toggle(languageSelectMenu, languages[i].language, {}, "", function(toggle)
		while util.is_session_transition_active() do
			util.yield()
		end
		languages[i].toggle = toggle
		if toggle then
			if languageNotification then
				local playerList <const> = players.list(false, true, true)
				for i, pid in ipairs(playerList) do
					if languages[players.get_language(pid) + 1].toggle then
						util.toast(players.get_name(pid) .. "'s game is in " .. languages[players.get_language(pid) + 1].language .. ". :)")
						util.yield(100)
					end
				end
			end
			if languageLog then
				local playerList <const> = players.list(false, true, true)
				for i, pid in ipairs(playerList) do
					if languages[players.get_language(pid) + 1].toggle then
						util.log(players.get_name(pid) .. "'s game is in " .. languages[players.get_language(pid) + 1].language .. ".")
						util.yield(100)
					end
				end
			end
			if languageChat then
				local playerList <const> = players.list(false, true, true)
				for i, pid in ipairs(playerList) do
					if languages[players.get_language(pid) + 1].toggle then
						chat.send_message(players.get_name(pid) .. "'s game is in " .. languages[players.get_language(pid) + 1].language .. ". :)", false, true, true)
						util.yield(100)
					end
				end
			end
			if languageTeamChat then
				local playerList <const> = players.list(false, true, true)
				for i, pid in ipairs(playerList) do
					if languages[players.get_language(pid) + 1].toggle then
						chat.send_message(players.get_name(pid) .. "'s game is in " .. languages[players.get_language(pid) + 1].language .. ". :)", true, true, true)
						util.yield(100)
					end
				end
			end
			if languageCrash then
				local playerList <const> = players.list(false, true, true)
				for i, pid in ipairs(playerList) do
					if languages[players.get_language(pid) + 1].toggle then
						menu.trigger_command(menu.ref_by_rel_path(menu.player_root(pid), "Crash>Elegant"), players.get_name(pid))
						util.yield(100)
					end
				end
			end
			if languageKick then
				local playerList <const> = players.list(false, true, true)
				for i, pid in ipairs(playerList) do
					if languages[players.get_language(pid) + 1].toggle then
						menu.trigger_command(menu.ref_by_rel_path(menu.player_root(pid), "Kick>Smart"), players.get_name(pid))
						util.yield(100)
					end
				end
			end
		end
	end)
end

local languageReactionMenu <const> = menu.list(languageMenu, "Reaction", {}, "")

menu.toggle(languageReactionMenu, "Notification", {}, "", function(toggle)
	while util.is_session_transition_active() do
		util.yield()
	end
	languageNotification = toggle
	if languageNotification then
		local playerList <const> = players.list(false, true, true)
		for i, pid in ipairs(playerList) do
			if languages[players.get_language(pid) + 1].toggle then
				util.toast(players.get_name(pid) .. "'s game is in " .. languages[players.get_language(pid) + 1].language .. ". :)")
				util.yield(100)
			end
		end
	end
end, true)
menu.toggle(languageReactionMenu, "Write To Log", {}, "", function(toggle)
	while util.is_session_transition_active() do
		util.yield()
	end
	languageLog = toggle
	if languageLog then
		local playerList <const> = players.list(false, true, true)
		for i, pid in ipairs(playerList) do
			if languages[players.get_language(pid) + 1].toggle then
				util.log(players.get_name(pid) .. "'s game is in " .. languages[players.get_language(pid) + 1].language .. ".")
				util.yield(100)
			end
		end
	end
end)
menu.toggle(languageReactionMenu, "Announce In Chat", {}, "", function(toggle)
	while util.is_session_transition_active() do
		util.yield()
	end
	languageChat = toggle
	if languageChat then
		local playerList <const> = players.list(false, true, true)
		for i, pid in ipairs(playerList) do
			if languages[players.get_language(pid) + 1].toggle then
				chat.send_message(players.get_name(pid) .. "'s game is in " .. languages[players.get_language(pid) + 1].language .. ". :)", false, true, true)
				util.yield(100)
			end
		end
	end
end)
menu.toggle(languageReactionMenu, "Announce In Team Chat", {}, "", function(toggle)
	while util.is_session_transition_active() do
		util.yield()
	end
	languageTeamChat = toggle
	if languageTeamChat then
		local playerList <const> = players.list(false, true, true)
		for i, pid in ipairs(playerList) do
			if languages[players.get_language(pid) + 1].toggle then
				chat.send_message(players.get_name(pid) .. "'s game is in " .. languages[players.get_language(pid) + 1].language .. ". :)", true, true, true)
				util.yield(100)
			end
		end
	end
end)

menu.divider(languageReactionMenu, "Player Actions")

menu.toggle(languageReactionMenu, "Kick", {}, "", function(toggle)
	while util.is_session_transition_active() do
		util.yield()
	end
	languageKick = toggle
	if languageKick then
		local playerList <const> = players.list(false, true, true)
		for i, pid in ipairs(playerList) do
			if languages[players.get_language(pid) + 1].toggle then
				menu.trigger_command(menu.ref_by_rel_path(menu.player_root(pid), "Kick>Smart"), players.get_name(pid))
				util.yield(100)
			end
		end
	end
end)
menu.toggle(languageReactionMenu, "Crash", {}, "", function(toggle)
	while util.is_session_transition_active() do
		util.yield()
	end
	languageCrash = toggle
	if languageCrash then
		local playerList <const> = players.list(false, true, true)
		for i, pid in ipairs(playerList) do
			if languages[players.get_language(pid) + 1].toggle then
				menu.trigger_command(menu.ref_by_rel_path(menu.player_root(pid), "Crash>Elegant"), players.get_name(pid))
				util.yield(100)
			end
		end
	end
end)

players.on_join(function(pid)
	while util.is_session_transition_active() do
		util.yield()
	end
	if languageNotification then
		if languages[players.get_language(pid) + 1].toggle and pid != players.user() then
			util.toast(players.get_name(pid) .. "'s game is in " .. languages[players.get_language(pid) + 1].language .. ". :)")
		end
	end
	if languageLog then
		if languages[players.get_language(pid) + 1].toggle and pid != players.user() then
			util.log(players.get_name(pid) .. "'s game is in " .. languages[players.get_language(pid) + 1].language .. ".")
		end
	end
	if languageChat then
		if languages[players.get_language(pid) + 1].toggle and pid != players.user() then
			chat.send_message(players.get_name(pid) .. "'s game is in " .. languages[players.get_language(pid) + 1].language .. ". :)", false, true, true)
		end
	end
	if languageTeamChat then
		if languages[players.get_language(pid) + 1].toggle and pid != players.user() then
			chat.send_message(players.get_name(pid) .. "'s game is in " .. languages[players.get_language(pid) + 1].language .. ". :)", true, true, true)
		end
	end
	if languageCrash then
		if languages[players.get_language(pid) + 1].toggle and pid != players.user() then
			menu.trigger_command(menu.ref_by_rel_path(menu.player_root(pid), "Crash>Elegant"), players.get_name(pid))
			util.yield(100)
		end
	end
	if languageKick then
		if languages[players.get_language(pid) + 1].toggle and pid != players.user() then
			menu.trigger_command(menu.ref_by_rel_path(menu.player_root(pid), "Kick>Smart"), players.get_name(pid))
			util.yield(100)
		end
	end
end)

--[[
----------------------
--- Player Options ---
----------------------
--]]

local businessProperties <const> = {
	-- Clubhouses
	"1334 Roy Lowenstein Blvd",
	"7 Del Perro Beach",
	"75 Elgin Avenue",
	"101 Route 68",
	"1 Paleto Blvd",
	"47 Algonquin Blvd",
	"137 Capital Blvd",
	"2214 Clinton Avenue",
	"1778 Hawick Avenue",
	"2111 East Joshua Road",
	"68 Paleto Blvd",
	"4 Goma Street",
	-- Facilities
	"Grand Senora Desert",
	"Route 68",
	"Sandy Shores",
	"Mount Gordo",
	"Paleto Bay",
	"Lago Zancudo",
	"Zancudo River",
	"Ron Alternates Wind Farm",
	"Land Act Reservoir",
	-- Arcades
	"Pixel Pete's - Paleto Bay",
	"Wonderama - Grapeseed",
	"Warehouse - Davis",
	"Eight-Bit - Vinewood",
	"Insert Coin - Rockford Hills",
	"Videogeddon - La Mesa"
}

local sextsLabels <const> = {
	"SXT_HCH_1ST",
	"SXT_HCH_2ND",
	"SXT_HCH_NEED",
	"SXT_INF_1ST",
	"SXT_INF_2ND",
	"SXT_INF_NEED",
	"SXT_JUL_1ST",
	"SXT_JUL_2ND",
	"SXT_JUL_NEED",
	"SXT_NIK_1ST",
	"SXT_NIK_2ND",
	"SXT_NIK_NEED",
	"SXT_SAP_1ST",
	"SXT_SAP_2ND",
	"SXT_SAP_NEED",
	"SXT_TXI_1ST",
	"SXT_TXI_2ND",
	"SXT_TXI_NEED"
}

function controlVehicle(pid)
	local pos <const> = players.get_position(players.user())
	local targetPos <const> = players.get_position(pid)
	local distance <const> = SYSTEM.VDIST2(targetPos.x, targetPos.y, 0, pos.x, pos.y, 0)
	local targetVehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(pid), true)
	local spectate <const> = menu.ref_by_rel_path(menu.player_root(pid), "Spectate>Ninja Method")
	local spectating <const> = menu.get_value(spectate)

	if targetVehicle == 0 and distance > 340000 then
		local timeout <const> = os.time() + 3
		menu.set_value(spectate, true)
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
		local timeout <const> = os.time() + 5
		while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(targetVehicle) and timeout > os.time() do
			NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(targetVehicle)
			util.yield(15)
		end
	end
	if not spectating then
		menu.set_value(spectate, false)
	end
	if targetVehicle == 0 then
		util.toast(players.get_name(pid) .. " isn't in a vehicle. :/")
	end
	return targetVehicle
end

players.on_join(function(pid)
	menu.divider(menu.player_root(pid), "-- Nexus --")

	local playerSETPMenu <const> = menu.list(menu.player_root(pid), "SE Teleport", {}, "")

	local playerSETPCayoPericoMenu <const> = menu.list(playerSETPMenu, "Cayo Perico", {}, "")
	local playerSETPClubhouseMenu <const> = menu.list(playerSETPMenu, "Clubhouse", {}, "")
	local playerSETPFacilityMenu <const> = menu.list(playerSETPMenu, "Facility", {}, "")
	local playerSETPArcadeMenu <const> = menu.list(playerSETPMenu, "Arcade", {}, "Will force them on a vehicle.")

	menu.action(playerSETPCayoPericoMenu, "Teleport To Cayo Perico", {}, "", function()
		util.trigger_script_event(1 << pid, {1463943751, pid, 0, 0, 3, 1, 0})
	end)
	menu.action(playerSETPCayoPericoMenu, "Teleport To Cayo Perico (No Cutscene)", {}, "", function()
		util.trigger_script_event(1 << pid, {1463943751, pid, 0, 0, 4, 1, 0})
	end)
	menu.action(playerSETPCayoPericoMenu, "Teleport To Main Island", {}, "Target needs to be at Cayo Perico.", function()
		util.trigger_script_event(1 << pid, {1463943751, pid, 0, 0, 3, 0, 0})
	end)
	menu.action(playerSETPCayoPericoMenu, "Kicked From Cayo Perico", {}, "Summons them to Del Perro Beach.", function()
		util.trigger_script_event(1 << pid, {1463943751, pid, 0, 0, 4, 0, 0})
	end)

	for i, name in ipairs(businessProperties) do
		if i < 13 then
			menu.action(playerSETPClubhouseMenu, name, {}, "", function()
				local netHash <const> = NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid)
				util.trigger_script_event(1 << pid, {962740265, pid, i, 32, netHash, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, math.random(1, 10)})
			end)
		elseif i < 22 then
			menu.action(playerSETPFacilityMenu, name, {}, "", function()
				local netHash <const> = NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid)
				util.trigger_script_event(1 << pid, {962740265, pid, i, 32, netHash, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0})
			end)
		else
			menu.action(playerSETPArcadeMenu, name, {}, "Will force them on a vehicle.", function()
				local netHash <const> = NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid)
				util.trigger_script_event(1 << pid, {962740265, pid, i, 32, netHash, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 1})
			end)
		end
	end

	local playerTrollingMenu <const> = menu.list(menu.player_root(pid), "Trolling", {}, "")

	menu.action(playerTrollingMenu, "Send Nudes", {}, "", function()
		for i = 1, #sextsLabels do
			local eventData = {-1702264142, players.user(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
			local out <const> = sextsLabels[i]:sub(1, 127)
			for i = 0, #out - 1 do
				local slot <const> = i // 8
				eventData[slot + 3] |= string.byte(out, i + 1) << ((i - slot * 8) * 8)
			end
			util.trigger_script_event(1 << pid, eventData)
		end
	end)

	local playerNotificationSpamMenu <const> = menu.list(playerTrollingMenu, "Notification Spam", {}, "")

	menu.toggle_loop(playerNotificationSpamMenu, "SMS Spam", {}, "", function()
		util.trigger_script_event(1 << pid, {1903866949, pid, math.random(-2147483647, 2147483647)})
	end)
	menu.toggle_loop(playerNotificationSpamMenu, "Nude Spam", {}, "", function()
		for i = 1, #sextsLabels do
			local eventData = {-1702264142, players.user(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
			local out <const> = sextsLabels[i]:sub(1, 127)
			for i = 0, #out - 1 do
				local slot <const> = i // 8
				eventData[slot + 3] |= string.byte(out, i + 1) << ((i - slot * 8) * 8)
			end
			util.trigger_script_event(1 << pid, eventData)
		end
	end)
	menu.toggle_loop(playerNotificationSpamMenu, "Invite Notification", {}, "", function()
		util.trigger_script_event(1 << pid, {1132878564, pid, math.random(1, 6)})
	end)
	menu.toggle_loop(playerNotificationSpamMenu, "Invite Notification v2", {}, "", function()
		util.trigger_script_event(1 << pid, {150518680, pid, math.random(1, 150), -1, -1})
		util.yield(25)
	end)
	menu.toggle_loop(playerNotificationSpamMenu, "Checkpoint Notification", {}, "", function()
		util.trigger_script_event(1 << pid, {677240627, pid, -1774405356, 0, 0, 0, 0, 0, 0, 0, pid, 0, 0, 0})
		util.yield(25)
	end)
	menu.toggle_loop(playerNotificationSpamMenu, "Character Notification", {}, "", function()
		util.trigger_script_event(1 << pid, {922450413, pid, math.random(0, 178), 0, 0, 0})
	end)
	menu.toggle_loop(playerNotificationSpamMenu, "SMS Label", {}, "", function()
		util.trigger_script_event(1 << pid, {-1702264142, pid, math.random(-2147483647, 2147483647)})
	end)
	menu.toggle_loop(playerNotificationSpamMenu, "Error Label", {}, "", function()
		util.trigger_script_event(1 << pid, {-1675759720, pid, math.random(-2147483647, 2147483647)})
	end)

	local playerVehicleMenu <const> = menu.list(menu.player_root(pid), "Vehicle", {}, "Functionality depends on network conditions.")

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

	menu.click_slider(menu.player_root(pid), "Set Wanted Level", {}, "Buggy Feature. Can take up to 20 seconds to apply.", 0, 5, 0, 1, function(click)
		local playerInfo <const> = memory.read_long(entities.handle_to_pointer(PLAYER.GET_PLAYER_PED(pid)) + 0x10C8)
		local bail <const> = menu.ref_by_rel_path(menu.player_root(pid), "Friendly>Never Wanted")
		local timeout <const> = os.time() + 20
		while memory.read_uint(playerInfo + 0x0888) != click and timeout > os.time() do
			if memory.read_uint(playerInfo + 0x0888) > click then
				menu.set_value(bail, true)
				util.yield(500)
				menu.set_value(bail, false)
			end
			for i = 1, 46 do
				PLAYER.REPORT_CRIME(pid, i, click)
			end
			util.yield(100)
		end
	end)
	menu.action(menu.player_root(pid), "Check Language", {}, "Checks the language of their game.", function()
		util.toast(players.get_name(pid) .. "'s game is in " .. languages[players.get_language(pid) + 1].language .. ". :)")
	end)
end)

players.dispatch_on_join()
