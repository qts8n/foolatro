-- Module imports
local Validate = require("foolatro.utils.validate")

-- Spritesheet class definition
local Spritesheet = {}
Spritesheet.__index = Spritesheet

--- Create a new spritesheet helper.
-- @param image           The already loaded Image object for the spritesheet.
-- @param frame_width     Width (in pixels) of the regular frames in the sheet.
-- @param frame_height    Height (in pixels) of the regular frames in the sheet.
-- @param overrides       Optional array with custom sprite definitions for frames that
--                        do NOT fit the regular grid. Each entry is a table with the keys:
--                          name   (string) unique identifier of the sprite
--                          x, y   (number) top-left pixel position in the sheet
--                          width, height (number) size of the sprite in pixels
--                        When provided, these custom quads are added (or overwrite) entries
--                        in the generated grid.
-- @return                A Spritesheet instance.
function Spritesheet.new(image, frame_width, frame_height, overrides)
    -- Validate input arguments early using shared Validate module
    Validate.image(image, "image")
    Validate.positive_number(frame_width, "frame_width")
    Validate.positive_number(frame_height, "frame_height")

    local self = setmetatable({}, Spritesheet)
    self.image = image
    self.frame_width = frame_width
    self.frame_height = frame_height
    self.quads = {}

    -- Generate quads for the regular grid
    local img_w, img_h = image:getWidth(), image:getHeight()
    local cols = math.floor(img_w / frame_width)
    local rows = math.floor(img_h / frame_height)
    local idx = 1

    for row = 0, rows - 1 do
        for col = 0, cols - 1 do
            local quad = love.graphics.newQuad(
                col * frame_width,
                row * frame_height,
                frame_width,
                frame_height,
                img_w,
                img_h
            )
            self.quads[idx] = quad
            idx = idx + 1
        end
    end

    -- Handle overrides for irregular-sized sprites (optional)
    if overrides then
        Validate.table(overrides, "overrides")

        for i, def in ipairs(overrides) do
            Validate.table(def, string.format("overrides[%d]", i))
            Validate.number(def.x, string.format("overrides[%d].x", i))
            Validate.number(def.y, string.format("overrides[%d].y", i))
            Validate.positive_number(def.width, string.format("overrides[%d].width", i))
            Validate.positive_number(def.height, string.format("overrides[%d].height", i))
        end

        for _, def in ipairs(overrides) do
            local name = def.name or ("custom_" .. tostring(_))
            local quad = love.graphics.newQuad(def.x, def.y, def.width, def.height, img_w, img_h)
            self.quads[name] = quad
        end
    end

    return self
end

--- Retrieve a quad by numeric index or by name (for overrides).
-- @param id   number or string index into the quad table.
-- @return     love.graphics.Quad or nil.
function Spritesheet:get(id)
    return self.quads[id]
end

--- Access the underlying Image object (useful for drawing).
function Spritesheet:get_image()
    return self.image
end

return Spritesheet
