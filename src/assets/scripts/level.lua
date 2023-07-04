local Class = require 'libs.classic'
local Vector = require 'libs.vector'
local STI = require 'libs.sti'
local Anim8 = require 'libs.anim8'

local Crate = require 'assets.scripts.interactables.Crate'
local Door = require 'assets.scripts.interactables.Door'

local Level = Class:extend()

function Level:new(world)
    -- Load map
    love.graphics.setBackgroundColor(0.133, 0.133, 0.133)
    self.map = STI('assets/maps/level1.lua')

    -- Set spawn
    self.spawn = Vector(0, 0)
    self.spawn.x, self.spawn.y = self.map:convertTileToPixel(18, 31)
    self.spawn.x = self.spawn.x + 8
    self.spawn.y = self.spawn.y + 8

    -- Create walls
    self.world = world

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
end

function Level:isFloor(x, y)
    local tile = self.map.layers['Floor'].data[y + 1][x + 1]
    return tile and tile.properties and tile.properties.isFloor
end

function Level:update(dt)
    self.map:update(dt)
    self.animations.fountain:update(dt)
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
            interactable = Crate(x, y, self)
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
    self.map:drawLayer(self.map.layers['Walls'])
    self.map:drawLayer(self.map.layers['Decoration'])

    self:drawAnimations()
    self:drawInteractables()
end

function Level:drawFog()
    love.graphics.setShader(Shaders.fog)
    Shaders.fog:send('radius', 700)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setShader()
end

function Level:drawUI()
    self:drawFog()
end

return Level
