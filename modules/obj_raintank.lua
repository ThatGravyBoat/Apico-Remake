
raintank = {
    object = {
        id = "raintank",
        name = "Rain Tank",
        category = "Tools",
        tooltip = "Rain Tank Description",
        shop_key = false,
        shop_buy = 0,
        shop_sell = 0,
        tools = {"mouse1", "hammer1"},
        layout = {
            {21, 63, "Liquid Output", {"canister1", "canister2"}}
        },
        buttons = {"Help", "Move", "Target", "Close"},
        info = {
            {"1. Water Output", "GREEN"},
            {"2. Water Tank", "YELLOW"}
        }
    },
    scripts = {
        draw = "raintank_draw",
        tick = "raintank_tick",
        define = "raintank_define",
        change = "raintank_change"
    }
}

function raintank.register()
    api_define_menu_object(raintank.object, "sprites/objects/raintank.png","sprites/menus/raintank.png", raintank.scripts)
    raintank.draining_sprite = api_define_sprite("raintank_draining", "sprites/menus/draining.png", 1)
end

function raintank_define(menu_id)
    api_dp(menu_id, "p_counter", 0)
    api_dp(menu_id, "p_drain_counter", 0)
    api_dp(menu_id, "p_has_canister", false)
    api_dp(menu_id, "p_draining", false)
    api_define_tank(menu_id, 0, 500, "water", 6, 14, "xlarge")
end

function raintank_change(menu_id)
    api_sp(menu_id, "p_has_canister", api_get_slot(menu_id, 1)["item"] ~= "")
end

function raintank_draw(menu_id)
    api_draw_tank(api_gp(menu_id, "tank_gui"))
    local coordinate = utils.gui_coordinates(menu_id)

    if (api_gp(menu_id, "p_has_canister") and api_gp(menu_id, "p_draining") and api_gp(menu_id, "tank_amount") > 0) then
        api_draw_sprite(raintank.draining_sprite, 1, coordinate.x + 25, coordinate.y + 56)
    end
end

function raintank_tick(menu_id)
    if (api_get_weather().active and api_gp(menu_id, "tank_amount") < 500) then
        utils.ap(menu_id, "p_counter", 1)
        if (api_gp(menu_id, "p_counter") == 10) then
            utils.ap(menu_id, "tank_amount", 1)
            api_sp(menu_id, "p_counter", 0)
        end
    end
    if (api_gp(menu_id, "p_has_canister")) then
        utils.ap(menu_id, "p_drain_counter", 1)
        if (api_gp(menu_id, "p_drain_counter") == 10) then
            slot_utils.drain_tank(menu_id, 1, 1)
            api_sp(menu_id, "p_drain_counter", 0)
        end
        api_sp(menu_id, "p_draining", slot_utils.get_canister_diff(api_get_slot(menu_id, 1)) > 0)
    end
end
