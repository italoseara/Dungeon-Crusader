local Class = require 'libs.classic'
local Vector = require 'libs.vector'

local Player = Class:extend()

function Player:new(x, y, world)
    -- World
    self.world = world

    -- Movement
    self.position = Vector(x, y)
    self.velocity = Vector(0, 0)
    self.friction = 10
    self.speed = 1000

    -- Collision
    self.width = 10
    self.height = 16

    self.collider = self.world:newBSGRectangleCollider(
        self.position.x - self.width / 2, self.position.y - self.height / 2,
        self.width, self.height, 2)
    self.collider:setCollisionClass('Player')
    self.collider:setFixedRotation(true)

    -- Keybinds
    self.keybinds = {
        up = 'w',
        down = 's',
        left = 'a',
        right = 'd'
    }
end

function Player:move(dt)
    local direction = Vector(0, 0)

    if love.keyboard.isDown(self.keybinds.up) then direction.y = direction.y - 1 end
    if love.keyboard.isDown(self.keybinds.down) then direction.y = direction.y + 1 end
    if love.keyboard.isDown(self.keybinds.left) then direction.x = direction.x - 1 end
    if love.keyboard.isDown(self.keybinds.right) then direction.x = direction.x + 1 end

    if direction:len() > 0 then direction = direction:normalized() end

    self.velocity = self.velocity + direction * self.speed * dt
end

function Player:physics(dt)
    self.collider:setLinearVelocity(self.velocity.x, self.velocity.y)
    self.position = Vector(self.collider:getPosition())
    self.velocity = self.velocity * (1 - math.min(dt * self.friction, 1))
end

function Player:update(dt)
    self:move(dt)
    self:physics(dt)
end

function Player:draw()

end

return Player
