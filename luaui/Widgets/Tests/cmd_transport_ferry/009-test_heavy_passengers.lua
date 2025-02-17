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

test("Transport Ferry Heavy Passenger One Transport One Passenger", function ()
	Test.expectCallin("UnitCmdDone")
	Test.expectCallin("UnitLoaded")
	Test.expectCallin("UnitUnloaded")

	-- create a ferry route
	local abductorUnitID = helpers.spawnTransport("armdfly", 0, -600)

	Spring.SelectUnit(abductorUnitID)
	helpers.moveTransport(abductorUnitID, -200, -600)
	helpers.setFerry(widget, 200, -600, 100, false)

	assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with set ferry adds one item to global table of ferry routes")

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.heavyServersReady(1, "Ferry route has one heavy transport ready to serve passengers")
    assert.ferryRoute(1).has.no.serversBusy("Ferry route has no transports busy serving passengers")

    -- create
    local bullUnitID = helpers.spawnUnit("armbull", -50, -600)
    Spring.SelectUnit(bullUnitID)
    helpers.moveUnit(bullUnitID, -150, -600)

    Test.waitUntilCallinArgs("UnitCmdDone", { bullUnitID, nil, nil, nil, nil, nil, nil }, timeout)

    assert.ferryRoute(1).has.no.serversReady("Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.no.heavyServersReady("Ferry route has no heavy transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")

    Test.waitUntilCallinArgs("UnitLoaded", { bullUnitID, nil, nil, nil, nil }, timeout)

    assert.ferryRoute(1).has.no.serversReady("Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.no.heavyServersReady("Ferry route has no heavy transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.unit(abductorUnitID).is.transportingUnits({bullUnitID}, "Transport has picked up the bull")

    Test.waitUntilCallin("UnitUnloaded", nil, timeout)

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.heavyServersReady(1, "Ferry route has one heavy transport ready to serve passengers")
    assert.ferryRoute(1).has.no.serversBusy("Ferry route has no transports busy serving passengers")
    assert.unit(abductorUnitID).is_not.transportingUnits("Transport is not transporting any units")

	Test.clearCallins()
end)

test("Transport Ferry Heavy Passenger One Transport Two Passengers", function ()
	Test.expectCallin("UnitCmdDone")
	Test.expectCallin("UnitLoaded")
	Test.expectCallin("UnitUnloaded")

	-- create a ferry route
	local abductorUnitID = helpers.spawnTransport("armdfly", 0, -600)

	Spring.SelectUnit(abductorUnitID)
	helpers.moveTransport(abductorUnitID, -200, -600)
	helpers.setFerry(widget, 200, -600, 100, false)

	assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with set ferry adds one item to global table of ferry routes")

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.heavyServersReady(1, "Ferry route has one heavy transport ready to serve passengers")
    assert.ferryRoute(1).has.no.serversBusy("Ferry route has no transports busy serving passengers")

    -- create
    local bull1UnitID = helpers.spawnUnit("armbull", -50, -600)
    Spring.SelectUnit(bull1UnitID)
    helpers.moveUnit(bull1UnitID, -150, -600)
    local bull2UnitID = helpers.spawnUnit("armbull", -50, -600)
    Spring.SelectUnit(bull2UnitID)
    helpers.moveUnit(bull2UnitID, -150, -600)

    Test.waitUntilCallin("UnitCmdDone", function (unitID, unitDefID, unitTeam, cmdID, cmdParams, options, cmdTag)
                return (unitID == bull1UnitID) or (unitID == bull2UnitID)
            end, timeout, 2)

    assert.ferryRoute(1).has.no.serversReady("Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.no.heavyServersReady("Ferry route has no heavy transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")

    Test.waitUntilCallin("UnitLoaded", nil, timeout)

    assert.ferryRoute(1).has.no.serversReady("Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.no.heavyServersReady("Ferry route has no heavy transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")

    Test.waitUntilCallin("UnitUnloaded", nil, timeout)

    assert.ferryRoute(1).has.no.serversReady("Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.no.heavyServersReady("Ferry route has no heavy transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")

    Test.waitUntilCallin("UnitLoaded", nil, timeout)

    assert.ferryRoute(1).has.no.serversReady("Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.no.heavyServersReady("Ferry route has no heavy transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")

    Test.waitUntilCallin("UnitUnloaded", nil, timeout)

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.heavyServersReady(1, "Ferry route has one heavy transport ready to serve passengers")
    assert.ferryRoute(1).has.no.serversBusy("Ferry route has no transports busy serving passengers")

	Test.clearCallins()
end)

test("Transport Ferry Two Heavy Passengers One Light One Heavy Transports", function ()
	Test.expectCallin("UnitCmdDone")
	Test.expectCallin("UnitLoaded")
	Test.expectCallin("UnitUnloaded")

	-- create a ferry route
	local storkUnitID = helpers.spawnTransport("armatlas", 0, -600)
	Spring.SelectUnit(storkUnitID)
	helpers.moveTransport(storkUnitID, -200, -600)
	helpers.setFerry(widget, 200, -600, 100, false)

	local abductorUnitID = helpers.spawnTransport("armdfly", 0, -600)
	Spring.SelectUnit(abductorUnitID)
	helpers.moveTransport(abductorUnitID, -200, -600)

	assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with set ferry adds one item to global table of ferry routes")

    assert.ferryRoute(1).has.serversReady(2, "Ferry route has two transports ready to serve passengers")
    assert.ferryRoute(1).has.heavyServersReady(1, "Ferry route has one heavy transport ready to serve passengers")
    assert.ferryRoute(1).has.no.serversBusy("Ferry route has no transports busy serving passengers")

    -- create
    local bull1UnitID = helpers.spawnUnit("armbull", -50, -650)
    Spring.SelectUnit(bull1UnitID)
    helpers.moveUnit(bull1UnitID, -200, -650)
    local bull2UnitID = helpers.spawnUnit("armbull", -50, -550)
    Spring.SelectUnit(bull2UnitID)
    helpers.moveUnit(bull2UnitID, -200, -550)

    Test.waitUntilCallin("UnitCmdDone", function (unitID, unitDefID, unitTeam, cmdID, cmdParams, options, cmdTag)
                return (unitID == bull1UnitID) or (unitID == bull2UnitID)
            end, timeout, 2)

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.no.heavyServersReady("Ferry route has no heavy transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.passengersWaiting(1, "Ferry route has one passenger waiting")

    Test.waitUntilCallin("UnitLoaded", nil, timeout)

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.no.heavyServersReady("Ferry route has no heavy transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.passengersWaiting(1, "Ferry route has one passenger waiting")

    Test.waitUntilCallin("UnitUnloaded", nil, timeout)

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.no.heavyServersReady("Ferry route has no heavy transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    Test.waitUntilCallinArgs("UnitLoaded", { bullUnitID, nil, nil, nil, nil }, timeout)

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.no.heavyServersReady("Ferry route has no heavy transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    Test.waitUntilCallin("UnitUnloaded", nil, timeout)

    assert.ferryRoute(1).has.serversReady(2, "Ferry route has two transports ready to serve passengers")
    assert.ferryRoute(1).has.heavyServersReady(1, "Ferry route has one heavy transport ready to serve passengers")
    assert.ferryRoute(1).has.no.serversBusy("Ferry route has no transports busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

	Test.clearCallins()
end)
