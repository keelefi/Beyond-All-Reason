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

test("Transport Ferry Factory Rally One Passenger", function ()
	Test.expectCallin("UnitFromFactory")
	Test.expectCallin("UnitCmdDone")
	Test.expectCallin("UnitLoaded")
	Test.expectCallin("UnitUnloaded")

	-- make transport
	local storkUnitID = helpers.spawnTransport("armatlas", 0, -600)

	-- make ferry route by issuing move order then set ferry order
	Spring.SelectUnit(storkUnitID)
	helpers.moveTransport(storkUnitID, -200, -600)
	helpers.setFerry(widget, 200, -600, 100, false)

	-- check that ferry route has been created
	assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with set ferry adds one item to global table of ferry routes")

    -- create factory and set rally point to departure
    local armlabUnitID = helpers.spawnUnit("armlab", -200, -1000, 0)
    Spring.SelectUnit(armlabUnitID)
    helpers.moveUnit(armlabUnitID, -200, -600, false)

    -- create unit from factory
    helpers.unitFromFactory(armlabUnitID, "armpw")

    -- wait for the factory to build a unit and assign pawn unitID
    local pawnUnitID = nil
    Test.waitUntilCallin("UnitFromFactory", function (unitID, unitDefID, unitTeam, factID, factDefID, userOrders)
                pawnUnitID = unitID
                return factID == armlabUnitID
            end, timeout)

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.no.serversBusy("Ferry route has no transports busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    -- wait for pawn to arrive to departure
    Test.waitUntilCallinArgs("UnitCmdDone", { pawnUnitID, nil, nil, CMD.MOVE, nil, nil, nil }, timeout, 2)

    assert.ferryRoute(1).has.no.serversReady("Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    Test.waitUntilCallinArgs("UnitLoaded", { pawnUnitID, nil, nil, nil, nil }, timeout)

    Test.waitUntilCallinArgs("UnitUnloaded", { pawnUnitID, nil, nil, nil, nil }, timeout)

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.no.serversBusy("Ferry route has no transports busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

	Test.clearCallins()
end)
