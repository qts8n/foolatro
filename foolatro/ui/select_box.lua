-- Module imports
local Validate = require("foolatro.utils.validate")

-- Component definition
local SelectBox = {}
SelectBox.__index = SelectBox

--- Creates a new SelectBox UI component with dropdown functionality.
-- @param opts table Required parameters:
--        x, y          Position of the top-left corner in pixels
--        w, h          Width and height in pixels
--        options       Array of option strings to display
--        selected      Index of initially selected option (default 1)
--        font          Custom LÖVE Font object for text (optional)
--        on_select     Function(selectbox, selected_index, selected_value) called when option selected
--        hover_color   RGBA color table {r,g,b,a} for hover state (optional)
--        max_dropdown_items Number of items to show in dropdown before scrolling (default 5)
function SelectBox.new(opts)
    Validate.table(opts, "opts")

    Validate.number(opts.x, "x")
    Validate.number(opts.y, "y")
    Validate.positive_number(opts.w, "w")
    Validate.positive_number(opts.h, "h")
    Validate.table(opts.options, "options")
    Validate.optional(Validate.number, opts.selected, "selected")
    -- TODO: Validate font
    Validate.optional(Validate.is_function, opts.on_select, "on_select")

    local self = setmetatable({}, SelectBox)

    self.x = opts.x
    self.y = opts.y
    self.w = opts.w
    self.h = opts.h

    self.options = opts.options
    self.selected = opts.selected or 1
    self.font = opts.font
    self.on_select = opts.on_select

    self.hover_color = opts.hover_color or { 0.8, 0.8, 0.8, 1.0 }
    self.base_color = { 0.2, 0.2, 0.2, 1.0 }
    self.dropdown_color = { 0.3, 0.3, 0.3, 1.0 }

    self.is_open = false
    self.is_hovered = false
    self.hovered_option = nil

    self.max_dropdown_items = opts.max_dropdown_items or 5
    self.scroll_offset = 0

    -- Calculate dropdown dimensions
    self.item_height = self.h
    self.dropdown_height = math.min(#self.options, self.max_dropdown_items) * self.item_height

    return self
end

-- Internal helper to test if mouse is over the main box
function SelectBox:_contains(x_, y_)
    return x_ >= self.x and x_ <= self.x + self.w and
           y_ >= self.y and y_ <= self.y + self.h
end

-- Internal helper to test if mouse is over the dropdown area
function SelectBox:_contains_dropdown(x_, y_)
    if not self.is_open then return false end

    return x_ >= self.x and x_ <= self.x + self.w and
           y_ >= self.y + self.h and y_ <= self.y + self.h + self.dropdown_height
end

-- Internal helper to get hovered option index
function SelectBox:_get_hovered_option(mx, my)
    if not self:_contains_dropdown(mx, my) then return nil end

    local relative_y = my - (self.y + self.h)
    local option_idx = math.floor(relative_y / self.item_height) + 1 + self.scroll_offset

    if option_idx >= 1 and option_idx <= #self.options then
        return option_idx
    end
    return nil
end

function SelectBox:update(dt)
    local mx, my = love.mouse.getPosition()
    self.is_hovered = self:_contains(mx, my)

    if self.is_open then
        self.hovered_option = self:_get_hovered_option(mx, my)
    end
end

function SelectBox:handle_mousepressed(mx, my, button)
    if button ~= 1 then
        return
    end

    if self:_contains(mx, my) then
        self.is_open = not self.is_open
        return
    end

    if self:_contains_dropdown(mx, my) then
        local option_idx = self:_get_hovered_option(mx, my)
        if option_idx then
            self.selected = option_idx
            self.is_open = false
            if self.on_select then
                self.on_select(self, self.selected, self.options[self.selected])
            end
        end
        return
    end

    self.is_open = false
end

function SelectBox:handle_mousereleased(_, _, _)
end

function SelectBox:handle_wheel(x, y)
    if not self.is_open or not self:_contains_dropdown(love.mouse.getPosition()) then
        return false
    end

    local max_scroll = math.max(0, #self.options - self.max_dropdown_items)
    self.scroll_offset = math.max(0, math.min(max_scroll, self.scroll_offset - y))
    return true
end

function SelectBox:draw()
    -- Draw main box
    local r, g, b, a = unpack(self.base_color)
    if self.is_hovered then
        r, g, b, a = unpack(self.hover_color)
    end

    love.graphics.setColor(r, g, b, a)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    -- Draw selected option
    local prev_font = nil
    if self.font then
        prev_font = love.graphics.getFont()
        love.graphics.setFont(self.font)
    end

    -- Draw selected text
    love.graphics.setColor(1, 1, 1, 1)
    local selected_text = self.options[self.selected]
    local text_h = love.graphics.getFont():getHeight()
    local tx = self.x + 10
    local ty = self.y + (self.h - text_h) / 2
    love.graphics.print(selected_text, tx, ty)

    -- Draw dropdown arrow
    local arrow_size = self.h * 0.3
    local arrow_x = self.x + self.w - arrow_size - 10
    local arrow_y = self.y + (self.h - arrow_size) / 2
    love.graphics.polygon("fill",
        arrow_x, arrow_y,
        arrow_x + arrow_size, arrow_y,
        arrow_x + arrow_size / 2, arrow_y + arrow_size
    )

    -- Draw dropdown if open
    if self.is_open then
        love.graphics.setColor(unpack(self.dropdown_color))
        love.graphics.rectangle("fill", self.x, self.y + self.h, self.w, self.dropdown_height)

        -- Draw visible options
        love.graphics.setScissor(self.x, self.y + self.h, self.w, self.dropdown_height)
        for i = 1, math.min(self.max_dropdown_items, #self.options - self.scroll_offset) do
            local opt_idx = i + self.scroll_offset
            local opt_y = self.y + self.h + (i - 1) * self.item_height

            -- Highlight hovered option
            if opt_idx == self.hovered_option then
                love.graphics.setColor(unpack(self.hover_color))
                love.graphics.rectangle("fill", self.x, opt_y, self.w, self.item_height)
            end

            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print(self.options[opt_idx], self.x + 10, opt_y + (self.item_height - text_h) / 2)
        end
        love.graphics.setScissor()
    end

    if prev_font then
        love.graphics.setFont(prev_font)
    end

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

return SelectBox
