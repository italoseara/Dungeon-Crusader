local Sword = require 'assets.scripts.weapons.Sword'
local GoldenSword = require 'assets.scripts.weapons.GoldenSword'
local Cleaver = require 'assets.scripts.weapons.Cleaver'
local Katana = require 'assets.scripts.weapons.Katana'
local AnimeSword = require 'assets.scripts.weapons.AnimeSword'
local GreenMagicStaff = require 'assets.scripts.weapons.GreenMagicStaff'
local ThrowingKnife = require 'assets.scripts.weapons.ThrowingKnife'
local RedMagicStaff = require 'assets.scripts.weapons.RedMagicStaff'
local Bow = require 'assets.scripts.weapons.Bow'

local CharacterStats = {
    knight_m = {
        weapon = Sword,
        maxHealth = 200,
        maxMana = 100,
        speed = 800,
    },
    wizard_m = {
        weapon = RedMagicStaff,
        maxHealth = 100,
        maxMana = 250,
        speed = 800,
    },
    lizard_m = {
        weapon = Bow,
        maxHealth = 100,
        maxMana = 100,
        speed = 900,
    },
    dwarf_m = {
        weapon = Cleaver,
        maxHealth = 250,
        maxMana = 50,
        speed = 600,
    },
    knight_f = {
        weapon = Sword,
        maxHealth = 200,
        maxMana = 100,
        speed = 800,
    },
    wizard_f = {
        weapon = RedMagicStaff,
        maxHealth = 100,
        maxMana = 250,
        speed = 800,
    },
    lizard_f = {
        weapon = Bow,
        maxHealth = 100,
        maxMana = 100,
        speed = 900,
    },
    dwarf_f = {
        weapon = Cleaver,
        maxHealth = 250,
        maxMana = 50,
        speed = 600,
    },
}

return CharacterStats
