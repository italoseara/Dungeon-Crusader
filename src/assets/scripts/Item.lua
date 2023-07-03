local Class = require 'libs.classic'
local Vector = require 'libs.vector'

local ButtonPrompt = require 'assets.scripts.ui.ButtonPrompt'

local Item = Class:extend()

function Item:new(cls, x, y, game)
    self.id = love.math.random(1000000, 9999999)

    self.game = game
    self.world = game.world
    self.player = game.player

    self.item = cls(game)
    self.position = Vector(x, y)

    self.prompt = ButtonPrompt(self.player.keybinds.interact)

    self.closest = false
end

function Item:update(dt)
    self.position.y = self.position.y + math.sin(love.timer.getTime() * 3) * 0.015
    self.closest = self.game:closestItem() == self

    if not self.player then return end
    if self.player.attacking then return end
    if not love.keyboard.isDown(self.player.keybinds.interact) then return end
    if love.timer.getTime() - self.player.lastPickup < 0.2 then return end
    if not self.closest then return end

    local distance = self.position:dist(self.player.position)

    if distance < 15 then
        if self.player.weapon then
            -- Swap weapons
            self.player.weapon:drop(self.player.position.x, self.player.position.y)
        end

        self.item:onPickup(self.player)
        self.game:removeItem(self)
        self.player.lastPickup = love.timer.getTime()
    end
end

function Item:draw()
    love.graphics.draw(
        self.item.image,
        self.position.x,
        self.position.y,
        0, 0.75, 0.75,
        self.item.width / 2,
        self.item.height / 2)

    -- If the player comes near, draw a button prompt
    if not self.closest then return end

    if self.player then
        local distance = self.position:dist(self.player.position)
        if distance < 15 then
            self.prompt:draw(self.position.x - 5, self.position.y - 16, 0.7)
        end
    end
end

return Item