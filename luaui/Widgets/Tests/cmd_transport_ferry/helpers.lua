-- TODO: fix test runner so that it no longer ERRORs on this file:
--
--	  [Test Runner] ���ERROR����: cmd_transport_ferry/helpers.lua | no tests

if _TRANSPORT_FERRY_TEST_HELPER_GUARD then return end
_TRANSPORT_FERRY_TEST_HELPER_GUARD = true

VFS.Include("luarules/configs/customcmds.h.lua")
VFS.Include("luaui/Widgets/Tests/cmd_transport_ferry/assertions_units.lua")

local say = require("say")

say:set_namespace("en")

local function inCircle(x, z, circle)
    local distanceSquared = (x-circle[1])^2 + (z-circle[2])^2
    local radiusSquared = circle[3]^2

    return distanceSquared < radiusSquared
end

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

local function unitPos(state, arguments)
	local centerX = Game.mapSizeX / 2
	local centerZ = Game.mapSizeZ / 2

    local expectedCircle = arguments[1]
    local unitID = arguments[2]

    local actualX, _, actualZ = Spring.GetUnitPosition(unitID)

    if not actualX then return false end

    local relativeX = actualX - centerX
    local relativeZ = actualZ - centerZ

    return inCircle(relativeX, relativeZ, expectedCircle)
end

say:set("assertion.unitPos.positive", "Expected %s unitPos for unit with id:\n%s")
say:set("assertion.unitPos.negative", "Expected %s unitPos not for unit with id:\n%s")
assert:register("assertion", "unitPos", unitPos, "assertion.unitPos.positive", "assertion.unitPos.negative")

local function unitInTransport(state, arguments)
    local passengerUnitID = arguments[1]
    local transportUnitID = arguments[2]

    local transporteeArray = Spring.GetUnitIsTransporting(transportUnitID)
    if not transporteeArray then
        -- it wasn't a transport
        return false
    end

    for _,unitID in ipairs(transporteeArray) do
        if passengerUnitID == unitID then
            return true
        end
    end

    return false
end

say:set("assertion.unitInTransport.positive", "Expected unit %s in transport:\n%s")
say:set("assertion.unitInTransport.negative", "Expected unit %s not in transport:\n%s")
assert:register("assertion", "unitInTransport", unitInTransport, "assertion.unitInTransport.positive", "assertion.unitInTransport.negative")

--[[
local function unitHasCommand(unitID, expectedID, expectedParams)
    local unitCommandQueue = Spring.GetUnitCommands(unitID, -1)

    if not unitCommandQueue then return false end

    for i = 1,#unitCommandQueue do
        if unitCommandQueue[i].id == expectedID then
            local match = true
            if expectedParams then
                for j,param in ipairs(unitCommandQueue[i].params) do
                    Spring.Echo("param: " .. tostring(param))
                    if expectedParams[j] and (expectedParams[j] ~= param) then
                        match = false
                    end
                end
            end
            if match then
                return true
            end
        end
    end

    return false
end

local function unitCommandMove(state, arguments)
	local centerX = Game.mapSizeX / 2
	local centerZ = Game.mapSizeZ / 2

    local unitID = arguments[1]
    local pos = arguments[2]

    local x = nil
    local z = nil

    if not pos then
        x = pos[1] + centerX
        z = pos[3] + centerZ
    end

    return unitHasCommand(unitID, CMD.MOVE, {x, nil, z})
end

say:set("assertion.unitCommandMove.positive", "Expected unit %s has command:\n%s")
say:set("assertion.unitCommandMove.negative", "Expected unit %s has not command:\n%s")
assert:register("assertion", "unitCommandMove", unitCommandMove, "assertion.unitCommandMove.positive", "assertion.unitCommandMove.negative")
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

	spawnUnit = function(unitType, offsetX, offsetZ)
		local myTeamID = Spring.GetMyTeamID()
		local x = Game.mapSizeX / 2
		local z = Game.mapSizeZ / 2
		local y = Spring.GetGroundHeight(x, z)
		local facing = 1

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
}

return obj
