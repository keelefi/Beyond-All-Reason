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

test("Transport Ferry Heavy Transport Create Ferry Route", function ()
	-- create a ferry route
	local abductorUnitID = helpers.spawnTransport("armdfly")

	Spring.SelectUnit(abductorUnitID)
	helpers.moveTransport(abductorUnitID, -200, 0)
	helpers.setFerry(widget, 200, 0, 100, false)

	assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with set ferry adds one item to global table of ferry routes")

	assert.table_has_fields({"heavyTransportCount"}, widget.ferryRoutes[1])

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.heavyServersReady(1, "Ferry route has one heavy transport ready to serve passengers")
end)

test("Transport Ferry Heavy Transport Add To Ferry Route Create With Light Transport", function ()
	-- create a ferry route
	local storkUnitID = helpers.spawnTransport("armatlas")

	Spring.SelectUnit(storkUnitID)
	helpers.moveTransport(storkUnitID, -200, 0)
	helpers.setFerry(widget, 200, 0, 100, false)

	assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with set ferry adds one item to global table of ferry routes")

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.no.heavyServersReady("Ferry route has no heavy transports ready to serve passengers")

    -- create heavy transport
	local abductorUnitID = helpers.spawnTransport("armdfly")

	Spring.SelectUnit(abductorUnitID)
	helpers.moveTransport(abductorUnitID, -200, 0)

	assert.is.equal(1, #widget.ferryRoutes, "There is one ferry route")

    assert.ferryRoute(1).has.serversReady(2, "Ferry route has two transports ready to serve passengers")
    assert.ferryRoute(1).has.heavyServersReady(1, "Ferry route has one heavy transport ready to serve passengers")
end)

test("Transport Ferry Heavy Transport Add To Ferry Route Created With Heavy Transport", function ()
	-- create a ferry route
	local abductor1UnitID = helpers.spawnTransport("armdfly")

	Spring.SelectUnit(abductor1UnitID)
	helpers.moveTransport(abductor1UnitID, -200, 0)
	helpers.setFerry(widget, 200, 0, 100, false)

	assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with set ferry adds one item to global table of ferry routes")

    assert.ferryRoute(1).has.serversReady(1, "Ferry route has one transport ready to serve passengers")
    assert.ferryRoute(1).has.heavyServersReady(1, "Ferry route has one heavy transport ready to serve passengers")

    -- create heavy transport
	local abductorUnitID = helpers.spawnTransport("armdfly")

	Spring.SelectUnit(abductorUnitID)
	helpers.moveTransport(abductorUnitID, -200, 0)

	assert.is.equal(1, #widget.ferryRoutes, "There is one ferry route")

    assert.ferryRoute(1).has.serversReady(2, "Ferry route has two transports ready to serve passengers")
    assert.ferryRoute(1).has.heavyServersReady(2, "Ferry route has two heavy transports ready to serve passengers")
end)
