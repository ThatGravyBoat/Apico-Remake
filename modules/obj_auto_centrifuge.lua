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
    },
    look_up = {
        common = "beepollen",
        forest = "stickypearl",
        verge = "honeydew",
        uncommon = "combfragment",
        verdant = "waxypearl",
        vibrant = "hivedust",
        drowsy = "morningdew",
        misty = "dye9",
        dream = "spice1",
        murky = "stickyshard",
        muggy = "stickyshard",
        glowing = "dye11",
        rocky = "stone",
        regal = "royaljelly",
        worker = "canister2",
        stubborn = "waxshard",
        domesticated = "glossypearl",
        hermit = "spice2",
        twilight = "dye10",
        frosty = "icyshard",
        fiery = "charredpearl",
        jurassic = "spice3",
        crystal = "honeycore2",
        ancient = "spice4",
        bohemian = "seed0",
        prolific = "gloriouspearl",
        industrial = "frame5",
        chaotic = "unstabledust",
        arctic = "dye17",
        blazing = "spice5",
        empress = "queenspearl",
        melodic = "discfragment",
        lightning = "lightningshard",
        hallowed = "dye18",
        sacred = "blessedpearl",
        glitched = "randomjelly"
    }
}

function auto_centrifuge.register()
    api_define_menu_object(auto_centrifuge.object, "sprites/objects/auto_centrifuge.png","sprites/menus/auto_centrifuge.png", auto_centrifuge.scripts)
end

function auto_centrifuge_draw(menu_id)
    auto_machine_utils.draw_battery(menu_id)
    api_draw_tank(api_gp(menu_id, "tank_gui"))
end

function auto_centrifuge_define(menu_id)
    api_define_tank(menu_id, 0, 1000, 'honey', 214, 14, 'large')
    auto_machine_utils.define_battery(menu_id, 48, 14)

    api_dp(menu_id, "p_working", false)
    api_dp(menu_id, "p_progress", 0)
    api_dp(menu_id, "p_drain_counter", 0)
    api_dp(menu_id, "p_has_canister", false)
    api_dp(menu_id, "p_draining", false)
end

function auto_centrifuge_change(menu_id)
    auto_centrifuge.check_inputs(menu_id)
end

function auto_centrifuge_tick(menu_id)
    auto_machine_utils.tick_battery(menu_id)

    if (api_gp(menu_id, "p_working") == true) then
        utils.ap(menu_id, "p_progress", 0.02)
        utils.ap(menu_id, "p_battery", -0.2)
        if (api_gp(menu_id, "p_progress") >= 1) then
            api_sp(menu_id, "p_progress", 0)
            auto_centrifuge.check_inputs(menu_id) --Check inputs and then process.
            if (api_gp(menu_id, "p_working") == true) then
                local slots = auto_centrifuge.get_good_frames(menu_id)
                local output_frame_slot = api_slot_match_range(menu_id, {""}, {17, 18, 19, 20, 21, 22}, true)
                local frame = slots[1]

                api_slot_set(output_frame_slot.id, frame.item, 1, slot_utils.create_frame(false, false, "", {}, ""))
                auto_centrifuge.process_frame(menu_id, frame.stats)
                api_slot_clear(frame.id)
                utils.ap(output_frame_slot.id, "current_health", -1)
                auto_centrifuge.check_inputs(menu_id)
            end
        end
    end
end

---@return slot[]
function auto_centrifuge.get_good_frames(menu_id)
    local slots = api_slot_match_range(menu_id, {"frame1", "frame2", "frame3"}, {1, 2, 3, 4, 5, 6}, false)
    local good_frames = {}
    for _, v in ipairs(slots) do
        if ((v.stats["framed"] or v.stats["uncapped"]) and auto_centrifuge.look_up[v.stats["species"]] ~= nil) then
            table.insert(good_frames, v)
        end
    end
    return good_frames
end

function auto_centrifuge.check_inputs(menu_id)
    local good_frames = auto_centrifuge.get_good_frames(menu_id)
    local output_frame_slots = api_slot_match_range(menu_id, {""}, {17, 18, 19, 20, 21, 22}, true)
    local output_slots = api_slot_match_range(menu_id, {""}, {8, 9, 10, 11, 12, 13, 14, 15, 16}, true)

    if (#good_frames > 0 and output_frame_slots ~= nil and output_slots ~= nil and api_gp(menu_id,  "tank_amount") < 1000) then
        api_sp(menu_id, "p_working", true)
    else
        api_sp(menu_id, "p_working", false)
        api_sp(menu_id, "p_progress", 0)
    end
end

function auto_centrifuge.process_frame(menu_id, frame_stats)
    local multiplier = hive_utils.get_multiplier(frame_stats["productivity"])

    auto_centrifuge.add_item(menu_id, auto_centrifuge.look_up[frame_stats["species"]], api_random_range(1, multiplier + 1))
    local flower = api_choose(utils.split(frame_stats["flowers"], ":"))
    if (flower ~= "") then
        auto_centrifuge.add_item(menu_id, "seed" .. string.sub(flower, -1), multiplier)
    end
    auto_centrifuge.add_item(menu_id, "beeswax", api_random_range(1, multiplier + 1))
    slot_utils.set_or_incr_slot(api_slot_match_range(menu_id, {"", "propolis"}, {7}, true), "propolis", multiplier)

    api_sp(menu_id,  "tank_amount", math.min(1000, api_gp(menu_id,  "tank_amount") + 10 * multiplier))
end

function auto_centrifuge.add_item(menu_id, item, amount)
    if (item == "" or item == nil or amount == 0) then return end
    slot_utils.set_or_incr_slot(api_slot_match_range(menu_id, {"", item}, {8, 9, 10, 11, 12, 13, 14, 15, 16}, true), item, amount)
end