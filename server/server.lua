ObjectController = {}
ObjectController._store = {}

-- _options = {
--     rotation = vector3,
--     freezed = boolean,
--     collision = boolean,
--     alpha = number,
--     clickable = boolean,
--     servervars = table,
--     sharedvars = table,
-- }

ObjectController.create = function(_model, _position, _uid, _options)

    if type(_model) ~= 'string' then
        print('ObjectController.create failed: _model is not a string.')
        return
    end

    if type(_position) ~= 'vector3' then
        print('ObjectController.create failed: _position is not a vector3.')
        return
    end

    if _uid == nil or type(_uid) ~= 'string' then
        _uid = ObjectController.generateUID()
        if not _uid then
            print('ObjectController.create failed: Uid is nil.')
            return
        end
    end

    if ObjectController._store[_uid] then
        print('ObjectController.create failed: Uid already exist in _store.')
        return
    end

    local self = {}
    self.data = {}
    self.data.uid = _uid
    self.data.model = _model
    self.data.position = _position
    -- Default values
    self.data.clickable = false
    self.data.rotation = vector3(0, 0, 0)
    self.data.freezed = true
    self.data.collision = true
    self.data.alpha = 255
    self.data.servervars = {} -- To keep them private on serverside
    self.data.sharedvars = {} -- Shared to clientside
    -- 

    if type(_options) == 'table' then
        if type(_options.servervars) == 'table' then
            self.data.servervars = _options.servervars
        end

        if type(_options.sharedvars) == 'table' then
            self.data.sharedvars = _options.sharedvars
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

    self.save = function()
        local exist = MySQL.Sync.fetchScalar('SELECT COUNT(1) FROM av_objects WHERE uid = @uid', {
            ['@uid'] = self.data.uid
        })

        if exist < 1 then
            local qry = 'INSERT INTO av_objects SET uid = @uid'
            MySQL.Async.execute(qry, {
                ['@uid'] = self.data.uid
            }, function()
                self.save()
            end)
        else
            local qry =
                'UPDATE av_objects SET sharedvars = @sharedvars, servervars = @servervars, pos = @pos, rot = @rot, uid = @uid'

            MySQL.Sync.execute(qry, {
                ['@sharedvars'] = json.encode(self.data.sharedvars),
                ['@servervars'] = json.encode(self.data.servervars),
                ['@pos'] = json.encode(self.data.position),
                ['@rot'] = json.encode(self.data.rotation),
                ['@uid'] = self.data.uid
            })
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

        self.data.servervars[key] = value
        TriggerEvent(Config.Events.variable_changed, self.data.uid, key, value)
    end

    self.getServerVar = function(key)
        if type(key) ~= 'string' then
            print('getServerVar failed: key is not a string.')
            return
        end
        return self.data.servervars[key]
    end

    self.setSharedVar = function(key, value)
        if type(key) ~= 'string' then
            print('setSharedVar failed: key is not a string.')
            return
        end
        self.data.sharedvars[key] = value
        TriggerEvent(Config.Events.variable_changed, self.data.uid, key, value)
        TriggerClientEvent(Config.Events.variable_changed, -1, self.data.uid, key, value)
    end

    self.getSharedVar = function(key)
        if type(key) ~= 'string' then
            print('getSharedVar failed: key is not a string.')
            return
        end
        return self.data.sharedvars[key]
    end

    ObjectController._store[self.data.uid] = self
    TriggerClientEvent(Config.Events.append, -1, self.data)

    Config.DebugMsg(string.format('Object created %s (uid: %s)', self.data.model, self.data.uid))

    return {
        uid = self.data.uid,
        object = ObjectController._store[self.data.uid]
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

AddEventHandler('playerJoining', function()
    ObjectController.populate(source)
end)

exports('oc_create', ObjectController.create)
exports('oc_delete', ObjectController.delete)
exports('oc_get', ObjectController.get)
exports('oc_exist', ObjectController.exist)

-- SetTimeout(200, function()
--     local o = ObjectController.create('prop_barrel_01a', vector3(-2612, 1870, 167), 'uid-1', {
--         clickable = true
--     })
--     o.object.setPosition(vector3(-2609, 1869, 167))
--     o.object.setSharedVar('name', 'Shared Variable Example')
--     o.object.save()
-- end)