local Class = require 'libs.classic'
local Vector = require 'libs.vector'

local Room = Class:extend()

function Room:new(level, x, y, depth)
    self.level = level

    self.pos = Vector(x, y)
    self.dim = Vector(math.random(12, 20), math.random(12, 20))
    self.distance = 30

    self.depth = depth or 1

    self.tileset = self.level.map.tilesets[1]

    self.north = nil
    self.south = nil
    self.east = nil
    self.west = nil

    table.insert(self.level.ocupied, self.pos)

    self:generate()
    self:addTiles()
end

function Room:generate()
    if self.depth > math.random(1, 2) then return end

    local possible = { "north", "south", "east", "west" }

    for _ = 1, math.random(2, 4) do
        local dir = possible[math.random(1, #possible)]

        if self[dir] then goto continue end

        for _, pos in pairs(self.level.ocupied) do
            if pos.x == self.pos.x and pos.y == self.pos.y - 1 and dir == "north" then goto continue end
            if pos.x == self.pos.x and pos.y == self.pos.y + 1 and dir == "south" then goto continue end
            if pos.x == self.pos.x + 1 and pos.y == self.pos.y and dir == "east" then goto continue end
            if pos.x == self.pos.x - 1 and pos.y == self.pos.y and dir == "west" then goto continue end
        end

        if dir == "north" then
            self.north = Room(self.level, self.pos.x, self.pos.y - 1, self.depth + 1)
        elseif dir == "south" then
            self.south = Room(self.level, self.pos.x, self.pos.y + 1, self.depth + 1)
        elseif dir == "east" then
            self.east = Room(self.level, self.pos.x + 1, self.pos.y, self.depth + 1)
        elseif dir == "west" then
            self.west = Room(self.level, self.pos.x - 1, self.pos.y, self.depth + 1)
        end

        ::continue::

        for i = #possible, 1, -1 do
            if possible[i] == dir then
                table.remove(possible, i)
            end
        end
    end
end

function Room:addTiles()
    -- Fill a box with tiles
    for i = 1, self.dim.x do
        for j = 1, self.dim.y do
            local x, y = 2, 2

            -- if math.random(1, 50) == 1 then
            --     x, y = math.random(3) - 1, math.random(3) - 1
            --     if x == 0 and y == 0 then
            --         x, y = 2, 2
            --     end
            -- end

            local tile = self.level:getTileID(self.tileset, x, y)

            local offsetX, offsetY = math.floor((20 - self.dim.x) / 2), math.floor((20 - self.dim.y) / 2)

            self.level:setTile(self.level.floorLayer,
                self.pos.x * self.distance + i - 10 + self.level.map.width / 2 + offsetX,
                self.pos.y * self.distance + j - 10 + self.level.map.height / 2 + offsetY,
                tile)
        end
    end
end

function Room:update(dt)

end

function Room:draw()
    -- love.graphics.setColor(1, 1, 1, 1)
    -- love.graphics.rectangle("line",
    --     distance * self.pos.x - self.dim.x / 2,
    --     distance * self.pos.y - self.dim.y / 2,
    --     self.dim.x,
    --     self.dim.y)

    -- if self.north then self.north:draw() end
    -- if self.south then self.south:draw() end
    -- if self.east then self.east:draw() end
    -- if self.west then self.west:draw() end
end

return Room
