-- unit footsteps CURRENTLY DISABLED

return {
  ["footstep-small"] = {
    dirtsplat = {
            class              = [[CSimpleParticleSystem]],
            count              = 2, -- 2
            ground             = true,
            properties = {
                airdrag            = 0.95,
                colormap           = [[0.08 0.06 0.02 0.88   0.1 0.07 0.033 0.68    0 0 0 0]],
                directional        = false,
                emitrot            = 180,
                emitrotspread      = 45,
                emitvector         = [[0, -0.3, 0]],
                gravity            = [[0, -0.08, 0]],
                numparticles       = [[1.2 r0.8]],
                particlelife       = 17,
                particlelifespread = 35,
                particlesize       = 3.5,
                particlesizespread = 10,
                particlespeed      = 2.5,
                particlespeedspread = 10,
                pos                = [[0, 6, 0]],
                rotParams          = [[-10 r20, 0, -180 r360]],
                sizegrowth         = [[-0.05 r0.18]],
                sizemod            = 1,
                texture            = [[randdots]],
                useairlos          = false,
                alwaysvisible      = false,
                castShadow         = true,
            },
        },
    dirtg2 = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,-- 1
      ground             = true,
      properties = {
        airdrag            = 0.67,
        --colormap           = [[0.20 0.18 0.14 0.55   0.35 0.30 0.27 0.50       0 0 0 0.01]],
        colormap           = [[0.15 0.12 0.07 0.7    0.06 0.04 0.04 0.4   0 0 0 0.01]],
        directional        = false,
        emitrot            = 60,
        emitrotspread      = 45,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, 0.09 r0.07, 0]],
        numparticles       = 1,
        particlelife       = 30,
        particlelifespread = 15,
        particlesize       = 28,
        particlesizespread = 10,
        particlespeed      = 2,
        particlespeedspread = 2,
        pos                = [[-0.2 r0.4, 0 r4, -0.2 r0.4]],
        rotParams          = [[-10 r20, 0, -180 r360]],
        sizegrowth         = 0.05,
        sizemod            = 1.005,
        texture            = [[smoke-ice-anim]],
        animParams         = [[8,8,50 r45]],
        useairlos          = false,
        alwaysvisible      = false,
        castShadow         = true,
      },
    },
    -- extradebree = {
    --   air                = true,
    --   class              = [[CSimpleParticleSystem]],
    --   count              = 0, -- 1
    --   ground             = true,
    --   water              = true, 
    --   underwater         = true,
    --   properties = {
    --     airdrag            = 0.94,
    --     colormap           = [[0.15 0.15 0.15 1   0.1 0.1 0.1 0.7   0 0 0 0]],
    --     directional        = false,
    --     emitrot            = 45,
    --     emitrotspread      = 45,
    --     emitvector         = [[0, 0.5, 0]],
    --     gravity            = [[0, -0.07, 0]],
    --     numparticles       = 2,
    --     particlelife       = 20,
    --     particlelifespread = 30,
    --     particlesize       = 1,
    --     particlesizespread = 4,
    --     particlespeed      = 6,
    --     particlespeedspread = 14,
    --     pos                = [[0, 4, 0]],
    --     sizegrowth         = 0.2,
    --     sizemod            = 0.98,
    --     texture            = [[shard3]],
    --     useairlos          = false,
    --   },
    -- },
  },
  ["footstep-medium"] = {
    dirtsplat = {
            class              = [[CSimpleParticleSystem]],
            count              = 2, -- 2
            ground             = true,
            properties = {
                airdrag            = 0.95,
                colormap           = [[0.08 0.06 0.02 0.88   0.1 0.07 0.033 0.68    0 0 0 0]],
                directional        = false,
                emitrot            = 180,
                emitrotspread      = 45,
                emitvector         = [[0, -0.3, 0]],
                gravity            = [[0, -0.08, 0]],
                numparticles       = [[1.2 r0.8]],
                particlelife       = 17,
                particlelifespread = 35,
                particlesize       = 3.5,
                particlesizespread = 10,
                particlespeed      = 2.5,
                particlespeedspread = 10,
                pos                = [[0, 6, 0]],
                rotParams          = [[-10 r20, 0, -180 r360]],
                sizegrowth         = [[-0.05 r0.18]],
                sizemod            = 1,
                texture            = [[randdots]],
                useairlos          = false,
                alwaysvisible      = false,
                castShadow         = true,
            },
        },
    dirtg2 = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,-- 1
      ground             = true,
      properties = {
        airdrag            = 0.67,
        --colormap           = [[0.20 0.18 0.14 0.55   0.35 0.30 0.27 0.50       0 0 0 0.01]],
        colormap           = [[0.15 0.12 0.07 0.7    0.06 0.04 0.04 0.4   0 0 0 0.01]],
        directional        = false,
        emitrot            = 60,
        emitrotspread      = 45,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, 0.09 r0.07, 0]],
        numparticles       = 1,
        particlelife       = 30,
        particlelifespread = 15,
        particlesize       = 38,
        particlesizespread = 18,
        particlespeed      = 2,
        particlespeedspread = 2,
        pos                = [[-0.3 r0.6, 0 r4, -0.3 r0.6]],
        rotParams          = [[-10 r20, 0, -180 r360]],
        sizegrowth         = 0.05,
        sizemod            = 1.005,
        texture            = [[smoke-ice-anim]],
        animParams         = [[8,8,60 r45]],
        useairlos          = false,
        alwaysvisible      = false,
        castShadow         = true,
      },
    },
    -- extradebree = {
    --   air                = true,
    --   class              = [[CSimpleParticleSystem]],
    --   count              = 0, -- 1
    --   ground             = true,
    --   water              = true, 
    --   underwater         = true,
    --   properties = {
    --     airdrag            = 0.94,
    --     colormap           = [[0.15 0.15 0.15 1   0.1 0.1 0.1 0.7   0 0 0 0]],
    --     directional        = false,
    --     emitrot            = 45,
    --     emitrotspread      = 45,
    --     emitvector         = [[0, 0.5, 0]],
    --     gravity            = [[0, -0.07, 0]],
    --     numparticles       = 2,
    --     particlelife       = 20,
    --     particlelifespread = 30,
    --     particlesize       = 1,
    --     particlesizespread = 4,
    --     particlespeed      = 6,
    --     particlespeedspread = 14,
    --     pos                = [[0, 4, 0]],
    --     sizegrowth         = 0.2,
    --     sizemod            = 0.98,
    --     texture            = [[shard3]],
    --     useairlos          = false,
    --   },
    -- },
  },

  ["footstep-large"] = {
    dirtsplat = {
            class              = [[CSimpleParticleSystem]],
            count              = 2, -- 2
            ground             = true,
            properties = {
                airdrag            = 0.95,
                colormap           = [[0.08 0.06 0.02 0.88   0.1 0.07 0.033 0.68    0 0 0 0]],
                directional        = false,
                emitrot            = 180,
                emitrotspread      = 45,
                emitvector         = [[0, -0.3, 0]],
                gravity            = [[0, -0.08, 0]],
                numparticles       = [[1.2 r0.9]],
                particlelife       = 17,
                particlelifespread = 35,
                particlesize       = 6.5,
                particlesizespread = 14,
                particlespeed      = 4.5,
                particlespeedspread = 14,
                pos                = [[0, 6, 0]],
                rotParams          = [[-10 r20, 0, -180 r360]],
                sizegrowth         = [[-0.05 r0.18]],
                sizemod            = 1,
                texture            = [[randdots]],
                useairlos          = false,
                alwaysvisible      = false,
                castShadow         = true,
            },
        },
    shockwave_fast = {
          air                = true,
          class              = [[CBitmapMuzzleFlame]],
          count              = 1,
          ground             = true,
          underwater         = false,
          water              = true,
          unit               = true,
          properties = {
            colormap           = [[0 0 0 0.01   0.6 0.5 0.4 0.22    0.4 0.3 0.15 0.15   0.10 0.08 0.04 0.012    0.06 0.04 0.02 0.006    0 0 0 0.01]],
            dir                = [[0, 1, 0]],
            --gravity            = [[0.0, 0.1, 0.0]],
            frontoffset        = 0,
            fronttexture       = [[shockwave]],
            length             = 1,
            sidetexture        = [[none]],
            size               = 1,
            sizegrowth         = [[-35 r8]],
            ttl                = 5,
            pos                = [[0, 0, 0]],
            drawOrder          = 1,
            useairlos          = false,
            alwaysvisible      = false,
          },
        },
    dirtg2 = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,-- 1
      ground             = true,
      properties = {
        airdrag            = 0.69,
        --colormap           = [[0.20 0.18 0.14 0.55   0.35 0.30 0.27 0.50       0 0 0 0.01]],
        colormap           = [[0.14 0.13 0.12 1    0.07 0.07 0.06 0.8   0 0 0 0.01]],
        directional        = false,
        emitrot            = 60,
        emitrotspread      = 45,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, 0.09 r0.07, 0]],
        numparticles       = 1,
        particlelife       = 40,
        particlelifespread = 15,
        particlesize       = 45,
        particlesizespread = 15,
        particlespeed      = 3,
        particlespeedspread = 3,
        pos                = [[-0.2 r0.4, 3 r8, -0.2 r0.4]],
        rotParams          = [[-10 r20, 0, -180 r360]],
        sizegrowth         = 0.05,
        sizemod            = 1.001,
        texture            = [[smoke-anim]],
        animParams         = [[8,6,41 r45]],
        useairlos          = false,
        alwaysvisible      = false,
        castShadow         = false,
      },
    },
    extradebree = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 0, -- 1
      ground             = true,
      water              = true, 
      underwater         = true,
      properties = {
        airdrag            = 0.94,
        colormap           = [[0.15 0.15 0.15 1   0.1 0.1 0.1 0.7   0 0 0 0]],
        directional        = false,
        emitrot            = 45,
        emitrotspread      = 45,
        emitvector         = [[0, 0.5, 0]],
        gravity            = [[0, -0.07, 0]],
        numparticles       = 2,
        particlelife       = 20,
        particlelifespread = 30,
        particlesize       = 1,
        particlesizespread = 4,
        particlespeed      = 6,
        particlespeedspread = 14,
        pos                = [[0, 4, 0]],
        sizegrowth         = 0.2,
        sizemod            = 0.98,
        texture            = [[shard3]],
        useairlos          = false,
      },
    },
  },

  ["footstep-huge"] = {
    dirtsplat = {
            class              = [[CSimpleParticleSystem]],
            count              = 2, -- 2
            ground             = true,
            properties = {
                airdrag            = 0.95,
                colormap           = [[0.08 0.06 0.02 0.88   0.1 0.07 0.033 0.68    0 0 0 0]],
                directional        = false,
                emitrot            = 180,
                emitrotspread      = 45,
                emitvector         = [[0, -0.6, 0]],
                gravity            = [[0, -0.12, 0]],
                numparticles       = [[1.2 r0.8]],
                particlelife       = 17,
                particlelifespread = 35,
                particlesize       = 10.5,
                particlesizespread = 15,
                particlespeed      = 2.5,
                particlespeedspread = 8,
                pos                = [[0, 0, 0]],
                rotParams          = [[-10 r20, 0, -180 r360]],
                sizegrowth         = [[-0.05 r0.20]],
                sizemod            = 1,
                texture            = [[randdots]],
                useairlos          = false,
                alwaysvisible      = false,
                castShadow         = true,
            },
        },
    shockwave_fast = {
          air                = true,
          class              = [[CBitmapMuzzleFlame]],
          count              = 1,
          ground             = true,
          underwater         = false,
          water              = true,
          unit               = true,
          properties = {
            colormap           = [[0 0 0 0.01   0.6 0.5 0.4 0.22    0.4 0.3 0.15 0.15   0.10 0.08 0.04 0.012    0.06 0.04 0.02 0.006    0 0 0 0.01]],
            dir                = [[0, 1, 0]],
            --gravity            = [[0.0, 0.1, 0.0]],
            frontoffset        = 0,
            fronttexture       = [[shockwave]],
            length             = 1,
            sidetexture        = [[none]],
            size               = 1,
            sizegrowth         = [[-40 r12]],
            ttl                = 6,
            pos                = [[0, 0, 0]],
            drawOrder          = 1,
            useairlos          = false,
            alwaysvisible      = false,
          },
        },
    dirtg2 = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 2,-- 1
      ground             = true,
      properties = {
        airdrag            = 0.72,
        --colormap           = [[0.20 0.18 0.14 0.55   0.35 0.30 0.27 0.50       0 0 0 0.01]],
        colormap           = [[0.15 0.12 0.07 1    0.06 0.04 0.04 0.6   0 0 0 0.01]],
        directional        = false,
        emitrot            = 60,
        emitrotspread      = 45,
        emitvector         = [[0, 1, 0]],
        gravity            = [[-0.05 r0.1, 0.16 r0.14, -0.05 r0.1]],
        numparticles       = 1,
        particlelife       = 60,
        particlelifespread = 0,
        particlesize       = 40,
        particlesizespread = 28,
        particlespeed      = 2,
        particlespeedspread = 2,
        pos                = [[-4 r8, 32 r12, -4 r8]],
        rotParams          = [[-10 r20, 0, -180 r360]],
        sizegrowth         = 0.17,
        sizemod            = 1.005,
        -- texture            = [[smoke-ice-anim]],
        texture            = [[smoke-anim]],
        animParams         = [[8,6,41 r45]],
        useairlos          = false,
        alwaysvisible      = false,
        --castShadow         = true,
      },
    },
    extradebree = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1, -- 1
      ground             = true,
      water              = true, 
      underwater         = true,
      properties = {
        airdrag            = 0.94,
        colormap           = [[0.15 0.15 0.15 1   0.1 0.1 0.1 0.7   0 0 0 0]],
        directional        = false,
        emitrot            = 45,
        emitrotspread      = 45,
        emitvector         = [[0, 0.5, 0]],
        gravity            = [[0, -0.07, 0]],
        numparticles       = 2,
        particlelife       = 20,
        particlelifespread = 30,
        particlesize       = 1,
        particlesizespread = 4,
        particlespeed      = 6,
        particlespeedspread = 14,
        pos                = [[0, 0, 0]],
        sizegrowth         = 0.2,
        sizemod            = 0.98,
        texture            = [[shard3]],
        useairlos          = false,
      },
    },
  },
}

