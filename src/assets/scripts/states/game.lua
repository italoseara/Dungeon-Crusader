local Class = require 'libs.classic'
local Camera = require 'libs.camera'
local WF = require 'libs.windfield'
local Timer = require 'libs.timer'

local Level = require 'assets.scripts.Level'
local Player = require 'assets.scripts.Player'

local Item = require 'assets.scripts.Item'

local Game = Class:extend()

function Game:new(characterID)
    -- Camera
    self.camera = Camera(0, 0, 4)
    self.camera.smoother = Camera.smooth.damped(10)

    -- Enemies
    self.enemies = {}

    -- Projectiles
    self.projectiles = {}

    -- Interactables
    self.items = {}
    self.chests = {}

    -- Level
    self.world = WF.newWorld(0, 0)
    self.world:addCollisionClass('Enemy')
    self.world:addCollisionClass('Player')
    self.world:addCollisionClass('Crate')
    self.world:addCollisionClass('Chest')
    self.world:addCollisionClass('Wall')
    self.world:addCollisionClass('Weapon', { ignores = { 'Weapon', 'Player' } })
    self.world:addCollisionClass('Projectile', { ignores = { 'Weapon', 'Player' } })

    self.level = Level(self, 1)

    -- Player
    self.player = Player(self.level.spawn.x, self.level.spawn.y, self, characterID)
    self.camera:lookAt(self.player.position.x, self.player.position.y)

    -- State
    self.state = 'running'
end

function Game:addChest(obj)
    table.insert(self.chests, obj)
end

function Game:removeChest(obj)
    for i, chest in ipairs(self.chests) do
        if chest == obj then
            table.remove(self.chests, i)
            break
        end
    end
end

function Game:updateChests(dt)
    for _, chest in pairs(self.chests) do
        chest:update(dt)
    end
end

function Game:addProjectile(collider, image, scale, angle)
    table.insert(self.projectiles, { collider = collider, image = image, scale = scale, angle = angle })
end

function Game:removeProjectile(collider)
    for i, v in ipairs(self.projectiles) do
        if v.collider == collider then
            table.remove(self.projectiles, i)
            break
        end
    end
end

function Game:drawProjectiles()
    for _, projectile in pairs(self.projectiles) do
        local x, y = projectile.collider:getPosition()
        local angle = projectile.angle
        local scale = projectile.scale
        local w, h = projectile.image:getDimensions()

        love.graphics.draw(projectile.image, x, y, angle, scale, scale, w / 2, h / 2)
    end
end

function Game:spawnEnemy(cls, x, y)
    table.insert(self.enemies, cls(x, y, self))
end

function Game:removeEnemy(enemy)
    for i, v in ipairs(self.enemies) do
        if v == enemy then
            table.remove(self.enemies, i)
            break
        end
    end
end

function Game:updateEnemies(dt)
    for _, enemy in pairs(self.enemies) do
        enemy:update(dt)
    end

    if #self.enemies == 0 then self.state = 'win' end
end

function Game:drawEnemies()
    for _, enemy in pairs(self.enemies) do
        enemy:draw()
    end
end

function Game:drawEnemiesUI()
    for _, enemy in pairs(self.enemies) do
        enemy:drawUI()
    end
end

function Game:getClosestInteractable()
    -- Returns the id of the closest item to the player
    local closestInteractable = nil
    local closestDistance = math.huge

    for _, item in pairs(self.items) do
        local distance = item.position:dist(self.player.position)

        if distance < closestDistance then
            closestInteractable = item
            closestDistance = distance
        end
    end

    for _, chest in pairs(self.chests) do
        local distance = chest.position:dist(self.player.position)

        if distance < closestDistance then
            closestInteractable = chest
            closestDistance = distance
        end
    end

    return closestInteractable
end

function Game:removeItem(item)
    for i, v in ipairs(self.items) do
        if v == item then
            table.remove(self.items, i)
            break
        end
    end
end

function Game:dropItem(cls, x, y)
    table.insert(self.items, Item(cls, x, y, self))
end

function Game:updateItems(dt)
    for _, item in pairs(self.items) do
        item:update(dt)
    end
end

function Game:saveTime(time)
    local file = io.open('data/level' .. self.level.id .. '.dat', 'a+')
    if not file then return end
    file:write(os.date('%d/%m/%Y %H:%M:%S') .. ' - ' .. time .. '\n')
    file:close()
end

function Game:updateEndscreen(dt)
    if self.state ~= 'running' then
        if love.keyboard.isDown('space') then
            if self.state == 'win' then
                self:saveTime(self.level:getTimer())
            end

            GameState = require 'assets.scripts.states.Menu' ()
        end
    end
end

function Game:update(dt)
    self.level:update(dt)
    self.player:update(dt)
    self.camera:lookAt(
        math.lerp(self.camera.x, self.player.position.x, (1.0 - math.exp(-10 * dt))),
        math.lerp(self.camera.y, self.player.position.y, (1.0 - math.exp(-10 * dt)))
    )
    self.world:update(dt)
    self:updateItems(dt)
    self:updateEnemies(dt)
    self:updateChests(dt)
    self:updateEndscreen(dt)

    Timer.update(dt)
end

function Game:drawItems()
    for _, item in pairs(self.items) do
        item:draw()
    end
end

function Game:drawEndscreen()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)

    local str, color
    if self.state == 'win' then
        str = 'Victory!'
        color = { 1, 0.68, 0.2, 1 }
    elseif self.state == 'over' then
        str = 'Defeat!'
        color = { 1, 0.3, 0.2, 1 }
    end

    local text = love.graphics.newText(Fonts.big3, str)
    local timer = love.graphics.newText(Fonts.medium, self.level:getTimer())

    love.graphics.setColor(color)
    love.graphics.draw(text, love.graphics.getWidth() / 2 - text:getWidth() / 2,
        love.graphics.getHeight() / 2 - text:getHeight() / 2)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(timer, love.graphics.getWidth() / 2 - timer:getWidth() / 2,
        love.graphics.getHeight() / 2 - timer:getHeight() / 2 + 40)

    local hint = love.graphics.newText(Fonts.small2, 'Press SPACE to go back to the menu')
    love.graphics.draw(hint, love.graphics.getWidth() / 2 - hint:getWidth() / 2,
        love.graphics.getHeight() - hint:getHeight() / 2 - 50)
end

function Game:draw()
    self.camera:attach()

    self.level:draw()
    self:drawItems()
    self:drawEnemies()

    self.player:draw()
    self.level:drawDoorsArch()
    self:drawProjectiles()

    if debug then self.world:draw() end

    self.camera:detach()

    if self.state == 'running' then
        self.level:drawUI()
        self.player:drawUI()
        self:drawEnemiesUI()
    else
        self:drawEndscreen()
    end
end

return Game
