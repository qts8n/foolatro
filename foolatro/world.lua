local World = {}
World.__index = World

function World.new()
    local self = setmetatable({}, World)

    self.lights = {}
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
    self.lights[1] = {
        -- At the top center of the screen
        x = math.floor(self.screen.width * 0.5),
        y = 0,
        r = 1,
        g = 1,
        b = 1,
    }
end

function World:get_the_sun()
    return self.lights[1]
end

return World
