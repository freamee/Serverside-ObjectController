Config = {}

Config.Events = {
    append = 'object-controller:append',
    remove = 'object-controller:remove',
    set_position = 'object-controller:set-position',
    set_alpha = 'object-controller:set-alpha',
    set_rotation = 'object-controller:set-rotation',
    set_freeze = 'object-controller:set-freeze',
    set_model = 'object-controller:set-model',

    -- server & client event
    variable_changed = 'object-controller:variable-changed'
}

Config.Debug = true -- Enable debug messages client & serverside.
Config.Distance = 15 -- How close localplayer needs to be to spawn the objects.
Config.ClientTickerMS = 1000 -- How often check the nearby objects on clientside player.

Config.DebugMsg = function(msg)
    if Config.Debug then
        print(msg)
    end
end

RegisterCommand('pos', function()
    print(GetEntityCoords(PlayerPedId()))
end, false)
