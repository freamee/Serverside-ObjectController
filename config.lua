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
    variable_changed = 'object-controller:variable-changed',
    object_clicked = 'object-controller:clicked'
}

Config.Debug = true -- Enable debug messages client & serverside.
Config.Distance = 15 -- How close localplayer needs to be to spawn the objects.
Config.ClientTickerMS = 1000 -- How often check the nearby objects on clientside player.

Config.AimEntity = {
    Enabled = true, -- Enable or disable the whole aimingEntity thing.
    Distance = 3, -- Maximum distance to search for aimingEntity.
    RefreshRateMS = 100, -- ShapeTest ticking MS
    Key = 'm', -- Default key to bind the cursor showing
    CenterCursorOnOpen = true,
    EnableDrawLine = true, -- Enable drawline between hitcoord and playercoords.
    EnableSprite = false, -- Enable the sprite rendering on the hitcoords.
    SpriteDict = 'mphud', -- If EnableSprite enabled
    SpriteName = 'spectating', -- If EnableSprite enabled
    CursorSpriteOnAim = 11, -- Cursor sprite when aimed on object
    CursorSpriteDefault = 1 -- Cursor sprite default
}

Config.DebugMsg = function(msg)
    if Config.Debug then
        print(msg)
    end
end

if IsDuplicityVersion() then -- Server
    RegisterNetEvent(Config.Events.object_clicked)
    RegisterNetEvent(Config.Events.variable_changed)

    AddEventHandler(Config.Events.object_clicked, function(uid, data)
        -- print(uid, data)
    end)

    AddEventHandler(Config.Events.variable_changed, function(uid, key, value)
        Config.DebugMsg(string.format('Object variable changed: (%s) %s', key, value))
    end)

else -- Client
    RegisterNetEvent(Config.Events.object_clicked)
    RegisterNetEvent(Config.Events.variable_changed)

    AddEventHandler(Config.Events.object_clicked, function(uid, data)
        -- print(uid, data)
    end)

    AddEventHandler(Config.Events.variable_changed, function(uid, key, value)
        if ClientObjectController._store[uid] then
            ClientObjectController._store[uid].sharedvars[key] = value
        end
    end)
end
