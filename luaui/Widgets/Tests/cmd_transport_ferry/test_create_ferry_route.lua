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
end

function cleanup()
	Test.clearMap()

	Spring.SetCameraState(initialCameraState)
end

test("Transport Ferry Create Ferry Route Simple", function ()
	VFS.Include("luarules/configs/customcmds.h.lua")

	widget = widgetHandler:FindWidget(widgetName)
	assert(widget)

    widget.removeAllFerryRoutes()
    assert(#widget.ferryRoutes == 0)

	local myTeamID = Spring.GetMyTeamID()
	local x, z = Game.mapSizeX / 2, Game.mapSizeZ / 2
	local y = Spring.GetGroundHeight(x, z)
	local facing = 1

    -- make transport
    local storkUnitDefName = "armatlas"
	local storkUnitID = SyncedRun(function(locals)
		return Spring.CreateUnit(
			locals.storkUnitDefName,
			locals.x,
			locals.y,
			locals.z,
			locals.facing,
			locals.myTeamID
		)
	end)

    -- make ferry route by issuing move order then set ferry order
    Spring.SelectUnit(storkUnitID)
	--Spring.GiveOrderToUnit(storkUnitID, CMD.MOVE, { x - 100, y, z - 100 }, 0)
    SyncedRun(function (locals)
	    Spring.GiveOrderToUnit(locals.storkUnitID, CMD.MOVE, { locals.x - 100, locals.y, locals.z - 100 }, 0)
    end)
	--widget:CommandNotify(CMD.MOVE, { x - 100, y, z - 100 }, {})
	--Spring.GiveOrderToUnit(storkUnitID, CMD_SET_FERRY, { x - 100, y, z + 100, 100 }, CMD.OPT_SHIFT)
	widget:CommandNotify(CMD_SET_FERRY, { x - 100, y, z + 100, 100 }, {})

    -- check that ferry route has been created
    assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with ferry route adds one item to global table of ferry routes")

    local newFerryRoute = widget.ferryRoutes[1]
    assert.table_has_fields({"destination", "zones"}, newFerryRoute)

    assert.is.equal(2, #newFerryRoute.zones, "Newly created ferry route has two zones")

    local newFerryRouteDestination = newFerryRoute.destination
    assert.is.equal(1, #newFerryRouteDestination.previousZones, "Destination has one previous zone")

    local newFerryRouteDeparture = newFerryRouteDestination.previousZones[1]
    assert.is.equals(newFerryRouteDestination, newFerryRouteDeparture.nextZone, "Next zone from departure is destination")
end)

test("Transport Ferry Create Ferry Route Simple (using shift)", function ()
	VFS.Include("luarules/configs/customcmds.h.lua")

	widget = widgetHandler:FindWidget(widgetName)
	assert(widget)

    widget.removeAllFerryRoutes()
    assert(#widget.ferryRoutes == 0)

	local myTeamID = Spring.GetMyTeamID()
	local x, z = Game.mapSizeX / 2, Game.mapSizeZ / 2
	local y = Spring.GetGroundHeight(x, z)
	local facing = 1

    -- make transport
    local storkUnitDefName = "armatlas"
	local storkUnitID = SyncedRun(function(locals)
		return Spring.CreateUnit(
			locals.storkUnitDefName,
			locals.x,
			locals.y,
			locals.z,
			locals.facing,
			locals.myTeamID
		)
	end)

    -- make ferry route by issuing move order then set ferry order
	--Spring.GiveOrderToUnit(storkUnitID, CMD.MOVE, { x - 100, y, z - 100 }, 0)
    Spring.SelectUnit(storkUnitID)
	widget:CommandNotify(CMD.MOVE, { x - 100, y, z - 100 }, {})
	--Spring.GiveOrderToUnit(storkUnitID, CMD_SET_FERRY, { x - 100, y, z + 100, 100 }, CMD.OPT_SHIFT)
	widget:CommandNotify(CMD_SET_FERRY, { x - 100, y, z + 100, 100 }, {shift=true})
    widget:KeyRelease(keyShift)

    -- check that ferry route has been created
    assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with ferry route adds one item to global table of ferry routes")

    local newFerryRoute = widget.ferryRoutes[1]
    assert.table_has_fields({"destination", "zones"}, newFerryRoute)

    assert.is.equal(2, #newFerryRoute.zones, "Newly created ferry route has two zones")

    local newFerryRouteDestination = newFerryRoute.destination
    assert.is.equal(1, #newFerryRouteDestination.previousZones, "Destination has one previous zone")

    local newFerryRouteDeparture = newFerryRouteDestination.previousZones[1]
    assert.is.equals(newFerryRouteDestination, newFerryRouteDeparture.nextZone, "Next zone from departure is destination")
end)

test("Transport Ferry Create Ferry Route Three Zones", function ()
	VFS.Include("luarules/configs/customcmds.h.lua")

	widget = widgetHandler:FindWidget(widgetName)
	assert(widget)

    widget.removeAllFerryRoutes()
    assert(#widget.ferryRoutes == 0)

	local myTeamID = Spring.GetMyTeamID()
	local x, z = Game.mapSizeX / 2, Game.mapSizeZ / 2
	local y = Spring.GetGroundHeight(x, z)
	local facing = 1

    -- make transport
    local storkUnitDefName = "armatlas"
	local storkUnitID = SyncedRun(function(locals)
		return Spring.CreateUnit(
			locals.storkUnitDefName,
			locals.x,
			locals.y,
			locals.z,
			locals.facing,
			locals.myTeamID
		)
	end)

    -- make ferry route by issuing move order then set ferry order
    Spring.SelectUnit(storkUnitID)
	widget:CommandNotify(CMD.MOVE, { x, y, z - 200 }, {})
	widget:CommandNotify(CMD_SET_FERRY, { x, y, z, 100 }, {shift=true})
	widget:CommandNotify(CMD_SET_FERRY, { x, y, z + 200, 100 }, {})

    -- check that ferry route has been created
    assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with ferry route adds one item to global table of ferry routes")

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
end)

test("Transport Ferry Create Ferry Route Two Previous Zones", function ()
	VFS.Include("luarules/configs/customcmds.h.lua")

	widget = widgetHandler:FindWidget(widgetName)
	assert(widget)

    widget.removeAllFerryRoutes()
    assert(#widget.ferryRoutes == 0)

	local myTeamID = Spring.GetMyTeamID()
	local x, z = Game.mapSizeX / 2, Game.mapSizeZ / 2
	local y = Spring.GetGroundHeight(x, z)
	local facing = 1

    -- make transport
    local storkUnitDefName = "armatlas"
	local stork1UnitID = SyncedRun(function(locals)
		return Spring.CreateUnit(
			locals.storkUnitDefName,
			locals.x,
			locals.y,
			locals.z,
			locals.facing,
			locals.myTeamID
		)
	end)
	local stork2UnitID = SyncedRun(function(locals)
		return Spring.CreateUnit(
			locals.storkUnitDefName,
			locals.x,
			locals.y,
			locals.z,
			locals.facing,
			locals.myTeamID
		)
	end)

    -- make ferry route by issuing move order then set ferry order
    Spring.SelectUnit(stork1UnitID)
	widget:CommandNotify(CMD.MOVE, { x - 200, y, z - 200 }, {})
	widget:CommandNotify(CMD_SET_FERRY, { x + 200, y, z, 100 }, {})

    assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with ferry route adds one item to global table of ferry routes")

    Spring.SelectUnit(stork2UnitID)
	widget:CommandNotify(CMD.MOVE, { x - 200, y, z + 200 }, {})
	widget:CommandNotify(CMD_SET_FERRY, { x + 200, y, z, 100 }, {})

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
end)

test("Transport Ferry Create Ferry Route Two Previous Zones (using shift)", function ()
	VFS.Include("luarules/configs/customcmds.h.lua")

	widget = widgetHandler:FindWidget(widgetName)
	assert(widget)

    widget.removeAllFerryRoutes()
    assert(#widget.ferryRoutes == 0)

	local myTeamID = Spring.GetMyTeamID()
	local x, z = Game.mapSizeX / 2, Game.mapSizeZ / 2
	local y = Spring.GetGroundHeight(x, z)
	local facing = 1

    -- make transport
    local storkUnitDefName = "armatlas"
	local stork1UnitID = SyncedRun(function(locals)
		return Spring.CreateUnit(
			locals.storkUnitDefName,
			locals.x,
			locals.y,
			locals.z,
			locals.facing,
			locals.myTeamID
		)
	end)
	local stork2UnitID = SyncedRun(function(locals)
		return Spring.CreateUnit(
			locals.storkUnitDefName,
			locals.x,
			locals.y,
			locals.z,
			locals.facing,
			locals.myTeamID
		)
	end)

    -- make ferry route by issuing move order then set ferry order
    Spring.SelectUnit(stork1UnitID)
	widget:CommandNotify(CMD.MOVE, { x - 200, y, z - 200 }, {})
	widget:CommandNotify(CMD_SET_FERRY, { x + 200, y, z, 100 }, {shift=true})
    widget:KeyRelease(keyShift)

    assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with ferry route adds one item to global table of ferry routes")

    Spring.SelectUnit(stork2UnitID)
	widget:CommandNotify(CMD.MOVE, { x - 200, y, z + 200 }, {})
	widget:CommandNotify(CMD_SET_FERRY, { x + 200, y, z, 100 }, {shift=true})
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
end)

--[[
    This test creates a ferry route comprised of several leaves on multiple layers.

            A  ->   B
                        \
    C  ->   D  ->   E  ->  F
        /               /
    G       H  ->   I
            J   /
]]
test("Transport Ferry Create Ferry Route Involved", function ()
	VFS.Include("luarules/configs/customcmds.h.lua")

	widget = widgetHandler:FindWidget(widgetName)
	assert(widget)

    widget.removeAllFerryRoutes()
    assert(#widget.ferryRoutes == 0)

	local myTeamID = Spring.GetMyTeamID()
	local x, z = Game.mapSizeX / 2, Game.mapSizeZ / 2
	local y = Spring.GetGroundHeight(x, z)
	local facing = 1

    -- make transport
    local storkUnitDefName = "armatlas"
	local stork1UnitID = SyncedRun(function(locals)
		return Spring.CreateUnit(
			locals.storkUnitDefName,
			locals.x,
			locals.y,
			locals.z,
			locals.facing,
			locals.myTeamID
		)
	end)
	local stork2UnitID = SyncedRun(function(locals)
		return Spring.CreateUnit(
			locals.storkUnitDefName,
			locals.x,
			locals.y,
			locals.z,
			locals.facing,
			locals.myTeamID
		)
	end)
	local stork3UnitID = SyncedRun(function(locals)
		return Spring.CreateUnit(
			locals.storkUnitDefName,
			locals.x,
			locals.y,
			locals.z,
			locals.facing,
			locals.myTeamID
		)
	end)
	local stork4UnitID = SyncedRun(function(locals)
		return Spring.CreateUnit(
			locals.storkUnitDefName,
			locals.x,
			locals.y,
			locals.z,
			locals.facing,
			locals.myTeamID
		)
	end)
	local stork5UnitID = SyncedRun(function(locals)
		return Spring.CreateUnit(
			locals.storkUnitDefName,
			locals.x,
			locals.y,
			locals.z,
			locals.facing,
			locals.myTeamID
		)
	end)

    -- make ferry route by issuing move order then set ferry order
    Spring.SelectUnit(stork1UnitID)
	--widget:CommandNotify(CMD.MOVE, { x - 400, y, z - 200 }, {})    -- A
    SyncedRun(function (locals)
	    Spring.GiveOrderToUnit(locals.stork1UnitID, CMD.MOVE, { locals.x - 400, locals.y, locals.z - 200 }, 0)
    end)
	widget:CommandNotify(CMD_SET_FERRY, { x - 200, y, z - 200, 100 }, {shift=true})       -- B
	widget:CommandNotify(CMD_SET_FERRY, { x, y, z, 100 }, {})      -- F

    assert.is.equal(1, #widget.ferryRoutes, "Creating a ferry route with ferry route adds one item to global table of ferry routes")

    Spring.SelectUnit(stork2UnitID)
	--widget:CommandNotify(CMD.MOVE, { x - 600, y, z }, {})   -- C
    SyncedRun(function (locals)
	    Spring.GiveOrderToUnit(locals.stork2UnitID, CMD.MOVE, { locals.x - 600, locals.y, locals.z }, 0)
    end)
	widget:CommandNotify(CMD_SET_FERRY, { x - 400, y, z, 100 }, {shift=true})  -- D
	widget:CommandNotify(CMD_SET_FERRY, { x - 200, y, z, 100 }, {shift=true})  -- E
	widget:CommandNotify(CMD_SET_FERRY, { x, y, z, 100 }, {})  -- F

    assert.is.equal(1, #widget.ferryRoutes, "Adding a path to existing ferry route did not create a new ferry route")

    Spring.SelectUnit(stork3UnitID)
	--widget:CommandNotify(CMD.MOVE, { x - 600, y, z + 200 }, {})   -- G
    SyncedRun(function (locals)
	    Spring.GiveOrderToUnit(locals.stork3UnitID, CMD.MOVE, { locals.x - 600, locals.y, locals.z + 200 }, 0)
    end)
	widget:CommandNotify(CMD_SET_FERRY, { x - 400, y, z, 100 }, {})  -- D

    assert.is.equal(1, #widget.ferryRoutes, "Adding a path to existing ferry route did not create a new ferry route")

    Spring.SelectUnit(stork4UnitID)
	--widget:CommandNotify(CMD.MOVE, { x - 400, y, z + 200 }, {})   -- H
    SyncedRun(function (locals)
	    Spring.GiveOrderToUnit(locals.stork4UnitID, CMD.MOVE, { locals.x - 400, locals.y, locals.z + 200 }, 0)
    end)
	widget:CommandNotify(CMD_SET_FERRY, { x - 200, y, z + 200, 100 }, {shift=true})  -- I
	widget:CommandNotify(CMD_SET_FERRY, { x, y, z, 100 }, {})  -- F

    assert.is.equal(1, #widget.ferryRoutes, "Adding a path to existing ferry route did not create a new ferry route")

    Spring.SelectUnit(stork5UnitID)
	--widget:CommandNotify(CMD.MOVE, { x - 400, y, z + 400 }, {})   -- J
    SyncedRun(function (locals)
	    Spring.GiveOrderToUnit(locals.stork5UnitID, CMD.MOVE, { locals.x - 400, locals.y, locals.z + 400 }, 0)
    end)
	widget:CommandNotify(CMD_SET_FERRY, { x - 200, y, z + 200, 100 }, {})  -- I

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
end)
