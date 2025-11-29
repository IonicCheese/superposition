-- LEVEL 5

local modpath = core.get_modpath("sp_levels")
local schematic_path = modpath .. "/schems/level5/"

local add = vector.add
local new = vector.new

-- CONSTANTS
local level4_pos = sp.levels[4].position
local level_vec = add(level4_pos, new(-1, 0, 18)) -- make it easy to relocate the level

local level_schematic = schematic.new(schematic_path .. "level5.mts", level_vec, 0)

local state_pos       = add(level_vec, new(8, 0, 0))

sp.register_map_state("level5_state", {
    schematic.new(
        schematic_path .. "state1.mts",
        state_pos,
        0
    ),

    schematic.new(
        schematic_path .. "state2.mts",
        state_pos,
        0
    ),

    schematic.new(
        schematic_path .. "state3.mts",
        state_pos,
        0
    ),

    schematic.new(
        schematic_path .. "state4.mts",
        state_pos,
        0
    ),
})

-- ITEM CHESTS
local chest1_pos = add(level_vec, new(7, 3, 18))
local chest2_pos = add(level_vec, new(17, 3, 3))


-- EXIT DOOR
local exit_door_pos = add(level_vec, new(0, 1, 13))


local committed = false

-- LEVEL 5
sp.levels.register_level_transition({
    start_level = 5,
    end_level = "end", -- END OF THE GAME
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        if not player then
            return
        end
        
        
    end,

})

sp.levels.register_level({
    spawn = add(level_vec, new(10, 1, 1)),
    position = level_vec,

    items = {"sp_flashlight:flashlight"},

    on_init = function()
        schematic.place(level_schematic, true)
        sp.set_map_state("level5_state", 1)
    end,

    on_load = function(player)
        sp.flashlight.turn_on_flashlight(player)
        place_door(add(level4_pos, new(9, 1, 18)), "doors:transition_4_5_a", 0)
    end,

    on_step = function(player, dtime)
        if not player then
            return
        end

        local pos           = player:get_pos()
        local current_state = sp.get_active_map_state("level5_state")
        local states        = sp.get_map_state("level5_state")

        if in_complete_darkness(pos) and not committed then
            local next_state = current_state + 1
            if next_state > #states then
                next_state = 1
            end

            sp.set_map_state("level5_state", next_state)
            place_door(add(level4_pos, new(9, 1, 18)), "doors:transition_4_5_a", 0)
            committed = true
        elseif not in_complete_darkness(pos) and committed then
            committed = false
        end
    end,
})