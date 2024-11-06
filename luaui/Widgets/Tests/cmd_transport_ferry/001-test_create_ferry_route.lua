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

test("Transport Ferry Create Ferry Route Simple", function ()
	-- make transport
	local storkUnitID = helpers.spawnTransport()

	-- make ferry route by issuing move order then set ferry order
	Spring.SelectUnit(storkUnitID)
	helpers.moveTransport(storkUnitID, -100, -100)
	helpers.setFerry(widget, -100, 100, 100, false)

	-- check that ferry route has been created
	assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with set ferry adds one item to global table of ferry routes")

	local newFerryRoute = widget.ferryRoutes[1]
	assert.table_has_fields({"destination", "zones"}, newFerryRoute)

	assert.ferryRoute(1).has.zoneCount(2, "Newly created ferry route has two zones")

	local newFerryRouteDestination = newFerryRoute.destination
	assert.is.equal(1, #newFerryRouteDestination.previousZones, "Destination has one previous zone")

	local newFerryRouteDeparture = newFerryRouteDestination.previousZones[1]
	assert.is.equals(newFerryRouteDestination, newFerryRouteDeparture.nextZone, "Next zone from departure is destination")

	assert.is.zone_coordinates(-100, -100, newFerryRouteDeparture, "Departure coordinates are correct")
	assert.is.zone_coordinates(-100, 100, newFerryRouteDestination, "Destination coordinates are correct")
end)

test("Transport Ferry Create Ferry Route Simple (using shift)", function ()
	-- make transport
	local storkUnitID = helpers.spawnTransport()

	-- make ferry route by issuing move order then set ferry order
	Spring.SelectUnit(storkUnitID)
	helpers.moveTransport(storkUnitID, -100, -100)
	helpers.setFerry(widget, -100, 100, 100, true)

	-- check that ferry route has been created
	assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with set ferry adds one item to global table of ferry routes")

	local newFerryRoute = widget.ferryRoutes[1]
	assert.table_has_fields({"destination", "zones"}, newFerryRoute)

	assert.is.equal(2, #newFerryRoute.zones, "Newly created ferry route has two zones")

	local newFerryRouteDestination = newFerryRoute.destination
	assert.is.equal(1, #newFerryRouteDestination.previousZones, "Destination has one previous zone")

	local newFerryRouteDeparture = newFerryRouteDestination.previousZones[1]
	assert.is.equals(newFerryRouteDestination, newFerryRouteDeparture.nextZone, "Next zone from departure is destination")

	assert.is.zone_coordinates(-100, -100, newFerryRouteDeparture, "Departure coordinates are correct")
	assert.is.zone_coordinates(-100, 100, newFerryRouteDestination, "Destination coordinates are correct")
end)

test("Transport Ferry Create Ferry Route Three Zones", function ()
	-- make transport
	local storkUnitID = helpers.spawnTransport()

	-- make ferry route by issuing move order then set ferry order
	Spring.SelectUnit(storkUnitID)
	helpers.moveTransport(storkUnitID, 0, -200)
	helpers.setFerry(widget, 0, 0, 100, true)
	helpers.setFerry(widget, 0, 200, 100, false)

	-- check that ferry route has been created
	assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with set ferry adds one item to global table of ferry routes")

	local newFerryRoute = widget.ferryRoutes[1]
	assert.table_has_fields({"destination", "zones"}, newFerryRoute)

	assert.is.equal(3, #newFerryRoute.zones, "Newly created ferry route has three zones")

	local newFerryRouteDestination = newFerryRoute.destination
	assert.is.equal(1, #newFerryRouteDestination.previousZones, "Destination has one previous zone")

	local newFerryRouteDeparture2 = newFerryRouteDestination.previousZones[1]
	assert.is.equal(1, #newFerryRouteDeparture2.previousZones, "Departure 2 has one previous zone")

	local newFerryRouteDeparture1 = newFerryRouteDeparture2.previousZones[1]
	assert.is.equals(newFerryRouteDeparture2, newFerryRouteDeparture1.nextZone, "Next zone from departure 1 is departure 2")
	assert.is.equals(newFerryRouteDestination, newFerryRouteDeparture2.nextZone, "Next zone from departure 2 is destination")

	assert.is.zone_coordinates(0, -200, newFerryRouteDeparture1, "Departure 1 coordinates are correct")
	assert.is.zone_coordinates(0, 0, newFerryRouteDeparture2, "Departure 2 coordinates are correct")
	assert.is.zone_coordinates(0, 200, newFerryRouteDestination, "Destination coordinates are correct")
end)

test("Transport Ferry Create Ferry Route Two Previous Zones", function ()
	-- make transports
	local stork1UnitID = helpers.spawnTransport()
	local stork2UnitID = helpers.spawnTransport()

	-- make ferry routes by issuing move order then set ferry order
	Spring.SelectUnit(stork1UnitID)
	helpers.moveTransport(stork1UnitID, -200, -200)
	helpers.setFerry(widget, 200, 0, 100, false)

	assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with set ferry adds one item to global table of ferry routes")

	Spring.SelectUnit(stork2UnitID)
	helpers.moveTransport(stork2UnitID, -200, 200)
	helpers.setFerry(widget, 200, 0, 100, false)

	assert.is.equal(1, #widget.ferryRoutes, "Adding a path to existing ferry route did not create a new ferry route")

	local newFerryRoute = widget.ferryRoutes[1]
	assert.table_has_fields({"destination", "zones"}, newFerryRoute)

	assert.is.equal(3, #newFerryRoute.zones, "Newly created ferry route has three zones")

	local newFerryRouteDestination = newFerryRoute.destination
	assert.is.equal(2, #newFerryRouteDestination.previousZones, "Destination has two previous zones")

	local newFerryRouteDeparture1 = newFerryRouteDestination.previousZones[1]
	assert.is.equal(0, #newFerryRouteDeparture1.previousZones, "Departure 1 has no previous zones")
	assert.is.equals(newFerryRouteDestination, newFerryRouteDeparture1.nextZone, "Departure 1 next zone is destination")

	local newFerryRouteDeparture2 = newFerryRouteDestination.previousZones[2]
	assert.is.equal(0, #newFerryRouteDeparture1.previousZones, "Departure 2 has no previous zones")
	assert.is.equals(newFerryRouteDestination, newFerryRouteDeparture2.nextZone, "Departure 2 next zone is destination")

	assert.is.zone_coordinates(-200, -200, newFerryRouteDeparture1, "Departure 1 coordinates are correct")
	assert.is.zone_coordinates(-200, 200, newFerryRouteDeparture2, "Departure 2 coordinates are correct")
	assert.is.zone_coordinates(200, 0, newFerryRouteDestination, "Destination coordinates are correct")
end)

test("Transport Ferry Create Ferry Route Two Previous Zones (using shift)", function ()
	-- make transports
	local stork1UnitID = helpers.spawnTransport()
	local stork2UnitID = helpers.spawnTransport()

	-- make ferry routes by issuing move order then set ferry order
	Spring.SelectUnit(stork1UnitID)
	helpers.moveTransport(stork1UnitID, -200, -200)
	helpers.setFerry(widget, 200, 0, 100, true)
	widget:KeyRelease(keyShift)

	assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with set ferry adds one item to global table of ferry routes")

	Spring.SelectUnit(stork2UnitID)
	helpers.moveTransport(stork2UnitID, -200, 200)
	helpers.setFerry(widget, 200, 0, 100, true)
	widget:KeyRelease(keyShift)

	assert.is.equal(1, #widget.ferryRoutes, "Adding a path to existing ferry route did not create a new ferry route")

	local newFerryRoute = widget.ferryRoutes[1]
	assert.table_has_fields({"destination", "zones"}, newFerryRoute)

	assert.is.equal(3, #newFerryRoute.zones, "Newly created ferry route has three zones")

	local newFerryRouteDestination = newFerryRoute.destination
	assert.is.equal(2, #newFerryRouteDestination.previousZones, "Destination has two previous zones")

	local newFerryRouteDeparture1 = newFerryRouteDestination.previousZones[1]
	assert.is.equal(0, #newFerryRouteDeparture1.previousZones, "Departure 1 has no previous zones")
	assert.is.equals(newFerryRouteDestination, newFerryRouteDeparture1.nextZone, "Departure 1 next zone is destination")

	local newFerryRouteDeparture2 = newFerryRouteDestination.previousZones[2]
	assert.is.equal(0, #newFerryRouteDeparture1.previousZones, "Departure 2 has no previous zones")
	assert.is.equals(newFerryRouteDestination, newFerryRouteDeparture2.nextZone, "Departure 2 next zone is destination")

	assert.is.zone_coordinates(-200, -200, newFerryRouteDeparture1, "Departure 1 coordinates are correct")
	assert.is.zone_coordinates(-200, 200, newFerryRouteDeparture2, "Departure 2 coordinates are correct")
	assert.is.zone_coordinates(200, 0, newFerryRouteDestination, "Destination coordinates are correct")
end)

--[[
	This test creates a ferry route comprised of several leaves on multiple layers.

			A  ->   B
						\
	C  ->   D  ->   E  ->  F
		/			   /
	G	   H  ->   I
			J   /
]]
test("Transport Ferry Create Ferry Route Involved", function ()
	-- make transports
	local stork1UnitID = helpers.spawnTransport()
	local stork2UnitID = helpers.spawnTransport()
	local stork3UnitID = helpers.spawnTransport()
	local stork4UnitID = helpers.spawnTransport()
	local stork5UnitID = helpers.spawnTransport()

	-- make ferry route by issuing move order then set ferry order
	Spring.SelectUnit(stork1UnitID)
	helpers.moveTransport(stork1UnitID, -400, -200)	 -- A
	helpers.setFerry(widget, -200, -200, 100, true)	 -- B
	helpers.setFerry(widget, 0, 0, 100, false)		  -- F

	assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with ferry route adds one item to global table of ferry routes")

	Spring.SelectUnit(stork2UnitID)
	helpers.moveTransport(stork2UnitID, -600, 0)	-- C
	helpers.setFerry(widget, -400, 0, 100, true)	-- D
	helpers.setFerry(widget, -200, 0, 100, true)	-- E
	helpers.setFerry(widget, 0, 0, 100, false)	  -- F

	assert.is.equal(1, #widget.ferryRoutes, "Adding a path to existing ferry route did not create a new ferry route")

	Spring.SelectUnit(stork3UnitID)
	helpers.moveTransport(stork3UnitID, -600, 200)  -- G
	helpers.setFerry(widget, -400, 0, 100, true)	-- D

	assert.is.equal(1, #widget.ferryRoutes, "Adding a path to existing ferry route did not create a new ferry route")

	Spring.SelectUnit(stork4UnitID)
	helpers.moveTransport(stork4UnitID, -400, 200)	  -- H
	helpers.setFerry(widget, -200, 200, 100, true)	  -- I
	helpers.setFerry(widget, 0, 0, 100, false)		  -- F

	assert.is.equal(1, #widget.ferryRoutes, "Adding a path to existing ferry route did not create a new ferry route")

	Spring.SelectUnit(stork5UnitID)
	helpers.moveTransport(stork5UnitID, -400, 400)	  -- J
	helpers.setFerry(widget, -200, 200, 100, false)	 -- I

	assert.is.equal(1, #widget.ferryRoutes, "Adding a path to existing ferry route did not create a new ferry route")

	local newFerryRoute = widget.ferryRoutes[1]
	assert.table_has_fields({"destination", "zones"}, newFerryRoute)

	assert.is.equal(10, #newFerryRoute.zones, "Newly created ferry route has ten zones")

	local newFerryRouteDestination = newFerryRoute.destination
	assert.is.equal(3, #newFerryRouteDestination.previousZones, "Destination has three previous zones")

	-- first branch
	local newFerryRouteDepartureB = newFerryRouteDestination.previousZones[1]
	assert.is.equal(1, #newFerryRouteDepartureB.previousZones, "Departure B has one previous zone")
	assert.is.equals(newFerryRouteDestination, newFerryRouteDepartureB.nextZone, "Departure B next zone is destination")

	local newFerryRouteDepartureA = newFerryRouteDepartureB.previousZones[1]
	assert.is.equal(0, #newFerryRouteDepartureA.previousZones, "Departure A has no previous zones")
	assert.is.equals(newFerryRouteDepartureB, newFerryRouteDepartureA.nextZone, "Departure A next zone is departure B")

	-- second branch
	local newFerryRouteDepartureE = newFerryRouteDestination.previousZones[2]
	assert.is.equal(1, #newFerryRouteDepartureE.previousZones, "Departure E has one previous zone")
	assert.is.equals(newFerryRouteDestination, newFerryRouteDepartureE.nextZone, "Departure E next zone is destination")

	local newFerryRouteDepartureD = newFerryRouteDepartureE.previousZones[1]
	assert.is.equal(2, #newFerryRouteDepartureD.previousZones, "Departure D has two previous zones")
	assert.is.equals(newFerryRouteDepartureE, newFerryRouteDepartureD.nextZone, "Departure D next zone is departure E")

	local newFerryRouteDepartureC = newFerryRouteDepartureD.previousZones[1]
	assert.is.equal(0, #newFerryRouteDepartureC.previousZones, "Departure C has no previous zones")
	assert.is.equals(newFerryRouteDepartureD, newFerryRouteDepartureC.nextZone, "Departure C next zone is departure D")

	local newFerryRouteDepartureG = newFerryRouteDepartureD.previousZones[2]
	assert.is.equal(0, #newFerryRouteDepartureG.previousZones, "Departure G has no previous zones")
	assert.is.equals(newFerryRouteDepartureD, newFerryRouteDepartureG.nextZone, "Departure G next zone is departure D")

	-- third branch
	local newFerryRouteDepartureI = newFerryRouteDestination.previousZones[3]
	assert.is.equal(2, #newFerryRouteDepartureI.previousZones, "Departure I has two previous zones")
	assert.is.equals(newFerryRouteDestination, newFerryRouteDepartureI.nextZone, "Departure I next zone is destination")

	local newFerryRouteDepartureH = newFerryRouteDepartureI.previousZones[1]
	assert.is.equal(0, #newFerryRouteDepartureH.previousZones, "Departure H has no previous zones")
	assert.is.equals(newFerryRouteDepartureI, newFerryRouteDepartureH.nextZone, "Departure H next zone is departure I")

	local newFerryRouteDepartureJ = newFerryRouteDepartureI.previousZones[2]
	assert.is.equal(0, #newFerryRouteDepartureJ.previousZones, "Departure J has no previous zones")
	assert.is.equals(newFerryRouteDepartureI, newFerryRouteDepartureJ.nextZone, "Departure J next zone is departure I")

	assert.is.zone_coordinates(-400, -200, newFerryRouteDepartureA, "Departure A coordinates are correct")
	assert.is.zone_coordinates(-200, -200, newFerryRouteDepartureB, "Departure B coordinates are correct")
	assert.is.zone_coordinates(-600, 0, newFerryRouteDepartureC, "Departure C coordinates are correct")
	assert.is.zone_coordinates(-400, 0, newFerryRouteDepartureD, "Departure D coordinates are correct")
	assert.is.zone_coordinates(-200, 0, newFerryRouteDepartureE, "Departure E coordinates are correct")
	assert.is.zone_coordinates(-600, 200, newFerryRouteDepartureG, "Departure G coordinates are correct")
	assert.is.zone_coordinates(-400, 200, newFerryRouteDepartureH, "Departure H coordinates are correct")
	assert.is.zone_coordinates(-200, 200, newFerryRouteDepartureI, "Departure I coordinates are correct")
	assert.is.zone_coordinates(-400, 400, newFerryRouteDepartureJ, "Departure J coordinates are correct")
	assert.is.zone_coordinates(0, 0, newFerryRouteDestination, "Destination coordinates are correct")
end)

test("Transport Ferry Create Two Separate Ferry Routes", function ()
	-- make transports
	local stork1UnitID = helpers.spawnTransport()
	local stork2UnitID = helpers.spawnTransport()

    -- create first ferry route
    Spring.SelectUnit(stork1UnitID)
	helpers.moveTransport(stork1UnitID, -200, -200)
	helpers.setFerry(widget, 200, -200, 100, false)

	-- check that a ferry routes has been created
	assert.is.equal(1, #widget.ferryRoutes, "One ferry routes have been created")

    -- create second ferry route
    Spring.SelectUnit(stork2UnitID)
	helpers.moveTransport(stork2UnitID, -200, 200)
	helpers.setFerry(widget, 200, 200, 100, false)

	-- check that two ferry routes have been created
	assert.is.equal(2, #widget.ferryRoutes, "Two ferry routes have been created")

	local ferryRoute1 = widget.ferryRoutes[1]
	assert.table_has_fields({"destination", "zones"}, ferryRoute1)
	local ferryRoute2 = widget.ferryRoutes[2]
	assert.table_has_fields({"destination", "zones"}, ferryRoute2)

	assert.is.equal(2, #ferryRoute1.zones, "Ferry route 1 has two zones")
	assert.is.equal(2, #ferryRoute2.zones, "Ferry route 2 has two zones")

    -- ferry route 1
	local ferryRoute1Destination = ferryRoute1.destination
	assert.is.equal(1, #ferryRoute1Destination.previousZones, "Ferry route 1 destination has one previous zone")

	local ferryRoute1Departure = ferryRoute1Destination.previousZones[1]
	assert.is.equal(0, #ferryRoute1Departure.previousZones, "Ferry route 1 departure has no previous zones")
	assert.is.equals(ferryRoute1Destination, ferryRoute1Departure.nextZone, "Ferry route 1 departure next zone is destination")

	assert.is.zone_coordinates(-200, -200, ferryRoute1Departure, "Ferry route 1 departure coordinates are correct")
	assert.is.zone_coordinates(200, -200, ferryRoute1Destination, "Ferry route 1 destination coordinates are correct")

    -- ferry route 2
	local ferryRoute2Destination = ferryRoute2.destination
	assert.is.equal(1, #ferryRoute2Destination.previousZones, "Ferry route 2 destination has one previous zone")

	local ferryRoute2Departure = ferryRoute2Destination.previousZones[1]
	assert.is.equal(0, #ferryRoute2Departure.previousZones, "Ferry route 2 departure has no previous zones")
	assert.is.equals(ferryRoute2Destination, ferryRoute2Departure.nextZone, "Ferry route 2 departure next zone is destination")

	assert.is.zone_coordinates(-200, 200, ferryRoute2Departure, "Ferry route 2 departure coordinates are correct")
	assert.is.zone_coordinates(200, 200, ferryRoute2Destination, "Ferry route 2 destination coordinates are correct")
end)

test("Transport Ferry Create Ferry Route Using Two Transports", function ()
	-- make transports
	local stork1UnitID = helpers.spawnTransport()
	local stork2UnitID = helpers.spawnTransport()

    -- move transports to different places
	helpers.moveTransport(stork1UnitID, -100, -200)
	helpers.moveTransport(stork2UnitID, 100, 0)

	-- make ferry route
	Spring.SelectUnitArray({stork1UnitID, stork2UnitID})
	helpers.setFerry(widget, 100, 100, 100, false)

	-- check that ferry route has been created
	assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with set ferry adds one item to global table of ferry routes")

	local newFerryRoute = widget.ferryRoutes[1]
	assert.table_has_fields({"destination", "zones", "serversReady"}, newFerryRoute)

	assert.is.equal(2, #newFerryRoute.zones, "Newly created ferry route has two zones")

	local newFerryRouteDestination = newFerryRoute.destination
	assert.is.equal(1, #newFerryRouteDestination.previousZones, "Destination has one previous zone")

	local newFerryRouteDeparture = newFerryRouteDestination.previousZones[1]
	assert.is.equals(newFerryRouteDestination, newFerryRouteDeparture.nextZone, "Next zone from departure is destination")

	assert.is.zone_coordinates(0, -100, newFerryRouteDeparture, "Departure coordinates are correct")
	assert.is.zone_coordinates(100, 100, newFerryRouteDestination, "Destination coordinates are correct")

    assert.is.equal(2, #newFerryRoute.serversReady, "Ferry route has two transports ready to serve passengers")
end)
