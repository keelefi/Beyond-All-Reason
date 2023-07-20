return {
	raptorpyroallterrain = {
		acceleration = 1.4375,
		bmcode = "1",
		brakerate = 2.3,
		buildcostenergy = 5280,
		buildcostmetal = 99,
		builder = false,
		buildpic = "raptors/raptorpyroallterrain.DDS",
		buildtime = 2250,
		canattack = true,
		canguard = true,
		canmove = true,
		canpatrol = true,
		canstop = "1",
		capturable = false,
		category = "BOT MOBILE WEAPON ALL NOTSUB NOTSHIP NOTAIR NOTHOVER SURFACE RAPTOR EMPABLE",
		collisionvolumeoffsets = "0 -3 -3",
		collisionvolumescales = "18 28 40",
		collisionvolumetype = "box",
		defaultmissiontype = "Standby",
		explodeas = "BUG_DEATH",
		footprintx = 2,
		footprintz = 2,
		leavetracks = true,
		maneuverleashlength = "640",
		mass = 89,
		maxdamage = 2000,
		maxreversevelocity = 3,
		maxslope = 18,
		maxvelocity = 3.25,
		maxwaterdepth = 15,
		movementclass = "CHICKALLTERRAINHOVER",
		noautofire = false,
		nochasecategory = "VTOL",
		objectname = "Raptors/raptorpyroallterrain.s3o",
		script = "Raptors/raptorc3.cob",
		seismicsignature = 0,
		selfdestructas = "BIGBUG_DEATH",
		side = "THUNDERBIRDS",
		sightdistance = 300,
		smoothanim = true,
		sonardistance = 450,
		steeringmode = "2",
		tedclass = "BOT",
		trackoffset = 0.5,
		trackstrength = 3,
		trackstretch = 1,
		tracktype = "RaptorTrackPointy",
		trackwidth = 35,
		turninplace = true,
		turninplaceanglelimit = 90,
		turnrate = 1840,
		unitname = "raptorc3",
		upright = false,
		waterline = 10,
		workertime = 0,
		customparams = {
			subfolder = "other/raptors",
			model_author = "KDR_11k, Beherith",
			normalmaps = "yes",
			normaltex = "unittextures/raptor_s_normals.png",
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
			flamer = {
				areaofeffect = 64,
				collidefriendly = 0,
				collidefeature = 0,
				avoidfeature = 0,
				avoidfriendly = 0,
				burst = 12,
				burstrate = 0.03333,
				cegtag = "burnflamexm",
				colormap = "1 0.95 0.82 0.03   0.7 0.4 0.25 0.027   0.44 0.25 0.15 0.024   0.033 0.018 0.011 0.02   0.0 0.0 0.0 0.01",
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.3,
				explosiongenerator = "custom:burnblack",
				firestarter = 100,
				flamegfxtime = 1,
				groundbounce = false,
				impulseboost = 0,
				impulsefactor = 0,
				intensity = 0.65,
				name = "FlameThrower",
				noselfdamage = true,
				proximitypriority = 4,
				range = 300,
				reloadtime = 0.7,
				rgbcolor = "1 0.94 0.88",
				rgbcolor2 = "0.9 0.83 0.77",
				sizegrowth = 0.7,
				soundhitwet = "sizzle",
				soundstart = "cflamhvy1",
				soundtrigger = false,
				sprayangle = 100,
				targetborder = 0.75,
				targetmoveerror = 0.001,
				tolerance = 2500,
				turret = true,
				weapontimer = 1,
				weapontype = "Flame",
				weaponvelocity = 265,
				damage = {
					default = 16,
				},
			},
		},
		weapons = {
			[1] = {
				def = "flamer",
				maindir = "0 0 1",
				maxangledif = 110,
			},
		},
	},
}
