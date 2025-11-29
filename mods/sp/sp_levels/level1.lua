-- LEVEL 1

local modpath = core.get_modpath("sp_levels")
local schematic_path = modpath .. "/schems/level1/"

local add = vector.add
local new = vector.new
local level_vec = new(0, 0, 0) -- make it easy to relocate the level

local level_schematic = schematic.new(schematic_path .. "level1.mts", level_vec, 0)

-- NON-EUCLIDEAN HALLWAY
-- this hallway *should* intersect itself, but it doesn't
sp.register_map_state("level1_hallway", {
    schematic.new(
        schematic_path .. "hallway_wall.mts",
        add(level_vec, new(10, 0, 10)),
        90
    ),
    
    schematic.new(
        schematic_path .. "hallway_wall.mts",
        add(level_vec, new(10, 0, 10)),
        0
    ),
})

local trigger1_pos1 = add(level_vec, new(22, 0, 4))
local trigger1_pos2 = add(level_vec, new(21, 4, 0))

local trigger2_pos1 = add(level_vec, new(22, 0, 4))
local trigger2_pos2 = add(level_vec, new(26, 4, 5))


-- MISC POSITIONS
local door_pos  = add(level_vec, new(9, 1, 27))
local chest_pos = add(level_vec, new(5, 1, 18))

-- LEVEL 1
sp.levels.register_level_transition({
    start_level = 1,
    end_level = 2,
    items = {},
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        if not player then
            return
        end

        if sp.levels.get_active_level(player) ~= 1 then
            return
        end

        if itemstack:get_name() ~= "sp_nodes:key" then
            core.chat_send_all("You need a key!")
            return
        end

        fade_in_out_black_mask(player, nil, nil, nil, function(player)
            sp.levels.set_active_level(player, 2)

            local next_spawn = sp.levels[2].spawn -- if this is nil god bless the player cause something is terribly wrong
            player:set_pos(next_spawn)
        end)

        return ItemStack()
    end
})

sp.levels.register_level({
    spawn = add(level_vec, new(20, 2, 25)),
    position = level_vec,
    
    on_init = function()
        schematic.place(level_schematic)
        sp.set_map_state("level1_hallway", 1, true)
        
        place_door(door_pos, "doors:transition_1_2_a", 3)

        core.set_node(chest_pos, {name = "sp_nodes:chest"})
        set_metadata(chest_pos, "item", "sp_nodes:key")
    end,

    on_load = function(player)
        interpolate_black_mask(player, 0, 255, 0.1, 50)
    end,
    
    on_step = function(player)
        local pos = player:get_pos()

        if in_area(pos, trigger1_pos1, trigger1_pos2) then
            -- switch the state of the hallway
            sp.set_map_state("level1_hallway", 1)
        elseif in_area(pos, trigger2_pos1, trigger2_pos2) then
            -- switch the state of the hallway
            sp.set_map_state("level1_hallway", 2)
        end
    end,
})