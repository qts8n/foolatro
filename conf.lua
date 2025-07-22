--- LÖVE configuration -------------------------------------------------------
-- This file is loaded by the engine *before* any other Lua code. It sets up
-- global parameters for window, modules, and other runtime options.
-- Style: snake_case, single spaces around '='.

function love.conf(t)
    -- Identity & version
    t.identity = "foolatro"   -- Save directory for app data
    t.version = "11.4"                  -- LÖVE version this game was developed with
    t.console = true                    -- Show console (useful on Windows)

    -- Window settings
    t.window.title = "Foolatro"
    t.window.width = 800
    t.window.height = 600
    t.window.resizable = true
    t.window.minwidth = 640
    t.window.minheight = 480

    t.window.vsync = 1                  -- 0 = off, 1 = adaptive, >1 = fixed
    t.window.msaa = 0                   -- Anti-aliasing (0 = disabled)

    -- Modules: disable unused ones to save memory/CPU
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.video = false
end
