local helpers = VFS.Include("luaui/Widgets/Tests/cmd_transport_ferry/helpers.lua")

local widgetName = "Transport Ferry"
local delay = 5  -- TODO: what is this btw?
local timeout = 30 * 30 -- 30 seconds

local keyShift = 0x130

function skip()
	return not Platform.gl
end

function setup()
	assert(widgetHandler.knownWidgets[widgetName] ~= nil)

	Test.clearMap()

	widget = Test.prepareWidget(widgetName)

	initialCameraState = Spring.GetCameraState()

	Spring.SetCameraState({
		mode = 5,
	})

	widget.removeAllFerryRoutes()
	assert(#widget.ferryRoutes == 0)
end

function cleanup()
	Test.clearMap()

	Spring.SetCameraState(initialCameraState)
end

local function getDistanceBetweenPoints(pointA, pointB)
    local distanceSquared = 0
    for i=1,3 do
        if pointA[i] and pointB[i] then
            distanceSquared = distanceSquared + (pointA[i] - pointB[i])^2
        end
    end

    return math.sqrt(distanceSquared)
end

test("Transport Ferry Vogel Radius 150", function ()
	Test.expectCallin("UnitLoaded")
	Test.expectCallin("UnitUnloaded")

    local transportCount = 9
    local pawnCount = transportCount

    local MIN_DISTANCE = 40

    local storkUnitIDs = {}

	storkUnitIDs[1] = helpers.spawnTransport("armatlas", 0, -600)

	-- make ferry route
	Spring.SelectUnit(storkUnitIDs[1])
	helpers.moveTransport(storkUnitIDs[1], -400, -600)
	helpers.setFerry(widget, 400, -600, 150, false)

	-- check that ferry route has been created
	assert.is.equal(1, #widget.ferryRoutes, "Ferry route created")

    -- add rest of the transports to ferry route
    for i=2,transportCount do
	    storkUnitIDs[i] = helpers.spawnTransport("armatlas", 0, -600)
	    Spring.SelectUnit(storkUnitIDs[i])
	    helpers.moveTransport(storkUnitIDs[i], -400, -600)
    end

    -- make pawns
    local pawnUnitIDs = {}
    for i=1,pawnCount do
        pawnUnitIDs[i] = helpers.spawnUnit("armpw", -200, -600)
        Spring.SelectUnit(pawnUnitIDs[i])
        helpers.moveUnit(pawnUnitIDs[i], -400, -600)
    end

    -- wait for transports to pickup passengers
    Test.waitUntilCallin("UnitLoaded", nil, timeout, transportCount)

    -- check that transports are routed correctly
    assert.units(storkUnitIDs).has.moveCommand({400, nil, -600}, 10, "One of the transports has a move command to the middle of the destination")

	local centerX = Game.mapSizeX / 2
	local centerZ = Game.mapSizeZ / 2
    local dropLocations = {}
    for i=1,#storkUnitIDs do
        local commandQueue = Spring.GetUnitCommands(storkUnitIDs[i], -1)
        local moveCommand = commandQueue[1]
        if moveCommand.id == CMD.MOVE then
            local params = moveCommand.params
            params[1] = params[1] - centerX
            params[3] = params[3] - centerZ
            Spring.Echo("move command: {" .. tostring(params[1]) .. ", " .. tostring(params[3]) .. "}")
            dropLocations[i] = {params[1], nil, params[3]}
        end
    end

    for i=1,(#dropLocations-1) do
        for j=(i+1),#dropLocations do
            local distance = getDistanceBetweenPoints(dropLocations[i], dropLocations[j])
            Spring.Echo("distance: " .. tostring(distance))
            assert.is.True(distance > MIN_DISTANCE)
        end
    end

    -- wait for transports to drop passengers
    Test.waitUntilCallin("UnitUnloaded", nil, timeout, transportCount)

	Test.clearCallins()
end)
