local Class = require 'libs.classic'
local Vector = require 'libs.vector'
local Anim8 = require 'libs.anim8'

local Player = Class:extend()

local Direction = {
    LEFT = -1,
    RIGHT = 1
}

function Player:new(x, y, world, camera, characterID)
    -- World
    self.world = world
    self.camera = camera

    -- Movement
    self.position = Vector(x, y)
    self.velocity = Vector(0, 0)
    self.friction = 10
    self.speed = 1200

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

    -- Animation
    local images = {
        idle = love.graphics.newImage('assets/images/animation/' .. characterID .. '/' .. characterID .. '_idle.png'),
        run = love.graphics.newImage('assets/images/animation/' .. characterID .. '/' .. characterID .. '_run.png'),
        hit = love.graphics.newImage('assets/images/animation/' .. characterID .. '/' .. characterID .. '_hit.png'),
    }

    self.animation = {
        idle = {
            image = images.idle,
            animation = Anim8.newAnimation(
                Anim8.newGrid(
                    images.idle:getWidth() / 4,
                    images.idle:getHeight(),
                    images.idle:getWidth(),
                    images.idle:getHeight())('1-4', 1),
                0.2)
        },
        run = {
            image = images.run,
            animation = Anim8.newAnimation(
                Anim8.newGrid(
                    images.run:getWidth() / 4,
                    images.run:getHeight(),
                    images.run:getWidth(),
                    images.run:getHeight())('1-4', 1),
                0.1)
        },
        hit = {
            image = images.hit,
            animation = Anim8.newAnimation(
                Anim8.newGrid(
                    images.hit:getWidth(),
                    images.hit:getHeight(),
                    images.hit:getWidth(),
                    images.hit:getHeight())(1, 1),
                1)
        },
    }

    self.currentAnimation = self.animation.idle
    self.direction = Direction.RIGHT
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

function Player:updateAnimations(dt)
    if self.velocity:len() > 70 then
        self.currentAnimation = self.animation.run
    else
        self.currentAnimation = self.animation.idle
    end

    -- Change direction based on mouse position relative to player
    local screenPos = Vector(self.camera:cameraCoords(self.position.x, self.position.y))

    self.direction = Direction.LEFT
    if Mouse.x > screenPos.x then
        self.direction = Direction.RIGHT
    end


    self.currentAnimation.animation:update(dt)
end

function Player:update(dt)
    self:move(dt)
    self:physics(dt)
    self:updateAnimations(dt)
end

function Player:draw()
    self.currentAnimation.animation:draw(
        self.currentAnimation.image,
        self.position.x, self.position.y,
        0, self.direction * 0.9, 0.9,
        self.width / 2 + 3, self.height + 3)
end

function Player:drawUI()
end

return Player
