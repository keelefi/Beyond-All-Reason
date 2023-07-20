return {
	raptorbroodartyh4small = {
		acceleration = 0.115,
		bmcode = "1",
		brakerate = 0.414,
		buildcostenergy = 12320,
		buildcostmetal = 396,
		builder = false,
		buildpic = "raptors/raptorbroodarty.DDS",
		buildtime = 6750,
		canattack = true,
		canguard = true,
		canmove = true,
		canpatrol = true,
		canstop = "1",
		capturable = false,
		category = "BOT MOBILE WEAPON ALL NOTSUB NOTSHIP NOTAIR NOTHOVER SURFACE RAPTOR EMPABLE",
		collisionvolumeoffsets = "0 1 0",
		collisionvolumescales = "25 34 44",
		collisionvolumetype = "box",
		defaultmissiontype = "Standby",
		explodeas = "BIGBUG_DEATH",
		footprintx = 3,
		footprintz = 3,
		hidedamage = 1,
		idleautoheal = 20,
		idletime = 300,
		leavetracks = true,
		maneuverleashlength = "640",
		mass = 4000,
		maxdamage = 2000,
		maxslope = 18,
		maxvelocity = 1.4,
		maxwaterdepth = 0,
		movementclass = "CHICKALLTERRAINBIGHOVER",
		noautofire = false,
		nochasecategory = "VTOL",
		objectname = "Raptors/raptor_artillery_brood_small.s3o",
		script = "Raptors/raptor_artillery_v2.cob",
		seismicsignature = 0,
		selfdestructas = "BIGBUG_DEATH",
		side = "THUNDERBIRDS",
		sightdistance = 1000,
		smoothanim = true,
		steeringmode = "2",
		tedclass = "BOT",
		trackoffset = 6,
		trackstrength = 3,
		trackstretch = 1,
		tracktype = "RaptorTrack",
		trackwidth = 30,
		turninplace = true,
		turninplaceanglelimit = 90,
		turnrate = 1840,
		unitname = "raptorbroodartyh4small",
		upright = false,
		workertime = 0,
		waterline = 10,
		customparams = {
			subfolder = "other/raptors",
			model_author = "KDR_11k, Beherith",
			normalmaps = "yes",
			normaltex = "unittextures/raptor_s_normals.png",
			--treeshader = "no",
		},
		sfxtypes = {
			explosiongenerators = {
				[1] = "custom:blood_spray",
				[2] = "custom:blood_explode",
				[3] = "custom:dirt",
			},
			pieceexplosiongenerators = {
				[1] = "blood_spray",
				[2] = "blood_spray",
				[3] = "blood_spray",
			},
		},
		weapondefs = {
			bloodyeggs = {
				accuracy = 256,
				areaofeffect = 128,
				collidefriendly = 0,
				collidefeature = 0,
				avoidfeature = 0,
				avoidfriendly = 0,
				burst = 1,
				burstrate = 0.5,
				cegtag = "arty-heavy-purple",
				craterareaofeffect = 128,
				craterboost = 0.2,
				cratermult = 0.2,
				edgeeffectiveness = 0.63,
				--explosiongenerator = "custom:ELECTRIC_EXPLOSION",
				explosiongenerator = "custom:dirt",
				impulseboost = 0,
				impulsefactor = 0.4,
				intensity = 0.7,
				interceptedbyshieldtype = 1,
				model = "Raptors/s_raptor_white.s3o",
				name = "GOOLAUNCHER",
				noselfdamage = true,
				proximitypriority = -4,
				range = 2000,
				reloadtime = 5,
				rgbcolor = "0.5 0 1",
				size = 5.5,
				sizedecay = 0.09,
				soundhit = "smallraptorattack",
				soundstart = "bugarty",
				sprayangle = 512,
				tolerance = 5000,
				turret = true,
				weapontimer = 0.2,
				weaponvelocity = 520,
				damage = {
					default = 1,
					shields = 200,
				},
				customparams = {
					spawns_name = "raptorh4",
					spawns_surface = "LAND SEA", -- Available: "LAND SEA"
				},
			},
		},
		weapons = {
			[1] = {
				badtargetcategory = "MOBILE",
				def = "bloodyeggs",
				maindir = "0 0 1",
				maxangledif = 50,
				onlytargetcategory = "NOTAIR",
			},
		},
	},
}
