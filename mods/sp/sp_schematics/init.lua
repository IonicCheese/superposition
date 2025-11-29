-- Schematic system

schematic = {}

-- a table of which EVERY SINGLE node is a key to "wool:red"
air_table = {}
core.register_on_mods_loaded(function()
    for node, _ in pairs(core.registered_nodes) do
        air_table[node] = "air"
    end
end)

-- @param path: string
-- @param pos: vector
-- @param rotation: number
-- @return table
function schematic.new(path, pos, rotation)
    if not path or not pos or not rotation then
        return false
    end
    
    local schem = {
        path     = path,
        pos      = pos,
        rotation = rotation,
    }
    return schem
end

-- @param schem: table
-- @param changes: table
-- @return schem: table
function schematic.copy(schem, changes)
    if not schem then
        return false
    end
    
    local path     = schem.path
    local pos      = schem.pos
    local rotation = schem.rotation

    if changes then
        path = changes.path or path
        pos = changes.pos or pos
        rotation = changes.rotation or rotation
    end

    local new_schem = schematic.new(path, pos, rotation)
    return new_schem
end

-- @param schem: table
-- @param force_replace: boolean (will overwrite any existing nodes)
-- @param replace_nodes: table (nodes to replace)
-- @return boolean
function schematic.place(schem, force_replace, replace_with_air)
    if not schem then
        return false
    end
    
    local path     = schem.path
    local pos      = schem.pos
    local rotation = schem.rotation

    if not path or not pos or not rotation then
        return false
    end

    local replace_nodes = nil

    if replace_with_air then
        replace_nodes = air_table
        -- forge a new schematic path
        -- using this because core.place_schematic() will cache the schematic path meaning we cant use different replacement tables,
        -- But if we forge a new path it will cache it as a new schematic meaning we can use different replacement tables
        path = "/." .. path
    end

    core.place_schematic(
        pos,
        path,
        rotation, 
        replace_nodes,
        force_replace,
        nil
    )

    return true
end

-- @param schem: table
-- @param angle: number
-- @return schem: table
function schematic.rotate(schem, angle)
    if not schem then
        return false
    end
    
    schem.rotation = angle
end

function schematic.verify(schem)
    if not schem then
        return false
    end
    
    local path     = schem.path
    local pos      = schem.pos
    local rotation = schem.rotation

    if not path or not pos or not rotation then
        return false
    end

    return true
end