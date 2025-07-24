local Validate = require("foolatro.utils.validate")

local LightSource = {}
LightSource.__index = LightSource

--- Creates a new LightSource for 3D lighting calculations.
-- @param opts table Required parameters:
--        x, y, z       Position in world space
--        r, g, b       RGB color components between 0-1 (default 1,1,1)
--        ambient       Ambient light intensity between 0-1 (default 0.1)
--        diffuse       Diffuse light intensity between 0-1 (default 0.9)
-- @return table A new LightSource instance
function LightSource.new(opts)
    if opts == nil then
        opts = {}
    end

    Validate.table(opts, "opts")

    Validate.number(opts.x, "x")
    Validate.number(opts.y, "y")
    Validate.number(opts.z, "z")
    Validate.optional(Validate.in_range, opts.r, "r", 0, 1)
    Validate.optional(Validate.in_range, opts.g, "g", 0, 1)
    Validate.optional(Validate.in_range, opts.b, "b", 0, 1)
    Validate.optional(Validate.in_range, opts.ambient, "ambient", 0, 1)
    Validate.optional(Validate.in_range, opts.diffuse, "diffuse", 0, 1)

    local self = setmetatable({}, LightSource)

    self.position = { x = opts.x, y = opts.y, z = opts.z }
    self.color = { r = opts.r or 1, g = opts.g or 1, b = opts.b or 1 }
    self.ambient = opts.ambient or 0.1
    self.diffuse = opts.diffuse or 0.9

    return self
end

function LightSource.get_position(self)
    return { self.position.x, self.position.y, self.position.z }
end

function LightSource.get_color(self)
    return { self.color.r, self.color.g, self.color.b }
end

return LightSource
