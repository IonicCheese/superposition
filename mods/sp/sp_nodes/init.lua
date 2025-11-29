-- Item Chest: Right click and it spawns a item on the ground

-- NODES
local texture_tint = "^[multiply:#bcac8c"
core.register_node("sp_nodes:chest", {
    description = "Item Chest",

    tiles = {
        "default_chest_top.png" .. texture_tint,
        "default_chest_top.png" .. texture_tint,
        "default_chest_side.png" .. texture_tint,
        "default_chest_side.png" .. texture_tint,
    },

    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local meta = core.get_meta(pos)
        local item = meta:get_string("item")
        if not item or item == "(nothing)" then
            return
        end
        
        local inv = clicker:get_inventory()
        inv:add_item("main", item)
        
        meta:set_string("item", "(nothing)")

        set_metadata(pos, "infotext", "Contains: (nothing)")

        return clicker:get_wielded_item()
    end,

    groups = {immortal = 1},
})

-- ITEMS
core.register_craftitem("sp_nodes:key", {
    description = "Key",
    inventory_image = "keys_key.png",
})


-- BREAKER BOX
local waypoints = {}

local param2_offsets = {
    [2] = vector.new(0.5, 0, 0),
    [3] = vector.new(-0.5, 0, 0),
    [4] = vector.new(0, 0, 0.5),
    [5] = vector.new(0, 0, -0.5),
}

core.register_node("sp_nodes:breaker_box", {
	description = "Breaker Box",
	drawtype = "signlike",
	tiles = {"default_ladder_steel.png"},
	inventory_image = "default_ladder_steel.png",
	wield_image = "default_ladder_steel.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	is_ground_content = false,
	selection_box = {
		type = "wallmounted",
		--wall_top = = <default>
		--wall_bottom = = <default>
		--wall_side = = <default>
	},
	groups = {},

    on_construct = function(pos)
        set_metadata(pos, "infotext", "Right-click to interact")
    end,

    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local meta = core.get_meta(pos)
        local state = meta:get_string("state") or "on"
        local player_name = clicker:get_player_name()

        if state == "off" then
            -- breaker is off
            set_metadata(pos, "state", "on")
            mask_set_world_lighting(clicker, 255, -200)

            if waypoints[player_name] then
                clicker:hud_remove(waypoints[player_name])
                waypoints[player_name] = nil
            end
        else
            -- breaker is on
            set_metadata(pos, "state", "off")
            mask_set_world_lighting(clicker, 1, -200)

            waypoints[player_name] = clicker:hud_add({
                type = "waypoint",
                number = 0xffff00,
                world_pos = vector.add(pos, param2_offsets[node.param2]),
                scale = {x = 5, y = 5},
                z_index = 100,
            })
        end
    end,
})

core.register_abm({
    label = "breaker_box_infotext",
    nodenames = {"sp_nodes:breaker_box"},
    interval = 10,
    chance = 1,

    min_y = -10,
    max_y = 40,
    action = function(pos, node)
        set_metadata(pos, "infotext", "Breaker Box\nRight-click to interact")
    end,
})

core.register_abm({
    label = "item_chest_infotext",
    nodenames = {"sp_nodes:chest"},
    interval = 10,
    chance = 1,

    min_y = -10,
    max_y = 40,
    action = function(pos, node)
        local meta = core.get_meta(pos)
        local item = meta:get_string("item")
        if not item or item == "(nothing)" then
            return
        end

        local item_name = core.registered_items[item].description or item
        if not item_name then
            return
        end

        set_metadata(pos, "infotext", "Contains: " .. item_name)
    end,
})

-- IMMORTAL NODES
local ignored_nodes = {
    "fireflies:firefly_bottle",
    "default:torch",
}

core.register_on_mods_loaded(function()
    for _, node in pairs(core.registered_nodes) do
        if not table.contains(ignored_nodes, node.name) then
            local groups = node.groups

            groups.dig_immediate           = 0
            groups.choppy                  = 0
            groups.oddly_breakable_by_hand = 0
            groups.immortal                = 1

            core.override_item(node.name, {
                groups = groups,
            })
        end
    end
end)

core.register_abm({
    label = "reload_lights",
    name = "sp_nodes:reload_lights",
    nodenames = {"default:meselamp", "fireflies:firefly_bottle", "default_torch"},

    interval = 1,
    chance = 1,

    action = function(pos, node)
        local meta = core.get_meta(pos)
        
        local loaded = meta:get_string("loaded")

        if loaded ~= "loaded" then
            core.set_node(pos, {name = "default:stone"})
            core.set_node(pos, {name = node.name})
            set_metadata(pos, "loaded", "loaded")
        end
    end
})

-- DUMMY DOOR
doors.register("dummy_door", {
    description = "Dummy door (i dont do anything)",
    tiles = {{name = "doors_door_steel.png", backface_culling = true}},
    inventory_image = "doors_item_steel.png",
    groups = {},
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing) -- dont do anything
        return
    end,
})