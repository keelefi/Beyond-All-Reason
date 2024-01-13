return {
	corcrw = {
		maxacc = 0.15,
		activatewhenbuilt = true,
		blocking = true,
		bankingallowed = false,
		maxdec = 0.15,
		energycost = 72000,
		metalcost = 5100,
		buildpic = "CORCRW.DDS",
		buildtime = 84200,
		canfly = true,
		canmove = true,
		category = "ALL WEAPON VTOL NOTSUB NOTHOVER",
		collide = true,
		collisionvolumeoffsets = "0 1 0",
		collisionvolumescales = "64 24 64",
		collisionvolumetype = "CylY",
		cruisealtitude = 75,
		explodeas = "largeexplosiongeneric",
		footprintx = 3,
		footprintz = 3,
		hoverattack = true,
		idleautoheal = 15,
		idletime = 1200,
		health = 16700,
		maxslope = 10,
		speed = 114.9,
		maxwaterdepth = 0,
		nochasecategory = "VTOL",
		objectname = "Units/CORCRW.s3o",
		script = "Units/CORCRW.cob",
		seismicsignature = 0,
		selfdestructas = "largeExplosionGenericSelfd",
		sightdistance = 494,
		turninplaceanglelimit = 360,
		turnrate = 300,
		upright = true,
		customparams = {
			unitgroup = 'weapon',
			model_author = "Mr Bob",
			normaltex = "unittextures/cor_normal.dds",
			subfolder = "coraircraft/t2",
			techlevel = 2,
		},
		sfxtypes = {
			crashexplosiongenerators = {
				[1] = "crashing-large",
				[2] = "crashing-large",
				[3] = "crashing-large2",
				[4] = "crashing-large3",
				[5] = "crashing-large3",
			},
			pieceexplosiongenerators = {
				[1] = "airdeathceg3",
				[2] = "airdeathceg4",
				[3] = "airdeathceg2",
			},
		},
		sounds = {
			canceldestruct = "cancel2",
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
				[1] = "vtolcrmv",
			},
			select = {
				[1] = "vtolcrac",
			},
		},
		weapondefs = {
			krowlaser = {
				areaofeffect = 8,
				avoidfeature = false,
				beamtime = 0.1,
				beamttl = 1,
				corethickness = 0.13,
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				cylindertargeting = 1,
				edgeeffectiveness = 0.15,
				energypershot = 50,
				explosiongenerator = "custom:laserhit-small-green",
				firestarter = 90,
				impulseboost = 0,
				impulsefactor = 0,
				laserflaresize = 6.05,
				name = "HighEnergyLaser",
				noselfdamage = true,
				proximitypriority = 1,
				range = 575,
				reloadtime = 0.63333,
				rgbcolor = "0 1 0",
				soundhitdry = "",
				soundhitwet = "sizzle",
				soundstart = "lasrcrw1",
				soundtrigger = 1,
				targetmoveerror = 0,
				thickness = 2,
				tolerance = 10000,
				turret = true,
				weapontype = "BeamLaser",
				weaponvelocity = 800,
				damage = {
					default = 90,
				},
			},
			krowlaser2 = {
				areaofeffect = 32,
				avoidfeature = false,
				beamtime = 0.25,
				beamttl = 1,
				corethickness = 0.2,
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				cylindertargeting = 1,
				edgeeffectiveness = 0.15,
				energypershot = 100,
				explosiongenerator = "custom:laserhit-large-green",
				firestarter = 90,
				impulseboost = 0,
				impulsefactor = 0,
				laserflaresize = 7.7,
				name = "High energy a2g laser",
				noselfdamage = true,
				range = 525,
				reloadtime = 1.3,
				rgbcolor = "0 1 0",
				soundhitdry = "",
				soundhitwet = "sizzle",
				soundstart = "lasrcrw2",
				soundtrigger = 1,
				targetmoveerror = 0,
				thickness = 2.7,
				tolerance = 10000,
				turret = true,
				weapontype = "BeamLaser",
				weaponvelocity = 800,
				damage = {
					default = 250,
				},
			},
		},
		weapons = {
			[1] = {
				def = "KROWLASER2",
				onlytargetcategory = "SURFACE",
			},
			[2] = {
				def = "KROWLASER",
				onlytargetcategory = "SURFACE",
			},
			[3] = {
				def = "KROWLASER",
				onlytargetcategory = "SURFACE",
			},
		},
	},
}
