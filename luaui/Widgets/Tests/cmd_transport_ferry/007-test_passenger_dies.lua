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

test("Transport Ferry Passenger Dies While Transport Is Arriving", function ()
	Test.expectCallin("UnitCmdDone")
	Test.expectCallin("UnitLoaded")

	-- make transport
	local storkUnitID = helpers.spawnTransport("armatlas", 100, -600)

	-- make ferry route by issuing move order then set ferry order
	Spring.SelectUnit(storkUnitID)
	helpers.moveTransport(storkUnitID, -200, -600)
	helpers.setFerry(widget, 200, -600, 100, false)

	-- check that ferry route has been created
	assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with set ferry adds one item to global table of ferry routes")

    -- create and add two pawns as passengers by issuing move order to departure
    local pawn1UnitID = helpers.spawnUnit("armpw", -50, -600)
    Spring.SelectUnit(pawn1UnitID)
    helpers.moveUnit(pawn1UnitID, -150, -600)
    local pawn2UnitID = helpers.spawnUnit("armpw", 0, -600)
    Spring.SelectUnit(pawn2UnitID)
    helpers.moveUnit(pawn2UnitID, -150, -600)

    -- while pawn is moving, no transport will yet be activated as pawn is enroute to departure
    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(0, "Ferry route has no transports busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    -- wait for pawns to arrive to departure
    Test.waitUntilCallin("UnitCmdDone", function (unitID, unitDefID, unitTeam, cmdID, cmdParams, options, cmdTag)
                return (unitID == pawn1UnitID) or (unitID == pawn2UnitID)
            end, timeout, 2)

    -- pawns have arrived and transport has been ordered to pick one up
    assert.ferryRoute(1).has.serversReady(0, "Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.passengersWaiting(1, "Ferry route has one passenger waiting")

    -- kill first pawn
	SyncedRun(function (locals)
	    Spring.DestroyUnit(locals.pawn1UnitID, false, true, nil, false)
	end)

    -- transport hs been freed from earlier duty
    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(0, "Ferry route has no transports busy serving passengers")
    assert.ferryRoute(1).has.passengersWaiting(1, "Ferry route has one passenger waiting")

    -- wait for the next GameFrame() to kick in for transport to get next assignment
    Test.waitFrames(30)

    -- transport is ordered to pickup other pawn
    assert.ferryRoute(1).has.no.serversReady("Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    -- wait for transport to pickup passenger
    Test.waitUntilCallinArgs("UnitLoaded", { pawn2UnitID, nil, nil, nil, nil }, timeout)

	Test.clearCallins()
end)
