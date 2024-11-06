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

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(0, "Ferry route has no transports busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    -- make pawn
    local pawnUnitID = helpers.spawnUnit("armpw", 0, -800)

    -- add pawn as passenger by issuing move order to departure
    Spring.SelectUnit(pawnUnitID)
    helpers.moveUnit(pawnUnitID, -190, -800)

    -- while pawn is moving, no transport will yet be activated as pawn is enroute to departure
    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(0, "Ferry route has no transports busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    -- wait for pawn to arrive to departure
    Test.waitUntilCallinArgs("UnitCmdDone", { pawnUnitID, nil, nil, nil, nil, nil, nil }, timeout)

    -- pawn has arrived and transport has been ordered to pick it up
    assert.ferryRoute(1).has.serversReady(0, "Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    assert.unit(pawnUnitID).has.position({-190, nil, -800}, 10, "Pawn is done moving and is waiting to be picked up by a transport")
    assert.unit(storkUnitID).is_not.transportingUnits({pawnUnitID}, "Pawn is not in a transport")

    -- wait for transport to pickup passenger
    Test.waitUntilCallinArgs("UnitLoaded", { pawnUnitID, nil, nil, nil, nil }, timeout)

    -- transport has picked up passenger and is enroute to drop passenger at destination
    assert.ferryRoute(1).has.serversReady(0, "Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    assert.unit(storkUnitID).has.position({-190, nil, -800}, 10, "Transport has moved to the position where the pawn is")
    assert.unit(storkUnitID).is.transportingUnits({pawnUnitID}, "Transport has picked up the pawn")

    -- wait for transport to drop passenger
    Test.waitUntilCallinArgs("UnitUnloaded", { pawnUnitID, nil, nil, nil, nil }, timeout)

    -- transport has dropped passenger and is enroute back to departure
    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(0, "Ferry route has no transports busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    assert.unit(pawnUnitID).has.position({100, nil, -800}, 10, "Pawn is at the destination")
    assert.unit(storkUnitID).has.position({100, nil, -800}, 10, "Transport is at the destination")
    assert.unit(storkUnitID).is_not.transportingUnits({pawnUnitID}, "Pawn has been unloaded from the transport")

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

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(0, "Ferry route has no transports busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    -- make pawn
    local pawnUnitID = helpers.spawnUnit("armpw", 0, -800)

    -- add pawn as passenger by issuing move order to departure
    Spring.SelectUnit(pawnUnitID)
    helpers.moveUnit(pawnUnitID, -190, -800)

    -- while pawn is moving, no transport will yet be activated as pawn is enroute to departure
    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(0, "Ferry route has no transports busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    assert.unit(storkUnitID).has.moveCommand({-100,nil,-800}, "Transport has move command to departure")

    -- wait for pawn to arrive to departure
    Test.waitUntilCallinArgs("UnitCmdDone", { pawnUnitID, nil, nil, nil, nil, nil, nil }, timeout)

    -- pawn has arrived and transport has been ordered to pick it up
    assert.ferryRoute(1).has.serversReady(0, "Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    assert.unit(pawnUnitID).has.position({-190, nil, -800}, 10, "Pawn is done moving and is waiting to be picked up by a transport")
    assert.unit(storkUnitID).is_not.transportingUnits({pawnUnitID}, "Pawn is not in a transport")

    assert.unit(storkUnitID).has.moveCommand({-190,nil,-800}, 10, "Transport has move command to where pawn is")

    -- wait for transport to pickup passenger
    Test.waitUntilCallinArgs("UnitLoaded", { pawnUnitID, nil, nil, nil, nil }, timeout)

    -- transport has picked up passenger and is enroute to drop passenger at destination
    assert.ferryRoute(1).has.serversReady(0, "Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    assert.unit(storkUnitID).has.position({-190, nil, -800}, 10, "Transport has moved to the position where the pawn is")
    assert.unit(storkUnitID).is.transportingUnits({pawnUnitID}, "Transport has picked up the pawn")

    -- wait for transport to drop passenger
    Test.waitUntilCallinArgs("UnitUnloaded", { pawnUnitID, nil, nil, nil, nil }, timeout)

    -- transport has dropped passenger and is enroute back to departure
    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(0, "Ferry route has no transports busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    assert.unit(pawnUnitID).has.position({100, nil, -800}, 10, "Pawn is at the destination")
    assert.unit(storkUnitID).has.position({100, nil, -800}, 10, "Transport is at the destination")
    assert.unit(storkUnitID).is_not.transportingUnits({pawnUnitID}, "Pawn has been unloaded from the transport")

	Test.clearCallins()
end)

test("Transport Ferry Add Two Passengers", function ()
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

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(0, "Ferry route has no transports busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    -- make pawn
    local pawn1UnitID = helpers.spawnUnit("armpw", 0, -800)
    local pawn2UnitID = helpers.spawnUnit("armpw", 0, -800)

    -- add pawn as passenger by issuing move order to departure
    Spring.SelectUnit(pawn1UnitID)
    helpers.moveUnit(pawn1UnitID, -190, -800)
    Spring.SelectUnit(pawn2UnitID)
    helpers.moveUnit(pawn2UnitID, -190, -800)

    -- while pawn is moving, no transport will yet be activated as pawn is enroute to departure
    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(0, "Ferry route has no transports busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    -- wait for pawn to arrive to departure
    Test.waitUntilCallin("UnitCmdDone", function (unitID, unitDefID, unitTeam, cmdID, cmdParams, options, cmdTag)
                return (unitID == pawn1UnitID) or (unitID == pawn2UnitID)
            end, timeout, 2)

    -- pawn has arrived and transport has been ordered to pick it up
    assert.ferryRoute(1).has.serversReady(0, "Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.passengersWaiting(1, "Ferry route has one passenger waiting")

    assert.unit(pawn1UnitID).has.position({-190, nil, -800}, 100, "Pawn 1 is done moving and is waiting to be picked up by a transport")
    assert.unit(pawn2UnitID).has.position({-190, nil, -800}, 100, "Pawn 2 is done moving and is waiting to be picked up by a transport")
    assert.unit(storkUnitID).is_not.transportingUnit({pawn1UnitID, pawn2UnitID}, "Transport is carrying neither pawn")

    -- wait for transport to pickup a passenger
    Test.waitUntilCallin("UnitLoaded", nil, timeout)

    -- transport has picked up passenger and is enroute to drop passenger at destination
    assert.ferryRoute(1).has.serversReady(0, "Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.passengersWaiting(1, "Ferry route has one passenger waiting")

    assert.unit(storkUnitID).has.position({-190, nil, -800}, 100, "Transport has moved to the position where a pawn is waiting")
    assert.unit(storkUnitID).is.transportingUnit({pawn1UnitID, pawn2UnitID}, "Transport has picked up a pawn")

    local pawn1 = Spring.GetUnitIsTransporting(storkUnitID)[1]
    local pawn2 = pawn1 == pawn1UnitID and pawn2UnitID or pawn1UnitID

    -- wait for transport to drop a passenger
    Test.waitUntilCallinArgs("UnitUnloaded", { pawn1, nil, nil, nil, nil }, timeout)

    -- transport has dropped passenger and is enroute back to departure
    assert.ferryRoute(1).has.serversReady(0, "Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    assert.unit(pawn1).has.position({100, nil, -800}, 10, "First pawn is at the destination")
    assert.unit(pawn2).has.position({-190, nil, -800}, 100, "Second pawn is at departure")
    assert.unit(storkUnitID).has.position({100, nil, -800}, 10, "Transport is at the destination")
    assert.unit(storkUnitID).is_not.transportingUnit({pawn1UnitID, pawn2UnitID}, "Transporting is not carrying either pawn")

    -- wait for transport to pickup second passenger
    Test.waitUntilCallinArgs("UnitLoaded", { pawn2, nil, nil, nil, nil }, timeout)

    assert.ferryRoute(1).has.serversReady(0, "Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has one passenger waiting")

    assert.unit(storkUnitID).has.position({-190, nil, -800}, 100, "Transport has moved to the position where a pawn is waiting")
    assert.unit(storkUnitID).is.transportingUnits({pawn2}, "Transport has picked up the second pawn")

    Test.waitUntilCallinArgs("UnitUnloaded", { pawn2, nil, nil, nil, nil }, timeout)

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(0, "Ferry route has no transports busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    assert.unit(pawn1).has.position({100, nil, -800}, 10, "First pawn is at the destination")
    assert.unit(pawn2).has.position({100, nil, -800}, 80, "Second pawn is at the destination")
    assert.unit(storkUnitID).has.position({100, nil, -800}, 80, "Transport is at the destination")
    assert.unit(storkUnitID).is_not.transportingUnit({pawn1UnitID, pawn2UnitID}, "Transporting is not carrying either pawn")

	Test.clearCallins()
end)

test("Transport Ferry Add Two Passengers Second Passanger Leaves", function ()
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

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(0, "Ferry route has no transports busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    -- make pawn
    local pawn1UnitID = helpers.spawnUnit("armpw", 0, -800)
    local pawn2UnitID = helpers.spawnUnit("armpw", 0, -800)

    -- add pawn as passenger by issuing move order to departure
    Spring.SelectUnit(pawn1UnitID)
    helpers.moveUnit(pawn1UnitID, -190, -800)
    Spring.SelectUnit(pawn2UnitID)
    helpers.moveUnit(pawn2UnitID, -190, -800)

    -- while pawn is moving, no transport will yet be activated as pawn is enroute to departure
    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(0, "Ferry route has no transports busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    -- wait for pawn to arrive to departure
    Test.waitUntilCallin("UnitCmdDone", function (unitID, unitDefID, unitTeam, cmdID, cmdParams, options, cmdTag)
                return (unitID == pawn1UnitID) or (unitID == pawn2UnitID)
            end, timeout, 2)

    -- pawn has arrived and transport has been ordered to pick it up
    assert.ferryRoute(1).has.serversReady(0, "Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.passengersWaiting(1, "Ferry route has one passenger waiting")

    assert.unit(pawn1UnitID).has.position({-190, nil, -800}, 100, "Pawn 1 is done moving and is waiting to be picked up by a transport")
    assert.unit(pawn2UnitID).has.position({-190, nil, -800}, 100, "Pawn 2 is done moving and is waiting to be picked up by a transport")
    assert.unit(storkUnitID).is_not.transportingUnit({pawn1UnitID, pawn2UnitID}, "Transport is carrying neither pawn")

    -- wait for transport to pickup a passenger
    Test.waitUntilCallin("UnitLoaded", nil, timeout)

    -- transport has picked up passenger and is enroute to drop passenger at destination
    assert.ferryRoute(1).has.serversReady(0, "Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.passengersWaiting(1, "Ferry route has one passenger waiting")

    assert.unit(storkUnitID).has.position({-190, nil, -800}, 100, "Transport has moved to the position where a pawn is waiting")
    assert.unit(storkUnitID).is.transportingUnit({pawn1UnitID, pawn2UnitID}, "Transport has picked up a pawn")

    local pawn1 = Spring.GetUnitIsTransporting(storkUnitID)[1]
    local pawn2 = pawn1 == pawn1UnitID and pawn2UnitID or pawn1UnitID

    -- remove second pawn from ferry route
    Spring.SelectUnit(pawn2)
    helpers.moveUnit(pawn2, -250, -800)

    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    -- wait for transport to drop a passenger
    Test.waitUntilCallinArgs("UnitUnloaded", { pawn1, nil, nil, nil, nil }, timeout)

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(0, "Ferry route has no transports busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    assert.unit(pawn1).has.position({100, nil, -800}, 10, "First pawn is at the destination")
    assert.unit(pawn2).has.position({-250, nil, -800}, 10, "Second pawn is outside of the ferry route")
    assert.unit(storkUnitID).has.position({100, nil, -800}, 10, "Transport is at the destination")
    assert.unit(storkUnitID).is_not.transportingUnit({pawn1UnitID, pawn2UnitID}, "Transporting is not carrying either pawn")

	Test.clearCallins()
end)

test("Transport Ferry Add Two Passengers Second Passanger Leaves When Transport Is Returning", function ()
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

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(0, "Ferry route has no transports busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    -- make pawn
    local pawn1UnitID = helpers.spawnUnit("armpw", 0, -800)
    local pawn2UnitID = helpers.spawnUnit("armpw", 0, -800)

    -- add pawn as passenger by issuing move order to departure
    Spring.SelectUnit(pawn1UnitID)
    helpers.moveUnit(pawn1UnitID, -190, -800)
    Spring.SelectUnit(pawn2UnitID)
    helpers.moveUnit(pawn2UnitID, -190, -800)

    -- while pawn is moving, no transport will yet be activated as pawn is enroute to departure
    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(0, "Ferry route has no transports busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    -- wait for pawn to arrive to departure
    Test.waitUntilCallin("UnitCmdDone", function (unitID, unitDefID, unitTeam, cmdID, cmdParams, options, cmdTag)
                return (unitID == pawn1UnitID) or (unitID == pawn2UnitID)
            end, timeout, 2)

    -- pawn has arrived and transport has been ordered to pick it up
    assert.ferryRoute(1).has.serversReady(0, "Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.passengersWaiting(1, "Ferry route has one passenger waiting")

    assert.unit(pawn1UnitID).has.position({-190, nil, -800}, 100, "Pawn 1 is done moving and is waiting to be picked up by a transport")
    assert.unit(pawn2UnitID).has.position({-190, nil, -800}, 100, "Pawn 2 is done moving and is waiting to be picked up by a transport")
    assert.unit(storkUnitID).is_not.transportingUnit({pawn1UnitID, pawn2UnitID}, "Transport is carrying neither pawn")

    -- wait for transport to pickup a passenger
    Test.waitUntilCallin("UnitLoaded", nil, timeout)

    -- transport has picked up passenger and is enroute to drop passenger at destination
    assert.ferryRoute(1).has.serversReady(0, "Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.passengersWaiting(1, "Ferry route has one passenger waiting")

    assert.unit(storkUnitID).has.position({-190, nil, -800}, 100, "Transport has moved to the position where a pawn is waiting")
    assert.unit(storkUnitID).is.transportingUnit({pawn1UnitID, pawn2UnitID}, "Transport has picked up a pawn")

    local pawn1 = Spring.GetUnitIsTransporting(storkUnitID)[1]
    local pawn2 = pawn1 == pawn1UnitID and pawn2UnitID or pawn1UnitID

    -- wait for transport to drop a passenger
    Test.waitUntilCallinArgs("UnitUnloaded", { pawn1, nil, nil, nil, nil }, timeout)

    -- transport has dropped passenger and is enroute back to departure
    assert.ferryRoute(1).has.serversReady(0, "Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    assert.unit(pawn1).has.position({100, nil, -800}, 10, "First pawn is at the destination")
    assert.unit(pawn2).has.position({-190, nil, -800}, 100, "Second pawn is at departure")
    assert.unit(storkUnitID).has.position({100, nil, -800}, 10, "Transport is at the destination")
    assert.unit(storkUnitID).is_not.transportingUnit({pawn1UnitID, pawn2UnitID}, "Transporting is not carrying either pawn")

    -- remove second pawn from ferry route
    Spring.SelectUnit(pawn2)
    helpers.moveUnit(pawn2, -250, -800)

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(0, "Ferry route has no transports busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    -- wait for transport to return to departure
    Test.clearCallinBuffer()
    Test.waitUntilCallinArgs("UnitCmdDone", { storkUnitID, nil, nil, CMD.MOVE, nil, nil, nil }, timeout)

    assert.unit(pawn1).has.position({100, nil, -800}, 10, "First pawn is at the destination")
    assert.unit(pawn2).has.position({-250, nil, -800}, 10, "Second pawn is outside of the ferry route")
    assert.unit(storkUnitID).has.position({-100, nil, -800}, 100, "Transport is at the departure")
    assert.unit(storkUnitID).is_not.transportingUnit({pawn1UnitID, pawn2UnitID}, "Transporting is not carrying either pawn")

	Test.clearCallins()
end)

test("Transport Ferry Add Five Passengers With Two Transports Serving", function ()
	Test.expectCallin("UnitCmdDone")
	Test.expectCallin("UnitLoaded")
	Test.expectCallin("UnitUnloaded")

	-- make transport
	local stork1UnitID = helpers.spawnTransport("armatlas", 0, -800)
	local stork2UnitID = helpers.spawnTransport("armatlas", 0, -800)

	-- make ferry route by issuing move order then set ferry order
	Spring.SelectUnit(stork1UnitID)
	helpers.moveTransport(stork1UnitID, -200, -800)
	helpers.setFerry(widget, 300, -800, 200, false)

    -- add second transport to the ferry route
	Spring.SelectUnit(stork2UnitID)
	helpers.moveTransport(stork2UnitID, -200, -800)

	-- check that ferry route has been created
	assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with set ferry adds one item to global table of ferry routes")

	local newFerryRoute = widget.ferryRoutes[1]
	assert.table_has_fields({"serversReady", "serversBusy", "passengersWaiting"}, newFerryRoute)

    assert.ferryRoute(1).has.serversReady(2, "Ferry route has two transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(0, "Ferry route has no transports busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    -- make pawn
    local pawn1UnitID = helpers.spawnUnit("armpw", -50, -800)
    local pawn2UnitID = helpers.spawnUnit("armpw", -50, -800)
    local pawn3UnitID = helpers.spawnUnit("armpw", -50, -800)
    local pawn4UnitID = helpers.spawnUnit("armpw", -50, -800)
    local pawn5UnitID = helpers.spawnUnit("armpw", -50, -800)

    local pawnUnitIDs = { pawn1UnitID, pawn2UnitID, pawn3UnitID, pawn4UnitID, pawn5UnitID }

    -- add pawn as passenger by issuing move order to departure
    Spring.SelectUnit(pawn1UnitID)
    helpers.moveUnit(pawn1UnitID, -250, -800)
    Spring.SelectUnit(pawn2UnitID)
    helpers.moveUnit(pawn2UnitID, -250, -800)
    Spring.SelectUnit(pawn3UnitID)
    helpers.moveUnit(pawn3UnitID, -250, -800)
    Spring.SelectUnit(pawn4UnitID)
    helpers.moveUnit(pawn4UnitID, -250, -800)
    Spring.SelectUnit(pawn5UnitID)
    helpers.moveUnit(pawn5UnitID, -250, -800)

    -- wait for five pawns to arrive to departure (note: last arguments, count, is 5)
    Test.waitUntilCallin("UnitCmdDone", function (unitID, unitDefID, unitTeam, cmdID, cmdParams, options, cmdTag)
                for _,pawnUnitID in ipairs(pawnUnitIDs) do
                    if unitID == pawnUnitID then
                        return true
                    end
                end
                return false
            end, timeout, 5)

    -- pawn has arrived and transport has been ordered to pick it up
    assert.ferryRoute(1).has.serversReady(0, "Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(2, "Ferry route has two transports busy serving passengers")
    assert.ferryRoute(1).has.passengersWaiting(3, "Ferry route has three passengers waiting")

    assert.units(stork1UnitID, stork2UnitID).is_not.transportingUnits("Neither transport is carrying any units")

    -- wait for transports to pickup a passengers
    Test.waitUntilCallin("UnitLoaded", nil, timeout, 2)

    -- transport has picked up passenger and is enroute to drop passenger at destination
    assert.ferryRoute(1).has.serversReady(0, "Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(2, "Ferry route has two transports busy serving passengers")
    assert.ferryRoute(1).has.passengersWaiting(3, "Ferry route has one passenger waiting")

    assert.units(stork1UnitID, stork2UnitID).are.transportingUnits(2, "Transports are carrying a total of 2 units")

    -- wait for transports to drop passengers
    Test.waitUntilCallin("UnitUnloaded", nil, timeout, 2)

    -- transport have dropped passengers and are enroute back to departure
    assert.ferryRoute(1).has.serversReady(0, "Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(2, "Ferry route has two transports busy serving passengers")
    assert.ferryRoute(1).has.passengersWaiting(1, "Ferry route has one passenger waiting")

    assert.units(stork1UnitID, stork2UnitID).is_not.transportingUnits("Neither transport is carrying any units")

    -- wait for transports to pickup a passengers
    Test.waitUntilCallin("UnitLoaded", nil, timeout, 2)

    assert.ferryRoute(1).has.serversReady(0, "Ferry route has no transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(2, "Ferry route has two transports busy serving passengers")
    assert.ferryRoute(1).has.passengersWaiting(1, "Ferry route has one passenger waiting")

    assert.units(stork1UnitID, stork2UnitID).are.transportingUnits(2, "Transports are carrying a total of 2 units")

    -- wait for transports to drop passengers
    Test.waitUntilCallin("UnitUnloaded", nil, timeout, 2)

    -- transport have dropped passengers and are enroute back to departure
    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    assert.units(stork1UnitID, stork2UnitID).is_not.transportingUnits("Neither transport is carrying any units")

    -- wait for a transport to pickup the last passsenger
    Test.waitUntilCallin("UnitLoaded", nil, timeout)

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(1, "Ferry route has one transport busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

    -- wait for the last passenger to be dropped
    Test.waitUntilCallin("UnitUnloaded", nil, timeout)

    assert.ferryRoute(1).has.serversReady(2, "Ferry route has two transports ready to serve passengers")
    assert.ferryRoute(1).has.serversBusy(0, "Ferry route has no transports busy serving passengers")
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route has no passengers waiting")

	Test.clearCallins()
end)

test("Transport Ferry Add Passengers To Two Routes", function ()
	Test.expectCallin("UnitCmdDone")
	Test.expectCallin("UnitLoaded")
	Test.expectCallin("UnitUnloaded")

	-- make transport
	local stork1UnitID = helpers.spawnTransport("armatlas", 0, -800)
	local stork2UnitID = helpers.spawnTransport("armatlas", 0, -800)

	-- make ferry route by issuing move order then set ferry order
	Spring.SelectUnit(stork1UnitID)
	helpers.moveTransport(stork1UnitID, -100, -900)
	helpers.setFerry(widget, 100, -900, 100, false)

    -- create second ferry route with other transport
	Spring.SelectUnit(stork2UnitID)
	helpers.moveTransport(stork2UnitID, -100, -700)
	helpers.setFerry(widget, 100, -700, 100, false)

	-- check that two ferry routes have been created
	assert.is.equal(2, #widget.ferryRoutes)

    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route 1 has no passengers waiting")
    assert.ferryRoute(2).has.no.passengersWaiting("Ferry route 2 has no passengers waiting")

    -- make two pawns
    local pawn1UnitID = helpers.spawnUnit("armpw", -50, -900)
    local pawn2UnitID = helpers.spawnUnit("armpw", -50, -700)

    -- add pawns to ferry routes
    Spring.SelectUnit(pawn1UnitID)
    helpers.moveUnit(pawn1UnitID, -150, -900)
    Spring.SelectUnit(pawn2UnitID)
    helpers.moveUnit(pawn2UnitID, -150, -700)

    -- wait for pawns to arrive to departures
    Test.waitUntilCallin("UnitCmdDone", function (unitID, unitDefID, unitTeam, cmdID, cmdParams, options, cmdTag)
                return (unitID == pawn1UnitID) or (unitID == pawn2UnitID)
            end, timeout, 2)

    -- pawns have arrived and transports have been ordered to pick them up
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route 1 has no passengers waiting")
    assert.ferryRoute(2).has.no.passengersWaiting("Ferry route 2 has no passengers waiting")
    assert.units(stork1UnitID, stork2UnitID).is_not.transportingUnits("Neither transport is carrying any units")

    -- wait for transports to pickup a passengers
    Test.waitUntilCallin("UnitLoaded", nil, timeout, 2)

    -- transport has picked up passenger and is enroute to drop passenger at destination
    assert.units(stork1UnitID, stork2UnitID).are.transportingUnits(2, "Transports are carrying a total of 2 units")

    -- wait for transports to drop passengers
    Test.waitUntilCallin("UnitUnloaded", nil, timeout, 2)

    -- transport have dropped passengers and are enroute back to departure
    assert.ferryRoute(1).has.no.passengersWaiting("Ferry route 1 has no passengers waiting")
    assert.ferryRoute(2).has.no.passengersWaiting("Ferry route 2 has no passengers waiting")
    assert.units(stork1UnitID, stork2UnitID).is_not.transportingUnits("Neither transport is carrying any units")

	Test.clearCallins()
end)
