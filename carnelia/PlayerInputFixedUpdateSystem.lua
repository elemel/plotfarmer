local heart = require("heart")

local M = heart.class.newClass()

function M:init(game, system)
  self.game = assert(game)

  self.physicsDomain = assert(self.game.domains.physics)
  self.timerDomain = assert(self.game.domains.timer)

  self.playerEntities = assert(self.game.componentEntitySets.player)

  self.characterComponents = assert(self.game.componentManagers.character)

  self.characterLowerStateComponents =
    assert(self.game.componentManagers.characterLowerState)

  self.raySensorComponents = assert(self.game.componentManagers.raySensor)
end

function M:handleEvent(dt)
  local fixedTime = self.timerDomain:getFixedTime()

  local bodies = self.physicsDomain.bodies
  local inputXs = self.characterComponents.inputXs
  local states = self.characterLowerStateComponents.states
  local contacts = self.raySensorComponents.contacts
  local directionXs = self.characterComponents.directionXs

  local leftInput = love.keyboard.isDown("a")
  local rightInput = love.keyboard.isDown("d")
  local inputX = (rightInput and 1 or 0) - (leftInput and 1 or 0)

  for id in pairs(self.playerEntities) do
    inputXs[id] = inputX
    contact = contacts[id]

    if contact then
      local body = bodies[id]
      local x, y = body:getPosition()
      local distance = heart.math.distance2(x, y, contact.x, contact.y)
      local targetDistance = 1.25

      -- TODO: Add proper state for crouching
      if love.keyboard.isDown("s") then
        targetDistance = 0.875
      end

      if inputX ~= 0 then
        local angle = 20 * fixedTime
        targetDistance = targetDistance + 0.125 * math.sin(angle)
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

      local velocityErrorX = contactLinearVelocityX + 5 * inputX - linearVelocityX

      local velocityErrorY = contactLinearVelocityY - linearVelocityY - linearVelocityX * tangentY
      --body:applyForce(0, -stiffness * mass * positionError + damping * mass * velocityErrorY)

      local forceX = 0
      local forceY = 0

      forceY = forceY + math.min(
        0, -stiffness * mass * positionError + damping * mass * velocityErrorY)

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

    if love.keyboard.isDown("s") then
      targetAngle = 0.25 * math.pi * directionXs[id]
    end

    local anglularError = heart.math.normalizeAngle(targetAngle - angle)
    local angularVelocity = bodies[id]:getAngularVelocity()
    local angularVelocityError = -angularVelocity
    local angularStiffness = 100
    local angularDamping = 10

    bodies[id]:applyTorque(
      angularStiffness * anglularError + angularDamping * angularVelocityError)

    states[id] = inputX == 0 and "standing" or "running"
  end
end

return M
