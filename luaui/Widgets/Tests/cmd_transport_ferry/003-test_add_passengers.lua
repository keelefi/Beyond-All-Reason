local helpers = VFS.Include("luaui/Widgets/Tests/cmd_transport_ferry/helpers.lua")

local widgetName = "Transport Ferry"
local delay = 5  -- TODO: what is this btw?
local timeout = 120 * 30 -- 2 minutes

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

test("Transport Ferry Add One Passenger", function ()
	Test.expectCallin("UnitCmdDone")
	Test.expectCallin("UnitLoaded")
	Test.expectCallin("UnitUnloaded")

	-- make transport
	local storkUnitID = helpers.spawnTransport("armatlas", 0, -800)

	-- make ferry route by issuing move order then set ferry order
	Spring.SelectUnit(storkUnitID)
	helpers.moveTransport(storkUnitID, -100, -800)
	helpers.setFerry(widget, 100, -800, 100, false)

	-- check that ferry route has been created
	assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with set ferry adds one item to global table of ferry routes")

	local newFerryRoute = widget.ferryRoutes[1]
	assert.table_has_fields({"serversReady", "serversBusy", "passengersWaiting"}, newFerryRoute)

    assert.is.equal(1, #newFerryRoute.serversReady, "Ferry route has one transport ready to serve passengers")
    assert.is.serversBusy(0, newFerryRoute.serversBusy, "Ferry route has no transports busy serving passengers")
    assert.is.True(widget.fifo_isEmpty(newFerryRoute.passengersWaiting), "Ferry route has no passengers waiting")

    -- make pawn
    local pawnUnitID = helpers.spawnUnit("armpw", 0, -800)

    -- add pawn as passenger by issuing move order to departure
    Spring.SelectUnit(pawnUnitID)
    helpers.moveUnit(pawnUnitID, -190, -800)

    -- while pawn is moving, no transport will yet be activated as pawn is enroute to departure
    assert.is.equal(1, #newFerryRoute.serversReady, "Ferry route has one transport ready to serve passengers")
    assert.is.serversBusy(0, newFerryRoute.serversBusy, "Ferry route has no transports busy serving passengers")
    assert.is.True(widget.fifo_isEmpty(newFerryRoute.passengersWaiting), "Ferry route has no passengers waiting")

    -- wait for pawn to arrive to departure
    Test.waitUntilCallinArgs("UnitCmdDone", { pawnUnitID, nil, nil, nil, nil, nil, nil }, timeout)

    -- pawn has arrived and transport has been ordered to pick it up
    assert.is.equal(0, #newFerryRoute.serversReady, "Ferry route has no transports ready to serve passengers")
    assert.is.serversBusy(1, newFerryRoute.serversBusy, "Ferry route has one transport busy serving passengers")
    assert.is.True(widget.fifo_isEmpty(newFerryRoute.passengersWaiting), "Ferry route has no passengers waiting")

    assert.is.unitPos({-190, -800, 10}, pawnUnitID, "Pawn is done moving and is waiting to be picked up by a transport")
    assert.is_not.unitInTransport(pawnUnitID, storkUnitID, "Pawn is not in a transport")

    -- wait for transport to pickup passenger
    Test.waitUntilCallinArgs("UnitLoaded", { pawnUnitID, nil, nil, nil, nil }, timeout)

    -- transport has picked up passenger and is enroute to drop passenger at destination
    assert.is.equal(0, #newFerryRoute.serversReady, "Ferry route has no transports ready to serve passengers")
    assert.is.serversBusy(1, newFerryRoute.serversBusy, "Ferry route has one transport busy serving passengers")
    assert.is.True(widget.fifo_isEmpty(newFerryRoute.passengersWaiting), "Ferry route has no passengers waiting")

    assert.is.unitPos({-190, -800, 10}, storkUnitID, "Transport has moved to the position where the pawn is")
    assert.is.unitInTransport(pawnUnitID, storkUnitID, "Transport has picked up the pawn")

    -- wait for transport to drop passenger
    Test.waitUntilCallinArgs("UnitUnloaded", { pawnUnitID, nil, nil, nil, nil }, timeout)

    -- transport has dropped passenger and is enroute back to departure
    assert.is.equal(1, #newFerryRoute.serversReady, "Ferry route has one transport ready to serve passengers")
    assert.is.serversBusy(0, newFerryRoute.serversBusy, "Ferry route has no transports busy serving passengers")
    assert.is.True(widget.fifo_isEmpty(newFerryRoute.passengersWaiting), "Ferry route has no passengers waiting")

    assert.is.unitPos({100, -800, 10}, pawnUnitID, "Pawn is at the destination")
    assert.is.unitPos({100, -800, 10}, storkUnitID, "Transport is at the destination")
    assert.is_not.unitInTransport(pawnUnitID, storkUnitID, "Pawn has been unloaded from the transport")

	Test.clearCallins()
end)

test("Transport Ferry Add One Passenger Arriving Before Transport", function ()
	Test.expectCallin("UnitCmdDone")
	Test.expectCallin("UnitLoaded")
	Test.expectCallin("UnitUnloaded")

	-- make transport
	local storkUnitID = helpers.spawnTransport("armatlas", -100, -400)

	-- make ferry route by issuing move order then set ferry order
	Spring.SelectUnit(storkUnitID)
	helpers.moveTransport(storkUnitID, -100, -800)
	helpers.setFerry(widget, 100, -800, 100, false)

	-- check that ferry route has been created
	assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with set ferry adds one item to global table of ferry routes")

	local newFerryRoute = widget.ferryRoutes[1]
	assert.table_has_fields({"serversReady", "serversBusy", "passengersWaiting"}, newFerryRoute)

    assert.is.equal(1, #newFerryRoute.serversReady, "Ferry route has one transport ready to serve passengers")
    assert.is.serversBusy(0, newFerryRoute.serversBusy, "Ferry route has no transports busy serving passengers")
    assert.is.True(widget.fifo_isEmpty(newFerryRoute.passengersWaiting), "Ferry route has no passengers waiting")

    -- make pawn
    local pawnUnitID = helpers.spawnUnit("armpw", 0, -800)

    -- add pawn as passenger by issuing move order to departure
    Spring.SelectUnit(pawnUnitID)
    helpers.moveUnit(pawnUnitID, -190, -800)

    -- while pawn is moving, no transport will yet be activated as pawn is enroute to departure
    assert.is.equal(1, #newFerryRoute.serversReady, "Ferry route has one transport ready to serve passengers")
    assert.is.serversBusy(0, newFerryRoute.serversBusy, "Ferry route has no transports busy serving passengers")
    assert.is.True(widget.fifo_isEmpty(newFerryRoute.passengersWaiting), "Ferry route has no passengers waiting")

    assert.unit(storkUnitID).has.commandMove({ -100,nil,-800 })

    -- wait for pawn to arrive to departure
    Test.waitUntilCallinArgs("UnitCmdDone", { pawnUnitID, nil, nil, nil, nil, nil, nil }, timeout)

    -- pawn has arrived and transport has been ordered to pick it up
    assert.is.equal(0, #newFerryRoute.serversReady, "Ferry route has no transports ready to serve passengers")
    assert.is.serversBusy(1, newFerryRoute.serversBusy, "Ferry route has one transport busy serving passengers")
    assert.is.True(widget.fifo_isEmpty(newFerryRoute.passengersWaiting), "Ferry route has no passengers waiting")

    assert.is.unitPos({-190, -800, 10}, pawnUnitID, "Pawn is done moving and is waiting to be picked up by a transport")
    --assert.is.unitPos({-100, -600, 400}, storkUnitID, "Transport is far from the departure")
    assert.is_not.unitInTransport(pawnUnitID, storkUnitID, "Pawn is not in a transport")

    --assert.has.Not.unitCommandMove(storkUnitID, { -100,nil,-800 })
    assert.unit(storkUnitID).has.commandMove({ -190,nil,-800 })

    -- wait for transport to pickup passenger
    Test.waitUntilCallinArgs("UnitLoaded", { pawnUnitID, nil, nil, nil, nil }, timeout)

    -- transport has picked up passenger and is enroute to drop passenger at destination
    assert.is.equal(0, #newFerryRoute.serversReady, "Ferry route has no transports ready to serve passengers")
    assert.is.serversBusy(1, newFerryRoute.serversBusy, "Ferry route has one transport busy serving passengers")
    assert.is.True(widget.fifo_isEmpty(newFerryRoute.passengersWaiting), "Ferry route has no passengers waiting")

    assert.is.unitPos({-190, -800, 10}, storkUnitID, "Transport has moved to the position where the pawn is")
    assert.is.unitInTransport(pawnUnitID, storkUnitID, "Transport has picked up the pawn")

    -- wait for transport to drop passenger
    Test.waitUntilCallinArgs("UnitUnloaded", { pawnUnitID, nil, nil, nil, nil }, timeout)

    -- transport has dropped passenger and is enroute back to departure
    assert.is.equal(1, #newFerryRoute.serversReady, "Ferry route has one transport ready to serve passengers")
    assert.is.serversBusy(0, newFerryRoute.serversBusy, "Ferry route has no transports busy serving passengers")
    assert.is.True(widget.fifo_isEmpty(newFerryRoute.passengersWaiting), "Ferry route has no passengers waiting")

    assert.is.unitPos({100, -800, 10}, pawnUnitID, "Pawn is at the destination")
    assert.is.unitPos({100, -800, 10}, storkUnitID, "Transport is at the destination")
    assert.is_not.unitInTransport(pawnUnitID, storkUnitID, "Pawn has been unloaded from the transport")

	Test.clearCallins()
end)
