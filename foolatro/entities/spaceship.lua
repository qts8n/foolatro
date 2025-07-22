-- Module imports
local asset_server = require("foolatro.utils.asset_server")
local Validate = require("foolatro.utils.validate")

-- Spaceship class definition
local Spaceship = {}
Spaceship.__index = Spaceship

--- Constructor
-- @param opts table Optional parameters:
--        x, y         Starting position (default 0,0)
--        quad_id      Quad index (or name) in the "spaceships" sheet (default 1)
--        scale        Uniform scale (default 1)
--        scale_x/y    Non-uniform scale overrides
--        rotation     Initial rotation in radians (default 0)
--        origin_x/y   Draw origin offsets (default 0)
function Spaceship.new(world, opts)
    -- Validate world
    Validate.table(world, "world")
    Validate.has_method(world, "get_the_sun", "get_the_sun")

    -- Validate options
    if opts == nil then
        opts = {}
    end
    Validate.table(opts, "opts")

    Validate.optional(Validate.number, opts.x, "x")
    Validate.optional(Validate.number, opts.y, "y")
    Validate.optional(Validate.number, opts.rotation, "rotation")
    Validate.optional(Validate.number, opts.scale, "scale")

    Validate.optional(Validate.positive_number, opts.scale_x, "scale_x")
    Validate.optional(Validate.positive_number, opts.scale_y, "scale_y")

    Validate.optional(Validate.number, opts.origin_x, "origin_x")
    Validate.optional(Validate.number, opts.origin_y, "origin_y")

    Validate.optional(Validate.number, opts.quad_id, "quad_id")

    local self = setmetatable({}, Spaceship)

    self.world = world

    self.sheet = asset_server:get_spritesheet("spaceships")
    Validate.exists(self.sheet, "spaceships")

    self.quad_id = opts.quad_id or 1

    self.x = opts.x or 0
    self.y = opts.y or 0

    self.rotation = opts.rotation or 0

    local uniform = opts.scale or 1
    self.scale_x = opts.scale_x or uniform
    self.scale_y = opts.scale_y or uniform

    self.origin_x = opts.origin_x or 0
    self.origin_y = opts.origin_y or 0

    return self
end

-- Get the current quad object.
function Spaceship:get_quad()
    return self.sheet:get(self.quad_id)
end

-- Set a different quad index or name (e.g., for animation).
function Spaceship:set_quad(id)
    self.quad_id = id
end

-- Update logic (placeholder for movement, animation, etc.).
function Spaceship:update(dt)
    -- Example: simple rotation – remove or replace with real gameplay logic.
    -- self.rotation = self.rotation + dt
end

-- Draw the spaceship to the screen.
function Spaceship:draw()
    local quad = self:get_quad()
    local img = self.sheet:get_image()

    love.graphics.draw(
        img,
        quad,
        self.x,
        self.y,
        self.rotation,
        self.scale_x,
        self.scale_y,
        self.origin_x,
        self.origin_y
    )
end

return Spaceship
