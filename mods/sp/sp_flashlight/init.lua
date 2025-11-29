sp.flashlight = {}

local flashlight_users = {}

local update_interval = 0.3
local timer           = 0

core.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer < update_interval then
        return
    end

    timer = 0


    for name, flashlight_data in pairs(flashlight_users) do
        local player            = core.get_player_by_name(name)
        local flashlight_active = flashlight_data.active
        local light_position    = flashlight_data.position
        local player_pos        = player:get_pos()

        core.set_node(light_position, {name = "air"})

        if flashlight_active then
            local rounded_pos = vector.round(player_pos)
            local node_data   = core.get_node_or_nil(rounded_pos)
            local node_name   = node_data and node_data.name or "air"

            local node_data   = core.registered_nodes[node_name]

            if node_data then
                if node_data.drawtype == "airlike" then
                    core.set_node(rounded_pos, {name = "wielded_light:8"})

                    --core.chat_send_all(vector.to_string(light_position) .. "    " .. vector.to_string(rounded_pos))
                    flashlight_data.position = rounded_pos
                else
                    core.set_node(light_position, {name = "wielded_light:8"})
                end
            end
        end
    end
end)

core.register_craftitem("sp_flashlight:flashlight", {
    description = "Flashlight",
    inventory_image = "sp_flashlight_flashlight.png",
    wield_scale = vector.new(2, 2, 1),

    on_place = function(itemstack, user, pointed_thing)
        local name            = user:get_player_name()
        local pos             = user:get_pos()
        local flashlight_data = flashlight_users[name]

        if not flashlight_data then
            flashlight_users[name] = {
                active   = true,
                position = pos,
            }
            flashlight_data = flashlight_users[name]
        end

        local flashlight_active = flashlight_data.active

        flashlight_users[user:get_player_name()].active = not flashlight_active
    end
})

function sp.flashlight.turn_on_flashlight(player)
    if not player then
        return
    end

    local name = player:get_player_name()

    flashlight_users[name].active = true
end

function sp.flashlight.turn_off_flashlight(player)
    if not player then
        return
    end

    local name = player:get_player_name()

    flashlight_users[name].active = true
end

core.register_on_joinplayer(function(player)
    local name   = player:get_player_name()
    local pos    = player:get_pos()
    flashlight_users[name] = {
        active   = false,
        position = pos,
    }
end)

core.register_on_leaveplayer(function(player)
    flashlight_users[player:get_player_name()] = nil
end)