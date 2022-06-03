
hive_utils = {}

---@param coordinate coordinate
---@return instance[] returns a list of bee_holders such as hives and nests and swarmer.
function hive_utils.get_bee_holders(coordinate, radius)
    local menu_objs = api_get_inst_in_circle('menu_obj', coordinate.x, coordinate.y, radius)
    local holders = {}

    for _, v in ipairs(menu_objs) do
        if (utils.starts(v.oid, "hive") or utils.starts(v.oid, "beehive")) then
            table.insert(holders, v)
        end
    end
    return holders
end

---@param coordinate coordinate
---@return instance[] returns a list of bee_holders that are active
function hive_utils.get_active_bee_holder(coordinate, radius)
    local active_hives = {}

    for _, v in ipairs(hive_utils.get_bee_holders(coordinate, radius)) do
        if (api_gp(v.menu_id, "working") == true) then
            table.insert(active_hives, 1, v)
        end
    end
    return active_hives
end

---@param coordinate coordinate
---@return number returns the amount of active bee holder.
function hive_utils.get_active_holder_count(coordinate, radius)
    return #hive_utils.get_active_bee_holder(coordinate, radius)
end

function hive_utils.get_multiplier(productivity)
    if (productivity == "Sluggish" or productivity == "Slowest" or productivity == "Slow") then
        return 1
    elseif (productivity == "Normal" or productivity == "Fast") then
        return 2
    elseif (productivity == "Fastest") then
        return 3
    elseif (productivity == "Brisk") then
        return 4
    end
    return 0
end