--- Validation helper module for type and value checking.
-- Provides reusable assertion helpers for validating function parameters
-- and ensuring data consistency across the project.
-- @module Validate
local Validate = {}

local function fail(name, message)
    error(string.format("Validation error: '%s' %s", name, message), 3)
end

-- Basic type checks

function Validate.exists(value, name)
    if value == nil then
        fail(name, "must be defined")
    end
    return value
end

function Validate.table(value, name)
    if type(value) ~= "table" then
        fail(name, "must be a table")
    end
    return value
end

function Validate.number(value, name)
    if type(value) ~= "number" then
        fail(name, "must be a number")
    end
    return value
end

function Validate.boolean(value, name)
    if type(value) ~= "boolean" then
        fail(name, "must be a boolean")
    end
    return value
end

function Validate.string(value, name)
    if type(value) ~= "string" then
        fail(name, "must be a string")
    end
    return value
end

function Validate.is_function(value, name)
    if type(value) ~= "function" then
        fail(name, "must be a function")
    end
    return value
end

function Validate.has_method(value, name, method_name)
    Validate.table(value, name)
    Validate.is_function(value[method_name], method_name)
    return value
end

-- Numeric constraint

function Validate.positive_number(value, name)
    Validate.number(value, name)
    if value <= 0 then
        fail(name, "must be greater than 0")
    end
    return value
end

function Validate.in_range(value, name, min, max)
    Validate.number(value, name)
    if value < min or value > max then
        fail(name, string.format("must be between %s and %s", tostring(min), tostring(max)))
    end
    return value
end

-- Love2D specific

function Validate.image(value, name)
    local t = type(value)
    if t ~= "userdata" and t ~= "table" then
        fail(name, "must be an Image object")
    end

    local has_width = type(value.getWidth) == "function"
    local has_height = type(value.getHeight) == "function"

    if not (has_width and has_height) then
        fail(name, "does not provide getWidth/getHeight methods")
    end
    return value
end

-- Utility

-- Conditionally validates only when value is not nil.
-- Usage: validate.optional(validate.number, maybe_value, "field_name")
function Validate.optional(validator, value, ...)
    if value ~= nil then
        validator(value, ...)
    end
end

return Validate
