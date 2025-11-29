-- LEVEL TRANSITIONS (through doors :)

-- @param def: table
-- def.start_level:     number
-- def.end_level:       number
-- def.on_rightclick:   function
-- def.on_receive_fields: function(player, formname, fields)

function sp.levels.register_level_transition(transition_def)
    local start_level       = transition_def.start_level
    local end_level         = transition_def.end_level
    local on_rightclick     = transition_def.on_rightclick
    local on_construct      = transition_def.on_construct or nil
    local on_receive_fields = transition_def.on_receive_fields or nil
    local name              = "transition_" .. start_level .. "_" .. end_level

    if not start_level or not end_level or not on_rightclick then
        return false
    end

    doors.register(name, {
        description = core.colorize("#ff0000", "Transition from level " .. start_level .. " to level " .. end_level),
        tiles = {{name = "doors_door_steel.png", backface_culling = true}},
        inventory_image = "doors_item_steel.png",
        on_rightclick = on_rightclick,
        on_receive_fields = on_receive_fields,
        on_construct = function(pos)
            local meta = core.get_meta(pos)
            meta:set_string("infotext", "Right-click to interact")
            if on_construct then
                on_construct(pos)
            end
        end,
        groups = {},
    })
end