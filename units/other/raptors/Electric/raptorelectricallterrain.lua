return {
	raptorelectricallterrain = {
		acceleration = 1.4375,
		bmcode = "1",
		brakerate = 2.3,
		buildcostenergy = 5280,
		buildcostmetal = 99,
		builder = false,
		buildpic = "raptors/raptorelectricallterrain.DDS",
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
		explodeas = "raptor_empdeath_small",
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
		objectname = "Raptors/raptorelectricallterrain.s3o",
		script = "Raptors/raptorc3.cob",
		seismicsignature = 0,
		selfdestructas = "raptor_empdeath_small",
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
			paralyzemultiplier = 0,
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
			raptorparalyzersmall = {
				areaofeffect = 100,
				collidefriendly = false,
				collidefriendly = 0,
				collidefeature = 0,
				avoidfeature = 0,
				avoidfriendly = 0,
				beamttl = 1,
				burst = 10,
				burstrate = 0.03333,
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				duration = 1,
				edgeeffectiveness = 1,
				energypershot = 0,
				explosiongenerator = "custom:genericshellexplosion-medium-lightning2",
				firestarter = 50,
				impactonly = 0,
				impulseboost = 0,
				impulsefactor = 0,
				intensity = 12,
				laserFlareSize = 2,
				name = "Close-quarters g2g lightning rifle",
				noselfdamage = true,
				paralyzer = true,
				paralyzetime = 20,
				range = 300,
				reloadtime = 1.5,
				rgbcolor = "0.5 0.5 1",
				--soundhit = "xplomed3",
				--soundhitwet = "sizzle",
				soundstart = "alien_electric",
				soundstartvolume = 42,
				soundtrigger = true,
				targetmoveerror = 0.15,
				thickness = 0.5,
				turret = true,
				weapontype = "LightningCannon",
				weaponvelocity = 400,
				damage = {
					default = 375,
				},
			},
		},
		weapons = {
			[1] = {
				def = "raptorparalyzersmall",
				maindir = "0 0 1",
				maxangledif = 110,
			},
		},
	},
}
