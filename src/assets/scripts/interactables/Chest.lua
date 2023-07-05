local Class = require 'libs.classic'
local Vector = require 'libs.vector'
local Anim8 = require 'libs.anim8'
local Timer = require 'libs.timer'

-- Weapons
local Sword = require 'assets.scripts.weapons.Sword'
local GoldenSword = require 'assets.scripts.weapons.GoldenSword'
local Cleaver = require 'assets.scripts.weapons.Cleaver'
local Katana = require 'assets.scripts.weapons.Katana'
local AnimeSword = require 'assets.scripts.weapons.AnimeSword'
local GreenMagicStaff = require 'assets.scripts.weapons.GreenMagicStaff'
local ThrowingKnife = require 'assets.scripts.weapons.ThrowingKnife'
local RedMagicStaff = require 'assets.scripts.weapons.RedMagicStaff'
local Bow = require 'assets.scripts.weapons.Bow'

local ButtonPrompt = require 'assets.scripts.ui.ButtonPrompt'

local Chest = Class:extend()

function Chest:new(x, y, game)
    self.game = game
    self.world = game.world

    self.collider = self.world:newRectangleCollider(x - 7, y - 5, 14, 8)
    self.collider:setCollisionClass('Chest')
    self.collider:setType('static')
    self.collider:setObject(self)

    self.position = Vector(x, y)

    self.image = love.graphics.newImage('assets/images/animation/chest_full_open.png')
    self.animation = Anim8.newAnimation(
        Anim8.newGrid(16, 16, self.image:getWidth(), self.image:getHeight())('1-3', 1), 0.3)
    self.animation:pauseAtStart()

    self.closest = false
    self.open = false
end

function Chest:getRandomWeapon()
    local weapons = {
        Sword,
        GoldenSword,
        Cleaver,
        Katana,
        AnimeSword,
        GreenMagicStaff,
        ThrowingKnife,
        RedMagicStaff,
        Bow
    }

    return weapons[love.math.random(1, #weapons)]
end

function Chest:update(dt)
    if not self.player and self.game.player then
        self.player = self.game.player
        self.prompt = ButtonPrompt(self.player.keybinds.interact)
    end

    self.animation:update(dt)

    self.closest = self.game:getClosestInteractable() == self

    if self.open then return end
    if not self.player then return end
    if self.player.attacking then return end
    if not love.keyboard.isDown(self.player.keybinds.interact) then return end
    if love.timer.getTime() - self.player.lastInteraction < 0.2 then return end
    if not self.closest then return end
    if self.position:dist(self.player.position) > 15 then return end

    self.player.lastInteraction = love.timer.getTime()
    self.animation:pauseAtEnd()

    Timer.after(0.3, function()
        self.open = true
        self.image = love.graphics.newImage('assets/images/animation/chest_empty_open.png')
        self.game:dropItem(self:getRandomWeapon(), self.position.x, self.position.y)
        self.game:removeChest(self)
    end)
end

function Chest:draw()
    self.animation:draw(self.image,
        self.position.x,
        self.position.y,
        0, 1, 1, 8, 8)

    -- If the player comes near, draw a button prompt
    if not self.closest then return end
    if self.open then return end

    if self.player then
        local distance = self.position:dist(self.player.position)
        if distance < 15 then
            self.prompt:draw(self.position.x - 5, self.position.y - 16, 0.7)
        end
    end
end

return Chest
