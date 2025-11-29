-- LEVEL 2

local modpath = core.get_modpath("sp_levels")
local schematic_path = modpath .. "/schems/level2/"

local add = vector.add
local sub = vector.subtract
local new = vector.new

-- LEVEL 2 CONSTANTS
local length     = 54
local level_vec  = new(6, 10, 15)
local repeat_pos = add(level_vec, new(4, 0, -length - 1))

-- SCHEMATICS
local hallway_start_schematic = schematic.new(
    schematic_path .. "hallway_start.mts",
    level_vec,
    0
)

local hallway_reapeating_schematic = schematic.new(
    schematic_path .. "hallway_repeating.mts",
    repeat_pos,
    0
)

-- TRIGGER
local spawn_trigger = {
    new(0, 0, 26),
    new(4, 5, 28)
}

-- SEGMENT SPAWNING

local spawned_positions = {}

local function spawn_hallway(segment)
    if spawned_positions[segment] then
        return
    end

    spawned_positions[segment] = true
    

    local offset    = vector.new(0, 0, length * segment)
    local spawn_pos = add(repeat_pos, add(offset, new(0, 0, length)))

    local hallway_segment = schematic.copy(
        hallway_reapeating_schematic,
        {
            pos = spawn_pos,
        }
    )

    schematic.place(hallway_segment, true)
end

local function spawn_hallway_pair(current_segment)
    -- spawn 2 segments in each direction (2 forward, 2 backward)
    for i = -3, 1 do
        spawn_hallway(current_segment + i)
    end
end

-- PHANTOM DOOR
local door_state = 0

-- LEVEL 2
sp.levels.register_level_transition({
    start_level = 2,
    end_level = 3,
    items = {},
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        if not player then
            return
        end

        if sp.levels.get_active_level(player) ~= 2 then
            return
        end
    
        fade_in_out_black_mask(player, nil, nil, nil, function(player)
            sp.levels.set_active_level(player, 3)

            local next_spawn = sp.levels[3].spawn -- if this is nil god bless me cause something is terribly wrong
            player:set_pos(next_spawn)
        end)
    end,
})

sp.levels.register_level({
    spawn = add(level_vec, new(5, 1, 12)),
    position = level_vec,
        
    on_init = function()
        spawn_hallway(-1)
        spawn_hallway(-2)

        schematic.place(hallway_start_schematic)

        --place_door(add(level_vec, new(3, 1, -2)), "doors:dummy_door", 3)
    end,
    on_step = function(player)
        local pos = player:get_pos()

        local relative_pos = sub(pos, repeat_pos) -- relative position to the repeat position

        local current_segment = math.floor((relative_pos.z - length / 2) / length)
        local offset          = vector.new(0, 0, length * current_segment)
        local modulated_pos   = sub(relative_pos, offset)

        if in_area(modulated_pos, spawn_trigger[1], spawn_trigger[2]) then
            spawn_hallway_pair(current_segment)
        end

        -- world is dark
        if mask_get_world_lighting(player) == 1 then

            -- lock the player to prevent them from moving
            player:set_physics_override({
                speed_walk = 0,
                jump = 0,
            })

            if door_state == 0 then
                door_state = 1
            end
    
        -- world is bright
        elseif mask_get_world_lighting(player) == 255 then
            player:set_physics_override({
                speed_walk = 1,
                jump = 1,
            })

            if door_state == 1 then
                door_state = 2
                local door_pos = add(level_vec, new(8, 0, pos.z - level_vec.z - 2))

                schematic.place(
                    schematic.new(
                        schematic_path .. "level3_enterance.mts",
                        door_pos,
                        0
                    ),
                    true
                )

                place_door(add(door_pos, new(0, 1, 2)), "doors:transition_2_3_a", 3)
            end
        end
    end,
})