auto_sawmill = {
    object = {
        id = "auto_sawmill",
        name = "Auto Sawmill",
        category = "Tools",
        tooltip = "Auto Sawmill Description",
        shop_key = false,
        shop_buy = 0,
        shop_sell = 0,
        tools = {"mouse1", "hammer1"},
        layout = {
            {7, 17, "Input", {"log", "planks1"}},
            {7, 40, "Input", {"log", "planks1"}},
            {76, 17, "Output"},
            {99, 17, "Output"},
            {87, 40, "OutputX"},
            {7, 66},
            {30, 66},
            {53, 66},
            {76, 66},
            {99, 66}
        },
        buttons = {"Help", "Move", "Target", "Close"},
        info = {
            { "1. Wood Input Slots", "GREEN" },
            { "2. Sawn Output Slots", "RED" },
            { "3. Extra Storage", "WHITE" }
        }
    },
    scripts = {
        draw = "auto_sawmill_draw",
        define = "auto_sawmill_define",
        change = "auto_sawmill_change",
        tick = "auto_sawmill_tick"
    },
    recipes = {
        log = {
            output = {
                item = "planks1",
                amount = 2
            },
            saw_dust = 0.5
        },
        planks1 = {
            output = {
                item = "sticks1",
                amount = 2
            },
            saw_dust = 0
        }
    }
}

function auto_sawmill.register()
    api_define_menu_object(auto_sawmill.object, "sprites/objects/auto_sawmill.png","sprites/menus/auto_sawmill.png", auto_sawmill.scripts)
end

function auto_sawmill_define(menu_id)
    auto_machine_utils.define_battery(menu_id, 25, 14)
    utils.define_gui_with_texture(menu_id, "progress_bar", 41, 20, "auto_sawmill", "sprites/menus/auto_squeezer_progress_bar.png")

    api_dp(menu_id, "p_working", false)
    api_dp(menu_id, "p_progress", 0)
end

function auto_sawmill_change(menu_id)
    auto_sawmill.check_inputs(menu_id)
end

function auto_sawmill_progress_bar_tooltip(menu_id)
    return {
        { "Sawing Wood", "FONT_WHITE"},
        { tostring(api_gp(menu_id, "p_progress") * 100) .. "%", "FONT_BGREY"},
    }
end

function auto_sawmill_draw(menu_id)
    auto_machine_utils.draw_battery(menu_id)

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
end

function auto_sawmill_tick(menu_id)
    auto_machine_utils.tick_battery(menu_id)

    if (api_gp(menu_id, "p_working") == true) then
        utils.ap(menu_id, "p_progress", 0.02)
        utils.ap(menu_id, "p_battery", -0.2)
        if (api_gp(menu_id, "p_progress") >= 1) then
            api_sp(menu_id, "p_progress", 0)
            auto_sawmill.check_inputs(menu_id) --Check inputs and then process.
            if (api_gp(menu_id, "p_working") == true) then
                local log_plank_slot = api_slot_match_range(menu_id, {"log", "planks1"}, {1, 2}, true)
                if (log_plank_slot ~= nil) then
                    local recipe = auto_sawmill.recipes[log_plank_slot.item]
                    local output_slots = api_slot_match_range(menu_id, {recipe.output.item, ""}, {3, 4}, false)

                    api_slot_decr(log_plank_slot.id, 1)

                    for _, v in ipairs(output_slots) do
                        if (v.item == "" or (v.count + recipe.output.amount) < 100) then
                            slot_utils.set_or_incr_slot(v, recipe.output.item, 2)
                            break
                        end
                    end

                    if (recipe.saw_dust ~= 0 and (api_random(100)/100) < recipe.saw_dust) then
                        slot_utils.set_or_incr_slot(api_get_slot(menu_id, 5), "sawdust1", 1)
                    end
                end
                auto_sawmill.check_inputs(menu_id) -- Check Inputs again so it doesnt process nothing at the end.
            end
        end
    end
end

function auto_sawmill.check_inputs(menu_id)
    local log_plank_slot = api_slot_match_range(menu_id, {"log", "planks1"}, {1, 2}, true)
    if (log_plank_slot ~= nil) then
        local recipe = auto_sawmill.recipes[log_plank_slot.item]
        local output_slots = api_slot_match_range(menu_id, {"", recipe.output.item}, {3, 4}, false)
        local can_process = false
        for _, v in ipairs(output_slots) do
            if (v.item == "" or (v.count + recipe.output.amount) < 100) then
                can_process = true
                break
            end
        end

        if (api_gp(menu_id,  "p_battery") > 10 and can_process) then
            api_sp(menu_id, "p_working", true)
            return
        end
    end

    api_sp(menu_id, "p_working", false)
    api_sp(menu_id, "p_progress", 0)
end
