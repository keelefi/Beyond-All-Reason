local widgetName = "Transport Ferry"

function skip()
	return Spring.GetGameFrame() <= 0
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

local testSuiteName = "Test Transport Ferry"
local printTestMessages = true
local function testEcho(message)
    if printTestMessages then
        Spring.Echo("[" .. testSuiteName .. "] " .. message)
    end
end

local checksPassed = 0
local function assertEquals(testName, expected, actual)
    if expected ~= actual then
        printTestMessage = true
    end

    testEcho(testName)

    testEcho("  expected: " .. tostring(expected))
    testEcho("  actual: " .. tostring(actual))

    assert(expected == actual)

    -- TODO: print checks passed somewhere
    checksPassed = checksPassed + 1
end

local function assertHasFields(object, fields)
    for _,field in ipairs(fields) do
        if (not object) or (not object[field]) then
            printTestMessage = true
            Spring.Echo("table does not have required field: " .. field)
            Spring.Echo(object)
            assert(false)
        end
    end
end

local delay = 5
addTest("Test Create Ferry Route", function ()
	VFS.Include("luarules/configs/customcmds.h.lua")

	widget = widgetHandler:FindWidget(widgetName)
	assert(widget)

	--while (#widget.ferryRoutes > 0) do
        -- TODO: remove ferry routes
		--widget.deleteBlueprint(1)
	--end
    -- TODO: remove this
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
	widget:CommandNotify(CMD_SET_FERRY, { x - 100, y, z + 100, 100 }, {})

    -- check that ferry route has been created
    --Spring.Echo("ferry route count: " .. tostring(#widget.ferryRoutes))
    assertEquals("Creating a ferry route with ferry route adds one item to global table of ferry routes", 1, #widget.ferryRoutes)

    local newFerryRoute = widget.ferryRoutes[1]
    assertHasFields(newFerryRoute, {"destination", "zones"})

    assertEquals("Newly created ferry route has two zones", 2, #newFerryRoute.zones)

    local newFerryRouteDestination = newFerryRoute.destination
    assertEquals("Destination has one previous zone", 1, #newFerryRouteDestination.previousZones)

    local newFerryRouteDeparture = newFerryRouteDestination.previousZones[1]
    assertEquals("Next zone from departure is destination", newFerryRouteDestination, newFerryRouteDeparture.nextZone)

	--local blueprintUnitDefName = "armsolar"
	--local builderUnitDefName = "armck"

	--local blueprintUnitDefID = UnitDefNames[blueprintUnitDefName].id

	--local myTeamID = Spring.GetMyTeamID()
	--local x, z = Game.mapSizeX / 2, Game.mapSizeZ / 2
	--local y = Spring.GetGroundHeight(x, z)
	--local facing = 1

	--local blueprintUnitID = SyncedRun(function(locals)
	--	return Spring.CreateUnit(
	--		locals.blueprintUnitDefName,
	--		locals.x,
	--		locals.y,
	--		locals.z,
	--		locals.facing,
	--		locals.myTeamID
	--	)
	--end)

	--Spring.SelectUnit(blueprintUnitID)

	--Test.waitFrames(delay)

	--widget:CommandNotify(CMD_BLUEPRINT_CREATE, {}, {})

	--assert(#(widget.blueprints) == 1)

	--Test.clearMap()

	--local builderUnitID = SyncedRun(function(locals)
	--	return Spring.CreateUnit(
	--		locals.builderUnitDefName,
	--		locals.x + 100,
	--		locals.y,
	--		locals.z,
	--		locals.facing,
	--		locals.myTeamID
	--	)
	--end)

	--Spring.SelectUnit(builderUnitID)

	--Test.waitFrames(delay)

	--Spring.SetActiveCommand(
	--	Spring.GetCmdDescIndex(CMD_BLUEPRINT_PLACE),
	--	1,
	--	true,
	--	false,
	--	false,
	--	false,
	--	false,
	--	false
	--)

	--Test.waitFrames(delay)

	--assert(widget.blueprintPlacementActive)

	--local sx, sy = Spring.WorldToScreenCoords(x, y, z)
	--Spring.WarpMouse(sx, sy)

	--Test.waitFrames(delay)

	--widget:CommandNotify(CMD_BLUEPRINT_PLACE, {}, {})

	--Test.waitFrames(delay)

	--local builderQueue = Spring.GetCommandQueue(builderUnitID, -1)

	--assert(#builderQueue == 1)
	--assert(builderQueue[1].id == -blueprintUnitDefID)
end)
