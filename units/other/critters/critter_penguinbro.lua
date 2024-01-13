return {
	critter_penguinbro = {
		maxacc = 0.15,
		blocking = true,
		maxdec = 1,
		energycost = 15000,
		metalcost = 1500,
		builder = false,
		buildpic = "critters/critter_penguin.DDS",
		buildtime = 5000,
		canattack = true,
		canguard = true,
		canmove = true,
		canpatrol = true,
		canstop = "1",
		cantbetransported = true,
		capturable = false,
		category = "MOBILE WEAPON NOTAIR NOTSUB",
		collisionvolumeoffsets = "0 0 0",
		collisionvolumescales = "15 32 15",
		collisionvolumetype = "CylY",
		explodeas = "BUG_DEATH",
		floater = true,
		footprintx = 1,
		footprintz = 1,
		idleautoheal = 0,
		leavetracks = true,
		maneuverleashlength = "640",
		mass = 66,
		health = 2200,
		maxslope = 45,
		speed = 22.5,
		maxwaterdepth = 22,
		movementclass = "BOT1",
		movestate = -1,
		noautofire = false,
		nochasecategory = "MOBILE ",
		objectname = "Critters/critter_penguinbro.s3o",
		reclaimable = false,
		script = "Critters/critter_penguin.lua",
		seismicsignature = 0,
		selfdestructas = "SMALLBUG_DEATH",
		selfdestructcountdown = 0,
		sightdistance = 280,
		smoothanim = true,
		sonarstealth = true,
		stealth = true,
		trackoffset = 0,
		trackstrength = 4,
		trackstretch = 1,
		tracktype = "bigfoot",
		trackwidth = 10,
		turninplace = 1,
		turnrate = 2000,
		unitname = "critter_penguinbro",
		upright = false,
		waterline = 6,
		workertime = 0,
		customparams = {
			subfolder = "other/critters",
		},
		weapondefs = {
			eyelaser = {
				areaofeffect = 8,
				avoidfeature = false,
				beamtime = 0.2,
				corethickness = 0.2,
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.3,
				energypershot = 0,
				explosiongenerator = "custom:laserhit-tiny-red",
				firestarter = 100,
				impactonly = 1,
				impulseboost = 0,
				impulsefactor = 0,
				laserflaresize = 3.146,
				name = "LightLaser",
				noselfdamage = true,
				proximitypriority = 2,
				range = 266,
				reloadtime = 0.2,
				rgbcolor = "1 0 0",
				soundhitdry = "",
				soundhitwet = "sizzle",
				soundstart = "lasrfir3",
				soundtrigger = 1,
				targetborder = 0.75,
				targetmoveerror = 0.1,
				thickness = 1.25,
				tolerance = 7000,
				turret = false,
				weapontype = "BeamLaser",
				weaponvelocity = 2250,
				customparams = {
					nohealthbars = true,
				},
				damage = {
					default = 70,
					vtol = 7,
				},
			},
		},
		weapons = {
			[1] = {
				badtargetcategory = "VTOL",
				def = "EYELASER",
				onlytargetcategory = "",
			},
			[2] = {
				badtargetcategory = "VTOL",
				def = "EYELASER",
				onlytargetcategory = "",
			},
		},
	},
}
