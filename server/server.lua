ObjectController = {}
ObjectController._store = {}

-- _options = {
--     rotation = vector3,
--     freezed = boolean,
--     collision = boolean,
--     alpha = number,
--     clickable = boolean,
--     servervariables = table,
--     sharedvariables = table,
-- }

ObjectController.create = function(_model, _position, _options)

    if type(_model) ~= 'string' then
        print('ObjectController.create failed: _model is not a string.')
        return
    end

    if type(_position) ~= 'vector3' then
        print('ObjectController.create failed: _position is not a vector3.')
        return
    end

    local uid = ObjectController.generateUID()
    if not uid then
        print('ObjectController.create failed: Uid is nil.')
        return
    end

    local self = {}
    self.data = {}
    self.data.uid = uid
    self.data.model = _model
    self.data.position = _position
    -- Default values
    self.data.clickable = false
    self.data.rotation = vector3(0, 0, 0)
    self.data.freezed = true
    self.data.collision = true
    self.data.alpha = 255
    self.data.servervariables = {} -- To keep them private on serverside
    self.data.sharedvariables = {} -- Shared to clientside
    -- 

    if type(_options) == 'table' then
        if type(_options.servervariables) == 'table' then
            self.data.servervariables = _options.servervariables
        end

        if type(_options.sharedvariables) == 'table' then
            self.data.sharedvariables = _options.sharedvariables
        end

        if type(_options.rotation) == 'vector3' then
            self.data.rotation = _options.rotation
        end

        if type(_options.freezed) == 'boolean' then
            self.data.freezed = _options.freezed
        end

        if type(_options.alpha) == 'number' then
            self.data.alpha = _options.alpha
        end

        if type(_options.collision) == 'boolean' then
            self.data.collision = _options.collision
        end

        if type(_options.clickable) == 'boolean' then
            self.data.clickable = _options.clickable
        end
    end

    self.setPosition = function(_pos)
        if type(_pos) ~= 'vector3' then
            print('setPosition failed: _pos is not a vector3.')
            return
        end

        self.data.position = _pos
        TriggerClientEvent(Config.Events.set_position, -1, self.data.uid, _pos)
    end

    self.setRotation = function(_rot)
        if type(_rot) ~= 'vector3' then
            print('setRotation failed: _rot is not a vector3.')
            return
        end

        self.data.rotation = _rot
        TriggerClientEvent(Config.Events.set_rotation, -1, self.data.uid, _rot)
    end

    self.setFreezed = function(_state)
        if type(_state) ~= 'boolean' then
            print('setFreeze failed: _state is not a boolean.')
            return
        end

        self.data.freezed = _state
        TriggerClientEvent(Config.Events.set_freeze, -1, self.data.uid, _state)
    end

    self.setModel = function(_value)
        if type(_value) ~= 'string' then
            print('setModel failed: _value is not a string.')
            return
        end

        self.data.model = _value
        TriggerClientEvent(Config.Events.set_model, -1, self.data.uid, _value)
    end

    self.setAlpha = function(_alpha)
        if type(_alpha) ~= 'number' then
            print('setAlpha failed: _alpha not a number.')
            return
        end

        self.data.alpha = _alpha
        TriggerClientEvent(Config.Events.set_alpha, -1, self.data.uid, _alpha)
    end

    self.setServerVariable = function(key, value)
        if type(key) ~= 'string' then
            print('setServerVariable failed: key is not a string.')
            return
        end

        self.data.servervariables[key] = value
        TriggerEvent(Config.Events.variable_changed, self.data.uid, key, value)
    end

    self.setSharedVar = function(key, value)
        if type(key) ~= 'string' then
            print('setSharedVar failed: key is not a string.')
            return
        end
        self.data.sharedvariables[key] = value
        TriggerEvent(Config.Events.variable_changed, self.data.uid, key, value)
        TriggerClientEvent(Config.Events.variable_changed, -1, self.data.uid, key, value)
    end

    self.getSharedVar = function(key)
        if type(key) ~= 'string' then
            print('getSharedVar failed: key is not a string.')
            return
        end
        return self.data.sharedvariables[key]
    end

    ObjectController._store[uid] = self
    TriggerClientEvent(Config.Events.append, -1, self.data)

    Config.DebugMsg(string.format('Object created %s (uid: %s)', self.data.model, uid))

    return {
        uid = uid,
        object = ObjectController._store[uid]
    }
end

ObjectController.exist = function(uid)
    return ObjectController._store[uid] ~= nil
end

ObjectController.get = function(uid)
    return ObjectController._store[uid]
end

ObjectController.generateUID = function()
    local maxnum = 99999
    local uid = 'obj-' .. math.random(1, maxnum)

    local maxtries = 50 -- to prevent the server crash if something really fucks up.
    local tries = 0
    while (ObjectController._store[uid] and tries < maxtries) do
        uid = 'obj-' .. math.random(1, maxnum)
        tries = tries + 1
    end

    if tries >= maxtries then
        print('ObjectController.generateUID failed: maxtries exceeded..')
        return
    end

    return uid
end

ObjectController.delete = function(uid)
    if ObjectController._store[uid] then
        TriggerClientEvent(Config.Events.remove, -1, uid)
        table.remove(ObjectController._store, uid)
    end
end

ObjectController.populate = function(source)
    if GetPlayerName(source) ~= nil then
        for k, v in pairs(ObjectController._store) do
            TriggerClientEvent(Config.Events.append, source, v.data)
        end
    end
end

SetTimeout(200, function()
    local o = ObjectController.create('prop_barrel_01a', vector3(-2612, 1870, 167), {
        clickable = true
    })
    -- o.object.setPosition(vector3(-266, -2422, 124))
    -- o.object.setSharedVar('name', 'Object Name')
end)

AddEventHandler('playerJoining', function()
    ObjectController.populate(source)
end)
