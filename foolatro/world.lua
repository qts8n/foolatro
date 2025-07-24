local LightSource = require("foolatro.light_source")

local World = {}
World.__index = World

function World.new()
    local self = setmetatable({}, World)

    self.sun = {}
    self.screen = {
        width = 0,
        height = 0,
    }

    return self
end

function World:load()
    --- Set defaults
    -- Set a calm background colour (soft dusk blue)
    love.graphics.setBackgroundColor(0.18, 0.22, 0.28)

    self.screen.width = love.graphics.getWidth()
    self.screen.height = love.graphics.getHeight()

    --- Intialize lights
    -- Sun
    self.sun = LightSource.new({
        x = math.floor(self.screen.width * 0.5),
        y = 0,
        z = math.floor(self.screen.height * 0.8),
    })
end

function World:get_the_sun()
    return self.sun
end

return World
