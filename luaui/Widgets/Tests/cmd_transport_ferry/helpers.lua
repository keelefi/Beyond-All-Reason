-- TODO: fix test runner so that it no longer ERRORs on this file:
--
--	  [Test Runner] ���ERROR����: cmd_transport_ferry/helpers.lua | no tests

if _TRANSPORT_FERRY_TEST_HELPER_GUARD then return end
_TRANSPORT_FERRY_TEST_HELPER_GUARD = true

VFS.Include("luarules/configs/customcmds.h.lua")
VFS.Include("luaui/Widgets/Tests/cmd_transport_ferry/assertions_ferry_routes.lua")
VFS.Include("luaui/Widgets/Tests/cmd_transport_ferry/assertions_units.lua")

local say = require("say")

say:set_namespace("en")

local function zone_coordinates(state, arguments)
	local centerX = Game.mapSizeX / 2
	local centerZ = Game.mapSizeZ / 2

	local expectedX = centerX + arguments[1]
	local expectedZ = centerZ + arguments[2]
	local actualZone = arguments[3]

	if (not actualZone) or (not actualZone["x"]) or (not actualZone["z"]) then
		return false
	end

	local actualX = actualZone.x
	local actualZ = actualZone.z

	if (actualX ~= expectedX) or (actualZ ~= expectedZ) then
		return false
	end

	return true
end

say:set("assertion.zone_coordinates.positive", "Expected coordinates [%s, %s] in:\n%s")
say:set("assertion.zone_coordinates.negative", "Expected coordinates [%s, %s] not in:\n%s")
assert:register("assertion", "zone_coordinates", zone_coordinates, "assertion.zone_coordinates.positive", "assertion.zone_coordinates.negative")

--[[
local function serversBusy(state, arguments)
    local expected = arguments[1]
    local actualServersBusy = arguments[2]

    local actualCount = 0
    for uID,_ in pairs(actualServersBusy) do
        actualCount = actualCount + 1
    end

	return expected == actualCount
end

say:set("assertion.serversBusy.positive", "Expected %s server(s) busy in:\n%s")
say:set("assertion.serversBusy.negative", "Expected %s server(s) busy not in :\n%s")
assert:register("assertion", "serversBusy", serversBusy, "assertion.serversBusy.positive", "assertion.serversBusy.negative")
]]

local obj = {
	spawnTransport = function(transportType, offsetX, offsetZ)
		local myTeamID = Spring.GetMyTeamID()
		local x = Game.mapSizeX / 2
		local z = Game.mapSizeZ / 2
		local y = Spring.GetGroundHeight(x, z)
		local facing = 1

		local unitDefName
		if transportType then
			unitDefName = transportType
		else
			unitDefName = "armatlas"
		end

		if offsetX and offsetZ then
			x = x + offsetX
			z = z + offsetZ
		end

		local unitID = SyncedRun(function(locals)
			return Spring.CreateUnit(
				locals.unitDefName,
				locals.x,
				locals.y,
				locals.z,
				locals.facing,
				locals.myTeamID
			)
		end)

		return unitID
	end,

	moveTransport = function(unitID, offsetX, offsetZ, shift)
		local x = Game.mapSizeX / 2 + offsetX
		local z = Game.mapSizeZ / 2 + offsetZ
		local y = Spring.GetGroundHeight(x, z)

		local cmdOpts1 = 0
		local cmdOpts2 = {}
		if shift then
			cmdOpts1 = cmdOpts1 + CMD.OPT_SHIFT
			cmdOpts2 = {shift=true}
		end

		SyncedRun(function (locals)
			Spring.GiveOrderToUnit(locals.unitID, CMD.MOVE, { locals.x, locals.y, locals.z }, locals.cmdOpts1)
		end)
		widget:CommandNotify(CMD.MOVE, { x, y, z, r }, cmdOpts2)
	end,

	setFerry = function(widget, offsetX, offsetZ, radius, shift)
		local x = Game.mapSizeX / 2 + offsetX
		local z = Game.mapSizeZ / 2 + offsetZ
		local y = Spring.GetGroundHeight(x, z)

		local r
		if radius then
			r = radius
		else
			r = 100
		end

		local cmdOpts
		if shift then
			cmdOpts = {shift=true}
		else
			cmdOpts = {}
		end

		widget:CommandNotify(CMD_SET_FERRY, { x, y, z, r }, cmdOpts)
		--SyncedRun(function (locals)
		--	Spring.GiveOrderToUnit(locals.unitID, CMD_SET_FERRY, { locals.x, locals.y, locals.z, locals.r }, locals.cmdOpts)
		--end)
	end,

	spawnUnit = function(unitType, offsetX, offsetZ, unitFacing)
		local myTeamID = Spring.GetMyTeamID()
		local x = Game.mapSizeX / 2
		local z = Game.mapSizeZ / 2
		local y = Spring.GetGroundHeight(x, z)

		local facing = nil
        if unitFacing ~= nil then
            facing = unitFacing
        else
            facing = 1
        end

		local unitDefName
		if unitType then
			unitDefName = unitType
		else
			unitDefName = "armpw"
		end

		if offsetX and offsetZ then
			x = x + offsetX
			z = z + offsetZ
		end

		local unitID = SyncedRun(function(locals)
			return Spring.CreateUnit(
				locals.unitDefName,
				locals.x,
				locals.y,
				locals.z,
				locals.facing,
				locals.myTeamID
			)
		end)

		return unitID
	end,

	moveUnit = function(unitID, offsetX, offsetZ, shift)
		local x = Game.mapSizeX / 2 + offsetX
		local z = Game.mapSizeZ / 2 + offsetZ
		local y = Spring.GetGroundHeight(x, z)

		local cmdOpts1 = 0
		local cmdOpts2 = {}
		if shift then
			cmdOpts1 = cmdOpts1 + CMD.OPT_SHIFT
			cmdOpts2 = {shift=true}
		end

		SyncedRun(function (locals)
			Spring.GiveOrderToUnit(locals.unitID, CMD.MOVE, { locals.x, locals.y, locals.z }, locals.cmdOpts1)
		end)
		widget:CommandNotify(CMD.MOVE, { x, y, z, r }, cmdOpts2)
	end,

	unitFromFactory = function(factoryID, unitDef)
        local unitDefID
        if unitDef == nil then
            unitDefID = UnitDefNames["armpw"].id
        elseif type(unitDef) == "string" then
            unitDefID = UnitDefNames[unitDef].id
        else
            unitDefID = unitDef
        end

		SyncedRun(function (locals)
			Spring.GiveOrderToUnit(locals.factoryID, CMD.INSERT, { 0, -locals.unitDefID, CMD.OPT_ALT + CMD.OPT_INTERNAL }, CMD.OPT_ALT + CMD.OPT_CTRL)
		end)
	end,
}

return obj
