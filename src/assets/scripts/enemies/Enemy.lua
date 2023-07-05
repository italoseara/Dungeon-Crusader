local Class = require 'libs.classic'
local Vector = require 'libs.vector'
local Anim8 = require 'libs.anim8'
local Timer = require 'libs.timer'
local AStar = require 'libs.astar'

local DamageIndicator = require 'assets.scripts.ui.DamageIndicator'

local Enemy = Class:extend()

local Direction = {
    LEFT = -1,
    RIGHT = 1
}

function Enemy:new(x, y, game)
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

    -- Pathfinding
    self.path = nil
    self.lastSearch = 0
    self.nextPosition = nil
    self.sawPlayer = false
end

function Enemy:searchPath()
    local map = self.game.level.map

    local start = {}
    local goal = {}
    start.x, start.y = map:convertPixelToTile(self.position.x, self.position.y)
    goal.x, goal.y = map:convertPixelToTile(self.game.player.position.x, self.game.player.position.y)

    goal.x = math.ceil(goal.x - 0.5)
    goal.y = math.ceil(goal.y - 0.5)
    start.x = math.ceil(start.x)
    start.y = math.ceil(start.y)

    self.path = AStar:find(map.width, map.height, start, goal, function(x, y)
        return self.game.level:isFloor(x, y)
    end, false, false)
end

function Enemy:updateMovement(dt)
    if not self.sawPlayer then
        if (self.position - self.game.player.position):len() < self.viewDistance then
            self.sawPlayer = true
        end

        return
    end

    if not self.path or (self.position - self.game.player.position):len() < 30 then
        self.nextPosition = nil
        local direction = (self.game.player.position - self.position):normalized()
        self.velocity = self.velocity + direction * self.speed * dt
    elseif self.path then
        local next = self.path[1]

        if next then
            self.nextPosition = Vector(
                next.x * self.game.level.map.tilewidth - self.game.level.map.tilewidth / 2,
                next.y * self.game.level.map.tileheight - self.game.level.map.tileheight / 2
            )

            local direction = (self.nextPosition - self.position):normalized()
            self.velocity = self.velocity + direction * self.speed * dt

            if (self.nextPosition - self.position):len() < 10 then
                table.remove(self.path, 1)
            end
        end
    end

    -- Search for path
    if love.timer.getTime() - self.lastSearch > 0.2 then
        self:searchPath()
        self.lastSearch = love.timer.getTime()
    end
end

function Enemy:updatePhysics(dt)
    if not self.collider then return end
    self.collider:setLinearVelocity(self.velocity.x, self.velocity.y)
    self.position = Vector(self.collider:getPosition())
    self.velocity = self.velocity * (1 - math.min(dt * self.friction, 1))
end

function Enemy:updateAnimations(dt)
    if self.velocity:len() > 20 then
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

    self.sawPlayer = true
    self.lastHit = love.timer.getTime()
    self.health = self.health - damage
    self.velocity = self.velocity + Vector(math.cos(angle), math.sin(angle)) * knockback

    if self.health <= 0 then
        self:die()
    end

    if self.dead then return end
    table.insert(self.damageIndicators, DamageIndicator(-damage, self))
end

function Enemy:die()
    self.health = 0
    self.dead = true

    Timer.after(5, function()
        if self.collider.body then self.collider:destroy() end
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

function Enemy:updateGameVariables()

end

function Enemy:update(dt)
    self:updateGameVariables()

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
        self.width / 2 + 3, self.height)
end

function Enemy:drawHit()
    if love.timer.getTime() - self.lastHit < 0.1 then
        love.graphics.setColor(1, 0, 0, 0.3)
        love.graphics.setShader(Shaders.Damage)
        self:drawBody()
        love.graphics.setColor(1, 1, 1)
        love.graphics.setShader()
    end
end

function Enemy:drawPath()
    if self.path then
        local map = self.game.level.map
        local tileSize = map.tilewidth
        local tileoffset = Vector(map.tilewidth / 2, map.tileheight / 2)

        love.graphics.setColor(1, 0, 0)
        for i = 1, #self.path - 1 do
            local x1 = self.path[i].x * tileSize - tileoffset.x
            local y1 = self.path[i].y * tileSize - tileoffset.y
            local x2 = self.path[i + 1].x * tileSize - tileoffset.x
            local y2 = self.path[i + 1].y * tileSize - tileoffset.y
            love.graphics.line(x1, y1, x2, y2)
        end
        love.graphics.setColor(1, 1, 1)
    end

    -- draw next position
    if self.nextPosition then
        love.graphics.setColor(0, 1, 0)
        love.graphics.circle("fill", self.nextPosition.x, self.nextPosition.y, 2)
        love.graphics.setColor(1, 1, 1)
    end
end

function Enemy:drawViewDistance()
    love.graphics.setColor(1, 0, 0, 0.2)
    love.graphics.circle("fill", self.position.x, self.position.y, self.viewDistance)
    love.graphics.setColor(1, 1, 1)
end

function Enemy:draw()
    self:drawBody()
    self:drawHit()

    if debug then
        self:drawPath()
        self:drawViewDistance()
    end
end

function Enemy:drawUI()
    self:drawDamageIndicators()
end

return Enemy
