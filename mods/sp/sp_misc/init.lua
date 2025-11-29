-- Miscellaneous helper functions

-- @param pos: vector
-- @param area_pos1: vector
-- @param area_pos2: vector
-- @return boolean
function in_area(pos, area_pos1, area_pos2)
    if not pos or not area_pos1 or not area_pos2 then
        return false
    end

    area_pos1, area_pos2 = vector.sort(area_pos1, area_pos2)

    return vector.in_area(pos, area_pos1, area_pos2)
end

-- LINE OF SIGHT
-- @param player: player
-- @param target_pos: vector
-- @return boolean
function out_of_player_view(player, target_pos)
    local player_pos = player:get_pos()
    local player_yaw = player:get_look_horizontal()

    local target_vec = target_pos - player_pos
    local sin_yaw = math.sin(player_yaw)
    local cos_yaw = math.cos(player_yaw)

    local local_z = (target_vec.x * sin_yaw) - (target_vec.z * cos_yaw)

    return local_z >= 0
end

-- @param pos: vector
-- @return boolean
function in_complete_darkness(pos)
    if not pos then
        return false
    end

    local light = core.get_node_light(pos) or 0
    return light <= 2
end

-- @param table: table
-- @param value: any
-- @return boolean
function table.contains(table, value)
    for _, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

-- @param pos: vector
-- @param key: string
-- @param value: any
-- @return boolean
function set_metadata(pos, key, value)
    if not pos or not key or not value then
        return false
    end

    local metadata = core.get_meta(pos)
    if not metadata then
        return false
    end

    local data_type = type(value)

    if data_type == "string" then
        metadata:set_string(key, value)
    elseif data_type == "number" then
        metadata:set_int(key, value)
    else
        metadata:set(key, value)
    end

    return true
end

-- @param player: player
-- @return void
function clear_inv(player)
    if not player then
        return
    end

    local inv = player:get_inventory()
    inv:set_list("main", {})
end

-- yes a function to place a door....
-- @param pos: vector
-- @param node_name: string
-- @return void
function place_door(pos, node_name, param2)
    core.set_node(pos, {name = node_name, param2 = param2})
    core.set_node(vector.add(pos, vector.new(0, 1, 0)), {name = "air"})
end

-- HUD ELEMENTS
local black_mask         = "blank.png^[noalpha]^[colorize:#000000:255"
local mask_elements      = {}
local black_mask_element = {
    type = "image",
    text = black_mask .. "^[opacity:0",
    position = {x = 0, y = 0},
    scale = {x = 10000, y = 10000}, -- make it enourmous
    z_index = -200, -- cover only the world + hand
}

-- set (fake) world lighting
-- @param player - the player to set the lighting for
-- @param level - the level to set the lighting to (0-255)
-- @return void
function mask_set_world_lighting(player, light_level, z_index)
    if not player then
        return
    end

    local name = player:get_player_name()
    local opacity = 255 - light_level

    if not mask_elements[name] then
        mask_elements[name] = {
            id          = player:hud_add(black_mask_element),
            light_level = light_level,
        }
    end
    
    local black_mask_id = mask_elements[name].id

    if not black_mask_id then
        core.log("error", "black_mask_id not found for player: " .. name)
        return
    end

    mask_elements[name].light_level = light_level
    player:hud_change(black_mask_id, "text", black_mask .. "^[opacity:" .. opacity)

    if z_index then
        player:hud_change(black_mask_id, "z_index", z_index)
    end
end

-- @param player: player
-- @return number
function mask_get_world_lighting(player)
    if not player then
        return
    end

    local name = player:get_player_name()

    if not mask_elements[name] then
        return
    end

    return mask_elements[name].light_level
end

-- flickering effect
local flicker_steps = {
    -- Interference
    {val = 210, time = 0.04}, 
    {val = 255, time = 0.06}, 
    {val = 140, time = 0.03}, 
    {val = 230, time = 0.05}, 

    -- Fail
    {val = 90,  time = 0.03},
    {val = 40,  time = 0.03},
    {val = 10,  time = 0.03},

    -- Pitch black
    {val = 0,   time = 0.45, darkest = true},  -- stuff happens here

    -- Spark
    {val = 50,  time = 0.04},
    {val = 10,  time = 0.03},
    {val = 110, time = 0.04},
    {val = 40,  time = 0.03},

    -- Return
    {val = 180, time = 0.04},
    {val = 255, time = 0.05},
    {val = 220, time = 0.03},
    {val = 255, time = 0.0}
}

local effect_running = false

-- @param player: player
-- @param dark_length: number
-- @param at_darkest: function
-- @return void
function flicker_black_mask(player, dark_length, at_darkest)
    if not player then
        return
    end

    if effect_running then
        return
    end

    effect_running = true

    local function step(i)
        if i > #flicker_steps or not effect_running then
            effect_running = false
            return
        end

        local opacity, time = flicker_steps[i].val, flicker_steps[i].time

        mask_set_world_lighting(player, opacity)

        if flicker_steps[i].darkest then
            time = dark_length or time
            if at_darkest then
                at_darkest(player)
            end
        end

        core.after(time, function()
            step(i + 1)
        end)
    end
    step(1)
end

-- @param player: player
-- @param start_opacity: number
-- @param end_opacity: number
-- @param step_duration: number
-- @param steps: integer
-- @param on_complete: function(player)
-- @return void
function interpolate_black_mask(player, start_opacity, end_opacity, step_duration, steps, on_complete)
    if not player or not start_opacity or not end_opacity or not step_duration or not steps then
        return
    end

    if effect_running then
        return
    end

    effect_running = true

    local function step(i)
        if i > steps or not effect_running then
            effect_running = false

            if on_complete then
                on_complete(player)
            end

            return
        end

        local opacity = start_opacity + (end_opacity - start_opacity) * (i / steps)

        mask_set_world_lighting(player, opacity, 1000)

        core.after(step_duration, function()
            step(i + 1)
        end)
    end

    step(1)
end

-- @param player: player
-- @param step_duration: number
-- @param steps: integer
-- @param on_complete_in: function(player)
-- @param on_complete_out: function(player)
-- @return void
function fade_in_out_black_mask(player, step_duration, steps, rest, on_complete_in, on_complete_out)
    if not player then
        return
    end

    step_duration = step_duration or 0.01
    steps         = steps or 20
    rest          = rest or 0.5

    interpolate_black_mask(player, 255, 0, step_duration, steps, function(player)
        if on_complete_in then
            on_complete_in(player)
        end

        core.after(rest, function()
            interpolate_black_mask(player, 0, 255, step_duration, steps, function(player)
                if on_complete_out then
                    on_complete_out(player)
                end
            end)
        end)
    end)
end

core.register_on_leaveplayer(function(player)
    local pname = player:get_player_name()
    if mask_elements[pname] then
        player:hud_remove(mask_elements[pname])
        mask_elements[pname] = nil
    end
end)

local warning = "WARNING: This game is in early"..core.colorize("#ff0000", " alpha").."\nDo not have high expectations for the game, the game is in work in progress.\n\nSome features may not function correctly or may not work at all.\n(Do take note that you can break bottles with fireflies in them!)\n(the darkness is your friend)"

local lava_texture_path = "default_lava.png"
sfinv.register_page("sp_misc:game", {
    title = "Game",
    get = function(self, player, context)
        return sfinv.make_formspec(player, context, table.concat({
            "textarea[0.1,0.1;7.5,8;;", warning, ";]",
            "label[0.1,2;If you have any complaints, take it up with our complaints department ↓↓↓]",
            
            "image[6,3;1.25,1.25;", lava_texture_path, "]",
            "image[5,3;1.25,1.25;", lava_texture_path, "]",
            "image[4,3;1.25,1.25;", lava_texture_path, "]",
        }), true)
    end
})