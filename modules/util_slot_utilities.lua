slot_utils = {}

---Drains tank by a certain amount
function slot_utils.drain_tank(menu_id, slot_index, amount)
    local slot = api_get_slot(menu_id, slot_index)
    local tank = api_gp(menu_id, "tank_amount")
    local type = api_gp(menu_id, "tank_type")
    local removed_amount = utils.ternary(tank < amount, tank, amount)
    local canister_left = slot_utils.get_canister_diff(slot)

    if (tank > 0 and canister_left ~= nil and (slot.stats["type"] == type or slot.stats["type"] == "")) then
        removed_amount = math.min(removed_amount, canister_left)
        utils.ap(menu_id, "tank_amount", -removed_amount)
        local amount_left_over = slot_utils.add_canister_amount(slot, type, removed_amount)
        if (amount_left_over ~= nil and amount_left_over > 0) then
            utils.ap(menu_id, "tank_amount", amount_left_over)
        end
    end
end

---@param slot slot
---@return number|nil returns diff between max and current amount otherwise nil if max, amount, or slot is nil
function slot_utils.get_canister_diff(slot)
    return utils.ternary(slot == nil or slot.stats["max"] == nil or slot.stats["amount"] == nil, nil, slot.stats["max"] - slot.stats["amount"])
end

---@param slot slot
---@param type string
---@return number|nil returns amount left over
function slot_utils.add_canister_amount(slot, type, amount)
    local diff = slot_utils.get_canister_diff(slot)
    if (diff == nil) then
        return nil
    else
        local amount_to_add = math.min(diff, amount)
        slot.stats["type"] = type
        slot.stats["amount"] = slot.stats["amount"] + amount_to_add
        slot_utils.change_stats(slot, slot.stats)
        api_slot_redraw(slot.id)
        return math.max(0, amount - amount_to_add)
    end
end

---@param slot slot
---@param newstats table
function slot_utils.change_stats(slot, newstats)
    api_sp(slot.id, "stats", newstats)
end

function slot_utils.set_or_incr_slot(slot, item, amount)
    if (slot == nil) then return end
    if (slot.item == "") then
        api_slot_set(slot.id, item, math.min(amount, 99))
    else
        api_slot_incr(slot.id, math.min(99 - slot.count, amount))
    end
end

---@return table
function slot_utils.create_frame(filled, uncapped, productivity, flowers, species)
    return {
        filled = filled,
        uncapped = uncapped,
        flowers = table.concat(flowers, ":"),
        productivity = productivity,
        species = species
    }
end