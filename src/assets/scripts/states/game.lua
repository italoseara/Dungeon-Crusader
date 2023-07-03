local Class = require 'libs.classic'
local Camera = require 'libs.camera'
local WF = require 'libs.windfield'
local Timer = require 'libs.timer'

local Level = require 'assets.scripts.Level'
local Player = require 'assets.scripts.Player'

-- Weapons
local AnimeSword = require 'assets.scripts.weapons.AnimeSword'
local Sword = require 'assets.scripts.weapons.Sword'
local Item = require 'assets.scripts.Item'

-- Enemies
local Plague = require 'assets.scripts.enemies.Plague'

local Game = Class:extend()

function Game:new(characterID)
    -- Camera
    self.camera = Camera(0, 0, 4)
    self.camera.smoother = Camera.smooth.damped(10)

    -- Level
    self.world = WF.newWorld(0, 0)
    self.world:addCollisionClass('Enemy')
    self.world:addCollisionClass('Player')
    self.world:addCollisionClass('Weapon', { ignores = { 'Weapon', 'Player' } })
    self.world:addCollisionClass('Wall')

    self.level = Level(self.world)

    -- Player
    self.player = Player(self.level.spawn.x, self.level.spawn.y, self, characterID)
    self.camera:lookAt(self.player.position.x, self.player.position.y)

    -- Items
    self.items = {}

    -- Enemies
    self.enemies = {}

    -- Test
    self:dropItem(Sword, self.level.spawn.x + 32, self.level.spawn.y)
    self:dropItem(AnimeSword, self.level.spawn.x + 42, self.level.spawn.y)

    self:spawnEnemy(Plague, self.level.spawn.x + 64, self.level.spawn.y)
    self:spawnEnemy(Plague, self.level.spawn.x + 64, self.level.spawn.y + 32)
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

function Game:closestItem()
    -- Returns the id of the closest item to the player
    local closestItem = nil
    local closestDistance = math.huge

    for _, item in pairs(self.items) do
        local distance = item.position:dist(self.player.position)

        if distance < closestDistance then
            closestItem = item
            closestDistance = distance
        end
    end

    return closestItem
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

    Timer.update(dt)
end

function Game:drawItems()
    for _, item in pairs(self.items) do
        item:draw()
    end
end

function Game:draw()
    self.camera:attach()

    self.level:draw()
    self:drawItems()
    self:drawEnemies()
    
    self.player:draw()
    self.level:drawDoorsArch()
    -- self.world:draw()

    self.camera:detach()

    self.level:drawUI()
    self.player:drawUI()
    self:drawEnemiesUI()
end

return Game
