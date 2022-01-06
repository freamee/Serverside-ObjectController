ObjectController = {}
ObjectController._store = {}

ObjectController.create = function(_model, _position, _rotation, _freezed, _collision, _alpha, _variables)
    if type(_model) ~= 'string' then
        print('ObjectController.create failed: _model is not a string.')
        return
    end

    if type(_position) ~= 'vector3' then
        print('ObjectController.create failed: _position is not a vector3.')
        return
    end

    if type(_rotation) ~= 'vector3' then
        print('ObjectController.create failed: _rotation is not a vector3.')
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
    self.data.rotation = _rotation
    self.data.freezed = _freezed
    self.data.collision = _collision
    self.data.alpha = _alpha
    self.data.visible = true
    self.data.variables = {}

    self.setPosition = function(_pos)
        if type(_pos) ~= 'vector3' then
            print('Object setPosition failed: _pos is not a vector3.')
            return
        end

        self.data.position = _pos
        -- CLIENT EVENT
    end

    self.setVisible = function(_state)
        if type(_state) ~= 'boolean' then
            print('Object setVisible failed: _state is not a boolean.')
            return
        end

        self.data.visible = _state
        -- CLIENT EVENT
    end

    self.setAlpha = function(_alpha)
        if type(_alpha) ~= 'number' then
            print('Object setAlpha failed: _alpha not a number.')
            return
        end

        self.data.alpha = _alpha
        -- CLIENT EVENT
    end

    self.setVar = function(key, value)
        if type(key) ~= 'string' then
            print('Object setVar failed: key is not a string.')
            return
        end
        self.data.variables[key] = value
    end

    self.getVar = function(key)
        if type(key) ~= 'string' then
            print('Object getVar failed: key is not a string.')
            return
        end
        return self.data.variables[key]
    end

    if type(_variables) == 'table' then
        self.variables = _variables
    end

    ObjectController._store[uid] = self
    TriggerClientEvent(Config.Events.append, -1, self.data)
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
    local o = ObjectController.create('prop_barrel_01a', vector3(1, 0, 0), vector3(0, 0, 0))
    o.object.setVar('test', true)
    o.object.setVar('test', nil)
end)

AddEventHandler('playerJoining', function()
    ObjectController.populate(source)
end)
