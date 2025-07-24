-- Module imports
local Validate = require("foolatro.utils.validate")

-- Component definition
local Button = {}
Button.__index = Button

--- Creates a new Button UI component with hover effects and click handling.
-- @param opts table Required parameters:
--        x, y          Position of the top-left corner in pixels
--        w, h          Width and height in pixels
--        label         Text to display (default "Button")
--        font          Custom LÖVE Font object for label (optional)
--        on_click      Function called when button is clicked (optional)
--        hover_color   RGBA color table {r,g,b,a} for hover state (optional)
--        press_offset  Vertical offset in pixels for press animation (default 2)
--        animation_speed Pixels per second for press animation (default 50)
-- @return table A new Button instance
function Button.new(opts)
    Validate.table(opts, "opts")

    Validate.number(opts.x, "x")
    Validate.number(opts.y, "y")
    Validate.positive_number(opts.w, "w")
    Validate.positive_number(opts.h, "h")
    Validate.string(opts.label, "label")
    -- TODO: Validate font
    Validate.optional(Validate.is_function, opts.on_click, "on_click")
    Validate.optional(Validate.number, opts.press_offset, "press_offset")

    local self = setmetatable({}, Button)

    self.x = opts.x
    self.y = opts.y
    self.w = opts.w
    self.h = opts.h

    self.label = opts.label or "Button"
    self.font = opts.font -- may be nil (uses current font)
    self.on_click = opts.on_click

    self.hover_color = opts.hover_color or { 0.8, 0.8, 0.8, 1.0 }
    self.base_color = { 0.2, 0.2, 0.2, 1.0 }

    self.press_offset = opts.press_offset or 2

    self.is_hovered = false
    self.is_pressed = false

    -- Animation state
    self.current_offset = 0
    self.animation_speed = (opts.animation_speed or 50) -- pixels per second toward target

    return self
end

-- Internal helper to test mouse position.
function Button:_contains(x_, y_)
    return x_ >= self.x and x_ <= self.x + self.w and y_ >= self.y and y_ <= self.y + self.h
end

--- Update hover state (call every frame).
function Button:update(dt)
    local mx, my = love.mouse.getPosition()
    self.is_hovered = self:_contains(mx, my)

    -- Determine target offset based on press state
    local target = 0
    if self.is_pressed then
        target = self.press_offset
    end

    -- Smoothly move current_offset toward target
    if self.current_offset < target then
        self.current_offset = math.min(self.current_offset + self.animation_speed * dt, target)
    elseif self.current_offset > target then
        self.current_offset = math.max(self.current_offset - self.animation_speed * dt, target)
    end
end

--- Handle Love2D mousepressed callback.
function Button:handle_mousepressed(mx, my, button)
    if button == 1 and self:_contains(mx, my) then
        self.is_pressed = true
    end
end

--- Handle Love2D mousereleased callback.
function Button:handle_mousereleased(mx, my, button)
    if button == 1 and self.is_pressed then
        self.is_pressed = false
        if self:_contains(mx, my) then
            if self.on_click then
                self.on_click(self)
            end
        end
    end
end

--- Draw the button.
function Button:draw()
    local r, g, b, a = unpack(self.base_color)
    if self.is_hovered then
        r, g, b, a = unpack(self.hover_color)
    end

    love.graphics.setColor(r, g, b, a)
    love.graphics.rectangle("fill", self.x, self.y + self.current_offset, self.w, self.h)

    -- Draw label centered
    local prev_font = nil
    if self.font then
        prev_font = love.graphics.getFont()
        love.graphics.setFont(self.font)
    end

    love.graphics.setColor(0, 0, 0, 1)
    local text_w = love.graphics.getFont():getWidth(self.label)
    local text_h = love.graphics.getFont():getHeight()
    local tx = self.x + (self.w - text_w) / 2
    local ty = self.y + (self.h - text_h) / 2 + self.current_offset
    love.graphics.print(self.label, tx, ty)

    if prev_font then
        love.graphics.setFont(prev_font)
    end

    -- Reset color to white for subsequent draws
    love.graphics.setColor(1, 1, 1, 1)
end

return Button
