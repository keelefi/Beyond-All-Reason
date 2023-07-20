return {
	raptorebomber1 = {
		acceleration = 1,
		airhoverfactor = 0,
		attackrunlength = 32,
		bmcode = "1",
		brakerate = 0.1,
		buildcostenergy = 50,
		buildcostmetal = 50,
		builder = false,
		buildpic = "raptors/raptorebomber1.DDS",
		buildtime = 6000,
		canattack = true,
		canfly = true,
		canguard = true,
		canland = true,
		canloopbackattack = true,
		canmove = true,
		canpatrol = true,
		canstop = "1",
		cansubmerge = true,
		capturable = false,
		category = "ALL MOBILE WEAPON NOTLAND VTOL NOTSUB NOTSHIP NOTHOVER RAPTOR",
		collide = true,
		collisionvolumeoffsets = "0 0 0",
		collisionvolumescales = "75 75 75",
		collisionvolumetype = "sphere",
		cruisealt = 220,
		defaultmissiontype = "Standby",
		explodeas = "raptor_empdeath_small",
		footprintx = 3,
		footprintz = 3,
		hidedamage = 1,
		idleautoheal = 15,
		idletime = 900,
		maneuverleashlength = "20000",
		mass = 227.5,
		maxacc = 0.25,
		maxaileron = 0.025,
		maxbank = 0.8,
		maxdamage = 835,
		maxelevator = 0.025,
		maxpitch = 0.75,
		maxrudder = 0.025,
		maxvelocity = 7,
		moverate1 = "32",
		noautofire = false,
		nochasecategory = "VTOL",
		objectname = "Raptors/raptorebomber1.s3o",
		radardistance = 500,
		script = "Raptors/raptorf2.cob",
		seismicsignature = 0,
		selfdestructas = "raptor_empdeath_small",
		side = "THUNDERBIRDS",
		sightdistance = 1000,
		smoothanim = true,
		speedtofront = 0.07,
		steeringmode = "2",
		tedclass = "VTOL",
		turninplace = true,
		turnradius = 64,
		turnrate = 1600,
		unitname = "raptorebomber1",
		usesmoothmesh = true,
		wingangle = 0.06593,
		wingdrag = 0.835,
		workertime = 0,
		customparams = {
			subfolder = "other/raptors",
			model_author = "KDR_11k, Beherith",
			normalmaps = "yes",
			normaltex = "unittextures/raptor_m_normals.png",
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
			weapon = {
				accuracy = 10000,
				areaofeffect = 240,
				collidefriendly = 0,
				collidefeature = 0,
				avoidfeature = 0,
				avoidfriendly = 0,
				burst = 4,
				burstrate = 0.28,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.3,
				explosiongenerator = "custom:genericshellexplosion-huge-lightning",
				impulseboost = 0,
				impulsefactor = 0,
				interceptedbyshieldtype = 0,
				model = "Raptors/raptoregg_l_blue.s3o",
				mygravity = 0.5,
				name = "GooBombs",
				noselfdamage = true,
				paralyzer = true,
				paralyzetime = 20,
				range = 1500,
				reloadtime = 0.5,
				soundhit = "empbomb",
				soundstart = "alien_bombrel",
				sprayangle = 20000,
				weapontype = "AircraftBomb",
				damage = {
					default = 40000,
				},
			},
		},
		weapons = {
			[1] = {
				def = "WEAPON",
			},
		},
	},
}
