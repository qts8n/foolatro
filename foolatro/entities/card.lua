--- Card Entity
-- Module imports
local asset_server = require("foolatro.utils.asset_server")
local Validate = require("foolatro.utils.validate")
local World = require("foolatro.world")

-- Entity definition
local Card = {}
Card.__index = Card

-- Constants
local DEFAULT_FOV = 90
local DEFAULT_TILT_MAX = 1  -- degrees
local DEFAULT_INSET = 0
local DEFAULT_CULL_BACK = 1
local DEFAULT_IDLE_SPEED = 0.35  -- cycles per second
local DEFAULT_IDLE_FACTOR = 0.55  -- portion of tilt_max used for idle motion
local DEFAULT_MOMENTUM = 0.45
local DEFAULT_SHININESS = 32.0

--- Creates a new Card entity with perspective tilt and lighting effects.
-- @param world table The world instance containing global state and light sources
-- @param opts table Optional parameters:
--        x, y          Top-left draw position (default 0,0)
--        image_name    Asset id registered in asset_server (default "card_back")
--        shader_name   Shader id registered in asset_server (default "card_perspective")
--        tilt_max      Max degrees tilt when hovered (default 1)
--        fov           Field of view for shader (default 90)
--        inset         Shader inset value (default 0)
--        cull_back     Shader cull flag (default 1)
--        idle_speed    Speed of idle rotation in cycles/sec (default 0.35)
--        idle_factor   Factor of tilt_max used for idle motion (default 0.55)
--        momentum      Movement smoothing factor between 0-1 (default 0.45)
--        shininess    Specular highlight sharpness (default 32.0)
-- @return table A new Card instance
function Card.new(world, opts)
    -- Validate world
    Validate.table(world, "world")
    Validate.has_method(world, "get_the_sun", "get_the_sun")

    -- Validate options
    if opts == nil then
        opts = {}
    end
    Validate.table(opts, "opts")

    Validate.number(opts.x, "x")
    Validate.number(opts.y, "y")
    Validate.optional(Validate.positive_number, opts.tilt_max, "tilt_max")
    Validate.optional(Validate.number, opts.fov, "fov")
    Validate.optional(Validate.number, opts.inset, "inset")
    Validate.optional(Validate.number, opts.cull_back, "cull_back")
    Validate.optional(Validate.positive_number, opts.idle_speed, "idle_speed")
    Validate.optional(Validate.positive_number, opts.idle_factor, "idle_factor")
    Validate.optional(Validate.in_range, opts.momentum, "momentum", 0, 1)

    local self = setmetatable({}, Card)

    self.world = world

    -- Asset retrieval
    self.image = asset_server:get_image("card_back")
    Validate.exists(self.image, "card_back")

    self.shader = asset_server:get_shader("card_perspective")
    Validate.exists(self.shader, "card_perspective")

    self.sounds = {
        flick = asset_server:get_sound("card_flick"),
        -- TODO: Add other sounds here
    }
    Validate.exists(self.sounds.flick, "card_flick")

    -- Geometry
    self.x = opts.x
    self.y = opts.y

    self.target_x = self.x
    self.target_y = self.y

    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    -- Shader parameters
    self.tilt_max = opts.tilt_max or DEFAULT_TILT_MAX
    self.fov = opts.fov or DEFAULT_FOV
    self.inset = opts.inset or DEFAULT_INSET
    self.cull_back = opts.cull_back or DEFAULT_CULL_BACK
    self.shininess = opts.shininess or DEFAULT_SHININESS

    -- Idle animation parameters
    self.idle_speed = opts.idle_speed or DEFAULT_IDLE_SPEED  -- cycles per second
    self.idle_factor = opts.idle_factor or DEFAULT_IDLE_FACTOR
    self.idle_phase = 0  -- radians

    -- Internal state
    self.is_dragged = false
    self.is_moving = false

    -- Physics
    self.momentum = opts.momentum or DEFAULT_MOMENTUM
    self.velocity_x = 0
    self.velocity_y = 0

    return self
end

-- Internal hover check
function Card:_contains(x_, y_)
    return x_ >= self.x and x_ <= self.x + self.width and y_ >= self.y and y_ <= self.y + self.height
end

-- Update logic
function Card:update(dt)
    -- Accumulate phase for idle rotation (converted to radians per second)
    local two_pi = math.pi * 2
    self.idle_phase = (self.idle_phase + dt * self.idle_speed * two_pi) % two_pi

    -- Change position if dragged
    if self.is_dragged then
        local mx, my = love.mouse.getPosition()
        self.target_x = mx - self.width * 0.5
        self.target_y = my - self.height * 0.5
    end

    --- Smoothly move to target position
    local tolerance = 0.1
    local delta_x = self.target_x - self.x
    local delta_y = self.target_y - self.y

    -- Check if the card is moving
    local is_moving = math.abs(delta_x) > tolerance or math.abs(delta_y) > tolerance

    -- Play flick sound when card stops moving
    if is_moving ~= self.is_moving and not is_moving and not self.is_dragged then
        self.sounds.flick:play()
    end

    local inv_momentum = 1 - self.momentum
    if math.abs(delta_x) > tolerance or math.abs(delta_y) > tolerance or is_moving then
        self.velocity_x = self.velocity_x * self.momentum + inv_momentum * delta_x * 30 * dt
        self.velocity_y = self.velocity_y * self.momentum + inv_momentum * delta_y * 30 * dt

        self.x = self.x + self.velocity_x
        self.y = self.y + self.velocity_y
    end

    -- Update moving state
    self.is_moving = is_moving
end

-- Handle Love2D mousepressed callback
function Card:handle_mousepressed(mx, my, button)
    if button == 1 and self:_contains(mx, my) then
        self.is_dragged = true
    end
end

-- Handle Love2D mousereleased callback
function Card:handle_mousereleased(_, _, button)
    if button == 1 and self.is_dragged then
        self.is_dragged = false
    end
end

--- Draw the card with perspective tilt effect
function Card:draw()
    local mx, my = love.mouse.getPosition()

    local cx = self.x + self.width * 0.5
    local cy = self.y + self.height * 0.5

    --- Shadow
    local sun = self.world:get_the_sun()

    -- Direction: if card center is to the right of sun, shadow shifts left.
    local dir = 1
    if cx > sun.position.x then
        dir = -1
    end

    -- Magnitude scales with horizontal distance (capped at a % of width).
    local dist_norm = math.min(math.abs(cx - sun.position.x) / self.world.screen.width, 1)
    local max_offset = self.width * 0.2
    local shadow_offset_x = dir * dist_norm * max_offset

    local shadow_height = self.height
    local shadow_offset_y = shadow_height * 0.05

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle(
        "fill",
        self.x + shadow_offset_x,
        self.y + shadow_offset_y,
        self.width,
        shadow_height
    )
    love.graphics.setColor(1, 1, 1, 1)

    --- Idle animation: circular tilt
    local amp = self.tilt_max * self.idle_factor
    local x_rot = math.sin(self.idle_phase) * amp
    local y_rot = math.cos(self.idle_phase) * amp

    local is_hovered = self:_contains(mx, my)
    if is_hovered then
        -- Determine tilt based on mouse position when hovering
        local dx_norm = (mx - cx) / (self.width * 0.5)
        local dy_norm = (my - cy) / (self.height * 0.5)

        x_rot = x_rot + dy_norm * self.tilt_max  -- vertical movement tilts around X axis
        y_rot = y_rot - dx_norm * self.tilt_max  -- horizontal movement tilts around Y axis
    end

    -- Determine scale based on whether the card is being dragged
    local x_scale = 1
    local y_scale = 1
    if self.is_dragged then
        x_scale = 1.05
        y_scale = 1.05
    end

    --- Apply shader uniforms and render the card
    love.graphics.setShader(self.shader)

    -- Perspective uniforms
    self.shader:send("fov", self.fov)
    self.shader:send("x_rot", x_rot)
    self.shader:send("y_rot", y_rot)
    self.shader:send("inset", self.inset)
    self.shader:send("cull_back", self.cull_back)
    self.shader:send("anchor", { cx, cy })
    self.shader:send("sprite_size", { self.width, self.height })
    self.shader:send("sprite_scale", { x_scale, y_scale })

    -- Lighting uniforms
    self.shader:send("light_pos", sun:get_position())
    self.shader:send("light_color", sun:get_color())
    self.shader:send("light_ambient", sun.ambient)
    self.shader:send("light_diffuse", sun.diffuse)
    self.shader:send("shininess", self.shininess)

    love.graphics.draw(self.image, self.x, self.y)

    love.graphics.setShader()
end

return Card
