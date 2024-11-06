if _TRANSPORT_FERRY_TEST_ASSERT_UNITS_GUARD then return end
_TRANSPORT_FERRY_TEST_ASSERT_UNITS_GUARD = true

local say = require("say")

say:set_namespace("en")

local UNITS_STATE_KEY = "__units_state"

local function _units_implementation(state, unitIDs)
    assert(rawget(state, UNITS_STATE_KEY) == nil, "unit(s) already set")
    rawset(state, UNITS_STATE_KEY, unitIDs)
    return state
end
local function units(state, args, level)
    assert(args.n > 0, "Must call units() with array of unit ID's")

    local unitArray = {}
    for i = 1,args.n do
        unitArray[i] = args[i]
    end

    return _units_implementation(state, unitArray)
end
local function unit(state, args, level)
    assert(args.n > 0, "Must call unit() with a unitID")
    return _units_implementation(state, {args[1]})
end

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
say:set("assertion.commandMove.negative", "Expected unit has not command:\n%s")
assert:register("assertion", "commandMove", commandMove, "assertion.commandMove.positive", "assertion.commandMove.negative")

assert:register("modifier", "unit", unit)
assert:register("modifier", "units", units)
