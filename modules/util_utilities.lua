
utils = {}

function utils.ternary(statement, first, second)
    if (statement) then
        return first
    else
        return second
    end
end

function utils.ap(id, prop_name, amount)
    api_sp(id, prop_name, api_gp(id, prop_name) + amount)
end

function utils.ap_max(id, prop_name, amount, max)
    api_sp(id, prop_name,   math.max(max, api_gp(id, prop_name) + amount))
end

function utils.define_gui_with_texture(menu_id, key, x, y, obj_id, sprite)
    api_define_gui(menu_id, key, x, y, obj_id .. "_" .. key .. "_tooltip", sprite)
    api_dp(menu_id, key .. "_sprite", api_get_sprite(MOD_ID .. "_" .. key))
end

--Taken off of Stackover flow.
function utils.table_to_string(tbl)
    local result = ""
    for k, v in pairs(tbl) do

        if type(k) == "string" then
            result = string.format("['%s'] = ", k)
        end

        if type(v) == "table" then
            result = result .. table_to_string(v)
        elseif type(v) == "boolean" or type(v) == "number" then
            result = result .. tostring(v)
        else
            result = string.format("'%s'", k)
        end
        result = result .. ","
    end

    if result ~= "" then
        result = result:sub(1, result:len()-1)
    end
    return string.format("{ %s }", result)
end

---@return coordinate returns the top left coords of the menu.
function utils.gui_coordinates(menu_id)
    return utils.gui_coordinates_with_gui(api_get_inst(menu_id))
end

---@param gui coordinate the gui coords
---@return coordinate returns the top left coords of the menu.
function utils.gui_coordinates_with_gui(gui)
    local cam = api_get_cam()
    return {
        x = gui["x"] - cam["x"],
        y = gui["y"] - cam["y"]
    }
end

---@param value string the string to check
---@param start string the string to that the value must start with
---@return boolean returns wither the string stats with another string
function utils.starts(value,stats)
    return string.sub(value,1, string.len(stats)) == stats
end

function utils.split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function utils.update_fields(menu_id, field)
    local fields = api_gp(menu_id, "_fields")
    table.insert(fields, field)
    api_sp(menu_id, "_fields", fields)
end