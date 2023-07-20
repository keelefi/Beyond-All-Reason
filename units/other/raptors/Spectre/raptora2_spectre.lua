return {
	raptora2_spectre = {
		acceleration = 0.414,
		airsightdistance = 1800,
		autoheal = 25,
		bmcode = "1",
		brakerate = 0.46,
		buildcostenergy = 3520,
		buildcostmetal = 302,
		builder = false,
		buildpic = "raptors/raptora2_spectre.DDS",
		buildtime = 30000,
		canattack = true,
		canguard = true,
		canmove = true,
		canpatrol = true,
		canstop = "1",
		capturable = false,
		cancloak = true,
		category = "BOT MOBILE WEAPON ALL NOTSUB NOTSHIP NOTAIR NOTHOVER SURFACE RAPTOR EMPABLE",
		cloakcost = 0,
		cloakcostmoving = 0,
		collisionvolumeoffsets = "0 0 2",
		collisionvolumescales = "37 75 130",
		collisionvolumetype = "box",
		defaultmissiontype = "Standby",
		explodeas = "MEGABUG_DEATH",
		footprintx = 3,
		footprintz = 3,
		initcloak = true,
		leavetracks = true,
		maneuverleashlength = "640",
		mass = 200000,
		maxdamage = 10000,
		maxslope = 18,
		maxvelocity = 1,
		maxwaterdepth = 0,
		mincloakdistance = 50,
		movementclass = "CHICKBIG2HOVER",
		noautofire = false,
		nochasecategory = "VTOL",
		objectname = "Raptors/raptora2_spectre.s3o",
		onlytargetcategory2 = "VTOL",
		script = "Raptors/raptora2.cob",
		seismicsignature = 4,
		selfdestructas = "MEGABUG_DEATH",
		side = "THUNDERBIRDS",
		sightdistance = 400,
		smoothanim = true,
		stealth = 1,
		steeringmode = "2",
		tedclass = "BOT",
		trackoffset = 7,
		trackstrength = 3,
		trackstretch = 1,
		tracktype = "RaptorTrack",
		trackwidth = 38,
		turninplace = true,
		turninplaceanglelimit = 90,
		turnrate = 920,
		unitname = "raptora2_spectre",
		upright = false,
		waterline = 40,
		workertime = 0,
		customparams = {
			maxrange = "200",
			subfolder = "other/raptors",
			model_author = "KDR_11k, Beherith",
			normalmaps = "yes",
			normaltex = "unittextures/raptor_l_normals.png",
		},
		sfxtypes = {
			explosiongenerators = {
				[1] = "custom:blood_spray",
				[2] = "custom:blood_explode",
				[3] = "custom:dirt",
				[4] = "custom:blob_fire",
			},
			pieceexplosiongenerators = {
				[1] = "blood_spray",
				[2] = "blood_spray",
				[3] = "blood_spray",
			},
		},
		weapondefs = {
			aaweapon = {
				areaofeffect = 128,
				avoidfriendly = false,
				burnblow = true,
				--cegtag = "sporetrail-large",
				collidefriendly = false,
				craterboost = 0,
				cratermult = 0,
				cameraShake = 700,
				dance = 4,
				edgeeffectiveness = 0.35,
				explosiongenerator = "custom:genericshellexplosion-huge-bomb",
				firestarter = 0,
				flighttime = 20,
				firesubmersed = true,
				impulseboost = 0,
				impulsefactor = 0.4,
				interceptedbyshieldtype = 4,
				metalpershot = 0,
				model = "SimpleFlareXL.s3o",
				name = "Deadly Defensive Spores",
				noselfdamage = true,
				range = 1200,
				reloadtime = 24,
				smoketrail = true,
				smokePeriod = 2,
				smoketime = 45,
				smokesize = 10.5,
				smokecolor = 1.0,
				soundhit = "spore_explo",
				soundstart = "spore_xl",
				soundstartvolume = 9,
				startvelocity = 1000,
				texture1 = "orangenovaexplo",
				texture2 = "sporetrail_xl",
				tolerance = 60000,
				tracks = true,
				trajectoryheight = 2,
				turnrate = 60000,
				turret = true,
				waterweapon = true,
				weaponacceleration = 40,
				weapontype = "MissileLauncher",
				weaponvelocity = 2000,
				wobble = 32000,
				damage = {
					default = 10,
					bombers = 1000,
					fighters = 1000,
					vtol = 1000,
				},
			},
			weapon = {
				areaofeffect = 42,
				collidefriendly = 0,
				collidefeature = 0,
				avoidfeature = 0,
				avoidfriendly = 0,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.3,
				explosiongenerator = "custom:raptorspike-large-sparks-burn",
				firesubmersed = true,
				impulseboost = 1,
				impulsefactor = 1,
				interceptedbyshieldtype = 0,
				model = "Raptors/spike.s3o",
				name = "Claws",
				noselfdamage = true,
				range = 400,
				reloadtime = 1.6,
				soundstart = "smallraptorattack",
				targetborder = 1,
				tolerance = 5000,
				turret = true,
				waterweapon = true,
				weapontype = "Cannon",
				weaponvelocity = 1500,
				damage = {
					default = 550,
				},
			},
		},
		weapons = {
			[1] = {
				badtargetcategory = "VTOL",
				def = "WEAPON",
				maindir = "0 0 1",
				maxangledif = 125,
				--onlytargetcategory = "NOTAIR",
			},
			[2] = {
				onlytargetcategory = "VTOL",
				def = "AAWEAPON",
			},
		},
	},
}
