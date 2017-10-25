return {
	corgplat = {
		acceleration = 0,
		activatewhenbuilt = true,
		brakerate = 0,
		buildangle = 16384,
		buildcostenergy = 1200,
		buildcostmetal = 120,
		buildpic = "CORGPLAT.DDS",
		buildtime = 3003,
		canrepeat = false,
		category = "ALL NOTLAND WEAPON NOTSUB NOTSHIP NOTAIR NOTHOVER SURFACE",
		collisionvolumeoffsets = "0 -6 0",
		collisionvolumescales = "76 36 76",
		collisionvolumetype = "CylY",
		corpse = "DEAD",
		description = "Floating Gun Platform (Good vs Light Boats)",
		energymake = 1,
		energystorage = 10,
		explodeas = "mediumBuildingexplosiongeneric",
		footprintx = 4,
		footprintz = 4,
		icontype = "building",
		idleautoheal = 5,
		idletime = 1800,
		maxdamage = 725,
		minwaterdepth = 1,
		name = "Gun Platform",
		nochasecategory = "MOBILE",
		objectname = "CORGPLAT",
		script = "CORGPLAT_LUS.LUA",
		seismicsignature = 0,
		selfdestructas = "mediumBuildingExplosionGenericSelfd",
		sightdistance = 450,
		waterline = 1,
		yardmap = "wwwwwwwwwwwwwwww",
		customparams = {
			removewait = true,
		},
		featuredefs = {
			dead = {
				blocking = false,
				category = "corpses",
				collisionvolumeoffsets = "0.0 -6.6047363281e-05 -15.62939453125e-06",
				collisionvolumescales = "50.0 45.7867279053 45.9999847412",
				collisionvolumetype = "Box",
				damage = 750,
				description = "Gun Platform Wreckage",
				energy = 0,
				footprintx = 4,
				footprintz = 4,
				height = 20,
				hitdensity = 100,
				metal = 80,
				object = "CORGPLAT_DEAD",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
		},
		sfxtypes = { 
 			pieceExplosionGenerators = { 
				"deathceg2",
				"deathceg3",
				"deathceg4",
			},
		},
		sounds = {
			canceldestruct = "cancel2",
			cloak = "kloak1",
			uncloak = "kloak1un",
			underattack = "warning1",
			cant = {
				[1] = "cantdo4",
			},
			count = {
				[1] = "count6",
				[2] = "count5",
				[3] = "count4",
				[4] = "count3",
				[5] = "count2",
				[6] = "count1",
			},
			ok = {
				[1] = "twractv3",
			},
			select = {
				[1] = "twractv3",
			},
		},
		weapondefs = {
			corgplat = {
				accuracy = 4,
				areaofeffect = 16,
				avoidfeature = false,
				sizedecay = 0.1,
				alphadecay = 0.5,
				burst = 1,
				burstrate = 0.1,
				projectiles = 1,
				cegTag = "missiletrailcorroyspecial",
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				explosiongenerator = "custom:plasmahit-medium",
				impulseboost = 0.123,
				impulsefactor = 0.123,
				name = "Cannon",
				noselfdamage = true,
				range = 430,
				reloadtime = 1.625*0.5,
				soundhit = "xplomed2",
				soundhitwet = "splshbig",
				soundhitwetvolume = 0.5,
				soundstart = "cannhvy1",
				model = "bomb",
				targetmoveerror = 0.1,
				texture1 = "trans",
				turret = true,
				size = 1.75,
				tolerance = 0,
				firetolerance = 200,
				weapontype = "Cannon",
				weaponvelocity = 550,
				separation = 1.0,
				nogap = false,
				stages = 20,
				damage = {
					bombers = 1*1.5*2.1,
					default = 30*1.5*2.1,
					heavyunits = 30*1.5*2.1*0.7,
					fighters = 10*1.5*2.1,
					subs = 1*1.5*2.1,
					vtol = 1*1.5*2.1,

				},
			},
		},
		weapons = {
			[1] = {
				badtargetcategory = "VTOL LIGHTBOAT CAPITALSHIP",
				def = "CORGPLAT",
				onlytargetcategory = "",
			},
		},
	},
}
