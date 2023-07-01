local Class = require 'libs.classic'

local ButtonPrompt = Class:extend()

ButtonPromptCoords = {
    a          = { x = 1, y = 1, w = 1 },
    b          = { x = 2, y = 1, w = 1 },
    c          = { x = 3, y = 1, w = 1 },
    d          = { x = 4, y = 1, w = 1 },
    e          = { x = 5, y = 1, w = 1 },
    f          = { x = 6, y = 1, w = 1 },
    g          = { x = 7, y = 1, w = 1 },
    h          = { x = 8, y = 1, w = 1 },
    i          = { x = 9, y = 1, w = 1 },
    j          = { x = 10, y = 1, w = 1 },
    k          = { x = 1, y = 2, w = 1 },
    l          = { x = 2, y = 2, w = 1 },
    m          = { x = 3, y = 2, w = 1 },
    n          = { x = 4, y = 2, w = 1 },
    o          = { x = 5, y = 2, w = 1 },
    p          = { x = 6, y = 2, w = 1 },
    q          = { x = 7, y = 2, w = 1 },
    r          = { x = 8, y = 2, w = 1 },
    s          = { x = 9, y = 2, w = 1 },
    t          = { x = 10, y = 2, w = 1 },
    u          = { x = 1, y = 3, w = 1 },
    v          = { x = 2, y = 3, w = 1 },
    w          = { x = 3, y = 3, w = 1 },
    x          = { x = 4, y = 3, w = 1 },
    y          = { x = 5, y = 3, w = 1 },
    z          = { x = 6, y = 3, w = 1 },
    up         = { x = 7, y = 3, w = 1 },
    down       = { x = 8, y = 3, w = 1 },
    left       = { x = 9, y = 3, w = 1 },
    right      = { x = 10, y = 3, w = 1 },
    space      = { x = 1, y = 4, w = 2 },
    ["return"] = { x = 3, y = 4, w = 2 },
    lshift     = { x = 5, y = 4, w = 2 },
    lctrl      = { x = 7, y = 4, w = 2 },
    tab        = { x = 9, y = 4, w = 2 },
    esc        = { x = 1, y = 5, w = 2 },
    lalt       = { x = 3, y = 5, w = 2 },
    backspace  = { x = 5, y = 5, w = 2 },
    mouse1     = { x = 7, y = 5, w = 2 },
    mouse2     = { x = 9, y = 5, w = 2 },
}

function ButtonPrompt:new(button)
    self.image = love.graphics.newImage('assets/images/ui/button_prompts.png')
    self.quad = love.graphics.newQuad(
        (ButtonPromptCoords[button].x - 1) * 16,
        (ButtonPromptCoords[button].y - 1) * 16,
        ButtonPromptCoords[button].w * 16,
        16,
        self.image:getDimensions()
    )
end

function ButtonPrompt:draw(x, y)
    love.graphics.draw(self.image, self.quad, x, y)
end

return ButtonPrompt
