return {
  components = {
    plant = {
      localX = 1,
    },

    bone = {},

    parentConstraint = {
      enabled = false,
    },
  },

  children = {
    {
      components = {
        jaw = {},
        upper = {},

        bone = {
          transform = {0, 0, -0.375 * math.pi},
        },

        parentConstraint = {},
      },

      children = {
        {
          components = {
            bone = {
              transform = {0, 0, 0, 1 / 32, 1 / 32, 3, 11},
            },

            parentConstraint = {},

            sprite = {
              image = "carnelia/resources/images/plant/upperJaw.png",
              normalMap = "carnelia/resources/images/plant/upperJawNormal.png",
            },
          },
        },
      },
    },

    {
      components = {
        jaw = {},
        lower = {},

        bone = {
          transform = {0, 0, 0.375 * math.pi},
        },

        parentConstraint = {},
      },

      children = {
        {
          components = {
            bone = {
              transform = {0, 0, 0, 1 / 32, 1 / 32, 3, 3},
            },

            parentConstraint = {},

            sprite = {
              image = "carnelia/resources/images/plant/lowerJaw.png",
              normalMap = "carnelia/resources/images/plant/lowerJawNormal.png",
            },
          },
        },
      },
    },
  },
}
