local Class = require 'libs.classic'
local Vector = require 'libs.vector'
local Anim8 = require 'libs.anim8'
local Timer = require 'libs.timer'

local DamageIndicator = require 'assets.scripts.ui.DamageIndicator'

local Player = Class:extend()

local Direction = {
    LEFT = -1,
    RIGHT = 1
}

function Player:new(x, y, game, characterID)
    -- Game
    self.game = game
    self.world = game.world
    self.camera = game.camera

    -- Movement
    self.position = Vector(x, y)
    self.velocity = Vector(0, 0)
    self.friction = 10
    self.speed = 800

    -- Health
    self.maxHealth = 200
    self.health = self.maxHealth
    self.healthRegen = 1
    self.dead = false

    -- Mana
    self.maxMana = 100
    self.mana = self.maxMana
    self.manaRegen = 5

    -- Damage
    self.lastHit = 0
    self.damageIndicators = {}

    -- Collision
    self.width = 10
    self.height = 16

    self.collider = self.world:newBSGRectangleCollider(
        self.position.x - self.width / 2, self.position.y - self.height / 2,
        self.width, self.height, 2)
    self.collider:setCollisionClass('Player')
    self.collider:setFixedRotation(true)
    self.collider:setObject(self)
    self.collider:setPreSolve(function(collider_1, collider_2, contact)
        local other = collider_2:getObject()

        if other.type == 'enemy' and not other.dead then
            if self.lastHit + 0.5 < love.timer.getTime() then
                self.lastHit = love.timer.getTime()
                self.health = self.health - other.attackDamage

                if self.health <= 0 then
                    self:die()
                end

                -- Apply knockback
                local direction = Vector(self.position.x - other.position.x, self.position.y - other.position.y)
                    :normalized()
                self.velocity = self.velocity + direction:normalized() * 200

                if self.dead then return end
                table.insert(self.damageIndicators, DamageIndicator(-other.attackDamage, self))
            end
        end
    end)

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
    self.images = {
        idle  = love.graphics.newImage('assets/images/animation/' .. characterID .. '/' .. characterID .. '_idle.png'),
        run   = love.graphics.newImage('assets/images/animation/' .. characterID .. '/' .. characterID .. '_run.png'),
        heart = love.graphics.newImage('assets/images/ui/ui_heart_full.png'),
        mana  = love.graphics.newImage('assets/images/ui/ui_mana_ball.png'),
    }

    self.animation = {
        idle = {
            image = self.images.idle,
            animation = Anim8.newAnimation(
                Anim8.newGrid(
                    self.images.idle:getWidth() / 4,
                    self.images.idle:getHeight(),
                    self.images.idle:getWidth(),
                    self.images.idle:getHeight())('1-4', 1),
                0.15)
        },
        run = {
            image = self.images.run,
            animation = Anim8.newAnimation(
                Anim8.newGrid(
                    self.images.run:getWidth() / 4,
                    self.images.run:getHeight(),
                    self.images.run:getWidth(),
                    self.images.run:getHeight())('1-4', 1),
                0.1)
        },
    }

    self.currentAnimation = self.animation.idle

    self.walkingDirection = Direction.RIGHT
    self.mouseDirection = Direction.RIGHT

    -- Attacking animation
    self.attacking = false
    self.attackTimer = 0
    self.attackAngle = 0

    -- Pickup
    self.lastPickup = 0

    -- Regeneration
    Timer.every(0.5, function()
        if love.timer.getTime() - self.lastHit < 10 or
            love.timer.getTime() - self.attackTimer < 10 or
            self.dead then
            return
        end

        if self.health < self.maxHealth then
            self.health = self.health + self.healthRegen
            table.insert(self.damageIndicators, DamageIndicator(self.healthRegen, self, { 0, 1, 0, 1 }))
        end

        if self.mana < self.maxMana then
            self.mana = self.mana + self.manaRegen
            table.insert(self.damageIndicators, DamageIndicator(self.manaRegen, self, { 0, 0, 1, 1 }))
        end
    end)
end

function Player:spendMana(cost)
    if self.mana < cost then return false end

    self.mana = self.mana - cost
    return true
end

function Player:die()
    self.game.state = 'over'
    self.health = 0
    self.dead = true

    if not self.weapon then return end
    self.weapon:drop(self.position.x, self.position.y)
    self.weapon = nil
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

    if self.velocity:len() > 50 then
        self.currentAnimation = self.animation.run

        -- Change direction based on velocity
        if not self.attacking then
            self.walkingDirection = Direction.LEFT
            if self.velocity.x > 0 then
                self.walkingDirection = Direction.RIGHT
            end
        end
    else
        self.currentAnimation = self.animation.idle
        if not self.attacking then
            self.walkingDirection = self.mouseDirection
        end
    end

    if not self.attacking then
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
            if not self.weapon then return end
            self.weapon:onAttack(self.attackAngle)
        end)
    end

    if self.attacking then
        if love.timer.getTime() - self.attackTimer > self.weapon.attackSpeed then
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

function Player:updateDamageIndicators()
    for i, damageIndicator in ipairs(self.damageIndicators) do
        if damageIndicator.dead then
            table.remove(self.damageIndicators, i)
        end
    end
end

function Player:update(dt)
    self:updateDamageIndicators()
    self:updatePhysics(dt)

    if self.dead then return end

    self:updateAnimations(dt)

    if self.game.state ~= 'running' then return end

    self:updateAttack(dt)
    self:updateMovement(dt)
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

function Player:drawBody()
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

function Player:drawHit()
    if love.timer.getTime() - self.lastHit < 0.1 then
        love.graphics.setColor(1, 0, 0, 0.3)
        love.graphics.setShader(Shaders.damage)
        self:drawBody()
        love.graphics.setColor(1, 1, 1)
        love.graphics.setShader()
    end
end

function Player:drawDamageIndicators()
    for _, damageIndicator in ipairs(self.damageIndicators) do
        damageIndicator:draw()
    end
end

function Player:drawHealth()
    love.graphics.draw(self.images.heart,
        10, love.graphics.getHeight() - self.images.heart:getHeight() * 2 - 15,
        0, 2, 2)

    local text = love.graphics.newText(Fonts.big, tostring(self.health))
    love.graphics.draw(text, 45, love.graphics.getHeight() - text:getHeight() - 10)
end

function Player:drawMana()
    love.graphics.draw(self.images.mana,
        100, love.graphics.getHeight() - self.images.mana:getHeight() * 2 - 15,
        0, 2, 2)

    local text = love.graphics.newText(Fonts.big, tostring(self.mana))
    love.graphics.draw(text, 135, love.graphics.getHeight() - text:getHeight() - 10)
end

function Player:drawHealthHit()
    if love.timer.getTime() - self.lastHit < 0.1 then
        love.graphics.setColor(1, 0, 0, 0.6)
        self:drawHealth()
        love.graphics.setColor(1, 1, 1)
    end
end

function Player:draw()
    self:drawBody()
    self:drawHit()
    self:drawWeapon()
end

function Player:drawUI()
    self:drawDamageIndicators()
    self:drawHealth()
    self:drawHealthHit()
    self:drawMana()
end

return Player
