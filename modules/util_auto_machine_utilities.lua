
auto_machine_utils = {}

function auto_machine_utils.define_battery(menu_id, x, y)
    utils.define_gui_with_texture(menu_id, "bv", x, y, "auto_machine", "sprites/menus/bv_bar.png")
    utils.define_gui_with_texture(menu_id, "charging", x+15, y, "auto_machine", "sprites/menus/bv_charging.png")

    api_dp(menu_id, "p_hive_counter", 0)
    api_dp(menu_id, "p_active_hives", 0)
    api_dp(menu_id, "p_battery", 0)
end

function auto_machine_utils.draw_battery(menu_id)
    --region BV Bar
    do
        local sprite = api_gp(menu_id, "bv_sprite")
        local gui = api_get_inst(api_gp(menu_id, "bv"))
        local coords = utils.gui_coordinates_with_gui(gui)

        local progress = (api_gp(menu_id, "p_battery") / 1000.0) * 22

        api_draw_sprite_part(sprite, 2, 0, 22 - progress, 16, progress, coords.x, (22 - progress) + coords.y)

        if api_get_highlighted("ui") == gui["id"] then
            api_draw_sprite(sprite, 0, coords.x, coords.y)
        end
    end
    --endregion

    --region BV Charging
    do
        local sprite = api_gp(menu_id, "charging_sprite")
        local gui = api_get_inst(api_gp(menu_id, "charging"))
        local coords = utils.gui_coordinates_with_gui(gui)

        if (api_gp(menu_id, "p_active_hives") > 0) then
            api_draw_sprite(sprite, 1, coords.x, coords.y)
        end

        if api_get_highlighted("ui") == gui["id"] then
            api_draw_sprite(sprite, 0, coords.x, coords.y)
        end
    end
    --endregion
end

function auto_machine_utils.tick_battery(menu_id)
    local active_hives = api_gp(menu_id, "p_active_hives")
    utils.ap(menu_id, "p_hive_counter", 1)

    if (api_gp(menu_id, "p_hive_counter") == 10) then
        api_sp(menu_id, "p_hive_counter", 0)
        local menu_obj_id = api_get_menus_obj(menu_id)
        if (menu_obj_id ~= nil) then
            local menu_inst = api_get_inst(menu_obj_id)
            if (menu_inst ~= nil) then
                api_sp(menu_id, "p_active_hives", hive_utils.get_active_holder_count(menu_inst, 100))
            end
        end
    end

    if (active_hives > 0 and api_gp(menu_id, "p_battery") < 1000) then
        utils.ap_max(menu_id, "p_battery", active_hives * 0.2, 1000)
    end
end

function auto_machine_bv_tooltip(menu_id)
    local active_hives = math.floor(api_gp(menu_id, "p_active_hives"))
    local tooltip = {
        {"Honeycore Battery", "FONT_WHITE"},
        {string.format("%.2f/1000BV", api_gp(menu_id, "p_battery")), "FONT_BGREY"},
        {string.format("%i active hives nearby", active_hives), "FONT_BGREY"}
    }
    if (active_hives > 0) then
        table.insert(tooltip, {string.format("Charging %iBV per second", active_hives), "FONT_YELLOW"})
    end
    return tooltip
end

function auto_machine_charging_tooltip(menu_id)
    local active_hives = math.floor(api_gp(menu_id, "p_active_hives"))
    return {
        utils.ternary(active_hives > 0, {"Charging", "FONT_YELLOW"}, {"Not Charging", "FONT_WHITE"}),
        {string.format("%i active hives nearby", active_hives), "FONT_BGREY"}
    }
end