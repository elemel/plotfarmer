return {
  components = {
    player = {},
    transform = {},
    bone = {},

    body = {
      bodyType = "dynamic",
      fixedRotation = true,
    },

    circleFixture = {
      radius = 0.375,
    },

    groundSensor = {
      ray = {0, 0, 0, 1.5},
    },
  },

  children = {
    {
      components = {
        transform = {
          transform = {0, 0, 0, 0.025, 0.025, 47.5, 60},
        },

        bone = {},
        parentConstraint = {},

        sprite = {
          image = "assets/images/skins/player/trunk.png",
        },
      },
    },

    {
      components = {
        wheel = {},

        transform = {
          transform = {0, 0.75},
        },

        body = {
          bodyType = "dynamic",
        },

        rectangleFixture = {
          width = 0.75,
          height = 0.75,
          friction = 5,
        },

        wheelJoint = {
          springFrequency = 5,
          maxMotorTorque = 50,
        },
      },
    },

    {
      prototype = "assets.entities.leg",

      components = {
        left = {},

        transform = {
          transform = {0.125, 0.25, -0.25 * math.pi},
        },
      },
    },

    {
      prototype = "assets.entities.leg",

      components = {
        right = {},

        transform = {
          transform = {-0.125, 0.25, -0.25 * math.pi},
        },
      },
    },
  },
}