-- SUPERPOSITION
-- "An object's state is not consistent if not in your line of sight"

sp = {}
local map_states = {}

replace = {}
core.register_on_mods_loaded(function()
    for node, _ in pairs(core.registered_nodes) do
        replace[node] = "wool:red"
    end
end)

-- Register state

-- @param stateid: string
-- @return void
function sp.register_map_state(stateid, schematics)
    if not schematics then
        return false, "No schematics found"
    end

    map_states[stateid] = schematics
    
    return true, "State registered successfully"
end

-- Get map state

-- @param stateid: string
-- @return table
-- {
--     schematics = {
--         {
--             path = string,
--             pos = vector,
--             rotation = number,
--         }
--     }
-- }

function sp.get_map_state(stateid)
    local state = map_states[stateid]
    if not state then
        return false
    end

    return state
end

-- Get active map state

-- @param stateid: string
-- @return number
-- @return nil if no active state
function sp.get_active_map_state(stateid)
    local state = map_states[stateid]
    if not state then
        return nil
    end

    return state.active or nil
end

-- Switch state

-- @param stateid: string
-- @param value: number
-- @param force: boolean
-- @return boolean
function sp.set_map_state(stateid, value, force)
    local state = map_states[stateid]
    if not state then
        return "No state found"
    end

    local schematics = state

    if not schematics then
        return "No schematics found"
    end

    if value > #schematics then
        return "State is out of bounds"
    end

    -- if the value is the same as the current state and force is not true then don't do anything
    if value == state.active and not force then
        return "State is already active"
    end

    local new_schem = schematics[value]
    local old_schem = nil

    if schematics.active then
        old_schem = schematics[state.active]
    else
        old_schem = new_schem
    end

    if not schematic.verify(new_schem) then
        return false
    end

    -- place the old schematic first incase the new one occludes the same spot
    schematic.place(old_schem, true, true)
    schematic.place(new_schem, true, false)

    state.active = value
    return true
end
