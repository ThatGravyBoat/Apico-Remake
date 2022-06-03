auto_squeezer = {
    object = {
        id = "auto_squeezer",
        name = "Auto Squeezer",
        category = "Tools",
        tooltip = "Auto Squeezer Description",
        shop_key = false,
        shop_buy = 0,
        shop_sell = 0,
        tools = {"mouse1", "hammer1"},
        layout = {
            { 7, 17, "Input", {"log"} },
            { 7, 40, "Input", {"acorn1"} },
            { 76, 63, "Liquid Output", {"canister1", "canister2"} },
            { 7, 89 },
            { 30, 89 },
            { 53, 89 },
            { 76, 89 }
        },
        buttons = {"Help", "Move", "Target", "Close"},
        info = {
            { "1. Wood Input Slots", "GREEN" },
            { "2. Resin Storage Tank", "YELLOW" },
            { "3. Resin Drainage Slot", "RED" },
            { "4. Extra Storage", "WHITE" }
        }
    },
    scripts = {
        draw = "auto_squeezer_draw",
        define = "auto_squeezer_define",
        change = "auto_squeezer_change",
        tick = "auto_squeezer_tick"
    }
}

function auto_squeezer.register()
    api_define_menu_object(auto_squeezer.object, "sprites/objects/auto_squeezer.png","sprites/menus/auto_squeezer.png", auto_squeezer.scripts)
    auto_squeezer.draining_sprite = api_define_sprite("auto_squeezer_draining", "sprites/menus/draining.png", 1)
end

function auto_squeezer_define(menu_id)
    api_define_tank(menu_id, 0, 1000, 'resin', 76, 14, 'large')
    auto_machine_utils.define_battery(menu_id, 25, 14)
    utils.define_gui_with_texture(menu_id, "progress_bar", 41, 20, "auto_squeezer", "sprites/menus/auto_squeezer_progress_bar.png")

    api_dp(menu_id, "p_working", false)
    api_dp(menu_id, "p_progress", 0)
    api_dp(menu_id, "p_drain_counter", 0)
    api_dp(menu_id, "p_has_canister", false)
    api_dp(menu_id, "p_draining", false)
end

function auto_squeezer_change(menu_id)
    auto_squeezer.check_inputs(menu_id)
    api_sp(menu_id, "p_has_canister", api_get_slot(menu_id, 3)["item"] ~= "")
end

function auto_squeezer_progress_bar_tooltip(menu_id)
    return {
        { "Squeezing", "FONT_WHITE"},
        { tostring(api_gp(menu_id, "p_progress") * 100) .. "%", "FONT_BGREY"},
    }
end

function auto_squeezer_draw(menu_id)
    api_draw_tank(api_gp(menu_id, "tank_gui"))
    auto_machine_utils.draw_battery(menu_id)

    -- I Use do blocks here to localize the scope of the variables inside to make it easier on my self
    -- this means I can have 2 variables named gui in the same function without one being named slightly different
    -- the only thing is those variables can only be accessed in those do blocks.

    --region Progress Bar
    do
        local sprite = api_gp(menu_id, "progress_bar_sprite")
        local gui = api_get_inst(api_gp(menu_id, "progress_bar"))
        local coords = utils.gui_coordinates_with_gui(gui)

        api_draw_sprite(sprite, 1, coords.x, coords.y)
        local progress = api_gp(menu_id, "p_progress") * 32

        api_draw_sprite_part(sprite, 2, 0, 0, progress, 10, coords.x, coords.y)
        api_draw_sprite(sprite, 1, coords.x, coords.y)

        if api_get_highlighted("ui") == gui["id"] then
            api_draw_sprite(sprite, 0, coords.x, coords.y)
        end
    end
    --endregion
    --region Draining
    do
        local coordinate = utils.gui_coordinates(menu_id)

        if (api_gp(menu_id, "p_has_canister") and api_gp(menu_id, "p_draining") and api_gp(menu_id, "tank_amount") > 0) then
            api_draw_sprite(auto_squeezer.draining_sprite, 1, coordinate.x + 80, coordinate.y + 56)
        end
    end
    --endregion
end

function auto_squeezer_tick(menu_id)

    auto_machine_utils.tick_battery(menu_id)

    if (api_gp(menu_id, "p_working") == true) then
        utils.ap(menu_id, "p_progress", 0.02)
        utils.ap(menu_id, "p_battery", -0.2)
        if (api_gp(menu_id, "p_progress") >= 1) then
            api_sp(menu_id, "p_progress", 0)
            auto_squeezer.check_inputs(menu_id) --Check inputs and then process.
            if (api_gp(menu_id, "p_working") == true) then
                local log_slot = api_get_slot(menu_id, 1)
                local acorn_slot = api_get_slot(menu_id, 2)
                if (log_slot.item == "log") then
                    api_slot_decr(log_slot.id, 1)
                elseif (acorn_slot.item == "acorn1") then
                    api_slot_decr(acorn_slot.id, 1)
                end
                api_sp(menu_id,  "tank_amount", math.min(1000, api_gp(menu_id,  "tank_amount") + 5))
                auto_squeezer.check_inputs(menu_id) -- Check Inputs again so it doesnt process nothing at the end.
            end
        end
    end

    if (api_gp(menu_id, "p_has_canister")) then
        utils.ap(menu_id, "p_drain_counter", 1)
        if (api_gp(menu_id, "p_drain_counter") == 10) then
            slot_utils.drain_tank(menu_id, 3, 5)
            api_sp(menu_id, "p_drain_counter", 0)
        end
        api_sp(menu_id, "p_draining", slot_utils.get_canister_diff(api_get_slot(menu_id, 3)) > 0)
    end
end

function auto_squeezer.check_inputs(menu_id)
    local log_slot = api_slot_item_id(menu_id, 1)
    local acorn_slot = api_slot_item_id(menu_id, 2)

    if ((log_slot == "log" or acorn_slot == "acorn1") and api_gp(menu_id,  "tank_amount") < 1000 and api_gp(menu_id,  "p_battery") > 10) then
        api_sp(menu_id, "p_working", true)
    else
        api_sp(menu_id, "p_working", false)
        api_sp(menu_id, "p_progress", 0)
    end
end
