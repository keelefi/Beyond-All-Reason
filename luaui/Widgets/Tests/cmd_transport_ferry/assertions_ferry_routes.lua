if _TRANSPORT_FERRY_TEST_ASSERT_FERRY_ROUTES_GUARD then return end
_TRANSPORT_FERRY_TEST_ASSERT_FERRY_ROUTES_GUARD = true

local say = require("say")

say:set_namespace("en")

local FERRY_ROUTE_STATE_KEY = "__ferry_route_state"

local function ferryRoute(state, args, level)
    assert(args.n > 0, "Must call ferryRoute() with an argument")

    local arg1 = args[1]
    local ferryRoute = WG.transportFerry.getFerryRoute(arg1)

    assert(rawget(state, FERRY_ROUTE_STATE_KEY) == nil, "ferryRoute already set")
    rawset(state, FERRY_ROUTE_STATE_KEY, ferryRoute)

    return state
end

assert:register("modifier", "ferryRoute", ferryRoute)

local function zoneCount(state, arguments)
    local ferryRoute = rawget(state, FERRY_ROUTE_STATE_KEY)
    assert(ferryRoute ~= nil, "no ferryRoute set, cannot check ferry route zone count")

    local expectedZoneCount = arguments[1]

    local actualZoneCount = #ferryRoute.zones

    return expectedZoneCount == actualZoneCount
end

say:set("assertion.zoneCount.positive", "Expected ferryRoute has zoneCount:\n%s")
say:set("assertion.zoneCount.negative", "Expected ferryRoute does not have zoneCount:\n%s")
assert:register("assertion", "zoneCount", zoneCount, "assertion.zoneCount.positive", "assertion.zoneCount.negative")

local function serversReady(state, arguments)
    local ferryRoute = rawget(state, FERRY_ROUTE_STATE_KEY)
    assert(ferryRoute ~= nil, "no ferryRoute set, cannot check servers ready")

    local expectedServersReady = arguments[1]
    local actualServersReady = #ferryRoute.serversReady

    return expectedServersReady == actualServersReady
end

say:set("assertion.serversReady.positive", "Expected ferryRoute has serversReady:\n%s")
say:set("assertion.serversReady.negative", "Expected ferryRoute does not have serversReady:\n%s")
assert:register("assertion", "serversReady", serversReady, "assertion.serversReady.positive", "assertion.serversReady.negative")

local function heavyServersReady(state, arguments)
    local ferryRoute = rawget(state, FERRY_ROUTE_STATE_KEY)
    assert(ferryRoute ~= nil, "no ferryRoute set, cannot check heavy servers ready")

    if ferryRoute.heavyTransportCount == 0 then
        return false
    end

    local expectedHeavyServersReady = arguments[1]

    local actualHeavyServersRedy = 0
    for _,unitID in pairs(ferryRoute.serversReady) do
        local unitDefID = Spring.GetUnitDefID(unitID)
        local unitDef = UnitDefs[unitDefID]
        if unitDef.transportMass > 750 then
            actualHeavyServersRedy = actualHeavyServersRedy + 1
        end
    end

    return expectedHeavyServersReady == actualHeavyServersRedy
end

say:set("assertion.heavyServersReady.positive", "Expected ferryRoute has heavyServersReady:\n%s")
say:set("assertion.heavyServersReady.negative", "Expected ferryRoute does not have heavyServersReady:\n%s")
assert:register("assertion", "heavyServersReady", heavyServersReady, "assertion.heavyServersReady.positive", "assertion.heavyServersReady.negative")

local function serversBusy(state, arguments)
    local ferryRoute = rawget(state, FERRY_ROUTE_STATE_KEY)
    assert(ferryRoute ~= nil, "no ferryRoute set, cannot check servers busy")

    local expectedServersBusy = arguments[1]

    local actualServersBusy = 0
    for uID,_ in pairs(ferryRoute.serversBusy) do
        actualServersBusy = actualServersBusy + 1
    end

    return expectedServersBusy == actualServersBusy
end

say:set("assertion.serversBusy.positive", "Expected ferryRoute has serversBusy:\n%s")
say:set("assertion.serversBusy.negative", "Expected ferryRoute does not have serversBusy:\n%s")
assert:register("assertion", "serversBusy", serversBusy, "assertion.serversBusy.positive", "assertion.serversBusy.negative")

local function passengersWaiting(state, arguments)
    local ferryRoute = rawget(state, FERRY_ROUTE_STATE_KEY)
    assert(ferryRoute ~= nil, "no ferryRoute set, cannot check passengers waiting")

    local expectedPassengersWaiting = arguments[1]

    local actualPassengersWaiting = 0

    local fifo = ferryRoute.passengersWaiting
    local currNode = fifo.head
    while currNode do
        actualPassengersWaiting = actualPassengersWaiting + 1
        currNode = currNode.nextNode
    end

    if (expectedPassengersWaiting ~= nil) and (type(expectedPassengersWaiting) == "number") then
        return expectedPassengersWaiting == actualPassengersWaiting
    end

    return actualPassengersWaiting > 0
end

say:set("assertion.passengersWaiting.positive", "Expected ferryRoute has passengersWaiting:\n%s")
say:set("assertion.passengersWaiting.negative", "Expected ferryRoute does not have passengersWaiting:\n%s")
assert:register("assertion", "passengersWaiting", passengersWaiting, "assertion.passengersWaiting.positive", "assertion.passengersWaiting.negative")
