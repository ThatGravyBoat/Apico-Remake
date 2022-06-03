trash_bin = {
    object = {
        id = "trash_bin",
        name = "Trash Can",
        category = "Tools",
        tooltip = "Trash Can Description",
        shop_key = false,
        shop_buy = 0,
        shop_sell = 0,
        tools = {"mouse1", "hammer1"},
        layout = {
            {7, 17},
            {30, 17},
            {53, 17},
            {7, 40},
            {30, 40},
            {53, 40}
        },
        buttons = {"Help", "Move", "Target", "Close"},
        info = {
            {"1. Trash Slots", "RED"}
        }
    },
    scripts = {
        draw = "trash_bin_draw",
        define = "trash_bin_define",
        change = "trash_bin_change"
    },
    buttons = {
        no_items = {
            x = 17,
            y = 62,
            text = "No Items"
        },
        bin_items = {
            x = 15,
            y = 62,
            text = "Bin Items"
        },
        bin_item = {
            x = 18,
            y = 62,
            text = "Bin Item"
        }

    }
}

function trash_bin.register()
    api_define_menu_object(trash_bin.object, "sprites/objects/trash_bin.png","sprites/menus/trash_bin.png", trash_bin.scripts)

    api_define_color("DISABLED_BUTTON_TEXT", { r = 200, g = 145, b = 165 })
    api_define_color("ENABLED_BUTTON_TEXT", { r = 255, g = 255, b = 255 })
end

function trash_bin.update_menu_state(menu_id)
    local bad_item = false
    local item_count = 0

    for slot_id = 1, 6, 1 do
        local item = api_slot_item_id(menu_id, slot_id)
        if (item ~= "") then
            item_count = item_count + 1
            local definition = api_get_definition(item)
            api_log("Bee", item)
            if ((definition ~= nil and definition["cost"]["key"] == 1) or utils.starts(item, "bee:")) then
                bad_item = true
            end
        end
    end

    api_sp(menu_id, "p_item_count", item_count)
    api_sp(menu_id, "p_has_bad_item", bad_item)
end

function trash_bin_define(menu_id)
    api_dp(menu_id, "p_item_count", 0)
    api_dp(menu_id, "p_has_bad_item", false)
    api_define_button(menu_id, "bin_btn", 4, 59, "", "trash_bin_click", "sprites/menus/trash_bin_btn.png")
end

function trash_bin_click(menu_id)

    trash_bin.update_menu_state(menu_id)

    if (api_gp(menu_id, "p_has_bad_item") == false) then
        api_play_sound("click")
        for _, v in ipairs(api_slot_match(menu_id, {"ANY"}, false)) do
            api_slot_clear(v.id)
        end
    else
        api_play_sound("error")
    end
    trash_bin.update_menu_state(menu_id)
end

function trash_bin_change(menu_id)
    trash_bin.update_menu_state(menu_id)
end

function trash_bin_draw(menu_id)
    api_draw_button(api_gp(menu_id, "bin_btn"), false)

    local gui = utils.gui_coordinates(menu_id)

    local button = trash_bin.buttons.no_items
    local item_count = api_gp(menu_id, "p_item_count")
    if (item_count > 0) then
        button = utils.ternary(item_count > 1, trash_bin.buttons.bin_items, trash_bin.buttons.bin_item)
    end

    local bad_item = api_gp(menu_id, "p_has_bad_item")

    local text_color = utils.ternary(bad_item or item_count <= 0, "DISABLED_BUTTON_TEXT", "ENABLED_BUTTON_TEXT")

    api_draw_text(gui.x + button.x, gui.y + button.y, button.text, false, text_color)

    if (bad_item) then
        api_draw_text(gui.x + 5, gui.y + 86, "You can't throw away key items!", true, "FONT_RED", 110)
    end

    --TODO Write code to display crosses on each slot depending on if they are empty.
end
