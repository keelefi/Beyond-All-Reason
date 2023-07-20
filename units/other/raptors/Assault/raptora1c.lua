return {
	raptora1c = {
		acceleration = 0.414,
		airsightdistance = 650,
		bmcode = "1",
		brakerate = 0.46,
		buildcostenergy = 3520,
		buildcostmetal = 152,
		builder = false,
		buildpic = "raptors/raptora1c.DDS",
		buildtime = 7500,
		canattack = true,
		canguard = true,
		canmove = true,
		canpatrol = true,
		canstop = "1",
		capturable = false,
		category = "BOT MOBILE WEAPON ALL NOTSUB NOTSHIP NOTAIR NOTHOVER SURFACE RAPTOR EMPABLE",
		collisionvolumeoffsets = "0 -5 0",
		collisionvolumescales = "27 48 60",
		collisionvolumetype = "box",
		defaultmissiontype = "Standby",
		explodeas = "BIGBUG_DEATH",
		footprintx = 3,
		footprintz = 3,
		leavetracks = true,
		maneuverleashlength = "640",
		mass = 100000,
		maxdamage = 4450,
		maxslope = 18,
		maxvelocity = 1.3,
		maxwaterdepth = 0,
		movementclass = "CHICKBIGHOVER",
		noautofire = false,
		nochasecategory = "VTOL",
		objectname = "Raptors/raptorac.s3o",
		onlytargetcategory2 = "VTOL",
		script = "Raptors/raptora1c.cob",
		seismicsignature = 0,
		selfdestructas = "BIGBUG_DEATH",
		side = "THUNDERBIRDS",
		sightdistance = 300,
		smoothanim = true,
		steeringmode = "2",
		tedclass = "BOT",
		trackoffset = 7,
		trackstrength = 3,
		trackstretch = 1,
		tracktype = "RaptorTrack",
		trackwidth = 34,
		turninplace = true,
		turninplaceanglelimit = 90,
		turnrate = 920,
		unitname = "raptora1c",
		upright = false,
		waterline = 24,
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
				dance = 20,
				edgeeffectiveness = 0.35,
				explosiongenerator = "custom:genericshellexplosion-huge-bomb",
				firestarter = 0,
				flighttime = 2,
				firesubmersed = true,
				impulseboost = 0,
				impulsefactor = 0.4,
				interceptedbyshieldtype = 4,
				metalpershot = 0,
				model = "SimpleFlareXL.s3o",
				name = "Deadly Defensive Spores",
				noselfdamage = true,
				range = 400,
				reloadtime = 8,
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
					default = 5,
					bombers = 500,
					fighters = 500,
					vtol = 500,
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
				explosiongenerator = "custom:raptorspike-medium-sparks-burn",
				firesubmersed = true,
				impulseboost = 1,
				impulsefactor = 1,
				interceptedbyshieldtype = 0,
				model = "Raptors/spike.s3o",
				name = "Claws",
				noselfdamage = true,
				range = 300,
				reloadtime = 0.9,
				soundstart = "smallraptorattack",
				targetborder = 1,
				tolerance = 5000,
				turret = true,
				waterweapon = true,
				weapontype = "Cannon",
				weaponvelocity = 1500,
				damage = {
					default = 250,
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
