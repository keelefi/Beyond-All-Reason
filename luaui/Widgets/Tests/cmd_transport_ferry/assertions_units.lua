if _TRANSPORT_FERRY_TEST_ASSERT_UNITS_GUARD then return end
_TRANSPORT_FERRY_TEST_ASSERT_UNITS_GUARD = true

local say = require("say")

say:set_namespace("en")

local function inRange(expected, actual, acceptedInaccuracy)
    local distanceSquared = 0
    for i=1,3 do
        if expected[i] then
            distanceSquared = distanceSquared + (expected[i] - actual[i])^2
        end
    end

    local inaccuracySquared = acceptedInaccuracy^2

    return distanceSquared <= inaccuracySquared
end

local UNITS_STATE_KEY = "__units_state"

local function _units_implementation(state, unitIDs)
    assert(rawget(state, UNITS_STATE_KEY) == nil, "unit(s) already set")
    rawset(state, UNITS_STATE_KEY, unitIDs)
    return state
end
local function units(state, args, level)
    assert(args.n > 0, "Must call units() with array of unit ID's")

    local unitArray = {}
    if type(args[1]) == "number" then
        for i = 1,args.n do
            unitArray[i] = args[i]
        end
    elseif type(args[1]) == "table" then
        for i = 1,#args[1] do
            unitArray[i] = args[1][i]
        end
    end

    return _units_implementation(state, unitArray)
end
local function unit(state, args, level)
    assert(args.n > 0, "Must call unit() with a unitID")
    return _units_implementation(state, {args[1]})
end

assert:register("modifier", "unit", unit)
assert:register("modifier", "units", units)

local function hasCommand(state, expectedID, expectedParams)
    local unitIDs = rawget(state, UNITS_STATE_KEY)
    assert(unitIDs ~= nil, "no unitID set, cannot check unit commands")

    -- TODO: loop over all units, not just first
    local unitID = unitIDs[1]

    local unitCommandQueue = Spring.GetUnitCommands(unitID, -1)

    if not unitCommandQueue then return false end

    for i = 1,#unitCommandQueue do
        if unitCommandQueue[i].id == expectedID then
            local match = true
            if expectedParams then
                for j,param in ipairs(unitCommandQueue[i].params) do
                    Spring.Echo("param: " .. tostring(param))
                    Spring.Echo("expectedparam: " .. tostring(expectedParams[j]))
                    if expectedParams[j] then
                        if type(expectedParams[j]) == "number" then
                            if ((expectedParams[j] - param) > 1) then
                                match = false
                            end
                        elseif (expectedParams[j] ~= param) then
                            match = false
                        end
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

--[[
local function commandMove(state, arguments)
	local centerX = Game.mapSizeX / 2
	local centerZ = Game.mapSizeZ / 2

    local pos = arguments[1]

    local x = nil
    local z = nil

    if pos then
        x = pos[1] + centerX
        z = pos[3] + centerZ
    end

    return hasCommand(state, CMD.MOVE, {x, nil, z})
end

say:set("assertion.commandMove.positive", "Expected unit has command:\n%s")
say:set("assertion.commandMove.negative", "Expected unit does not have command:\n%s")
assert:register("assertion", "commandMove", commandMove, "assertion.commandMove.positive", "assertion.commandMove.negative")
]]

local function moveCommand(state, arguments)
    local unitIDs = rawget(state, UNITS_STATE_KEY)
    assert(unitIDs ~= nil, "no unitID set, cannot check unit commands")

    local expectedPosition = nil
    local acceptedInaccuracy = 0
    if (#arguments >= 1) and (type(arguments[1] == "table")) then
        expectedPosition = arguments[1]

        if (#arguments >= 2) and (type(arguments[2]) == "number") then
            acceptedInaccuracy = arguments[2]
        end
    end

    local match = false
    for _,unitID in ipairs(unitIDs) do
        local unitCommandQueue = Spring.GetUnitCommands(unitID, -1)
        assert(unitCommandQueue ~= nil, "failed to fetch unit commands for unit")

        for i=1,#unitCommandQueue do
            if unitCommandQueue[i].id == CMD.MOVE then
                if expectedPosition ~= nil then
                    local params = {}
                    params[1] = unitCommandQueue[i].params[1] - Game.mapSizeX / 2
                    params[2] = unitCommandQueue[i].params[2]
                    params[3] = unitCommandQueue[i].params[3] - Game.mapSizeZ / 2
                    if inRange(expectedPosition, params, acceptedInaccuracy) then
                        match = true
                    end
                else
                    match = true
                end
            end
        end
    end

    return match
end

say:set("assertion.moveCommand.positive", "Expected unit has move command:\n%s")
say:set("assertion.moveCommand.negative", "Expected unit does not have move command:\n%s")
assert:register("assertion", "moveCommand", moveCommand, "assertion.moveCommand.positive", "assertion.moveCommand.negative")

local function position(state, arguments)
    local unitIDs = rawget(state, UNITS_STATE_KEY)
    assert(unitIDs ~= nil, "no unitID set, cannot check unit position")

    local expectedPosition = arguments[1]

    local acceptedInaccuracy = 0
    if #arguments >= 2 then
        acceptedInaccuracy = arguments[2]
    end

    for _,unitID in ipairs(unitIDs) do
        local actualPosition = { Spring.GetUnitPosition(unitID) }
        if not actualPosition then return false end

        actualPosition[1] = actualPosition[1] - Game.mapSizeX / 2
        actualPosition[3] = actualPosition[3] - Game.mapSizeZ / 2

        if not inRange(expectedPosition, actualPosition, acceptedInaccuracy) then
            return false
        end
    end

    return true
end

say:set("assertion.position.positive", "Expected unit has position:\n%s")
say:set("assertion.position.negative", "Expected unit does not have position:\n%s")
assert:register("assertion", "position", position, "assertion.position.positive", "assertion.position.negative")

--[[
    transportingUnit(<unitIDs) checks if any of the passengers is in any of the transports
]]
local function transportingUnit(state, arguments)
    local transportUnitIDs = rawget(state, UNITS_STATE_KEY)
    assert(transportUnitIDs ~= nil, "no unitID set, cannot check transportees")

    local passengerUnitIDs = arguments[1]
    assert(passengerUnitIDs ~= nil, "no transportee unitIDs set")

    local transporteeUnitIDs = {}
    for _,transportUnitID in ipairs(transportUnitIDs) do
        local transporteeArray = Spring.GetUnitIsTransporting(transportUnitID)
        assert(transporteeArray ~= nil, "unitID " .. tostring(transportUnitID) .. " is not a transport")

        for _,transporteeUnitID in ipairs(transporteeArray) do
            for _,passengerUnitID in ipairs(passengerUnitIDs) do
                if passengerUnitID == transporteeUnitID then
                    return true
                end
            end
        end
    end

    return false
end

say:set("assertion.transportingUnit.positive", "Expected unit %s in transport:\n%s")
say:set("assertion.transportingUnit.negative", "Expected unit %s not in transport:\n%s")
assert:register("assertion", "transportingUnit", transportingUnit, "assertion.transportingUnit.positive", "assertion.transportingUnit.negative")

--[[
    transportingUnits(<unitIDs) checks if all of the passengers are in the transports
]]
local function transportingUnits(state, arguments)
    local transportUnitIDs = rawget(state, UNITS_STATE_KEY)
    assert(transportUnitIDs ~= nil, "no unitID set, cannot check transportees")

    local passengerUnitIDs = arguments[1]

    local transporteeUnitIDs = {}
    for _,transportUnitID in ipairs(transportUnitIDs) do
        local transporteeArray = Spring.GetUnitIsTransporting(transportUnitID)
        assert(transporteeArray ~= nil, "unitID " .. tostring(transportUnitID) .. " is not a transport")

        for _,transporteeUnitID in ipairs(transporteeArray) do
            table.insert(transporteeUnitIDs, transporteeUnitID)
        end
    end

    if (passengerUnitIDs == nil) or (type(passengerUnitIDs) == "string") then
        return #transporteeUnitIDs > 0
    end
    if type(passengerUnitIDs) == "number" then
        return #transporteeUnitIDs == tonumber(passengerUnitIDs)
    end

    for _,passengerUnitID in ipairs(passengerUnitIDs) do
        local passengerFound = false
        for _,transporteeUnitID in ipairs(transporteeUnitIDs) do
            if passengerUnitID == transporteeUnitID then
                passengerFound = true
                break
            end
        end
        if not passengerFound then return false end
    end

    return true
end

say:set("assertion.transportingUnits.positive", "Expected unit %s in transport:\n%s")
say:set("assertion.transportingUnits.negative", "Expected unit %s not in transport:\n%s")
assert:register("assertion", "transportingUnits", transportingUnits, "assertion.transportingUnits.positive", "assertion.transportingUnits.negative")
