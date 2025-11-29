-- LEVEL 4

local modpath        = core.get_modpath("sp_levels")
local schematic_path = modpath .. "/schems/level4/"
local prop_path      = modpath .. "/schems/props/"

local add = vector.add
local sub = vector.subtract
local new = vector.new

-- CONSTANTS
local level3_pos = sp.levels[3].position
local level_vec  = add(level3_pos, new(-24, 0, 0))


-- SCHEMATICS
local level_schematic              = schematic.new(schematic_path .. "level4.mts", level_vec, 0)

-- DESTROYED LAB
local destroyed_lab_shelf_path     = schematic_path .. "destroyed_lab_shelf.mts"
local destroyed_lab_junk_path      = schematic_path .. "destroyed_lab_junk" -- .. "1.mts"

-- LAB
local lab_shelf_state1             = schematic_path .. "lab_shelf_state1.mts"
local lab_shelf_state2             = schematic_path .. "lab_shelf_state2.mts"
local lab_shelf_state3             = schematic_path .. "lab_shelf_state3.mts"

-- DESTROYED FACTORY
local destroyed_factory_chest_path = schematic_path .. "destroyed_factory_chests.mts"
local destroyed_factory_junk_path  = schematic_path .. "destroyed_factory_junk" -- .. "1.mts"

-- FACTORY
local factory_cart_panel_state1    = schematic_path .. "factory_cart_panel_state1.mts" -- X+
local factory_cart_panel_state2    = schematic_path .. "factory_cart_panel_state2.mts" -- X-

-- MISC PROPS
local chair_path                   = prop_path .. "chair.mts"


-- ROOM
sp.register_map_state("level4_room", {
    schematic.new( -- Destroyed lab
        schematic_path .. "destroyed_lab.mts",
        add(level_vec, new(7, 0, 0)),
        0
    ),

    schematic.new( -- Lab
        schematic_path .. "lab.mts",
        add(level_vec, new(7, 0, 0)),
        0
    ),

    schematic.new( -- Destroyed factory
        schematic_path .. "destroyed_factory.mts",
        add(level_vec, new(7, 0, 0)),
        0
    ),

    schematic.new( -- factory
        schematic_path .. "factory.mts",
        add(level_vec, new(7, 0, 0)),
        0
    ),
})

sp.register_map_state("level4_chair", {    
    schematic.new(
        chair_path,
        add(level_vec, new(18, 1, 7)),
        0
    ),

    schematic.new(
        chair_path,
        add(level_vec, new(4, 1, 17)),
        90
    ),

    schematic.new(
        chair_path,
        add(level_vec, new(6, 1, 9)),
        180
    ),
})

-- DESTROYED LAB
sp.register_map_state("level4_destroyed_lab_shelf", {
    schematic.new(
        destroyed_lab_shelf_path,
        add(level_vec, new(8, 1, 6)),
        180
    ),

    schematic.new(
        destroyed_lab_shelf_path,
        add(level_vec, new(8, 1, 10)),
        180
    ),

    schematic.new(
        destroyed_lab_shelf_path,
        add(level_vec, new(11, 1, 6)),
        0
    ),

    schematic.new(
        destroyed_lab_shelf_path,
        add(level_vec, new(11, 1, 10)),
        0
    ),
})

sp.register_map_state("level4_destroyed_lab_junk", {
    schematic.new(
        destroyed_lab_junk_path .. "1.mts",
        add(level_vec, new(8, 1, 1)),
        0
    ),
    
    schematic.new(
        destroyed_lab_junk_path .. "2.mts",
        add(level_vec, new(8, 1, 1)),
        0
    ),

    schematic.new(
        destroyed_lab_junk_path .. "3.mts",
        add(level_vec, new(8, 1, 1)),
        0
    ),
})

-- LAB
sp.register_map_state("level4_lab_shelf", {    
    schematic.new(
        lab_shelf_state1,
        add(level_vec, new(8, 1, 17)),
        0
    ),

    schematic.new(
        lab_shelf_state2,
        add(level_vec, new(8, 1, 17)),
        0
    ),

    schematic.new(
        lab_shelf_state3,
        add(level_vec, new(8, 1, 17)),
        0
    ),
})

-- DESTROYED FACTORY
sp.register_map_state("level4_destroyed_factory_chests", {
    schematic.new(
        destroyed_factory_chest_path,
        add(level_vec, new(8, 1, 13)),
        0
    ),

    schematic.new(
        destroyed_factory_chest_path,
        add(level_vec, new(16, 1, 15)),
        0
    ),

    schematic.new(
        destroyed_factory_chest_path, 
        add(level_vec, new(11, 1, 10)),
        90
    ),
})

sp.register_map_state("level4_destroyed_factory_junk", {
    schematic.new(
        destroyed_factory_junk_path .. "1.mts",
        add(level_vec, new(14, 1, 6)),
        0
    ),

    schematic.new(
        destroyed_factory_junk_path .. "2.mts",
        add(level_vec, new(14, 1, 6)),
        0
    ),
    
    schematic.new(
        destroyed_factory_junk_path .. "3.mts",
        add(level_vec, new(14, 1, 6)),
        0
    ),
})

-- FACTORY
sp.register_map_state("level4_factory_cart_panel", {
    schematic.new(
        factory_cart_panel_state1,
        add(level_vec, new(8, 2, 6)),
        0
    ),

    schematic.new(
        factory_cart_panel_state2,
        add(level_vec, new(16, 2, 6)),
        0
    ),
})

-- QUANTUM OBJECTS
sp.quantum.register_object("level4_destroyed_lab_shelf", "view_only", true)
sp.quantum.register_object("level4_lab_shelf", "light_only", true)
sp.quantum.register_object("level4_destroyed_factory_chests", "both", true)
sp.quantum.register_object("level4_factory_cart_panel", "light_only", true)
sp.quantum.register_object("level4_chair", "both", true)

local committed = false


-- TRIGGERS
local to_destroyed_lab = {
    add(level_vec, new(17, 0, 11)),
    add(level_vec, new(20, 4, 10))
}

local to_lab = {
    add(level_vec, new(3, 0, 11)),
    add(level_vec, new(8, 4, 10))
}

local to_destroyed_factory = {
    add(level_vec, new(3, 0, 7)),
    add(level_vec, new(8, 4, 8))
}

local to_factory = {
    add(level_vec, new(17, 0, 7)),
    add(level_vec, new(20, 4, 8))
}


-- MISCELLANEOUS
local function set_to_existing_state(map_state_id)
    local current_state = sp.get_active_map_state(map_state_id) or 1
    if not current_state then
        return
    end

    sp.set_map_state(map_state_id, current_state, true)
end

local destroyed_lab_chest_pos           = add(level_vec, new(12, 1, 1))
local destroyed_lab_chest_collected     = false

local destroyed_factory_chest_pos       = add(level_vec, new(16, 1, 8))
local destroyed_factory_chest_collected = false


-- LEVEL 4
local exit_door_pos = add(level_vec, new(9, 1, 18))

sp.levels.register_level_transition({
    start_level = 4,
    end_level = 5,

    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        if not player then
            return
        end

        if sp.levels.get_active_level(player) ~= 4 then
            return
        end

        if itemstack:get_name() ~= "sp_nodes:key" or itemstack:get_count() ~= 2 then
            core.chat_send_all("You need 2 keys!")
            return
        end

        fade_in_out_black_mask(player, nil, nil, nil, function(player)
            sp.levels.set_active_level(player, 5)

            local next_spawn = sp.levels[5].spawn -- if this is nil god bless the player cause something is terribly wrong
            player:set_pos(next_spawn)
        end)

        return ItemStack()
    end
})

sp.levels.register_level({
    spawn = add(level_vec, new(23, 1, 15)),
    position = level_vec,

    items = {"sp_flashlight:flashlight"},

    on_init = function()
        schematic.place(level_schematic)

        set_to_existing_state("level4_factory_cart_panel")

        set_to_existing_state("level4_chair")
    end,

    on_load = function(player)
        sp.flashlight.turn_on_flashlight(player)

        sp.set_map_state("level4_room", 4) -- start the level in the factory state

        place_door(add(level3_pos, new(0, 1, 15)), "doors:transition_3_4_a", 3)
        place_door(exit_door_pos, "doors:transition_4_5_a", 0)
    end,

    on_step = function(player)
        -- TRIGGER LOGIC
        local pos = player:get_pos()

        local current_state                = sp.get_active_map_state("level4_room")

        local destroyed_lab_junk_state     = sp.get_active_map_state("level4_destroyed_lab_junk")
        local destroyed_factory_junk_state = sp.get_active_map_state("level4_destroyed_factory_junk")

        -- DESTROYED LAB
        if in_area(pos, to_destroyed_lab[1], to_destroyed_lab[2]) and current_state ~= 1 then
            sp.set_map_state("level4_room", 1)
            set_to_existing_state("level4_destroyed_lab_shelf")
            set_to_existing_state("level4_destroyed_lab_junk")

        -- LAB
        elseif in_area(pos, to_lab[1], to_lab[2]) and current_state ~= 2 then
            sp.set_map_state("level4_room", 2)
            set_to_existing_state("level4_lab_shelf")

        -- DESTROYED FACTORY
        elseif in_area(pos, to_destroyed_factory[1], to_destroyed_factory[2]) and current_state ~= 3 then
            sp.set_map_state("level4_room", 3)
            set_to_existing_state("level4_destroyed_factory_chests")
            set_to_existing_state("level4_destroyed_factory_junk")
            
        -- FACTORY
        elseif in_area(pos, to_factory[1], to_factory[2]) and current_state ~= 4 then
            sp.set_map_state("level4_room", 4)
            set_to_existing_state("level4_factory_cart_panel")
            
            place_door(exit_door_pos, "doors:transition_4_5_a", 0)

        end

        -- update the current state
        current_state = sp.get_active_map_state("level4_room")

        -- QUANTUM OBJECTS
        -- DESTROYED LAB
        if current_state == 1 then
            sp.quantum.update("level4_destroyed_lab_shelf", player)

            local in_darkness = in_complete_darkness(add(level_vec, new(12, 3, 3)))

            if in_darkness and not committed and not destroyed_lab_chest_collected then
                local next_state = destroyed_lab_junk_state + 1

                if next_state == 4 then
                    core.set_node(destroyed_lab_chest_pos, {name = "sp_nodes:chest"})
                    set_metadata(destroyed_lab_chest_pos, "item", "sp_nodes:key")

                    destroyed_lab_chest_collected = true
                else
                    sp.set_map_state("level4_destroyed_lab_junk", next_state)
                end

                committed = true
            elseif not in_darkness and committed then
                committed = false
            end

        -- LAB
        elseif current_state == 2 then
            sp.quantum.update("level4_lab_shelf", player)
        
        -- DESTROYED FACTORY
        elseif current_state == 3 then
            sp.quantum.update("level4_destroyed_factory_chests", player)
            
            local in_darkness = in_complete_darkness(add(level_vec, new(16, 2, 8)))

            if in_darkness and not committed and not destroyed_factory_chest_collected then
                local next_state = destroyed_factory_junk_state + 1

                if next_state == 4 then
                    core.set_node(destroyed_factory_chest_pos, {name = "sp_nodes:chest"})
                    set_metadata(destroyed_factory_chest_pos, "item", "sp_nodes:key")

                    destroyed_factory_chest_collected = true
                else
                    sp.set_map_state("level4_destroyed_factory_junk", next_state)
                end

                committed = true
            elseif not in_darkness and committed then
                committed = false
            end

        -- FACTORY
        elseif current_state == 4 then
            sp.quantum.update("level4_factory_cart_panel", player)
        end
        

        sp.quantum.update("level4_chair", player)
    end,
})