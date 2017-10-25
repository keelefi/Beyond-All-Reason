return {
	corparrow = {
		acceleration = 0.015,
		activatewhenbuilt = true,

		brakerate = 0.2145,
		buildcostenergy = 30000,
		buildcostmetal = 1000,
		buildpic = "CORPARROW.DDS",
		buildtime = 22181,
		canmove = true,
		category = "ALL TANK PHIB WEAPON NOTSUB NOTAIR NOTHOVER SURFACE CANBEUW",
		collisionvolumeoffsets = "0 -10 1",
		collisionvolumescales = "44 44 53",
		collisionvolumetype = "CylZ",
		corpse = "DEAD",
		description = "Very Heavy Amphibious Tank",
		energymake = 2.1,
		energyuse = 2.1,
		explodeas = "mediumexplosiongeneric-phib",
		footprintx = 3,
		footprintz = 3,
		idleautoheal = 5,
		idletime = 1800,
		leavetracks = true,
		maxdamage = 5700,
		maxslope = 12,
		maxvelocity = 1.95,
		maxwaterdepth = 255,
		movementclass = "ATANK3",
		name = "Poison Arrow",
		nochasecategory = "VTOL",
		objectname = "CORPARROW",
		seismicsignature = 0,
		selfdestructas = "mediumExplosionGenericSelfd-phib",
		sightdistance = 385,
		sonardistance = 385*0.75,
		trackoffset = -6,
		trackstrength = 10,
		tracktype = "StdTank",
		trackwidth = 45,
		turninplace = 0,
		turninplace = true,
		turninplaceanglelimit = 110,
		turninplacespeedlimit = 1.287,
		turnrate = 400,
		script = "BASICTANKSCRIPT.LUA",
		customparams = {
			--ANIMATION DATA
				--PIECENAMES HERE
					basename = "base",
					turretname = "turret",
					sleevename = "sleeve",
					cannon1name = "barrel",
					flare1name = "emit",
					cannon2name = nil, --optional (replace with nil)
					flare2name = nil, --optional (replace with nil)
				--SFXs HERE
					firingceg = "barrelshot-medium",
					driftratio = "0.25", --How likely will the unit drift when performing turns?
					rockstrength = "2", --Howmuch will its weapon make it rock ?
					rockspeed = "80", -- More datas about rock(honestly you can keep 2 and 1 as default here)
					rockrestorespeed = "20", -- More datas about rock(honestly you can keep 2 and 1 as default here)
					cobkickbackrestorespeed = "3", --How fast will the cannon come back in position?
					kickback = "-4", --How much will the cannon kickback
				--AIMING HERE
					cobturretyspeed = "55", --turretSpeed as seen in COB script
					cobturretxspeed = "35", --turretSpeed as seen in COB script
					restoretime = "3000", --restore delay as seen in COB script
		},
		featuredefs = {
			dead = {
				blocking = true,
				category = "corpses",
				collisionvolumeoffsets = "4.526512146 -4.16978120361 3.13526153564",
				collisionvolumescales = "36.4536895752 11.1021575928 54.8021697998",
				collisionvolumetype = "Box",
				damage = 4000,
				description = "Poison Arrow Wreckage",
				energy = 0,
				featuredead = "HEAP",
				featurereclamate = "SMUDGE01",
				footprintx = 3,
				footprintz = 3,
				height = 9,
				hitdensity = 100,
				metal = 642,
				object = "CORPARROW_DEAD",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "all",
			},
			heap = {
				blocking = false,
				category = "heaps",
				damage = 3000,
				description = "Poison Arrow Heap",
				energy = 0,
				featurereclamate = "SMUDGE01",
				footprintx = 3,
				footprintz = 3,
				hitdensity = 100,
				metal = 257,
				object = "3X3A",
                collisionvolumescales = "55.0 4.0 6.0",
                collisionvolumetype = "cylY",
				reclaimable = true,
				resurrectable = 0,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "all",
			},
		},
		sfxtypes = { 
 			pieceExplosionGenerators = { 
				"deathceg2",
				"deathceg3",
				"deathceg4",
			},
			explosiongenerators = {
				[1] = "custom:barrelshot-large",
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
				[1] = "tcormove",
			},
			select = {
				[1] = "tcorsel",
			},
		},
		weapondefs = {
			core_parrow = {
				areaofeffect = 160,
				avoidfeature = false,
				craterareaofeffect = 160,
				craterboost = 0,
				cratermult = 0,
				explosiongenerator = "custom:genericshellexplosion-medium",
				gravityaffected = "true",
				impulseboost = 0.123,
				impulsefactor = 0.123,
				name = "PoisonArrowCannon",
				noselfdamage = true,
				range = 575,
				reloadtime = 1.8,
				soundhit = "xplomed1",
				soundhitwet = "splslrg",
				soundhitwetvolume = 0.5,
				soundstart = "largegun",
				turret = true,
				weapontype = "Cannon",
				weaponvelocity = 300,
				damage = {
					bombers = 60,
					default = 370,
					fighters = 60,
					subs = 5,
					vtol = 60,
				},
			},
			-- core_uwparrow = {
				-- areaofeffect = 160,
				-- avoidfeature = false,
				-- craterareaofeffect = 160,
				-- craterboost = 0,
				-- cratermult = 0,
				-- explosiongenerator = "custom:genericshellexplosion-medium",
				-- gravityaffected = "true",
				-- impulseboost = 0.123,
				-- impulsefactor = 0.123,
				-- model = "torpedo",
				-- name = "PoisonArrowCannon",
				-- noselfdamage = true,
				-- range = 575,
				-- reloadtime = 1.8,
				-- soundhit = "xplomed1",
				-- soundhitwet = "splslrg",
				-- soundhitwetvolume = 0.5,
				-- soundstart = "largegun",
				-- turret = true,
				-- waterweapon = true, 
				-- weapontype = "Cannon",
				-- weaponvelocity = 225,
				-- damage = {
					-- bombers = 60,
					-- default = 185,
					-- fighters = 60,
					-- subs = 145,
					-- vtol = 60,
				-- },
			-- },
		},
		weapons = {
			[1] = {
				badtargetcategory = "VTOL",
				def = "CORE_PARROW",
				onlytargetcategory = "",
			},
			-- [2] = {
				-- badtargetcategory = "VTOL",
				-- def = "CORE_UWPARROW",
				-- onlytargetcategory = "NOTHOVER",
			-- },
		},
	},
}
