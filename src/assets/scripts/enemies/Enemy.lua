local Class = require 'libs.classic'
local Vector = require 'libs.vector'
local Anim8 = require 'libs.anim8'
local Timer = require 'libs.timer'

local DamageIndicator = require 'assets.scripts.ui.DamageIndicator'

local Enemy = Class:extend()

local Direction = {
    LEFT = -1,
    RIGHT = 1
}

function Enemy:new(x, y, game)
    -- Set by child:
    -- self.name
    -- self.width
    -- self.height
    -- self.maxHealth
    -- self.attackSpeed
    -- self.attackDamage
    -- self.speed

    self.type = 'enemy'

    -- Health
    self.dead = false
    self.maxHealth = self.maxHealth or 100
    self.health = self.maxHealth

    self.damageIndicators = {}

    -- Game
    self.game = game
    self.world = game.world

    -- Movement
    self.position = Vector(x, y)
    self.velocity = Vector(0, 0)
    self.friction = 10
    self.speed = self.speed or 800

    -- Collision
    self.collider = self.world:newBSGRectangleCollider(
        self.position.x - self.width / 2, self.position.y - self.height / 2,
        self.width, self.height, 2)
    self.collider:setCollisionClass('Enemy')
    self.collider:setFixedRotation(true)
    self.collider:setObject(self)

    -- Attack
    self.lastHit = 0
    self.hitDelay = 0.5

    -- Animation
    local images = {
        idle = love.graphics.newImage('assets/images/animation/' .. self.name .. '/' .. self.name .. '_idle.png'),
        run = love.graphics.newImage('assets/images/animation/' .. self.name .. '/' .. self.name .. '_run.png'),
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
        }
    }

    self.walkingDirection = Direction.RIGHT
    self.currentAnimation = self.animation.idle
end

function Enemy:updateMovement(dt)

end

function Enemy:updatePhysics(dt)
    if not self.collider then return end
    self.collider:setLinearVelocity(self.velocity.x, self.velocity.y)
    self.position = Vector(self.collider:getPosition())
    self.velocity = self.velocity * (1 - math.min(dt * self.friction, 1))
end

function Enemy:updateAnimations(dt)
    if self.velocity:len() > 50 then
        self.currentAnimation = self.animation.run

        -- Change direction based on velocity
        self.walkingDirection = Direction.LEFT
        if self.velocity.x > 0 then
            self.walkingDirection = Direction.RIGHT
        end
    else
        self.currentAnimation = self.animation.idle
    end

    self.currentAnimation.animation:update(dt)
end

function Enemy:takeDamage(damage, angle, knockback)
    if love.timer.getTime() - self.lastHit < self.hitDelay then return end

    self.lastHit = love.timer.getTime()
    self.health = self.health - damage
    self.velocity = self.velocity + Vector(math.cos(angle), math.sin(angle)) * knockback

    if self.health <= 0 then
        self:die()
    end

    table.insert(self.damageIndicators, DamageIndicator(damage, self))
end

function Enemy:die()
    self.health = 0
    self.dead = true

    Timer.after(5, function()
        self.collider:destroy()
        self.game:removeEnemy(self)
    end)
end

function Enemy:updateDamageIndicators(dt)
    for i, damageIndicator in ipairs(self.damageIndicators) do
        if damageIndicator.dead then
            table.remove(self.damageIndicators, i)
        end
    end
end

function Enemy:drawDamageIndicators()
    for i, damageIndicator in ipairs(self.damageIndicators) do
        damageIndicator:draw()
    end
end

function Enemy:update(dt)
    self:updateDamageIndicators(dt)
    self:updatePhysics(dt)

    if self.dead then return end

    self:updateMovement(dt)
    self:updateAnimations(dt)
end

function Enemy:drawBody()
    local rotation = 0
    if self.dead then
        rotation = -math.pi / 2 * self.walkingDirection
    end

    self.currentAnimation.animation:draw(
        self.currentAnimation.image,
        self.position.x, self.position.y,
        rotation, self.walkingDirection * 0.9, 0.9,
        self.width / 2 + 3, self.height + 3)
end

function Enemy:drawHit()
    if love.timer.getTime() - self.lastHit < 0.1 then
        love.graphics.setColor(1, 0, 0, 0.3)
        love.graphics.setShader(Shaders.damage)
        self:drawBody()
        love.graphics.setColor(1, 1, 1)
        love.graphics.setShader()
    end
end

function Enemy:draw()
    self:drawBody()
    self:drawHit()
end

function Enemy:drawUI()
    self:drawDamageIndicators()
end

return Enemy
