local helpers = VFS.Include("luaui/Widgets/Tests/cmd_transport_ferry/helpers.lua")

local widgetName = "Transport Ferry"
local delay = 5  -- TODO: what is this btw?

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

test("Transport Ferry Add Transport To Existing Ferry Route", function ()
	-- create a ferry route
	local stork1UnitID = helpers.spawnTransport()

	Spring.SelectUnit(stork1UnitID)
	helpers.moveTransport(stork1UnitID, -200, 0)
	helpers.setFerry(widget, 200, 0, 100, false)

	assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with set ferry adds one item to global table of ferry routes")

	local newFerryRoute = widget.ferryRoutes[1]
	assert.table_has_fields({"serversReady"}, newFerryRoute)

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")

    -- add second transport
	local stork2UnitID = helpers.spawnTransport()
	Spring.SelectUnit(stork2UnitID)
	helpers.moveTransport(stork2UnitID, -200, 0)

	assert.is.equal(1, #widget.ferryRoutes, "We have one ferry route after adding a transport to an existing ferry route")

    assert.ferryRoute(1).has.serversReady(2, "Ferry route has two transports ready to serve passengers")
end)

test("Transport Ferry Add Ten Transports To Three Ferry Routes", function ()
	-- make transports
    local storkUnitIDs = {}
    for i = 1,13 do
        storkUnitIDs[i] = helpers.spawnTransport()
    end

    -- create first ferry route
    Spring.SelectUnit(storkUnitIDs[1])
	helpers.moveTransport(storkUnitIDs[1], -200, -200)
	helpers.setFerry(widget, 200, -200, 100, false)

    -- create second ferry route
    Spring.SelectUnit(storkUnitIDs[2])
	helpers.moveTransport(storkUnitIDs[2], -200, 0)
	helpers.setFerry(widget, 200, 0, 100, false)

    -- create third ferry route
    Spring.SelectUnit(storkUnitIDs[3])
	helpers.moveTransport(storkUnitIDs[3], -200, 200)
	helpers.setFerry(widget, 200, 200, 100, false)

	-- check that three ferry routes have been created
	assert.is.equal(3, #widget.ferryRoutes, "Three ferry routes have been created")

	local ferryRoute1 = widget.ferryRoutes[1]
	assert.table_has_fields({"serversReady"}, ferryRoute1)
	local ferryRoute2 = widget.ferryRoutes[2]
	assert.table_has_fields({"serversReady"}, ferryRoute2)
	local ferryRoute3 = widget.ferryRoutes[3]
	assert.table_has_fields({"serversReady"}, ferryRoute3)

    assert.ferryRoute(1).has.serversReady(1, "Ferry route 1 has one transport ready to serve passengers")
    assert.ferryRoute(2).has.serversReady(1, "Ferry route 2 has one transport ready to serve passengers")
    assert.ferryRoute(3).has.serversReady(1, "Ferry route 3 has one transport ready to serve passengers")

	Spring.SelectUnit(storkUnitIDs[4])
	helpers.moveTransport(storkUnitIDs[4], -200, -200)
	Spring.SelectUnit(storkUnitIDs[5])
	helpers.moveTransport(storkUnitIDs[5], -200, 0)
	Spring.SelectUnit(storkUnitIDs[6])
	helpers.moveTransport(storkUnitIDs[6], -200, 200)

    assert.ferryRoute(1).has.serversReady(2, "Ferry route 1 has two transports ready to serve passengers")
    assert.ferryRoute(2).has.serversReady(2, "Ferry route 2 has two transports ready to serve passengers")
    assert.ferryRoute(3).has.serversReady(2, "Ferry route 3 has two transports ready to serve passengers")

	Spring.SelectUnit(storkUnitIDs[7])
	helpers.moveTransport(storkUnitIDs[7], -200, 0)
	Spring.SelectUnit(storkUnitIDs[8])
	helpers.moveTransport(storkUnitIDs[8], -200, 0)
	Spring.SelectUnit(storkUnitIDs[9])
	helpers.moveTransport(storkUnitIDs[9], -200, 0)

    assert.ferryRoute(1).has.serversReady(2, "Ferry route 1 has two transports ready to serve passengers")
    assert.ferryRoute(2).has.serversReady(5, "Ferry route 2 has five transports ready to serve passengers")
    assert.ferryRoute(3).has.serversReady(2, "Ferry route 3 has two transports ready to serve passengers")

	Spring.SelectUnit(storkUnitIDs[10])
	helpers.moveTransport(storkUnitIDs[10], -200, 200)
	Spring.SelectUnit(storkUnitIDs[11])
	helpers.moveTransport(storkUnitIDs[11], -200, 200)
	Spring.SelectUnit(storkUnitIDs[12])
	helpers.moveTransport(storkUnitIDs[12], -200, 200)
	Spring.SelectUnit(storkUnitIDs[13])
	helpers.moveTransport(storkUnitIDs[13], -200, 200)

    assert.ferryRoute(1).has.serversReady(2, "Ferry route 1 has two transports ready to serve passengers")
    assert.ferryRoute(2).has.serversReady(5, "Ferry route 2 has five transports ready to serve passengers")
    assert.ferryRoute(3).has.serversReady(6, "Ferry route 3 has six transports ready to serve passengers")
end)

test("Transport Ferry Remove Transport From Ferry Route", function ()
	-- create a ferry route
	local stork1UnitID = helpers.spawnTransport()

	Spring.SelectUnit(stork1UnitID)
	helpers.moveTransport(stork1UnitID, -200, 0)
	helpers.setFerry(widget, 200, 0, 100, false)

	assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with set ferry adds one item to global table of ferry routes")

	local newFerryRoute = widget.ferryRoutes[1]
	assert.table_has_fields({"serversReady"}, newFerryRoute)

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")

    -- add second transport
	local stork2UnitID = helpers.spawnTransport()
	Spring.SelectUnit(stork2UnitID)
	helpers.moveTransport(stork2UnitID, -200, 0)

	assert.is.equal(1, #widget.ferryRoutes, "We have one ferry route after adding a transport to an existing ferry route")
    assert.ferryRoute(1).has.serversReady(2, "Ferry route has two transports ready to serve passengers")

    -- remove second transport
	Spring.SelectUnit(stork2UnitID)
	helpers.moveTransport(stork2UnitID, -400, 0)

	assert.is.equal(1, #widget.ferryRoutes, "We have one ferry route after removing a transport from a ferry route with two transports")
    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")

    -- remove first transport
	Spring.SelectUnit(stork1UnitID)
	helpers.moveTransport(stork2UnitID, -400, 0)

	assert.is.equal(0, #widget.ferryRoutes, "We have no ferry routes left after removing last transport from the ferry route")
end)

test("Transport Ferry Add And Remove Transports Between Three Ferry Routes", function ()
	-- make transports
    local storkUnitIDs = {}
    for i = 1,13 do
        storkUnitIDs[i] = helpers.spawnTransport()
    end

    -- create first ferry route
    Spring.SelectUnit(storkUnitIDs[1])
	helpers.moveTransport(storkUnitIDs[1], -200, -200)
	helpers.setFerry(widget, 200, -200, 100, false)

    -- create second ferry route
    Spring.SelectUnit(storkUnitIDs[2])
	helpers.moveTransport(storkUnitIDs[2], -200, 0)
	helpers.setFerry(widget, 200, 0, 100, false)

    -- create third ferry route
    Spring.SelectUnit(storkUnitIDs[3])
	helpers.moveTransport(storkUnitIDs[3], -200, 200)
	helpers.setFerry(widget, 200, 200, 100, false)

	-- check that three ferry routes have been created
	assert.is.equal(3, #widget.ferryRoutes, "Three ferry routes have been created")

	local ferryRoute1 = widget.ferryRoutes[1]
	assert.table_has_fields({"serversReady"}, ferryRoute1)
	local ferryRoute2 = widget.ferryRoutes[2]
	assert.table_has_fields({"serversReady"}, ferryRoute2)
	local ferryRoute3 = widget.ferryRoutes[3]
	assert.table_has_fields({"serversReady"}, ferryRoute3)

    assert.ferryRoute(1).has.serversReady(1, "Ferry route 1 has one transport ready to serve passengers")
    assert.ferryRoute(2).has.serversReady(1, "Ferry route 2 has one transport ready to serve passengers")
    assert.ferryRoute(3).has.serversReady(1, "Ferry route 3 has one transport ready to serve passengers")

	Spring.SelectUnit(storkUnitIDs[4])
	helpers.moveTransport(storkUnitIDs[4], -200, -200)
	Spring.SelectUnit(storkUnitIDs[5])
	helpers.moveTransport(storkUnitIDs[5], -200, -200)
	Spring.SelectUnit(storkUnitIDs[6])
	helpers.moveTransport(storkUnitIDs[6], -200, -200)
	Spring.SelectUnit(storkUnitIDs[7])
	helpers.moveTransport(storkUnitIDs[7], -200, -200)
	Spring.SelectUnit(storkUnitIDs[8])
	helpers.moveTransport(storkUnitIDs[8], -200, 0)
	Spring.SelectUnit(storkUnitIDs[9])
	helpers.moveTransport(storkUnitIDs[9], -200, 0)
	Spring.SelectUnit(storkUnitIDs[10])
	helpers.moveTransport(storkUnitIDs[10], -200, 0)
	Spring.SelectUnit(storkUnitIDs[11])
	helpers.moveTransport(storkUnitIDs[11], -200, 200)
	Spring.SelectUnit(storkUnitIDs[12])
	helpers.moveTransport(storkUnitIDs[12], -200, 200)
	Spring.SelectUnit(storkUnitIDs[13])
	helpers.moveTransport(storkUnitIDs[13], -200, 200)

    assert.ferryRoute(1).has.serversReady(5, "Ferry route 1 has five transports ready to serve passengers")
    assert.ferryRoute(2).has.serversReady(4, "Ferry route 2 has four transports ready to serve passengers")
    assert.ferryRoute(3).has.serversReady(4, "Ferry route 3 has four transports ready to serve passengers")

	Spring.SelectUnit(storkUnitIDs[6])
	helpers.moveTransport(storkUnitIDs[6], -200, 200)
	Spring.SelectUnit(storkUnitIDs[7])
	helpers.moveTransport(storkUnitIDs[7], -200, 200)
	Spring.SelectUnit(storkUnitIDs[8])
	helpers.moveTransport(storkUnitIDs[8], -200, 200)
	Spring.SelectUnit(storkUnitIDs[9])
	helpers.moveTransport(storkUnitIDs[9], -200, 200)
	Spring.SelectUnit(storkUnitIDs[10])
	helpers.moveTransport(storkUnitIDs[10], -200, 200)

    assert.ferryRoute(1).has.serversReady(3, "Ferry route 1 has three transports ready to serve passengers")
    assert.ferryRoute(2).has.serversReady(1, "Ferry route 2 has one transport ready to serve passengers")
    assert.ferryRoute(3).has.serversReady(9, "Ferry route 3 has nine transports ready to serve passengers")

	Spring.SelectUnit(storkUnitIDs[6])
	helpers.moveTransport(storkUnitIDs[6], -200, 0)
	Spring.SelectUnit(storkUnitIDs[7])
	helpers.moveTransport(storkUnitIDs[7], -200, 0)
	Spring.SelectUnit(storkUnitIDs[8])
	helpers.moveTransport(storkUnitIDs[8], -200, 0)
	Spring.SelectUnit(storkUnitIDs[9])
	helpers.moveTransport(storkUnitIDs[9], -200, 0)
	Spring.SelectUnit(storkUnitIDs[10])
	helpers.moveTransport(storkUnitIDs[10], -200, 0)
	Spring.SelectUnit(storkUnitIDs[11])
	helpers.moveTransport(storkUnitIDs[11], -200, 0)
	Spring.SelectUnit(storkUnitIDs[12])
	helpers.moveTransport(storkUnitIDs[12], -200, 0)
	Spring.SelectUnit(storkUnitIDs[13])
	helpers.moveTransport(storkUnitIDs[13], -200, 0)

    assert.ferryRoute(1).has.serversReady(3, "Ferry route 1 has three transports ready to serve passengers")
    assert.ferryRoute(2).has.serversReady(9, "Ferry route 2 has nine transports ready to serve passengers")
    assert.ferryRoute(3).has.serversReady(1, "Ferry route 3 has one transport ready to serve passengers")
end)
