-- SUPERPOSITION: QUANTUM OBJECTS

sp.quantum = {}

sp.quantum.objects = {}
local objects = sp.quantum.objects -- alias to sp.quantum.objects


-- @param map_state_id: string
-- @param type:         string ("both", "light_only", "view_only")
-- @param active:       bool   (if not provided then it defaults to false)
function sp.quantum.register_object(map_state_id, type, active)
    if not map_state_id then
        return false
    end

    local map_state = sp.get_map_state(map_state_id)
    if not map_state then
        return false
    end

    objects[map_state_id] = {
        -- PARAMETERS
        active         = active or false, -- unused variable
        type           = type or "both",

        -- INTERNAL
        committed      = false, -- if true then the program will wait for the player to observe it before choosing the next state
        previous_state = nil, -- the previous state of the object
    }
    return true
end

-- @param map_state_id: string
-- @param active:       bool (if not provided then it defaults to false)
function sp.quantum.set_is_active(map_state_id, active)
    if not map_state_id or not type(active) == bool then
        return false
    end

    if not objects[map_state_id] then
        return false
    end

    objects[map_state_id].active = active or false
    return true
end

-- @param map_state_id: string
-- @return: bool
function sp.quantum.get_is_active(map_state_id)
    if not map_state_id then
        return false
    end

    if not objects[map_state_id] then
        return false
    end

    return objects[map_state_id]
end

-- @param player: player object
-- @param pos: vector
-- @param object_type: string ("light_only", "view_only", "both")
-- @return: bool
function sp.quantum.get_not_observed(player, pos, object_type)
    if not player or not pos or not object_type then
        return false
    end

    local in_view = out_of_player_view(player, pos)
    local in_shadow = in_complete_darkness(pos)
    
    local observed_via_light = (object_type == "light_only" or object_type == "both") and in_shadow
    local observed_via_view = (object_type == "view_only" or object_type == "both") and in_view

    return observed_via_light or observed_via_view
end

--[[ -- @param player: player object
-- @param pos: vector
-- @param type: string ("light_only", "view_only", "both")
-- @return: bool
function sp.quantum.get_observed(player, pos, type)
    if not player or not pos or not type then
        return false
    end

    local in_shadow = in_complete_darkness(pos)
    local in_view = out_of_player_view(player, pos)

    local observed_via_light = (type == "light_only" or type == "both") and in_shadow
    local observed_via_view = (type == "view_only" or type == "both") and in_view


end]]

-- @param map_state_id: string
-- @param player: player object
function sp.quantum.update(map_state_id, player)
    if not map_state_id or not player then
        return
    end

    -- PLAYER DATA
    local player_pos = player:get_pos()
    if not player_pos then
        return
    end

    -- MAP STATE DATA
    local map_state = sp.get_map_state(map_state_id)
    if not map_state then
        return
    end

    local schematics = map_state -- yeeaaah so the schematics is just stored in the map state table.. that was a mistake
    if not schematics then
        return
    end
    
    local possible_states = #schematics
    if possible_states <= 1 then
        return
    end

    -- ACTIVE STATE DATA
    local active_state          = map_state.active
    local active_schematic      = schematics[active_state]
    local active_pos            = active_schematic.pos

     -- PREVIOUS STATE DATA
    local previous_state        = objects[map_state_id].previous_state or active_state

    local previous_schematic    = schematics[previous_state]
    local previous_pos          = previous_schematic.pos

    local object_type           = objects[map_state_id].type
    local committed             = objects[map_state_id].committed

    local active_not_observed   = sp.quantum.get_not_observed(player, active_pos, object_type)
    local previous_not_observed = sp.quantum.get_not_observed(player, previous_pos, object_type)

    if not committed and active_not_observed then
        local valid_states = {}

        -- scan for valid states
        for state, schem in ipairs(schematics) do
            if state ~= active_state and sp.quantum.get_not_observed(player, schem.pos, object_type) then
                table.insert(valid_states, state)
            end
        end

        -- check for valid states and commit to a new state
        if #valid_states > 0 then
            local random_index = math.random(1, #valid_states)
            local next_state = valid_states[random_index]

            objects[map_state_id].previous_state = active_state

            objects[map_state_id].committed = true
            sp.set_map_state(map_state_id, next_state)    
        end

    elseif committed and (not active_not_observed or not previous_not_observed) then
        objects[map_state_id].committed = false
    end
end