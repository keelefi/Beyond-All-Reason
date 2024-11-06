function widget:GetInfo()
	return {
		name = "Transport Ferry",
		desc = "Allow the creation of ferry routes for transports. Move transports and units to route entrance to assign them to the ferry route.",
		author = "CMDR*Zod",
		date = "2025",
		license = "GNU GPL, v2 or later",
		handler = true,
		layer = 0,
		enabled = true,
	}
end

VFS.Include("luarules/configs/customcmds.h.lua")

--[[
Feature ideas:
- Resizing existing zones
- Modifying ferry route with transport already in ferry route
- Front-queueing commands for transports and passengers
]]

local debugLevel = 2
local debugLevels = {
    showStats = 1,
    displayMessages = 2,
    showVogel = 3,
    max = 4,
}

local CMD_MOVE = CMD.MOVE
local CMD_STOP = CMD.STOP
local CMD_LOAD_UNITS = CMD.LOAD_UNITS
local CMD_UNLOAD_UNIT = CMD.UNLOAD_UNIT
local CMD_REMOVE = CMD.REMOVE

local CMD_OPT_ALT = CMD.OPT_ALT
local CMD_OPT_SHIFT = CMD.OPT_SHIFT

local ROUTING_MAX_DEPTH = 64

local circleSegments = 128
local circleThickness = 6
local glowRadiusCoefficient = -0.3
local arrowSize = 50
local arrowColor = { 0, 1, 0, 0.4 }

local updateDisplayList = true
local myDisplayList = nil

local departureAreaColors = { 1, 1, 0, 0.6 }
local departureAreaColorsGlow = { 1, 1, 0, 0.3 }
local departureAreaMouseOverColors = { 1, 1, 0, 0.8 }
local departureAreaMouseOverColorsGlow = { 1, 1, 0, 0.5 }
local destinationAreaColors = { 0, 0, 1, 0.6 }
local destinationAreaColorsGlow = { 0, 0, 1, 0.3 }

local ferryDepartureRadius = 100
local ferryDestinationMinimumRadius = 100
local transportAboveUnit = 50

local ferryCustomCommand = {
	id = CMD_SET_FERRY,
	type = CMDTYPE.ICON_AREA,
	name = "Set Ferry",
	action = "setferry",
	cursor = "cursorpickup", -- TODO: this doesn't work and we need different cursor anyway
	tooltip = "Set ferry routes for transports",
}

local printCommandQueueGameFrame = nil
local printCommandQueueUnitID = nil

local UPDATE_PERIOD = 2 / 30
local timeSinceLastUpdate = 0
local mouseOverDeparture = nil

local selectedUnits
local myTeam = Spring.GetLocalTeamID()

local isTransportDef = {}
local isLightTransportDef = {}
local isHeavyTransportDef = {}
local isLightLandUnitDef = {}
local isHeavyLandUnitDef = {}
for unitDefID, unitDef in pairs(UnitDefs) do
	if unitDef.isTransport and unitDef.canFly and unitDef.transportCapacity > 0 then
		isTransportDef[unitDefID] = true
        if unitDef.transportMass and unitDef.transportMass >= 750 then
            isHeavyTransportDef[unitDefID] = true
        else
            isLightTransportDef[unitDefID] = true
        end
    elseif not unitDef.cantBeTransported then
        if unitDef.mass >= 750  then
            isHeavyLandUnitDef[unitDefID] = true
        else
            isLightLandUnitDef[unitDefID] = true
        end
	end
end

local myTransports = {}
local myLightTransports = {}
local myHeavyTransports = {}

local myFerries = {}    -- map transport unitIDs to the ferryRoutes they belong to

local myPassengers = {}     -- map passenger unitIDs to the departures and transports they belong to

local factoryRallies = {}   -- map factory unitIDs to the departures they belong to

local ferryRouteInConstruction = nil    -- pointer to the ferryRoute under construction
local ferryRoutes = {
}

local function debugPrint(message)
    if debugLevel >= debugLevels.displayMessages then
        Spring.Echo(message)
    end
end

local function fifo_new()
    local result = {
        head = nil,
        tail = nil,
    }

    return result
end
local function fifo_push(list, id, value)
    local newNode = {
        nextNode = nil,
        id = id,
        value = value,
    }

    if not list.head then
        list.head = newNode
        list.tail = newNode
        return
    end

    list.tail.nextNode = newNode
    list.tail = newNode
end
local function fifo_pop(list)
    if not list.head then
        error("list is empty")
    end

    local result = list.head
    list.head = list.head.nextNode

    return result.id, result.value
end
local function fifo_remove(list, id)
    local prevNode = nil
    local currNode = list.head
    while currNode do
        if currNode.id == id then
            if not prevNode then
                -- we removed the first item
                list.head = currNode.nextNode
                return currNode.id, currNode.value
            else
                prevNode.nextNode = currNode.nextNode
            end

            if currNode == list.tail then
                -- we removed the last item
                list.tail = prevNode
            end

            return currNode.id, currNode.value
        end

        prevNode = currNode
        currNode = currNode.nextNode
    end

    return nil, nil
end
local function fifo_isEmpty(list)
    return not list.head
end

local function isHeavyTransport(unitDef)
    if unitDef.transportMass > 750 then
        return true
    end

    return false
end

local function serversBusyCount(ferryRoute)
    local actualServersBusy = 0
    for uID,_ in pairs(ferryRoute.serversBusy) do
        actualServersBusy = actualServersBusy + 1
    end
    return actualServersBusy
end

local function transportSelected()
    for _,unitID in ipairs(selectedUnits) do
        if myTransports[unitID] then
            return true
        end
    end

    return false
end

local function inCircle(x, z, circle)
    local distanceSquared = (x-circle.x)^2 + (z-circle.z)^2
    local radiusSquared = circle.radius^2

    return distanceSquared < radiusSquared
end

local function getFerryZone(x, z)
    for _,ferryRoute in ipairs(ferryRoutes) do
        for _,zone in ipairs(ferryRoute.zones) do
            if inCircle(x, z, zone) then
                return ferryRoute, zone
            end
        end
    end

    return nil, nil
end

local function checkOverlappingZone(x, z, radius)
    local function checkOverlapping(zone)
        local euclideanDistance = math.sqrt(math.pow(x-zone.x, 2) + math.pow(z-zone.z, 2))
        local radiiSum = radius + zone.radius
        return euclideanDistance < radiiSum
    end

    for _,ferryRoute in ipairs(ferryRoutes) do
        for _,zone in ipairs(ferryRoute.zones) do
            if checkOverlapping(zone) then
                return true
            end
        end
    end

    return false
end

local function findClosestTransport(x, z, ferryRoute, remove)
    debugPrint("findClosestTransport")

    local function getDistanceSquared(x, z, transportID)
        local transportX, _, transportZ = Spring.GetUnitPosition(transportID)
        return (x-transportX)^2 + (z-transportZ)^2
    end

    local closestRadiusSquared = -1
    local closestTransportID = -1
    local entryToRemove = -1

    for i,unitID in ipairs(ferryRoute.serversReady) do
        local currentRadiusSquared = getDistanceSquared(x, z, unitID)
        if (closestRadiusSquared == -1) or (currentRadiusSquared < closestRadiusSquared) then
            closestRadiusSquared = currentRadiusSquared
            closestTransportID = unitID
            entryToRemove = i
        end
    end

    if remove and (entryToRemove > -1) then
        table.remove(ferryRoute.serversReady, entryToRemove)
        debugPrint("Removed transport from ready: " .. closestTransportID)
    end

    return closestTransportID
end

local function findClosestDeparture(transportX, transportZ, ferryRoute)
    local function getDistanceSquared(departure)
        return (transportX-departure.x)^2 + (transportZ-departure.z)^2
    end

    local closestRadiusSquared = -1
    local closestDeparture = nil
    for _,zone in ipairs(ferryRoute.zones) do
        if zone ~= ferryRoute.destination then
            local departure = zone
            local currentRadiusSquared = getDistanceSquared(departure)

            if (not closestDeparture) or (currentRadiusSquared < closestRadiusSquared) then
                closestRadiusSquared = currentRadiusSquared
                closestDeparture = departure
            end
        end
    end

    if not closestDeparture then
        closestDeparture = ferryRoute.destination
    end

    return closestDeparture
end

local function getSelectedTransports()
    local selectedTransports = {}

    for _,unitID in ipairs(selectedUnits) do
        if myTransports[unitID] then
            selectedTransports[#selectedTransports+1] = unitID
        end
    end

    return selectedTransports
end

-- TODO: remove this?
local function checkServerIsReady(ferryRoute, unitID)
    for _,serverID in ipairs(ferryRoute.serversReady) do
        if serverID == unitID then
            return true
        end
    end

    return false
end

local function heavyTransportsIncludedCount(transportUnitIDs)
    local heavyTransportCount = 0
    for i = 1,#transportUnitIDs do
        local unitID = transportUnitIDs[i]
        if myHeavyTransports[unitID] then
            heavyTransportCount = heavyTransportCount + 1
        end
    end

    return heavyTransportCount
end

local function getLastMoveAverage(transportUnitIDs)
    local function getTransportLastMoveCommand(unitID)
        local unitCommandQueue = Spring.GetUnitCommands(unitID, -1)

        for i = #unitCommandQueue,1,-1 do
            if unitCommandQueue[i].id == CMD_MOVE then
                return unitCommandQueue[i].params[1], unitCommandQueue[i].params[3]
            end
        end

        -- unit has no move command in queue, use current position instead
        local unitBasePointX, _, unitBasePointZ = Spring.GetUnitPosition(unitID)
        return unitBasePointX, unitBasePointZ
    end

    local x = 0
    local z = 0
    local count = 0

    --for unitID,_ in pairs(transportUnitIDs) do
    for i = 1,#transportUnitIDs do
        local unitID = transportUnitIDs[i]
        local lastMoveX, lastMoveZ = getTransportLastMoveCommand(unitID)

        count = count + 1
        x = (x * (count - 1) + lastMoveX) / count
        z = (z * (count - 1) + lastMoveZ) / count
    end

    debugPrint("getLastMoveAverage(): [x: " .. tostring(x) .. ", z: " .. tostring(z) .. "]")

    return x, z
end

-- discover zones from the point of view of the new zone
local function routingTableDiscoverZones(newZone)
    local function recursePreviousZones(direction, currentZone, depth)
        local newDepth = depth + 1
        if newDepth > ROUTING_MAX_DEPTH then
            -- TODO: kill widget
            return
        end

        newZone.routingTable[currentZone] = direction

        for _,previousZone in ipairs(currentZone.previousZones) do
            recursePreviousZones(direction, previousZone, newDepth)
        end
    end

    if newZone.nextZone then
        local direction = newZone.nextZone
        local currentZone = direction
        local depth = 0
        while currentZone do
            newZone.routingTable[currentZone] = direction

            for _,previousZone in ipairs(currentZone.previousZones) do
                if (previousZone ~= newZone) and (not newZone.routingTable[previousZone]) then
                    recursePreviousZones(direction, previousZone, 0)
                end
            end

            currentZone = currentZone.nextZone

            depth = depth + 1
            if depth > ROUTING_MAX_DEPTH then
                -- TODO: kill widget
                return
            end
        end
    end

    for _,previousZone in ipairs(newZone.previousZones) do
        recursePreviousZones(previousZone, previousZone, 0)
    end
end

local function routingTableAddNewEntry(newEntry, directionZone, currentZone, depth)
    local newDepth = depth + 1
    if newDepth > ROUTING_MAX_DEPTH then
        -- we might have a loop, bail out
        -- TODO: kill widget
        return
    end

    currentZone.routingTable[newEntry] = directionZone

    for _,previousZone in ipairs(currentZone.previousZones) do
        if previousZone ~= directionZone then
            routingTableAddNewEntry(newEntry, currentZone, previousZone, newDepth)
        end
    end

    if currentZone.nextZone and (currentZone.nextZone ~= directionZone) then
        routingTableAddNewEntry(newEntry, currentZone, currentZone.nextZone, newDepth)
    end
end

local function addZone(ferryRoute, x, z, radius, afterZones, beforeZone)
    local previousZones
    if afterZones then
        if afterZones.x then
            -- it was a single zone
            previousZones = { afterZones }
        else
            -- it's already a table
            previousZones = afterZones
        end
    else
        previousZones = {}
    end

    local newZone = {
        x = x,
        y = Spring.GetGroundHeight(x, z),
        z = z,
        radius = radius,

        previousZones = previousZones,
        nextZone = beforeZone,   -- note: this might be nil and that is fine
        routingTable = {},

        ferryRoute = ferryRoute,
    }

    if beforeZone then
        table.insert(beforeZone.previousZones, newZone)

        routingTableAddNewEntry(newZone, newZone, beforeZone, 0)
    end

    for _,afterZone in ipairs(previousZones) do
        -- TODO: check if nextZone was already set. if yes, what then?

        afterZone.nextZone = newZone

        routingTableAddNewEntry(newZone, newZone, afterZone, 0)
    end

    -- TODO: remove this variable, it is used only for debugging
    newZone.id = #ferryRoute.zones

    routingTableDiscoverZones(newZone)

    table.insert(ferryRoute.zones, newZone)

    debugPrint("Added zone: [id: " .. tostring(newZone.id) .. ", x: " .. tostring(newZone.x) .. ", z: " .. tostring(newZone.z) .. ", radius: " .. tostring(newZone.radius) .. "]")

    return newZone
end

local vogelModelCoefficient = 2.399963 -- Golden angle
local vogelModelScale = 50
local function initVogel(radius)
    local locations = math.floor(math.pow(radius / vogelModelScale, 2))

    debugPrint("Initialized vogel, amount of locations: " .. tostring(locations))

    return {
        n = locations,
        i = 0,
        maxAttempts = math.min(locations / 10, 10)
    }
end

local function findNextDropVogel(destination)
    local n = destination.state.n
    local i = destination.state.i
    debugPrint("i = " .. tostring(i))

    local dropPosFound = false
    local attempts = 0

    local x, y, z
    while (not dropPosFound) and (attempts < destination.state.maxAttempts) do
        if i >= n then
            i = 0 -- start from the beginning
        end

        local theta = i * vogelModelCoefficient
        local radius = vogelModelScale * math.sqrt(i)

        x = radius * math.cos(theta) + destination.x
        z = radius * math.sin(theta) + destination.z

        y = Spring.GetGroundHeight(x, z)

        i = i + 1

        -- TODO: test if transport can land in designated area
        dropPosFound = true

        attempts = attempts + 1
    end

    destination.state.i = i

    debugPrint("Next drop: " .. tostring(x) .. ", " .. tostring(z))

    return x, y, z
end

local function transportPickupPassenger(transportUnitID, passengerUnitID, ferryRoute, departure)
    debugPrint("transportPickupPassenger, id: " .. transportUnitID)

    -- cancel everything else transport was doing
    Spring.GiveOrderToUnit(transportUnitID, CMD_STOP, 0, 0)

    local passengerX, passengerY, passengerZ = Spring.GetUnitPosition(passengerUnitID)
    local transportX, _, transportZ = Spring.GetUnitPosition(transportUnitID)
    if not inCircle(transportX, transportZ, departure) then
        -- move transport to departure
        local currentDeparture = findClosestDeparture(transportX, transportZ, ferryRoute)

        local depth = 0
        while currentDeparture ~= departure do
            Spring.GiveOrderToUnit(transportUnitID, CMD_MOVE, { currentDeparture.x, currentDeparture.y + transportAboveUnit, currentDeparture.z }, CMD_OPT_SHIFT)

            currentDeparture = currentDeparture.routingTable[departure]

            depth = depth + 1
            if depth > ROUTING_MAX_DEPTH then
                -- TODO: kill widget
                return
            end
        end
    end

    -- transport is already at departure, just pick up the passenger
    Spring.GiveOrderToUnit(transportUnitID, CMD_MOVE, { passengerX, passengerY + transportAboveUnit, passengerZ }, CMD_OPT_SHIFT)
    Spring.GiveOrderToUnit(transportUnitID, CMD_LOAD_UNITS, { passengerUnitID }, CMD_OPT_SHIFT)

    --table.insert(ferryRoute.serversBusy, { transportUnitID, passengerUnitID, departure })
    ferryRoute.serversBusy[transportUnitID] = { passengerUnitID, departure }
    myPassengers[passengerUnitID][2] = transportUnitID
end

local function transportDropPassenger(transportUnitID, departure, destination, passengerUnitID)
    local dropLocation = table.pack(findNextDropVogel(destination))

    if departure then
        local currentZone = departure.routingTable[destination]
        local depth = 0
        while currentZone ~= destination do
            local x = currentZone.x
            local y = currentZone.y
            local z = currentZone.z

            debugPrint("Transport move order (drop): id - " .. tostring(transportUnitID) .. " [x: " .. tostring(x) .. ", z: " .. tostring(z) .. "]")

            Spring.GiveOrderToUnit(transportUnitID, CMD_MOVE, {x, y + transportAboveUnit, z}, CMD_OPT_SHIFT)

            currentZone = currentZone.routingTable[destination]

            depth = depth + 1
            if depth > ROUTING_MAX_DEPTH then
                -- TODO: kill widget
                return
            end
        end
    end

    Spring.GiveOrderToUnit(transportUnitID, CMD_MOVE, dropLocation, CMD_OPT_SHIFT)
    Spring.GiveOrderToUnit(transportUnitID, CMD_UNLOAD_UNIT, dropLocation, CMD_OPT_SHIFT)
end

local function transportReturnToDeparture(transportUnitID, departure, destination)
    local currentZone = destination
    local depth = 0
    while currentZone ~= departure do
        currentZone = currentZone.routingTable[departure]

        local x = currentZone.x
        local y = currentZone.y
        local z = currentZone.z

        debugPrint("Transport move order (return): id - " .. tostring(transportUnitID) .. " [x: " .. tostring(x) .. ", z: " .. tostring(z) .. "]")

        Spring.GiveOrderToUnit(transportUnitID, CMD_MOVE, {x, y + transportAboveUnit, z}, CMD_OPT_SHIFT)

        depth = depth + 1
        if depth > ROUTING_MAX_DEPTH then
            -- TODO: kill widget
            return
        end
    end
end

local function passengerEligibleForFerryRoute(ferryRoute, unitDefID)
    return isLightLandUnitDef[unitDefID] or (isHeavyLandUnitDef[unitDefID] and (ferryRoute.heavyTransportCount > 0))
end

local function createFerryRoute(x, z, radius, shift, createDestination)
    debugPrint("createFerryRoute()")

    -- TODO: do we need to remove transports from their earlier routes?

    -- TODO: do we need to check if a route has no transport and should be removed?

    -- set ferry departure where last move command for transport or where transport is now
    local selectedTransports = getSelectedTransports()
    local departureX, departureZ = getLastMoveAverage(selectedTransports)

    local heavyTransportsSelectedCount = heavyTransportsIncludedCount(selectedTransports)

    ferryRoutes[#ferryRoutes+1] = {
        zones = {},
        destination = nil,

        serversReady = {},
        serversBusy = {},

        passengersWaiting = fifo_new(),

        heavyTransportCount = heavyTransportsSelectedCount,

        routeFinished = not shift,
    }
    local newFerryRoute = ferryRoutes[#ferryRoutes]

    local departure = addZone(newFerryRoute, departureX, departureZ, ferryDepartureRadius, nil, nil)

    if createDestination then
        local destination = addZone(newFerryRoute, x, z, radius, departure, nil)
        newFerryRoute.destination = destination
    else
        newFerryRoute.destination = departure
    end

    if not shift and createDestination then
        newFerryRoute.destination.state = initVogel(radius)
    else
        ferryRouteInConstruction = newFerryRoute
    end

    for _,unitID in ipairs(selectedTransports) do
        addTransportToFerryRoute(newFerryRoute, departure, unitID, true)
    end

    -- TODO: check if shift was used. If not, have transport move to departure.

    -- TODO: have units in departure area become passengers

    -- TODO: have units with move order to departure area become passengers

    debugPrint("New route")

    return newFerryRoute
end

local function modifyFerryRoute(ferryRoute, x, z, radius)
    -- TODO: make sure areas don't overlap

    local oldDestination = ferryRoute.destination
    local newZone = addZone(ferryRoute, x, z, radius, oldDestination, nil)
    ferryRoute.destination = newZone
end

local function finishFerryRoute()
    local radius = ferryRouteInConstruction.destination.radius
    ferryRouteInConstruction.destination.state = initVogel(radius)

    for transportUnitID,data in pairs(ferryRouteInConstruction.serversBusy) do
        local passengerUnitID, departure = unpack(data)
        transportDropPassenger(transportUnitID, departure, ferryRouteInConstruction.destination, passengerUnitID)
    end

    ferryRouteInConstruction.routeFinished = true

    ferryRouteInConstruction = nil

    updateDisplayList = true

    debugPrint("Finished building ferry route")
end

local function destroyFerryRoute(ferryRoute)
    -- TODO: remove references to ferry route

    table.removeFirst(ferryRoutes, ferryRoute)

    updateDisplayList = true
end

local function joinFerryRoute(ferryRouteOld, ferryRouteNew, departureJoin)
    local function addPreviousZones(currentZone, zoneToCopy, depth)
        local newDepth = depth + 1
        if newDepth > ROUTING_MAX_DEPTH then
            -- TODO: crash widget
            return
        end

        for _,previousZone in ipairs(zoneToCopy.previousZones) do
            local newZone = addZone(ferryRouteOld, previousZone.x, previousZone.z, previousZone.radius, nil, currentZone)

            addPreviousZones(newZone, previousZone, newDepth)
        end
    end

    local currentZone = ferryRouteNew.destination
    local newZone = addZone(ferryRouteOld, currentZone.x, currentZone.z, currentZone.radius, nil, departureJoin)
    addPreviousZones(newZone, currentZone, 0)

    --for _,serverReady in ipairs(ferryRouteNew.serversReady) do
    --    table.insert(ferryRouteOld.serversReady, serverReady)
    --end
    for _,serverReady in ipairs(ferryRouteNew.serversReady) do
        --removeTransportFromFerryRoute(ferryRouteNew, serverReady)
        addTransportToFerryRoute(ferryRouteOld, nil, serverReady, false)
    end
    -- TODO: move busy servers to new ferry route
    -- TODO: move passengers to new ferry route

    destroyFerryRoute(ferryRouteNew)
end

function addTransportToFerryRoute(ferryRoute, departure, unitID, removeFromOld)
    debugPrint("addTransportToFerryRoute: unitID " .. tostring(unitID))

    if myFerries[unitID] then
        if myFerries[unitID] == ferryRoute then
            debugPrint("Adding transport " .. tostring(unitID) .. " failed: Transport was already added to the route")
            return false
        end

        if removeFromOld then
            removeTransportFromFerryRoute(myFerries[unitID], unitID)
        end
    end

    local transporteeArray = Spring.GetUnitIsTransporting(unitID)
    if not transporteeArray then
        -- it wasn't a transport? this should never happen
        return false
    end

    if #transporteeArray >= 1 then
        -- transport has cargo. drop cargo first
        local passengerUnitID = transporteeArray[1]
        ferryRoute.serversBusy[unitID] = { passengerUnitID, departure }

        if routeFinished then
            transportDropPassenger(unitID, departure, ferryRoute.destination, passengerUnitID)
        end
    else
        -- transport is empty, ready to serve immediately
        table.insert(ferryRoute.serversReady, unitID)
        local transportX, _, transportZ = Spring.GetUnitPosition(unitID)
        local departure = findClosestDeparture(transportX, transportZ, ferryRoute)
        -- TODO: figure out if the move command to departure is already queued (overlapping move command is a cancel)
        --Spring.GiveOrderToUnit(unitID, CMD_MOVE, { departure.x, departure.y, departure.z }, CMD_OPT_SHIFT)
    end

    if myHeavyTransports[unitID] then
        ferryRoute.heavyTransportCount = ferryRoute.heavyTransportCount + 1
    end

    debugPrint("Transport " .. tostring(unitID) .. " added to route")

    myFerries[unitID] = ferryRoute

    return true
end

function removeTransportFromFerryRoute(ferryRoute, unitID)
    local checkServersBusy = true

    -- TODO: use table.removeFirst()
    for serverIndex,serverID in ipairs(ferryRoute.serversReady) do
        if serverID == unitID then
            table.remove(ferryRoute.serversReady, serverIndex)

            debugPrint("Ready transport " .. tostring(unitID) .. " removed from route")

            checkServersBusy = false
            break
        end
    end

    if checkServersBusy then
        local passengerTable = ferryRoute.serversBusy[unitID]
        if passengerTable then
            ferryRoute.serversBusy[unitID] = nil
            if #ferryRoute.serversReady > 0 then
                local passengerUnitID = passengerTable[1]
                local departure = passengerTable[2]
                local unitX, _, unitZ = Spring.GetUnitPosition(passengerUnitID)
                local newTransportID = findClosestTransport(unitX, unitZ, ferryRoute, true)
                transportPickupPassenger(newTransportID, passengerUnitID, ferryRoute, departure)
            end
        end
    end

    --if checkServersBusy then
    --    for serverIndex,serverBusy in ipairs(ferryRoute.serversBusy) do
    --        local serverUnitID = serverBusy[1]
    --        local passengerUnitID = serverBusy[2]
    --        if serverUnitID == unitID then
    --            local unitX, _, unitZ = Spring.GetUnitPosition(passengerUnitID)
    --            for _,departure in ipairs(ferryRoute.departures) do
    --                if inCircle(passengerX, passengerZ, departure) then
    --                    table.insert(ferryRoute.passengersWaiting, passengerID)
    --                    break
    --                end
    --            end

    --            table.remove(ferryRoute.serversBusy, serverIndex)

    --            debugPrint("Busy transport " .. tostring(unitID) .. " removed from route")

    --            break
    --        end
    --    end
    --end

    if myHeavyTransports[unitID] then
        ferryRoute.heavyTransportCount = ferryRoute.heavyTransportCount - 1
    end

    myFerries[unitID] = nil

    if (#ferryRoute.serversReady == 0) and (serversBusyCount(ferryRoute) == 0) then
        destroyFerryRoute(ferryRoute)
    end
end

local function passengerMoveToDeparture(unitID, departure)
    Spring.GiveOrderToUnit(unitID, CMD_MOVE, { departure.x, departure.y, departure.z }, 0)
end

local function addPassengerToDeparture(departure, unitID)
    debugPrint("addPassengerToDeparture: unitID " .. tostring(unitID))

    local myPassenger = myPassengers[unitID]
    if myPassenger then
        local oldDeparture = myPassenger[1]
        if oldDeparture == departure then
            return false
        else
            removePassengerFromFerryRoute(unitID)
        end
    end

    local ferryRoute = departure.ferryRoute

    myPassengers[unitID] = { departure, nil }

    debugPrint("addPassengerToDeparture: myPassenger: " .. tostring(myPassengers[unitID]))

    -- check if passenger is stationary
    local passengerCommandQueue = Spring.GetCommandQueue(unitID, 0)
    if not passengerCommandQueue then
        local unitX, _, unitZ = Spring.GetUnitPosition(unitID)
        if inCircle(unitX, unitZ, departure) then
            --table.insert(ferryRoute.passengersWaiting, { unitID, departure })
            fifo_push(ferryRoute.passengersWaiting, unitID, departure)
            return true
        end

        passengerMoveToDeparture(unitID, departure)
    end

    return true
end

function removePassengerFromFerryRoute(passengerUnitID)
    debugPrint("removePassengerFromFerryRoute: passengerUnitID: " .. tostring(passengerUnitID))

    local myPassenger = myPassengers[passengerUnitID]
    if myPassenger then
        local transportUnitID = myPassenger[2]
        if transportUnitID then
            -- transport was about to pick up passenger. make the transport ready to serve another passenger instead.

            Spring.GiveOrderToUnit(transportUnitID, CMD_REMOVE, CMD_LOAD_UNITS, CMD_OPT_ALT)

            local ferryRoute = myFerries[transportUnitID]

            if ferryRoute then
                ferryRoute.serversBusy[transportUnitID] = nil
                table.insert(ferryRoute.serversReady, transportUnitID)
            end
        end

        local departure = myPassenger[1]
        if departure then
            local ferryRoute = departure.ferryRoute
            debugPrint("Removing passenger from waiting: " .. tostring(passengerUnitID))
            fifo_remove(ferryRoute.passengersWaiting, passengerUnitID)
            --for i,passengerWaiting in ipairs(ferryRoute.passengersWaiting) do
            --    local unitID = passengerWaiting[1]
            --    if unitID == passengerUnitID then
            --        table.remove(ferryRoute.passengersWaiting, i)
            --        Spring.Echo("remove passengersWaiting line 821")
            --        break
            --    end
            --end
        end
    end

    myPassengers[passengerUnitID] = nil

    -- TODO: use table.removeFirst()
    --local departurePassengersArriving = departure.passengersArriving
    --for i,unitID in ipairs(departurePassengersArriving) do
    --    if unitID == unitIDToRemove then
    --        table.remove(departurePassengerArriving, i)
    --        debugPrint("Arriving passenger " .. tostring(unitIDToRemove) .. " removed from departure")
    --        return true
    --    end
    --end

    --local departurePassengersWaiting = departure.passengersWaiting
    --for i,unitID in pairs(departurePassengersWaiting) do
    --    if unitID == passengerUnitID then
    --        table.remove(departurePassengersWaiting, i)
    --        debugPrint("Waiting passenger " .. tostring(unitIDToRemove) .. " removed from departure")
    --        return true
    --    end
    --end

    --debugPrint("Attempted to remove unknown passenger " .. tostring(unitIDToRemove) .. " from departure")

    --return false
end

local function addFactoryRallyToDeparture(departure, unitID)
    if factoryRallies[unitID] then
        if factoryRallies[unitID] == departure then
            debugPrint("Adding factory rally " .. tostring(unitID) .. " failed: Factory rally was already added to the departure")
            return false
        end

        removeFactoryRallyFromDeparture(factoryRallies[unitID], unitID)
    end

    table.insert(departure.factoryRallies, unitID)
    factoryRallies[unitID] = departure

    debugPrint("Factory rally " .. tostring(unitID) .. " added to departure")

    return true
end

function removeFactoryRallyFromDeparture(departure, unitID)
    for i,factoryID in ipairs(departure.factoryRallies) do
        if factoryID == unitID then
            table.remove(departure.factoryRallies, i)
            debugPrint("Factory rally " .. tostring(unitID) .. " removed from departure")
            break
        end
    end

    factoryRallies[unitID] = nil
end

--local function printCommand(unitID, cmdId, cmdParams, cmdOpts, cmdTag)
--    if cmdId == CMD_MOVE then
--        Spring.Echo("UnitCommand MOVE: unitID " .. tostring(unitID) .. ", x: " .. tostring(cmdParams[1]) .. ", y: " .. tostring(cmdParams[2]) .. ", z: " .. tostring(cmdParams[3]) .. ", shift: " .. tostring(cmdOpts.shift))
--    elseif cmdId == CMD_LOAD_UNITS then
--        Spring.Echo("UnitCommand LOAD: unitID " .. tostring(unitID) .. ", passenger: " .. tostring(cmdOpts[1]) .. ", shift: " .. tostring(cmdOpts.shift))
--    elseif cmdId == CMD_UNLOAD_UNIT then
--        Spring.Echo("UnitCommand UNLOAD: unitID " .. tostring(unitID) .. ", x: " .. tostring(cmdParams[1]) .. ", y: " .. tostring(cmdParams[2]) .. ", z: " .. tostring(cmdParams[3]) .. ", shift: " .. tostring(cmdOpts.shift))
--    else
--        Spring.Echo("UnitCommand unknown: unitID " .. tostring(unitID))
--    end
--end

--function widget:UnitCommand(unitID, unitDefID, unitTeam, cmdId, cmdParams, cmdOpts, cmdTag)
--    if not myTransports[unitID] then return end
--
--    printCommand(unitID, cmdId, cmdParams, cmdOpts, cmdTag)
--end

local function printRoutingTables(ferryRoute)
    debugPrint("Printing routing tables for " .. tostring(#ferryRoute.zones) .. " zones")
    for _,zone in ipairs(ferryRoute.zones) do
        debugPrint("Zone " .. tostring(zone.id) .. " routingTable:")
        for k,v in pairs(zone.routingTable) do
            debugPrint("    " .. tostring(k.id) .. ": " .. tostring(v.id))
        end
    end
    debugPrint("Printing done")
end

function widget:CommandNotify(id, params, options)
	selectedUnits = Spring.GetSelectedUnits()
    if id == CMD_SET_FERRY then
        debugPrint("CMD_SET_FERRY, shift: " .. tostring(options.shift))
        -- set ferry point destination where we clicked
	    local cmdX, _, cmdZ, cmdRadius = params[1], params[2], params[3], params[4]
        cmdRadius = math.max(cmdRadius, ferryDestinationMinimumRadius)

        local ferryRoute, zone = getFerryZone(cmdX, cmdZ)
        if not ferryRoute then
            if checkOverlappingZone(cmdX, cmdZ, cmdRadius) then
                -- TODO: error, can't make overlapping zones

                return
            end

            if ferryRouteInConstruction then
                modifyFerryRoute(ferryRouteInConstruction, cmdX, cmdZ, cmdRadius)

                if not options.shift then
                    finishFerryRoute()
                end
            else
                createFerryRoute(cmdX, cmdZ, cmdRadius, options.shift, true)
            end
        else
            local ferryRouteNew = ferryRouteInConstruction
            if not ferryRouteNew then
                ferryRouteNew = createFerryRoute(cmdX, cmdZ, cmdRadius, false, false)
            end
            joinFerryRoute(ferryRoute, ferryRouteNew, zone)
            ferryRouteInConstruction = nil
            printRoutingTables(ferryRoute)
        end

        updateDisplayList = true

        if ferryRouteInConstruction then
            printRoutingTables(ferryRouteInConstruction)
        end
    elseif id == CMD_MOVE then
        for _,unitID in ipairs(selectedUnits) do
            -- if move order is to ferry departure point
	        local cmdX, _, cmdZ = params[1], params[2], params[3]
            local ferryRoute, zone = getFerryZone(cmdX, cmdZ)
            if ferryRoute and (zone ~= ferryRoute.destination) then
                local departure = zone
                --local ferryRoute = ferryRoutes[ferryRouteIndex]
                local unitDefID = Spring.GetUnitDefID(unitID)
                local unitDef = UnitDefs[unitDefID]
                -- if land units
                if passengerEligibleForFerryRoute(ferryRoute, unitDefID) then
                    -- units are assigned to be picked up
                    addPassengerToDeparture(departure, unitID)
                -- if transport
                elseif myTransports[unitID] then
                    -- add transport to ferry route
                    addTransportToFerryRoute(ferryRoute, departure, unitID, true)
                -- if land factory
                elseif unitDef.isFactory then   -- TODO: check if factory produces land units
                    addFactoryRallyToDeparture(departure, unitID)
                end
            else -- not a ferry departure
                if myPassengers[unitID] then
                    --local departure = myPassengers[unitID][1]
                    --local ferryRoute = departure.ferryRoute
                    removePassengerFromFerryRoute(unitID)
                elseif myFerries[unitID] then
                    local ferryRoute = myFerries[unitID]
                    removeTransportFromFerryRoute(ferryRoute, unitID)
                elseif factoryRallies[unitID] then
                    local departure = factoryRallies[unitID]
                    removeFactoryRallyFromDeparture(departure, unitID)
                end
            end
        end
    end

    return false
end

function widget:KeyRelease(key)
    if not ferryRouteInConstruction then return end

    local keyShift = 0x130
    if key == keyShift then
        finishFerryRoute()
    end
end

function widget:UnitFromFactory(unitID, unitDefID, unitTeam, factID, factDefID, userOrders)
    if not factoryRallies[factID] then return end

    local departure = factoryRallies[factID]
    if passengerEligibleForFerryRoute(departure.ferryRoute, unitDefID) then
        addPassengerToDeparture(departure, unitID)
    end
end

function widget:Update(dt)
    timeSinceLastUpdate = timeSinceLastUpdate + dt
	if timeSinceLastUpdate < UPDATE_PERIOD then
		return
	end
	timeSinceLastUpdate = 0

    local oldMouseOverDeparture = mouseOverDeparture
    mouseOverDeparture = nil

    local mx, my = Spring.GetMouseState()

    local pos = select(2, Spring.TraceScreenRay(mx, my, true))

    if pos then
        local ferryRoute, zone = getFerryZone(pos[1], pos[3])

        if ferryRoute and (zone ~= ferryRoute.destination) then
            mouseOverDeparture = zone
        end
    end

    if oldMouseOverDeparture ~= mouseOverDeparture then
        debugPrint("mouseOverDeparture changed")
        updateDisplayList = true
    end
end

function widget:GameFrame(frameNum)
    --if printCommandQueueGameFrame and printCommandQueueGameFrame == frameNum then
    --    local cmdQueue = Spring.GetCommandQueue(printCommandQueueUnitID, -1) or {}
    --    if #cmdQueue > 0 then
    --        for _,cmdInQueue in ipairs(cmdQueue) do
    --            printCommand(printCommandQueueUnitID, cmdInQueue.id, cmdInQueue.params, cmdInQueue.options, cmdInQueue.tag)
    --        end
    --    end

    --    printCommandQueueGameFrame = nil
    --    printCommandQueueUnitID = nil
    --end

    --local checkGotReady = frameNum % 30 == 14

    for _,ferryRoute in ipairs(ferryRoutes) do
        while (#ferryRoute.serversReady > 0) and (not fifo_isEmpty(ferryRoute.passengersWaiting)) do
            local passengerUnitID, departure = fifo_pop(ferryRoute.passengersWaiting)
            local unitX, unitY, unitZ = Spring.GetUnitPosition(passengerUnitID)
            local transportUnitID = findClosestTransport(unitX, unitZ, ferryRoute, true)
            ferryRoute.serversBusy[transportUnitID] = { passengerUnitID, departure }
            transportPickupPassenger(transportUnitID, passengerUnitID, ferryRoute, departure)
        end
    end
end

function widget:UnitCmdDone(unitID, unitDefID, unitTeam, cmdID, cmdParams, options, cmdTag)
    debugPrint("UnitCmdDone, unitID: " .. tostring(unitID))

    -- make sure it was a move command that ended
    if cmdID ~= CMD_MOVE then return end

    -- make sure unit stopped
    local unitCommandQueueLength = Spring.GetUnitCommands(unitID, 0)
    if unitCommandQueueLength ~= 0 then return end

    -- make sure it's our passenger
    local myPassenger = myPassengers[unitID]
    debugPrint("UnitCmdDone: myPassenger: " .. tostring(myPassenger))
    if not myPassenger then return end

    local departure = myPassenger[1]
    local transportUnitID = myPassenger[2]
    if transportUnitID then
        -- transport was already on their way to pickup passenger
        debugPrint("UnitCmdDone: transport already on their way to pickup passenger")
        return
    end

    -- make sure passenger is at departure
    local unitX, unitY, unitZ = Spring.GetUnitPosition(unitID)
    if not inCircle(unitX, unitZ, departure) then
        debugPrint("UnitCmdDone: passenger not at departure")
        passengerMoveToDeparture(unitID, departure)
        return
    end

    local ferryRoute = departure.ferryRoute
    if #ferryRoute.serversReady > 0 then
        local transportID = findClosestTransport(unitX, unitZ, ferryRoute, true)
        transportPickupPassenger(transportID, unitID, ferryRoute, departure)
        --myPassenger[2] = transportID
    else
        --table.insert(ferryRoute.passengersWaiting, { unitID, departure })
        fifo_push(ferryRoute.passengersWaiting, unitID, departure)
    end
end

function widget:UnitLoaded(unitID, unitDefID, unitTeam, transportID, transportTeam)
    debugPrint("UnitLoaded")

    if transportTeam ~= myTeam then return end

    local ferryRoute = myFerries[transportID]
    if not ferryRoute then return end

    local myPassenger = myPassengers[unitID]
    if not myPassenger then return end
    local departure = myPassenger[1]

    local destination = ferryRoute.destination

    transportDropPassenger(transportID, departure, destination, unitID)
end

function widget:UnitUnloaded(unitID, unitDefID, unitTeam, transportID, transportTeam)
    debugPrint("UnitUnloaded")

    if transportTeam ~= myTeam then return end

    if myPassengers[unitID] then
        myPassengers[unitID] = nil
    end

    local ferryRoute = myFerries[transportID]
    if not ferryRoute then return end

    local transporteeArray = Spring.GetUnitIsTransporting(transportID)
    if transporteeArray and (#transporteeArray > 0) then
        -- transport is not empty
        transportDropPassenger(transportID, nil, ferryRoute.destination, transporteeArray[1])
    else
        --local _, _, departure = table.removeFirst(ferryRoute.serversBusy, i)
        if fifo_isEmpty(ferryRoute.passengersWaiting) then
            local departure = ferryRoute.serversBusy[transportID][2]
            ferryRoute.serversBusy[transportID] = nil
            table.insert(ferryRoute.serversReady, transportID)

            transportReturnToDeparture(transportID, departure, ferryRoute.destination)
        else
            local passengerUnitID, departure = fifo_pop(ferryRoute.passengersWaiting)
            local unitX, unitY, unitZ = Spring.GetUnitPosition(passengerUnitID)
            ferryRoute.serversBusy[transportID] = { passengerUnitID, departure }
            transportPickupPassenger(transportID, passengerUnitID, ferryRoute, departure)
        end
    end
end

function widget:MetaUnitAdded(unitID, unitDefID, unitTeam)
    debugPrint("MetaUnitAdded, unitID: " .. tostring(unitID))

    if unitTeam == myTeam then
        if isTransportDef[unitDefID] then
            myTransports[unitID] = true
            local unitDef = UnitDefs[unitDefID]
            if isHeavyTransport(unitDef) then
                debugPrint("heavy transport added")
                myHeavyTransports[unitID] = true
            else
                debugPrint("light transport added")
                myLightTransports[unitID] = true
            end
        end
    end
end

function widget:MetaUnitRemoved(unitID, unitDefID, unitTeam)
    debugPrint("MetaUnitRemoved, unitID: " .. tostring(unitID))

    if unitTeam == myTeam then
        if myTransports[unitID] then
            myTransports[unitID] = nil
            myLightTransports[unitID] = nil
            myHeavyTransports[unitID] = nil

            local ferryRoute = myFerries[unitID]

            -- does transport belong to a route?
            if ferryRoute then
                removeTransportFromFerryRoute(ferryRoute, unitID)
            end
        else
            local myPassenger = myPassengers[unitID]

            if myPassenger then
                removePassengerFromFerryRoute(unitID)
            end
        end
    end
end

-- TODO: why would this be needed?
--function widget:SelectionChanged(sel)
--	selectedUnits = sel
--end

function widget:CommandsChanged()
	selectedUnits = Spring.GetSelectedUnits()
	if #selectedUnits > 0 and transportSelected() then
		local customCommands = widgetHandler.customCommands

		customCommands[#customCommands + 1] = ferryCustomCommand
	end
end

local function toggleDebug()
    debugLevel = debugLevel + 1

    if debugLevel >= debugLevels.max then
        debugLevel = 0
    end

    Spring.Echo("[Transport Ferry] Debug level set to: " .. tostring(debugLevel))

    updateDisplayList = true
end

local function removeAllFerryRoutes()
    for _,ferryRoute in ipairs(ferryRoutes) do
        destroyFerryRoute(ferryRoute)
    end
end

local function getFerryRouteImplementation(arg)
    if type(arg) == "number" then
        local index = arg
        if (index < 1) or  (index > #ferryRoutes) then
            return nil
        end
        return  ferryRoutes[index]
    elseif type(arg) == "table" then
        local ferryRoute, zone = getFerryZone(position[1], position[3])
        return ferryRoute
    end

    return nil
end

function widget:Initialize()
    widgetHandler.actionHandler:AddAction(self, "transport_ferry_debug_toggle", toggleDebug, nil, "p")

	for _, unitID in ipairs(Spring.GetTeamUnits(myTeam)) do
		widget:MetaUnitAdded(unitID, Spring.GetUnitDefID(unitID), myTeam)
	end

    WG["transportFerry"] = {
        getFerryRoute = function (arg)
            return getFerryRouteImplementation(arg)
        end,
    }
end

function widget:Shutdown()
    removeAllFerryRoutes()

    WG.transportFerry = {}
end

-- copied from map_start_position_suggestions
-- TODO: move to includable source code file ?
-- Note: small modifications have been made
local function drawArrow(departure, destination, size, color)
    local a = { departure.x, departure.y, departure.z }
    local b = { destination.x, destination.y, destination.z }

	local dir = { b[1] - a[1], b[2] - a[2], b[3] - a[3] }
	local length = math.sqrt(dir[1] ^ 2 + dir[2] ^ 2 + dir[3] ^ 2)

	local dirN = { dir[1] / length, dir[2] / length, dir[3] / length }

	local horizontalAngle = math.atan2(dirN[1], dirN[3])
	local verticalAngle = -math.asin(dirN[2])

	size = size or 0.1 * length
	local headL = size
	local headW = size / 2

	local pL = { -headW, 0, length - headL }
	local pR = { headW, 0, length - headL }

	local shaftWidth = headW / 6

	local function drawShaft()
        gl.Color(color)

		gl.Vertex(-shaftWidth, 0, 0)
		gl.Vertex(shaftWidth, 0, 0)

		gl.Vertex(shaftWidth, 0, length - headL)
		gl.Vertex(-shaftWidth, 0, length - headL)
	end

	local function drawHead()
		gl.Vertex(0, 0, length)
		gl.Vertex(pL[1], pL[2], pL[3])
		gl.Vertex(pR[1], pR[2], pR[3])
	end

	gl.PushMatrix()
	gl.Translate(a[1], a[2], a[3])
	gl.Rotate(horizontalAngle * 180 / math.pi, 0, 1, 0) -- Rotate around Y-axis
	gl.Rotate(verticalAngle * 180 / math.pi, 1, 0, 0) -- Tilt up or down

	gl.BeginEnd(GL.QUADS, drawShaft)
	gl.BeginEnd(GL.TRIANGLES, drawHead)

	gl.PopMatrix()
end

-- copied from map_start_position_suggestions
-- TODO: move to includable source code file ?
-- Note: small modifications have been made
local function drawCircle(position, segments, thickness, colors, colorsGlow)
	local startAngle = -math.pi / 2
    local cx = position.x
    local cy = position.y
    local cz = position.z
    local radius = position.radius

	local function drawArc(r, s, t, a1, a2, ci, co)
		for i = 0, s do
			local angle = startAngle + a1 + (a2 - a1) * (i / s)
			local xOuter = cx + r * math.cos(angle)
			local zOuter = cz + r * math.sin(angle)
			local xInner = cx + (r - t) * math.cos(angle)
			local zInner = cz + (r - t) * math.sin(angle)

			if ci ~= nil then
				gl.Color(ci)
			end
			gl.Vertex(xInner, Spring.GetGroundHeight(xInner, zInner), zInner)

			if co ~= nil then
				gl.Color(co)
			end
			gl.Vertex(xOuter, Spring.GetGroundHeight(xOuter, zOuter), zOuter)
		end
	end

	if colors ~= nil and #colors > 0 then
		if type(colors[1]) == "number" then
			-- single color
			colors = { colors }
		end

		local s = math.ceil(segments / #colors)
		for i, co in ipairs(colors) do
			local a1 = i * 2 * math.pi / #colors
			local a2 = (i + 1) * 2 * math.pi / #colors
			gl.BeginEnd(
				GL.TRIANGLE_STRIP, drawArc,
				radius,
				s,
				thickness,
				a1,
				a2,
				co,
				co
			)
		end
	end

	if colorsGlow ~= nil and #colorsGlow > 0 then
		if type(colorsGlow[1]) == "number" then
			-- single color
			colorsGlow = { colorsGlow }
		end

		local s = math.ceil(segments / #colorsGlow)
		for i, co in ipairs(colorsGlow) do
			local ci = { co[1], co[2], co[3], 0 }
			local a1 = i * 2 * math.pi / #colorsGlow
			local a2 = (i + 1) * 2 * math.pi / #colorsGlow
			gl.BeginEnd(
				GL.TRIANGLE_STRIP, drawArc,
				radius,
				s,
				radius * glowRadiusCoefficient,
				a1,
				a2,
				ci,
				co
			)
		end
	end
end

local function drawVogelPoint(x, y, z, r, color)
	local function drawFilledCircle(x, y, z, r, s)
        -- origo
        gl.Vertex(x, y, z)

        for i = 0, s do
            local angle = 2 * math.pi * (i / s)

            local xpos = x + r * math.cos(angle)
            local zpos = z + r * math.sin(angle)

            local ypos = Spring.GetGroundHeight(xpos, zpos)

            gl.Vertex(xpos, ypos, zpos)
        end
	end

    local segments = 36

    gl.Color(color)

    gl.BeginEnd(
        GL.TRIANGLE_FAN, drawFilledCircle,
        x,
        y,
        z,
        r,
        segments
    )
end

local function drawDestinationVogel()
    local function generateVogel(destination)
        local result = {}

        local n = destination.state.n

        for i = 1,n do
            result[i] = table.pack(findNextDropVogel(destination))
        end

        return result
    end

    local vogelPointRadius = 12
    local vogelPointColor = {0.4, 0, 0.6}

    for _,ferryRoute in ipairs(ferryRoutes) do
        if ferryRoute.routeFinished then
            if not ferryRoute.destination.vogelPoints then
                ferryRoute.destination.vogelPoints = generateVogel(ferryRoute.destination)
            end

            for _,vogelPoint in ipairs(ferryRoute.destination.vogelPoints) do
                drawVogelPoint(vogelPoint[1], vogelPoint[2], vogelPoint[3], vogelPointRadius, vogelPointColor)
            end
        end
    end
end

local displayListFunction = function()
    for _,ferryRoute in ipairs(ferryRoutes) do
        --local lastDeparture = nil
        for _,zone in ipairs(ferryRoute.zones) do
            if zone == ferryRoute.destination then
                drawCircle(
                    zone,
                    circleSegments,
                    circleThickness,
                    destinationAreaColors,
                    destinationAreaColorsGlow
                )
            else
                local circleColors, circleColorsGlow
                if zone == mouseOverDeparture then
                    circleColors = departureAreaMouseOverColors
                    circleColorsGlow = departureAreaMouseOverGlowColors
                else
                    circleColors = departureAreaColors
                    circleColorsGlow = departureAreaGlowColors
                end

                drawCircle(
                    zone,
                    circleSegments,
                    circleThickness,
                    circleColors,
                    circleColorsGlow
                )
            end

            if zone.nextZone then
                drawArrow(
                    zone,
                    zone.nextZone,
                    arrowSize,
                    arrowColor
                )
            end
        end
    end

    if debugLevel >= debugLevels.showVogel then
        drawDestinationVogel()
    end
end

function widget:DrawGenesis()
    if updateDisplayList then
        if myDisplayList then
            gl.DeleteList(myDisplayList)
        end

        myDisplayList = gl.CreateList(displayListFunction)
        updateDisplayList = false
    end
end

function widget:DrawWorldPreUnit()
    gl.CallList(myDisplayList)
end

local font = nil
local viewScreenWidth, viewScreenHeight
local function updateFont()
    font = WG['fonts'].getFont()
    viewScreenWidth, viewScreenHeight = Spring.GetViewGeometry()
end

local function drawDebugText()
    local textToDraw = "Route Count: " .. tostring(#ferryRoutes)

    for _,ferryRoute in ipairs(ferryRoutes) do
        textToDraw = textToDraw .. "\n\n" .. "Route Servers: " .. tostring(#ferryRoute.serversReady) .. " ready, " .. tostring(#ferryRoute.serversBusy) .. " busy"
        textToDraw = textToDraw .. "\n" .. "Route Departures: " .. tostring(#ferryRoute.zones-1)
        --textToDraw = textToDraw .. "\n" .. "Route Passengers Waiting: " .. tostring(#ferryRoute.passengersWaiting)
    end

	font:Begin()
	    font:SetTextColor(textColorWhite)

		font:Print(
			textToDraw,
			viewScreenWidth - viewScreenWidth * 0.20,
			viewScreenHeight - viewScreenHeight * 0.20,
			32, -- fontsize
			'o'
        )
	font:End()
end

function widget:DrawScreen()
    if debugLevel >= debugLevels.showStats then
        if not font then
            updateFont()
        end

        drawDebugText()
    end
end

