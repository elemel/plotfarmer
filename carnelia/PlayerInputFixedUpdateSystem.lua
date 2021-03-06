local heart = require("heart")

local M = heart.class.newClass()

function M:init(game, config)
  self.game = assert(game)

  self.physicsDomain = assert(self.game.domains.physics)
  self.timerDomain = assert(self.game.domains.timer)

  self.playerEntities = assert(self.game.componentEntitySets.player)

  self.characterComponents = assert(self.game.componentManagers.character)

  self.characterLowerStateComponents =
    assert(self.game.componentManagers.characterLowerState)

  self.characterUpperStateComponents =
    assert(self.game.componentManagers.characterUpperState)

  self.raySensorComponents = assert(self.game.componentManagers.raySensor)
end

function M:handleEvent(dt)
  local fixedTime = self.timerDomain:getFixedTime()

  local bodies = self.physicsDomain.bodies

  local inputXs = self.characterComponents.inputXs
  local inputYs = self.characterComponents.inputYs

  local lowerStateComponents = self.characterLowerStateComponents
  local upperStateComponents = self.characterUpperStateComponents

  local lowerStates = self.characterLowerStateComponents.states
  local upperStates = self.characterUpperStateComponents.states

  local contacts = self.raySensorComponents.contacts
  local directionXs = self.characterComponents.directionXs

  local targetXs = self.characterComponents.targetXs
  local targetYs = self.characterComponents.targetYs

  local leftInput = love.keyboard.isDown("a")
  local rightInput = love.keyboard.isDown("d")

  local upInput = love.keyboard.isDown("w")
  local downInput = love.keyboard.isDown("s")

  local runInput = love.keyboard.isDown("lshift")

  local inputX = (rightInput and 1 or 0) - (leftInput and 1 or 0)
  local inputY = (downInput and 1 or 0) - (upInput and 1 or 0)

  for id in pairs(self.playerEntities) do
    if lowerStates[id] == "crouching" then
      if not contacts[id] then
        lowerStateComponents:setState(id, "falling")
      elseif inputY ~= 1 then
        lowerStateComponents:setState(id, "standing")
      end
    elseif lowerStates[id] == "falling" then
      if contacts[id] then
        lowerStateComponents:setState(id, "standing")
      end
    elseif lowerStates[id] == "running" then
      if not contacts[id] then
        lowerStateComponents:setState(id, "falling")
      elseif not runInput or inputX ~= directionXs[id] then
        lowerStateComponents:setState(id, "walking")
      end
    elseif lowerStates[id] == "standing" then
      if not contacts[id] then
        lowerStateComponents:setState(id, "falling")
      elseif inputY == 1 then
        lowerStateComponents:setState(id, "crouching")
      elseif inputX ~= 0 then
        lowerStateComponents:setState(id, "walking")
      end
    elseif lowerStates[id] == "walking" then
      if not contacts[id] then
        lowerStateComponents:setState(id, "falling")
      elseif inputX == 0 then
        lowerStateComponents:setState(id, "standing")
      elseif runInput and inputX == directionXs[id] then
        lowerStateComponents:setState(id, "running")
      end
    end

    if upperStates[id] == "aiming" then
      if runInput then
        upperStateComponents:setState(id, "vaultAiming")
      end
    elseif upperStates[id] == "vaultAiming" then
      if not runInput then
        upperStateComponents:setState(id, "aiming")
      end
    end

    inputXs[id] = inputX
    inputYs[id] = inputY

    local contact = contacts[id]
    local body = bodies[id]
    local x, y = body:getPosition()

    if contact then
      local distance = heart.math.distance2(x, y, contact.x, contact.y)
      local targetDistance = 1.25

      if inputY == 1 then
        if inputX == 0 then
          targetDistance = 1
        end
      end

      local positionError = targetDistance - distance
      local mass = body:getMass()
      local stiffness = 100
      local damping = 10
      local linearVelocityX, linearVelocityY = body:getLinearVelocity()

      local tangentX = contact.normalY
      local tangentY = -contact.normalX

      local contactBody = contact.fixture:getBody()

      local contactLinearVelocityX, contactLinearVelocityY =
        contactBody:getLinearVelocityFromWorldPoint(contact.x, contact.y)

      local targetVelocity = 0

      if lowerStates[id] == "running" then
        targetVelocity = 8
      elseif lowerStates[id] == "walking" then
        if inputY == 1 then
          targetVelocity = 3
        else
          targetVelocity = 5
        end
      end

      local velocityErrorX = contactLinearVelocityX + targetVelocity * inputX - linearVelocityX

      local velocityErrorY = contactLinearVelocityY - linearVelocityY - linearVelocityX * tangentY

      local forceX = 0
      local forceY = 0

      forceY = forceY - stiffness * mass * positionError
      forceY = forceY + damping * mass * velocityErrorY

      if upperStates[id] == "vaulting" then
        forceY = math.min(0, forceY)
      end

      local maxWalkForce = 50

      local walkForce = heart.math.clamp(
        10 * mass * velocityErrorX, -maxWalkForce, maxWalkForce)

      forceX = forceX - walkForce * tangentX
      forceY = forceY - walkForce * tangentY

      body:applyForce(forceX, forceY, x, y)
      contactBody:applyForce(-forceX, -forceY, x, y)
    end

    local angle = bodies[id]:getAngle()
    local targetAngle = 0

    local angularStiffness = 20
    local angularDamping = 2

    if lowerStates[id] == "falling" then
      -- targetAngle = heart.math.normalizeAngle(math.atan2(targetYs[id] - y, targetXs[id] - x) + 0.5 * math.pi)
      -- targetAngle = heart.math.mix(0, targetAngle, math.cos(targetAngle) * math.cos(targetAngle))

      -- angularStiffness = 5
      -- angularDamping = 0.5

      angularStiffness = 0
      angularDamping = 0
    end

    local anglularError = heart.math.normalizeAngle(targetAngle - angle)
    local angularVelocity = bodies[id]:getAngularVelocity()
    local angularVelocityError = -angularVelocity

    bodies[id]:applyTorque(
      angularStiffness * anglularError + angularDamping * angularVelocityError)
  end
end

return M
