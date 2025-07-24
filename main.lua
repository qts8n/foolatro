-- Module imports
local asset_server = require("foolatro.utils.asset_server")
local Spaceship = require("foolatro.entities.spaceship")
local Button = require("foolatro.ui.button")
local Checkbox = require("foolatro.ui.checkbox")
local SelectBox = require("foolatro.ui.select_box")
local Card = require("foolatro.entities.card")
local World = require("foolatro.world")

-- Entities
local world
local button
local checkbox
local select_box
local card
local spaceship

-- Prepare assets
function love.load()
    -- Load assets
    asset_server:load_assets()

    -- Initialize world
    world = World.new()
    world:load()

    -- Initialize UI
    button = Button.new({
        x = 200,
        y = 200,
        w = 100,
        h = 50,
        label = "Click me",
        on_click = function()
            print("Button clicked")
        end
    })
    checkbox = Checkbox.new({
        x = 500,
        y = 500,
        size = 20,
        label = "Check me",
    })
    select_box = SelectBox.new({
        x = 200,
        y = 400,
        w = 200,
        h = 30,
        options = {"Option 1", "Option 2", "Option 3", "Option 4"},
        selected = 1,
        on_select = function(_, index, value)
            print("Selected:", value, "at index", index)
        end,
        max_dropdown_items = 3
    })

    -- Initialize entities
    spaceship = Spaceship.new({
        world = world,
        x = 100,
        y = 100,
        quad_id = 2,
        scale = 1,
        scale_x = 1,
        scale_y = 1,
        rotation = 0,
        origin_x = 0,
        origin_y = 0
    })
    card = Card.new({
        world = world,
        x = 500,
        y = 100,
        fov = 45,
        tilt_max = 5,
    })
end


function love.mousepressed(x, y, b)
    button:handle_mousepressed(x, y, b)
    checkbox:handle_mousepressed(x, y, b)
    select_box:handle_mousepressed(x, y, b)
    card:handle_mousepressed(x, y, b)
end


function love.mousereleased(x, y, b)
    button:handle_mousereleased(x, y, b)
    checkbox:handle_mousereleased(x, y, b)
    select_box:handle_mousereleased(x, y, b)
    card:handle_mousereleased(x, y, b)
end


function love.wheelmoved(x, y)
    select_box:handle_wheel(x, y)
end


function love.update(dt)
    spaceship:update(dt)
    button:update(dt)
    checkbox:update(dt)
    select_box:update(dt)
    card:update(dt)
end


-- Rendering
function love.draw()
    spaceship:draw()
    button:draw()
    checkbox:draw()
    select_box:draw()
    card:draw()
end
