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

test("Transport Ferry Transport Dies When Picking Up Passenger", function ()
	Test.expectCallin("UnitCmdDone")
	Test.expectCallin("UnitLoaded")

	-- make transport
	local stork1UnitID = helpers.spawnTransport("armatlas", 100, -600)

	-- make ferry route by issuing move order then set ferry order
	Spring.SelectUnit(stork1UnitID)
	helpers.moveTransport(stork1UnitID, -200, -600)
	helpers.setFerry(widget, 200, -600, 100, false)

	-- check that ferry route has been created
	assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with set ferry adds one item to global table of ferry routes")

    -- add second transport so that route stays alive
	local stork2UnitID = helpers.spawnTransport("armatlas", 100, -600)
	Spring.SelectUnit(stork2UnitID)
	helpers.moveTransport(stork2UnitID, -200, -600)

    -- create and add pawn as passenger by issuing move order to departure
    local pawnUnitID = helpers.spawnUnit("armpw", -50, -600)
    Spring.SelectUnit(pawnUnitID)
    helpers.moveUnit(pawnUnitID, -150, -600)

    -- while pawn is moving, no transport will yet be activated as pawn is enroute to departure
    assert.ferryRoute(1).has.serversReady(2, "Ferry route has two transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(0, "Ferry route has no transports busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    -- wait for pawn to arrive to departure
    Test.waitUntilCallinArgs("UnitCmdDone", { pawnUnitID, nil, nil, nil, nil, nil, nil }, timeout)

    -- pawn has arrived and transport has been ordered to pick it up
    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")
    assert.units(stork1UnitID).has.moveCommand({-150, nil, -600}, 10, "Transport 1 is moving to pickup pawn")

    -- kill transport
	SyncedRun(function (locals)
	    Spring.DestroyUnit(locals.stork1UnitID, false, true, nil, false)
	end)

    -- second transport has been activated to pickup pawn
    assert.ferryRoute(1).has.serversReady(0, "Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    -- wait for transport to pickup passenger
    Test.waitUntilCallinArgs("UnitLoaded", { pawnUnitID, nil, nil, nil, nil }, timeout)

    -- transport has picked up passenger and is enroute to drop passenger at destination
    assert.ferryRoute(1).has.serversReady(0, "Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    assert.unit(stork2UnitID).has.position({-150, nil, -600}, 10, "Transport 2 has moved to the position where the pawn is")
    assert.unit(stork2UnitID).is.transportingUnits({pawnUnitID}, "Transport 2 has picked up the pawn")

	Test.clearCallins()
end)
