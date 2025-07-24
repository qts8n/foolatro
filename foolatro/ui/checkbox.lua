-- Module imports
local Validate = require("foolatro.utils.validate")

-- Component definition
local Checkbox = {}
Checkbox.__index = Checkbox

--- Creates a new Checkbox UI component with label and toggle functionality.
-- @param opts table Required parameters:
--        x, y          Position of the top-left corner in pixels
--        size          Width/height of the square box in pixels
--        label         Text shown to the right of the box
--        font          Custom LÖVE Font object for label (optional)
--        checked       Initial checked state (default false)
--        on_toggle     Callback function(checkbox, new_state) on state change
--        hover_color   RGBA color table {r,g,b,a} for hover state (optional)
--        press_offset  Vertical offset in pixels for press animation (default 2)
--        animation_speed Pixels per second for press animation (default 50)
-- @return table A new Checkbox instance
function Checkbox.new(opts)
    Validate.table(opts, "opts")

    Validate.number(opts.x, "x")
    Validate.number(opts.y, "y")
    Validate.positive_number(opts.size, "size")
    Validate.string(opts.label, "label")
    -- TODO: Validate font
    Validate.optional(Validate.boolean, opts.checked, "checked")
    Validate.optional(Validate.is_function, opts.on_toggle, "on_toggle")
    Validate.optional(Validate.number, opts.press_offset, "press_offset")

    local self = setmetatable({}, Checkbox)

    self.x = opts.x
    self.y = opts.y
    self.size = opts.size

    self.label = opts.label or ""
    self.font = opts.font

    self.is_checked = opts.checked or false
    self.on_toggle = opts.on_toggle

    self.hover_color = opts.hover_color or { 0.8, 0.8, 0.8, 1.0 }
    self.box_color = { 1, 1, 1, 1 }
    self.tick_color = { 1, 1, 1, 1 }

    self.press_offset = opts.press_offset or 2

    self.is_hovered = false
    self.is_pressed = false

    self.current_offset = 0
    self.animation_speed = 50 -- pixels per second

    return self
end

-- Internal bounding box check
function Checkbox:_contains(x_, y_)
    return x_ >= self.x and x_ <= self.x + self.size and y_ >= self.y and y_ <= self.y + self.size
end

-- Update hover and animation
function Checkbox:update(dt)
    local mx, my = love.mouse.getPosition()
    self.is_hovered = self:_contains(mx, my)

    local target = 0
    if self.is_pressed then
        target = self.press_offset
    end

    if self.current_offset < target then
        self.current_offset = math.min(self.current_offset + self.animation_speed * dt, target)
    elseif self.current_offset > target then
        self.current_offset = math.max(self.current_offset - self.animation_speed * dt, target)
    end
end

function Checkbox:handle_mousepressed(mx, my, button)
    if button == 1 and self:_contains(mx, my) then
        self.is_pressed = true
    end
end

function Checkbox:handle_mousereleased(mx, my, button)
    if button == 1 and self.is_pressed then
        self.is_pressed = false
        if self:_contains(mx, my) then
            self.is_checked = not self.is_checked
            if self.on_toggle then
                self.on_toggle(self, self.is_checked)
            end
        end
    end
end

-- Draw checkbox and label
function Checkbox:draw()
    local r, g, b, a = unpack(self.box_color)
    if self.is_hovered then
        r, g, b, a = unpack(self.hover_color)
    end

    love.graphics.setColor(r, g, b, a)
    love.graphics.rectangle("line", self.x, self.y + self.current_offset, self.size, self.size)

    if self.is_checked then
        love.graphics.setColor(self.tick_color)
        local pad = self.size * 0.2
        love.graphics.rectangle("fill", self.x + pad, self.y + pad + self.current_offset, self.size - pad * 2, self.size - pad * 2)
    end

    -- Draw label
    if self.label ~= "" then
        local prev_font = nil
        if self.font then
            prev_font = love.graphics.getFont()
            love.graphics.setFont(self.font)
        end

        love.graphics.setColor(1, 1, 1, 1)
        local text_x = self.x + self.size + 8
        local text_y = self.y + self.current_offset + (self.size - love.graphics.getFont():getHeight()) / 2
        love.graphics.print(self.label, text_x, text_y)

        if prev_font then
            love.graphics.setFont(prev_font)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return Checkbox
