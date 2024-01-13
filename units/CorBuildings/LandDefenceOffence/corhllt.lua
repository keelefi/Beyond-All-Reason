return {
	corhllt = {
		maxacc = 0,
		maxdec = 0,
		buildangle = 32768,
		energycost = 1750,
		metalcost = 195,
		buildpic = "CORHLLT.DDS",
		buildtime = 5440,
		canrepeat = false,
		cantbetransported = false,
		category = "ALL NOTLAND WEAPON NOTSUB NOTSHIP NOTAIR NOTHOVER SURFACE EMPABLE",
		collisionvolumeoffsets = "0 6 0",
		collisionvolumescales = "32 90 32",
		collisionvolumetype = "CylY",
		corpse = "DEAD",
		explodeas = "mediumBuildingexplosiongeneric",
		footprintx = 2,
		footprintz = 2,
		idleautoheal = 5,
		idletime = 1800,
		mass = 10200,
		health = 1670,
		maxslope = 10,
		maxwaterdepth = 0,
		objectname = "Units/CORHLLT.s3o",
		script = "Units/CORHLLT.cob",
		seismicsignature = 0,
		selfdestructas = "mediumBuildingExplosionGenericSelfd",
		sightdistance = 475,
		yardmap = "oooo",
		customparams = {
			usebuildinggrounddecal = true,
			buildinggrounddecaltype = "decals/corhllt_aoplane.dds",
			buildinggrounddecalsizey = 4,
			buildinggrounddecalsizex = 4,
			buildinggrounddecaldecayspeed = 30,
			unitgroup = 'weapon',
			model_author = "Mr Bob",
			normaltex = "unittextures/cor_normal.dds",
			removewait = true,
			subfolder = "corbuildings/landdefenceoffence",
		},
		featuredefs = {
			dead = {
				blocking = true,
				category = "corpses",
				collisionvolumeoffsets = "0 6 0",
				collisionvolumescales = "32 90 32",
				collisionvolumetype = "CylY",
				damage = 900,
				energy = 0,
				featuredead = "HEAP",
				featurereclamate = "SMUDGE01",
				footprintx = 3,
				footprintz = 3,
				height = 6.5,
				hitdensity = 100,
				metal = 120,
				object = "Units/corhllt_dead.s3o",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
			heap = {
				blocking = false,
				category = "heaps",
				collisionvolumescales = "85.0 14.0 6.0",
				collisionvolumetype = "cylY",
				damage = 450,
				energy = 0,
				featurereclamate = "SMUDGE01",
				footprintx = 3,
				footprintz = 3,
				height = 1,
				hitdensity = 100,
				metal = 48,
				object = "Units/cor4X4D.s3o",
				reclaimable = true,
				resurrectable = 0,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
		},
		sfxtypes = {
			pieceexplosiongenerators = {
				[1] = "deathceg2",
				[2] = "deathceg3",
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
				[1] = "lltok",
			},
			select = {
				[1] = "hlltselect",
			},
		},
		weapondefs = {
			hllt_bottom = {
				areaofeffect = 12,
				avoidfeature = false,
				beamtime = 0.12,
				corethickness = 0.175,
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.15,
				energypershot = 15,
				explosiongenerator = "custom:laserhit-small-red",
				firestarter = 100,
				impactonly = 1,
				impulseboost = 0,
				impulsefactor = 0,
				laserflaresize = 7.7,
				name = "Close-quarters light g2g laser",
				noselfdamage = true,
				proximitypriority = 3,
				range = 400,
				reloadtime = 0.46667,
				rgbcolor = "1 0 0",
				soundhitdry = "",
				soundhitwet = "sizzle",
				soundstart = "lasrfir3",
				soundtrigger = 1,
				targetmoveerror = 0.1,
				thickness = 2,
				tolerance = 10000,
				turret = true,
				weapontype = "BeamLaser",
				weaponvelocity = 2250,
				damage = {
					commanders = 112.5,
					default = 75,
					vtol = 5,
				},
			},
			hllt_top = {
				areaofeffect = 12,
				avoidfeature = false,
				beamtime = 0.12,
				corethickness = 0.175,
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.15,
				energypershot = 15,
				explosiongenerator = "custom:laserhit-small-red",
				firestarter = 30,
				impactonly = 1,
				impulseboost = 0,
				impulsefactor = 0,
				laserflaresize = 8.8,
				name = "Close-quarters light g2g laser",
				noselfdamage = true,
				proximitypriority = -1.5,
				range = 480,
				reloadtime = 0.46667,
				rgbcolor = "1 0 0",
				soundhitdry = "",
				soundhitwet = "sizzle",
				soundstart = "lasrfir3",
				soundtrigger = 1,
				targetmoveerror = 0.1,
				thickness = 2,
				tolerance = 10000,
				turret = true,
				weapontype = "BeamLaser",
				weaponvelocity = 2250,
				damage = {
					commanders = 112.5,
					default = 75,
					vtol = 5,
				},
			},
		},
		weapons = {
			[1] = {
				badtargetcategory = "VTOL",
				def = "HLLT_TOP",
				onlytargetcategory = "NOTSUB",
				fastautoretargeting = true,
			},
			[2] = {
				badtargetcategory = "VTOL",
				def = "HLLT_BOTTOM",
				onlytargetcategory = "NOTSUB",
				fastautoretargeting = true,
			},
		},
	},
}
