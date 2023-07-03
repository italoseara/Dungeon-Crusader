local Class = require 'libs.classic'
local Vector = require 'libs.vector'
local Anim8 = require 'libs.anim8'
local Timer = require 'libs.timer'

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
    self.speed = 800

    -- Collision
    self.width = 10
    self.height = 16

    self.collider = self.world:newBSGRectangleCollider(
        self.position.x - self.width / 2, self.position.y - self.height / 2,
        self.width, self.height, 2)
    self.collider:setCollisionClass('Player')
    self.collider:setFixedRotation(true)
    self.collider:setObject(self)

    -- Keybinds
    self.keybinds = {
        up = 'w',
        down = 's',
        left = 'a',
        right = 'd',
        interact = 'e',
        drop = 'g',
    }

    -- Weapon
    self.weapon = nil

    -- Animation
    local images = {
        idle = love.graphics.newImage('assets/images/animation/' .. characterID .. '/' .. characterID .. '_idle.png'),
        run = love.graphics.newImage('assets/images/animation/' .. characterID .. '/' .. characterID .. '_run.png'),
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
                0.15)
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
    }

    self.currentAnimation = self.animation.idle

    self.walkingDirection = Direction.RIGHT
    self.mouseDirection = Direction.RIGHT

    -- Attacking animation
    self.attacking = false
    self.attackTimer = 0
    self.attackAngle = 0 -- The angle of the attack when it was started
    self.attackChange = false

    -- Pickup
    self.lastPickup = 0
end

function Player:updateMovement(dt)
    local direction = Vector(0, 0)

    if love.keyboard.isDown(self.keybinds.up) then direction.y = direction.y - 1 end
    if love.keyboard.isDown(self.keybinds.down) then direction.y = direction.y + 1 end
    if love.keyboard.isDown(self.keybinds.left) then direction.x = direction.x - 1 end
    if love.keyboard.isDown(self.keybinds.right) then direction.x = direction.x + 1 end

    if direction:len() > 0 then direction = direction:normalized() end

    self.velocity = self.velocity + direction * self.speed * dt
end

function Player:updatePhysics(dt)
    self.collider:setLinearVelocity(self.velocity.x, self.velocity.y)
    self.position = Vector(self.collider:getPosition())
    self.velocity = self.velocity * (1 - math.min(dt * self.friction, 1))
end

function Player:updateAnimations(dt)
    local screenPos = Vector(self.camera:cameraCoords(self.position.x, self.position.y))

    if not self.attacking then
        if self.velocity:len() > 50 then
            self.currentAnimation = self.animation.run

            -- Change direction based on velocity
            self.walkingDirection = Direction.LEFT
            if self.velocity.x > 0 then
                self.walkingDirection = Direction.RIGHT
            end
        else
            self.currentAnimation = self.animation.idle
            self.walkingDirection = self.mouseDirection
        end

        -- Change direction based on mouse position
        self.mouseDirection = Direction.LEFT
        if Mouse.x > screenPos.x then
            self.mouseDirection = Direction.RIGHT
        end
    end

    self.currentAnimation.animation:update(dt)
end

function Player:updateAttack(dt)
    if not self.attacking and self.weapon and love.mouse.isDown(1) then
        self.attackAngle = self:getWeaponAngle()
        self.attackTimer = love.timer.getTime()
        self.walkingDirection = self.mouseDirection
        self.attacking = true

        Timer.after(self.weapon.attackSpeed * 0.75, function()
            self.weapon:onAttack(self.attackAngle)
        end)
    end

    if self.attacking then
        if love.timer.getTime() - self.attackTimer > self.weapon.attackSpeed then
            self.weapon:onAttackEnd(self.attackAngle)
            self.attacking = false
        end
    end
end

function Player:dropWeapon(dt)
    if self.weapon and love.keyboard.isDown(self.keybinds.drop) and not self.attacking then
        self.weapon:drop(self.position.x, self.position.y)
        self.weapon = nil
    end
end

function Player:update(dt)
    self:updateMovement(dt)
    self:updatePhysics(dt)
    self:updateAnimations(dt)
    self:updateAttack(dt)
    self:dropWeapon(dt)
end

function Player:getWeaponAngle()
    if self.attacking then
        local t = love.timer.getTime() - self.attackTimer
        return self.weapon:getAttackAngle(t, self.attackAngle, self.mouseDirection)
    end

    local screenPos = Vector(self.camera:cameraCoords(self.position.x, self.position.y + 4))
    local angle = math.atan2(Mouse.y - screenPos.y + self.height / 2, Mouse.x - screenPos.x)

    return angle
end

function Player:drawWeapon()
    if self.weapon then
        love.graphics.draw(
            self.weapon.image,
            self.position.x,
            self.position.y + 4,
            self:getWeaponAngle() + math.rad(90),
            self.mouseDirection * 0.8, 0.8,
            self.weapon.image:getWidth() / 2,
            self.weapon.image:getHeight() / 2 + 12
        )
    end
end

function Player:draw()
    self.currentAnimation.animation:draw(
        self.currentAnimation.image,
        self.position.x, self.position.y,
        0, self.walkingDirection * 0.9, 0.9,
        self.width / 2 + 3, self.height + 3)
    self:drawWeapon()
end

function Player:drawUI()
end

return Player
