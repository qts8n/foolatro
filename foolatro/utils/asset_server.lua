-- Module imports
local Spritesheet = require("foolatro.utils.spritesheet")

-- Module constants
local ASSET_DIR_PATH = "assets/"

-- Module definition
local AssetServer = {}

-- Image asset table
local image_assets = {
    card_back = "sprites/card-back-1.png",
}

-- Spritesheet asset table
local spritesheet_assets = {
    spaceships = {
        path = "sprites/sheets/spaceships.png",
        frame_width = 16,  -- 16x16 grid for most sprites
        frame_height = 16,
        -- Optional overrides for irregular sprites (uncomment / edit as needed)
        -- overrides = {
        --     { name = "boss", x = 0, y = 64, width = 32, height = 32 },
        -- },
    },
}

-- Shader asset table
local shader_assets = {
    card_perspective = "shaders/card_perspective.glsl",
}

-- Sound asset table
local sound_assets = {
    card_flick = "sounds/card-flick.mp3",
}

-- Load all assets
function AssetServer:load_assets()
    -- Load standalone images
    self.images = {}
    for name, path in pairs(image_assets) do
        self.images[name] = love.graphics.newImage(ASSET_DIR_PATH .. path)
    end

    -- Load spritesheets and generate quads
    self.spritesheets = {}
    for name, cfg in pairs(spritesheet_assets) do
        local image = love.graphics.newImage(ASSET_DIR_PATH .. cfg.path)
        self.spritesheets[name] = Spritesheet.new(
            image,
            cfg.frame_width,
            cfg.frame_height,
            cfg.overrides
        )
    end

    -- Load shaders
    self.shaders = {}
    for name, path in pairs(shader_assets) do
        self.shaders[name] = love.graphics.newShader(ASSET_DIR_PATH .. path)
    end

    -- Load sounds
    self.sounds = {}
    for name, path in pairs(sound_assets) do
        self.sounds[name] = love.audio.newSource(ASSET_DIR_PATH .. path, "static")
    end
end

--- Retrieve a previously loaded Image.
function AssetServer:get_image(name)
    return self.images and self.images[name]
end

--- Retrieve a previously loaded Spritesheet.
function AssetServer:get_spritesheet(name)
    return self.spritesheets and self.spritesheets[name]
end

--- Retrieve a quad by spritesheet name and id (number or string).
function AssetServer:get_quad(sheet_name, id)
    local sheet = self:get_spritesheet(sheet_name)
    if sheet then
        return sheet:get(id)
    end
    return nil
end

--- Retrieve a previously loaded Shader.
function AssetServer:get_shader(name)
    return self.shaders and self.shaders[name]
end

--- Retrieve a previously loaded Sound.
function AssetServer:get_sound(name)
    return self.sounds and self.sounds[name]
end

return AssetServer

