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

test("Transport Ferry Routing Two Branches", function ()
	Test.expectCallin("UnitCmdDone")
	Test.expectCallin("UnitLoaded")
	Test.expectCallin("UnitUnloaded")

	local stork1UnitID = helpers.spawnTransport("armatlas", 0, -600)
	local stork2UnitID = helpers.spawnTransport("armatlas", 0, -600)

	-- make ferry route
	Spring.SelectUnit(stork1UnitID)
	helpers.moveTransport(stork1UnitID, -400, -800)
	helpers.setFerry(widget, 0, -800, 100, true)
	helpers.setFerry(widget, 400, -600, 100, false)

	Spring.SelectUnit(stork2UnitID)
	helpers.moveTransport(stork2UnitID, -400, -400)
	helpers.setFerry(widget, 0, -400, 100, true)
	helpers.setFerry(widget, 400, -600, 100, false)

	-- check that ferry route has been created
	assert.is.equal(1, #widget.ferryRoutes, "Ferry route created")

    -- wait for transports to move to departures
    Test.waitUntilCallin("UnitCmdDone", nil, timeout, 2)

    -- make pawns
    local pawn1UnitID = helpers.spawnUnit("armpw", 0, -600)
    local pawn2UnitID = helpers.spawnUnit("armpw", 0, -600)

    -- move pawns to first departures
    Spring.SelectUnit(pawn1UnitID)
    helpers.moveUnit(pawn1UnitID, -350, -800)
    Spring.SelectUnit(pawn2UnitID)
    helpers.moveUnit(pawn2UnitID, -350, -400)

    -- wait for transports to pickup passengers
    Test.waitUntilCallin("UnitLoaded", nil, timeout, 2)

    -- check that transports are routed correctly
    assert.unit(stork1UnitID).has.moveCommand({0, nil, -800}, "Transport 1 has move command to second departure")
    assert.unit(stork1UnitID).has.moveCommand({400, nil, -600}, 100, "Transport 1 has move command to destination")
    assert.unit(stork2UnitID).has.moveCommand({0, nil, -400}, "Transport 2 has move command to second departure")
    assert.unit(stork2UnitID).has.moveCommand({400, nil, -600}, 100, "Transport 2 has move command to destination")

    -- wait for transports to drop passengers
    Test.waitUntilCallin("UnitUnloaded", nil, timeout, 2)

    -- check that transports are routed correctly
    assert.unit(stork1UnitID).has.moveCommand({0, nil, -800}, "Transport 1 has move command to second departure")
    assert.unit(stork1UnitID).has.moveCommand({-400, nil, -800}, "Transport 1 has move command to first departure")
    assert.unit(stork2UnitID).has.moveCommand({0, nil, -400}, "Transport 2 has move command to second departure")
    assert.unit(stork2UnitID).has.moveCommand({-400, nil, -400}, "Transport 2 has move command to first departure")

	Test.clearCallins()
end)

test("Transport Ferry Routing Two Branches One Transport", function ()
	Test.expectCallin("UnitCmdDone")
	Test.expectCallin("UnitLoaded")
	Test.expectCallin("UnitUnloaded")

	local storkUnitID = helpers.spawnTransport("armatlas", 0, -600)
	local stork2UnitID = helpers.spawnTransport("armatlas", 0, -600)

	-- make ferry route
	Spring.SelectUnit(storkUnitID)
	helpers.moveTransport(storkUnitID, -400, -800)
	helpers.setFerry(widget, 0, -800, 100, true)
	helpers.setFerry(widget, 400, -600, 100, false)

	Spring.SelectUnit(stork2UnitID)
	helpers.moveTransport(stork2UnitID, -400, -400)
	helpers.setFerry(widget, 0, -400, 100, true)
	helpers.setFerry(widget, 400, -600, 100, false)

	-- check that ferry route has been created
	assert.is.equal(1, #widget.ferryRoutes, "Ferry route created")

    -- remove second transport
	Spring.SelectUnit(stork2UnitID)
	helpers.moveTransport(stork2UnitID, 0, -1000)

	-- check that ferry route wasn't removed
	assert.is.equal(1, #widget.ferryRoutes, "There's one ferry route")
    assert.ferryRoute(1).has.zoneCount(5, "Ferry route has 5 zones")

    -- wait for transport to move to departure
    Test.waitUntilCallin("UnitCmdDone", function (unitID, unitDefID, unitTeam, cmdID, cmdParams, options, cmdTag)
                return unitID == storkUnitID
            end, timeout)

    -- make two pawns with pawn 1 closer to departure than pawn 2
    local pawn1UnitID = helpers.spawnUnit("armpw", -200, -600)
    local pawn2UnitID = helpers.spawnUnit("armpw", 200, -600)

    -- move pawns to departures, pawn 1 to second branch and pawn 2 to first branch
    Spring.SelectUnit(pawn1UnitID)
    helpers.moveUnit(pawn1UnitID, -350, -400)
    Spring.SelectUnit(pawn2UnitID)
    helpers.moveUnit(pawn2UnitID, -350, -800)

    -- wait for pawn to move to departure
    Test.waitUntilCallin("UnitCmdDone", function (unitID, unitDefID, unitTeam, cmdID, cmdParams, options, cmdTag)
                return unitID == pawn1UnitID
            end, timeout)

    -- check that transport is routed correctly
    assert.unit(storkUnitID).has.moveCommand({0, nil, -800}, "Transport has move command to second departure of first branch")
    assert.unit(storkUnitID).has.moveCommand({400, nil, -600}, "Transport has move command to destination")
    assert.unit(storkUnitID).has.moveCommand({0, nil, -400}, "Transport has move command to second departure of second branch")
    assert.unit(storkUnitID).has.moveCommand({-400, nil, -400}, 100, "Transport has move command to first departure of second branch")

    -- wait for transport to pickup first passenger
    Test.waitUntilCallin("UnitLoaded", nil, timeout)

    assert.unit(storkUnitID).has.moveCommand({0, nil, -400}, "Transport has move command to second departure of second branch")
    assert.unit(storkUnitID).has.moveCommand({400, nil, -600}, 100, "Transport has move command to destination")

    -- wait for transports to drop passenger
    Test.waitUntilCallin("UnitUnloaded", nil, timeout)

    -- check that transport is routed correctly
    assert.unit(storkUnitID).has.moveCommand({0, nil, -800}, "Transport has move command to second departure of first branch")
    assert.unit(storkUnitID).has.moveCommand({-400, nil, -800}, 100, "Transport has move command to first departure of first branch")

    -- wait for transport to pickup first passenger
    Test.waitUntilCallin("UnitLoaded", nil, timeout)

    assert.unit(storkUnitID).has.moveCommand({0, nil, -800}, "Transport has move command to second departure of first branch")
    assert.unit(storkUnitID).has.moveCommand({400, nil, -600}, 100, "Transport has move command to destination")

    -- wait for transports to drop passenger
    Test.waitUntilCallin("UnitUnloaded", nil, timeout)

    -- check that transport is routed correctly
    assert.unit(storkUnitID).has.moveCommand({0, nil, -800}, "Transport has move command to second departure of first branch")
    assert.unit(storkUnitID).has.moveCommand({-400, nil, -800}, "Transport has move command to first departure of first branch")

	Test.clearCallins()
end)
