local Class = require 'libs.classic'
local Vector = require 'libs.vector'
local STI = require 'libs.sti'
local Anim8 = require 'libs.anim8'

-- Interactables
local Crate = require 'assets.scripts.interactables.Crate'
local Door = require 'assets.scripts.interactables.Door'
local Chest = require 'assets.scripts.interactables.Chest'

-- Enemies
local Plague = require 'assets.scripts.enemies.Plague'
local Ogre = require 'assets.scripts.enemies.Ogre'
local Imp = require 'assets.scripts.enemies.Imp'
local BigDemon = require 'assets.scripts.enemies.BigDemon'
local OrcWarrior = require 'assets.scripts.enemies.OrcWarrior'

local Level = Class:extend()

function Level:new(game, id)
    self.id = id

    -- Load map
    love.graphics.setBackgroundColor(0.133, 0.133, 0.133)
    self.map = STI('assets/maps/level' .. self.id .. '.lua')

    -- Run Timer
    self.timer = 0

    -- Set spawn
    self.spawn = Vector(0, 0)
    self.spawn.x, self.spawn.y = self.map:convertTileToPixel(18, 31)
    self.spawn = self.spawn + Vector(8, 8)

    -- Create walls
    self.game = game
    self.world = game.world

    self.walls = {}
    if self.map.layers['Collide'] then
        for _, obj in pairs(self.map.layers['Collide'].objects) do
            local x, y, w, h = obj.x, obj.y, obj.width, obj.height
            local wall = self.world:newRectangleCollider(x, y, w, h)
            wall:setCollisionClass('Wall')
            wall:setType('static')
            wall:setFriction(0)
            wall:setRestitution(0)
            wall:setObject(obj)
            table.insert(self.walls, wall)
        end
    end

    -- Load animations
    self.images = {
        fountain_blue = love.graphics.newImage('assets/images/animation/fountain_blue.png'),
        fountain_red  = love.graphics.newImage('assets/images/animation/fountain_red.png'),
        door_open     = love.graphics.newImage('assets/images/animation/door_open.png'),
        door_arch     = love.graphics.newImage('assets/images/animation/door_arch.png'),
    }

    self.animations = {
        fountain = Anim8.newAnimation(
            Anim8.newGrid(16, 32,
                self.images.fountain_blue:getWidth(),
                self.images.fountain_blue:getHeight())('1-2', 1), 0.15)
    }

    self.interactables = {}
    self:loadInteractables()
    self:spawnEnemies()
end

function Level:spawnEnemies()
    for _, obj in pairs(self.map.layers['Enemies'].objects) do
        if obj.name == 'plague' then
            self.game:spawnEnemy(Plague, obj.x + 8, obj.y + 8)
        elseif obj.name == 'ogre' then
            self.game:spawnEnemy(Ogre, obj.x + 8, obj.y + 8)
        elseif obj.name == 'imp' then
            self.game:spawnEnemy(Imp, obj.x + 8, obj.y + 8)
        elseif obj.name == 'big_demon' then
            self.game:spawnEnemy(BigDemon, obj.x + 8, obj.y + 8)
        elseif obj.name == 'orc_warrior' then
            self.game:spawnEnemy(OrcWarrior, obj.x + 8, obj.y + 8)
        end
    end
end

function Level:isFloor(x, y)
    local tile = self.map.layers['Floor'].data[y + 1][x + 1]
    return tile and tile.properties and tile.properties.isFloor
end

function Level:update(dt)
    self.map:update(dt)
    self.animations.fountain:update(dt)

    if self.game.state ~= 'running' then return end
    self.timer = self.timer + dt
end

function Level:removeInteractable(object)
    for i, obj in pairs(self.interactables) do
        if obj == object then
            table.remove(self.interactables, i)
            break
        end
    end
end

function Level:loadInteractables()
    for _, obj in pairs(self.map.layers['Interact'].objects) do
        local interactable

        if obj.name == 'door' then
            local x, y = obj.x, obj.y
            interactable = Door(x, y)
        elseif obj.name == 'crate' then
            local x, y = obj.x, obj.y
            interactable = Crate(x, y, self.game, self)
        elseif obj.name == 'chest' then
            local x, y = obj.x, obj.y
            interactable = Chest(x + 8, y + 8, self.game)
            self.game:addChest(interactable)
        end

        table.insert(self.interactables, interactable)
    end
end

function Level:drawInteractables()
    for _, obj in pairs(self.interactables) do
        obj:draw()
    end
end

function Level:drawDoorsArch()
    for _, obj in pairs(self.map.layers['Interact'].objects) do
        if obj.name == 'door' then
            local x, y = obj.x - 16, obj.y - 28
            local image = self.images.door_arch

            if image then
                love.graphics.draw(image, x, y)
            end
        end
    end
end

function Level:drawAnimations()
    for _, obj in pairs(self.map.layers['Animation'].objects) do
        local x, y = obj.x, obj.y
        local image = self.images[obj.name]

        if image then
            self.animations[obj.type]:draw(image, x, y)
        end
    end
end

function Level:draw()
    self.map:drawLayer(self.map.layers['Floor'])
    self:drawInteractables()
    self.map:drawLayer(self.map.layers['Walls'])
    self.map:drawLayer(self.map.layers['Decoration'])

    self:drawAnimations()
end

function Level:drawFog()
    love.graphics.setShader(Shaders.fog)
    Shaders.fog:send('radius', 700)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setShader()
end

function Level:getTimer()
    -- Convert time to minutes and seconds
    local minutes = math.floor(self.timer / 60)
    local seconds = math.floor(self.timer % 60)
    local milliseconds = math.floor((self.timer * 100) % 100)

    -- Format time
    return string.format('%02d:%02d:%02d', minutes, seconds, milliseconds)
end

function Level:drawTimer()
    local time = self:getTimer()
    local text = love.graphics.newText(Fonts.medium, time)

    local x = love.graphics.getWidth() / 2 - text:getWidth() / 2
    local y = 10

    -- Draw time
    love.graphics.draw(text, x, y)
end

function Level:drawUI()
    self:drawFog()
    self:drawTimer()
end

return Level
