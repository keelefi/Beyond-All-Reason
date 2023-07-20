return {
	raptor_turretl = {
		acceleration = 0.0115,
		activatewhenbuilt = true,
		autoheal = 1,
		bmcode = "0",
		brakerate = 0.0115,
		buildcostenergy = 6000,
		buildcostmetal = 240,
		builddistance = 500,
		builder = false,
		buildpic = "raptors/raptor_turretl.DDS",
		buildtime = 5200,
		canattack = true,
		canreclaim = false,
		canrestore = false,
		canstop = "1",
		capturable = false,
		category = "BOT MOBILE WEAPON ALL NOTSUB NOTSHIP NOTAIR NOTHOVER SURFACE RAPTOR EMPABLE",
		collisionvolumeoffsets = "0 -15 0",
		collisionvolumescales = "40 50 40",
		collisionvolumetype = "box",
		--energystorage = 500,
		explodeas = "tentacle_death",
		--extractsmetal = 0.001,
		footprintx = 4,
		footprintz = 4,
		idleautoheal = 15,
		idletime = 300,
		levelground = false,
		mass = 1400,
		maxdamage = 11100,
		maxslope = 255,
		maxvelocity = 0,
		maxwaterdepth = 0,
		movementclass = "NANO",
		noautofire = false,
		nochasecategory = "MOBILE",
		objectname = "Raptors/raptor_turretl_v2.s3o",
		--reclaimspeed = 200,
		repairable = false,
		script = "Raptors/raptor_turretl_v2.cob",
		seismicsignature = 0,
		selfdestructas = "tentacle_death",
		side = "THUNDERBIRDS",
		sightdistance = 500,
		smoothanim = true,
		tedclass = "METAL",
		turninplace = true,
		turninplaceanglelimit = 90,
		turnrate = 1840,
		unitname = "raptord2",
		upright = false,
		waterline = 1,
		workertime = 100,
		customparams = {
			subfolder = "other/raptors",
			model_author = "LathanStanley, Beherith",
			normalmaps = "yes",
			normaltex = "unittextures/raptor_l_normals.png",
			treeshader = "yes",
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
			weapon = {
				accuracy = 256,
				areaofeffect = 256,
				collidefriendly = 0,
				collidefeature = 0,
				avoidfeature = 0,
				avoidfriendly = 0,
				burst = 1,
				burstrate = 0.5,
				cegtag = "blob_trail_red",
				collidefriendly = 0,
				craterareaofeffect = 256,
				craterboost = 0.2,
				cratermult = 0.2,
				edgeeffectiveness = 0.63,
				--explosiongenerator = "custom:ELECTRIC_EXPLOSION",
				explosiongenerator = "custom:genericshellexplosion-huge",
				impulseboost = 0,
				impulsefactor = 0.4,
				intensity = 0.7,
				interceptedbyshieldtype = 1,
				name = "GOOLAUNCHER",
				noselfdamage = true,
				proximitypriority = -4,
				range = 2000,
				reloadtime = 6,
				rgbcolor = "1 0.5 0.1",
				size = 5.5,
				sizedecay = 0.09,
				soundhit = "bombsmed2",
				soundstart = "bugarty",
				sprayangle = 512,
				tolerance = 5000,
				turret = true,
				weapontimer = 0.2,
				weaponvelocity = 750,
				damage = {
					default = 1280,
					shields = 320,
				},
			},
			-- cc_laser = {
			-- 	areaofeffect = 64,
			-- 	avoidfeature = false,
			-- 	beamtime = 2.4,
			-- 	cameraShake = 200,
			-- 	corethickness = 0.3,
			-- 	craterareaofeffect = 0,
			-- 	craterboost = 0,
			-- 	cratermult = 0,
			-- 	edgeeffectiveness = 0.55,
			-- 	explosiongenerator = "custom:laserhit-large-yellow",
			-- 	firestarter = 90,
			-- 	impulseboost = 0,
			-- 	impulsefactor = 0,
			-- 	intensity = 1.0,
			-- 	laserflaresize = 5.5,
			-- 	leadLimit = 16,
			-- 	minIntensity = 0.8,
			-- 	name = "HeatRay",
			-- 	noselfdamage = true,
			-- 	range = 400,
			-- 	reloadtime = 5.5,
			-- 	rgbcolor = "0.47 0.21 0",
			-- 	rgbcolor2 = "1 0.88 0.5",
			-- 	soundhitdry = "",
			-- 	soundhitwet = "sizzle",
			-- 	soundstart = "raptorlaser",
			-- 	--soundhitvolume = 6,
			-- 	soundstartvolume = 34,
			-- 	soundtrigger = 1,
			-- 	--sweepFire = true,
			-- 	targetborder = 0.3,
			-- 	targetmoveerror = 0.1,
			-- 	thickness = 4.8,
			-- 	tolerance = 60000,
			-- 	turret = true,
			-- 	weapontype = "BeamLaser",
			-- 	weaponvelocity = 700,
			-- 	damage = {
			-- 		raptor = 0.1,
			-- 		default = 28000,
			-- 	},
			-- },
		},
		weapons = {
			[1] = {
				def = "WEAPON",
				onlytargetcategory = "NOTAIR",
			},
			-- [2] = {
			-- 	def = "CC_LASER",
			-- },
		},
	},
}
