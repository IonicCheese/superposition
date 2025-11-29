-- LEVEL 3

local modpath        = core.get_modpath("sp_levels")
local schematic_path = modpath .. "/schems/level3/"
local prop_path      = modpath .. "/schems/props/"

local add = vector.add
local new = vector.new

-- CONSTANTS
local level_vec = new(50, 0, 0) -- random position on the map as the placement of level 3 is dependent on what happens in level 2

-- SCHEMATICS
local level_schematic = schematic.new(schematic_path .. "level3.mts", level_vec, 0)

sp.register_map_state("level3_room", {
    schematic.new(
        schematic_path .. "state1.mts",
        level_vec,
        0
    ),
    schematic.new(
        schematic_path .. "state2.mts",
        level_vec,
        0
    ),
})

local chair_path = prop_path .. "chair.mts"
local shelf_path = schematic_path .. "shelf.mts"

sp.register_map_state("level3_state2_quantum_chair", {
    schematic.new(
        chair_path,
        add(level_vec, new(1, 1, 9)),
        0
    ),

    schematic.new(
        chair_path,
        add(level_vec, new(5, 1, 1)),
        270
    ),

    schematic.new(
        chair_path,
        add(level_vec, new(3, 1, 19)),
        90
    ),

--    schematic.new(
--        chair_path,
--        add(level_vec, new(3, 2, 25)),
--        90
--    )
})

sp.register_map_state("level3_state2_quantum_shelf", {
    schematic.new(
        shelf_path,
        add(level_vec, new(1, 1, 2)),
        0
    ),
    schematic.new(
        shelf_path,
        add(level_vec, new(10, 1, 5)),
        0
    ),
})

sp.quantum.register_object("level3_state2_quantum_chair", "both", true)
sp.quantum.register_object("level3_state2_quantum_shelf", "both", true)


sp.register_map_state("level3_state2_quantum_path", {
    schematic.new(
        schematic_path .. "path_state1.mts",
        add(level_vec, new(8, 1, 19)),
        0
    ),

    schematic.new(
        schematic_path .. "path_state2.mts",
        add(level_vec, new(8, 1, 19)),
        0
    ),
})

-- TRIGGER
local state1_trigger = {
    add(level_vec, new(15, 0, 14)),
    add(level_vec, new(13, 4, 17))
}

local state2_trigger = {
    add(level_vec, new(15, 0, 14)),
    add(level_vec, new(13, 4, 10))
}

local shelf_trigger = {
    add(level_vec, new(2, 0, 1)),
    add(level_vec, new(9, 5, 26))
}

-- PERMANENT PATH STATE
local permanent_path_state = 1

-- MISC POSITIONS
local chest_pos          = add(level_vec, new(5, 1, 25)) -- item chest
local enterance_door_pos = add(level_vec, new(2, 1, 27)) -- enterance door
local exit_door_pos      = add(level_vec, new(0, 1, 15)) -- exit door

-- LEVEL 3

sp.levels.register_level_transition({
    start_level = 3,
    end_level = 4,
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_string("formspec", formspec)
    end,

    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        if not player then
            return
        end

        if sp.levels.get_active_level(player) ~= 3 then
            return
        end

        if itemstack:get_name() ~= "sp_nodes:key" then
            core.chat_send_all("You need a key!")
            return
        end

        fade_in_out_black_mask(player, nil, nil, nil, function(player)
            sp.levels.set_active_level(player, 4)

            local next_spawn = sp.levels[4].spawn -- if this is nil god bless the player cause something is terribly wrong
            player:set_pos(next_spawn)
        end)

        return ItemStack()
    end,
})

sp.levels.register_level({
    spawn = add(level_vec, new(2, 1, 25)),
    position = level_vec,
    items = {"sp_flashlight:flashlight"},
    
    on_init = function()
        schematic.place(level_schematic)

        schematic.place(
            schematic.new(
                schematic_path .. "level2_enterance.mts",
                add(level_vec, new(0, 0, 28)),
                0
            ),
            true
        )

        set_metadata(chest_pos, "item", "sp_nodes:key")
    end,

    on_load = function(player)
        sp.flashlight.turn_on_flashlight(player)

        place_door(exit_door_pos, "doors:transition_3_4_a", 3)
        place_door(enterance_door_pos, "doors:transition_2_3_a", 0)
    end,

    on_step = function(player)
        local pos = player:get_pos()

        local current_state = sp.get_active_map_state("level3_room")

        -- State 1
        if in_area(pos, state1_trigger[1], state1_trigger[2]) and current_state ~= 1 then
            sp.set_map_state("level3_room", 1)

            -- place the exit door
            place_door(exit_door_pos, "doors:transition_3_4_a", 3)

        -- State 2
        elseif in_area(pos, state2_trigger[1], state2_trigger[2]) and current_state ~= 2 then
            -- collect and smuggle current item metadata from the chest
            local item = core.get_meta(chest_pos):get_string("item")
            
            -- set the room to the second state
            sp.set_map_state("level3_room", 2)

            -- set the quantum objects to the first state
            sp.set_map_state("level3_state2_quantum_chair", 1)
            sp.set_map_state("level3_state2_quantum_shelf", 1)

            -- set the path to the first state
            sp.set_map_state("level3_state2_quantum_path", permanent_path_state, true)

            -- spawn the item chest...
            core.set_node(chest_pos, {name = "sp_nodes:chest"})
            set_metadata(chest_pos, "item", item)
        end

        -- Quantum Objects
        if current_state == 2 then
            sp.quantum.update("level3_state2_quantum_chair", player)

            -- make sure the player is in a certain area to update the shelf
            if in_area(pos, shelf_trigger[1], shelf_trigger[2]) then
                sp.quantum.update("level3_state2_quantum_shelf", player)
            else
                -- reset the shelf to the first state to prevent soft-locks
                sp.set_map_state("level3_state2_quantum_shelf", 1)
            end

            -- path light check (if the path is in complete darkness then switch to the second state)
            local path_light = core.get_node_light(add(level_vec, new(8, 1, 19)))

            if path_light <= 0 then
                permanent_path_state = 2
                sp.set_map_state("level3_state2_quantum_path", permanent_path_state, false)
            end
        end
    end,
})