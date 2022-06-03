auto_centrifuge = {
    object = {
        id = "auto_centrifuge",
        name = "Auto Centrifuge",
        category = "Tools",
        tooltip = "Auto Centrifuge Description",
        shop_key = false,
        shop_buy = 0,
        shop_sell = 0,
        tools = {"mouse1", "hammer1"},
        layout = {
            {7, 17, "Input", {"frameX:filled", "frameX:uncapped"}},
            {7, 40, "Input", {"frameX:filled", "frameX:uncapped"}},
            {7, 63, "Input", {"frameX:filled", "frameX:uncapped"}},
            {30, 17, "Input", {"frameX:filled", "frameX:uncapped"}},
            {30, 40, "Input", {"frameX:filled", "frameX:uncapped"}},
            {30, 63, "Input", {"frameX:filled", "frameX:uncapped"}},
            {65, 63, "OutputY"},
            {99, 17, "Output"},
            {99, 40, "Output"},
            {99, 63, "Output"},
            {122, 17, "Output"},
            {122, 40, "Output"},
            {122, 63, "Output"},
            {145, 17, "Output"},
            {145, 40, "Output"},
            {145, 63, "Output"},
            {168, 17, "OutputX"},
            {168, 40, "OutputX"},
            {168, 63, "OutputX"},
            {191, 17, "OutputX"},
            {191,40, "OutputX"},
            {191, 63, "OutputX"},
            {214, 63, "Liquid Output", {"canister1", "canister2"}},
            {7, 89},
            {30, 89},
            {53, 89},
            {76, 89},
            {99, 89},
            {122, 89},
            {145, 89},
            {168, 89},
            {191, 89},
            {214, 89}
        },
        buttons = {"Help", "Move", "Target", "Close"},
        info = {
            {"1. $info_slot26", "GREEN"},
            {"2. $info_slot27", "RED"},
            {"3. $info_slot28", "RED"},
            {"4. $info_slot31", "YELLOW"},
            {"5. $info_slot36", "RED"},
            {"6. $info_slot55", "RED"},
            {"7. $info_slot06", "WHITE"}
        }
    },
    scripts = {
        draw = "auto_centrifuge_draw",
        define = "auto_centrifuge_define",
        change = "auto_centrifuge_change",
        tick = "auto_centrifuge_tick"
    }
}

function auto_centrifuge.register()
    api_define_menu_object(auto_centrifuge.object, "sprites/objects/auto_centrifuge.png","sprites/menus/auto_centrifuge.png", auto_centrifuge.scripts)
end

function auto_centrifuge_draw(menu_id)
    auto_machine_utils.draw_battery(menu_id)
end

function auto_centrifuge_define(menu_id)
    auto_machine_utils.define_battery(menu_id, 48, 14)

    api_sp(menu_id, "_fields", {"p_active_hives", "p_battery"})
end

function auto_centrifuge_change(menu_id)

end

function auto_centrifuge_tick(menu_id)
    auto_machine_utils.tick_battery(menu_id)
end