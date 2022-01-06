ClientObjectController = {}
ClientObjectController._store = {}
ClientObjectController._streamed = {}

ClientObjectController.append = function(_d)
    if ClientObjectController._store[_d.uid] then -- If already exist then return
        return
    end

    ClientObjectController._store[_d.uid] = _d
    Config.DebugMsg(string.format('Object append %s', _d.uid))
end

ClientObjectController.remove = function(uid)
    if ClientObjectController._store[uid] then
        ClientObjectController._store[uid] = nil
    end

    if ClientObjectController.isStreamed(uid) then
        ClientObjectController.removeStream(uid)
    end

    Config.DebugMsg(string.format('Object removed %s', uid))
end

ClientObjectController.isStreamed = function(uid)
    return ClientObjectController._streamed[uid] ~= nil and DoesEntityExist(ClientObjectController._streamed[uid])
end

-- Search through the streamed for an object. (Needed for aimingEntity)
ClientObjectController.getObjectByHandle = function(obj)
    for uid, object in pairs(ClientObjectController._streamed) do
        if obj == object and ClientObjectController._store[uid] then
            return ClientObjectController._store[uid]
        end
    end
end

ClientObjectController.getObjectByUID = function(uid)
    if ClientObjectController.isStreamed(uid) then
        return ClientObjectController._streamed[uid]
    end
end

ClientObjectController.removeStream = function(uid)
    if ClientObjectController.isStreamed(uid) then
        local object = ClientObjectController._streamed[uid]
        if DoesEntityExist(object) then
            DeleteObject(object)
        end

        ClientObjectController._streamed[uid] = nil
        Config.DebugMsg(string.format('Object removeStream %s', uid))
    end
end

ClientObjectController.addStream = function(uid)
    Citizen.CreateThread(function()
        local data = ClientObjectController._store[uid]
        if not data then
            return
        end

        local x, y, z = table.unpack(data.position)
        local rx, ry, rz = table.unpack(data.rotation)

        local modelhash = GetHashKey(data.model)
        -- Alert the client player if the model is not valid.
        if not IsModelInCdimage(modelhash) or not IsModelValid(modelhash) then
            print(string.format('addStream failed: model is not valid: %s', data.model))
            return
        end

        RequestModel(modelhash)
        while not HasModelLoaded(modelhash) do
            Citizen.Wait(10)
        end

        local obj = CreateObject(GetHashKey(data.model), x, y, z, false, false, false)
        SetEntityRotation(obj, rx, ry, rz, 2, false)
        SetEntityAlpha(obj, data.alpha, false)
        FreezeEntityPosition(obj, data.freezed)
        SetEntityCollision(obj, data.collision, true)

        ClientObjectController._streamed[uid] = obj
        Config.DebugMsg(string.format('Object addStream %s', uid))
    end)
end

Citizen.CreateThread(function()
    while true do
        local playerpos = GetEntityCoords(PlayerPedId())

        for uid, v in pairs(ClientObjectController._store) do
            local dist = #(playerpos - v.position)
            if dist < Config.Distance then
                if not ClientObjectController.isStreamed(uid) then -- If not streamed
                    ClientObjectController._streamed[uid] = true -- Set true here, maybe the requestModel is so slow.
                    ClientObjectController.addStream(uid)
                end
            else
                if ClientObjectController.isStreamed(uid) then -- If streamed
                    ClientObjectController.removeStream(uid)
                end
            end
        end

        Citizen.Wait(Config.ClientTickerMS)
    end
end)

-- Remove objects on resource restart..
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for uid, _ in pairs(ClientObjectController._streamed) do
            ClientObjectController.removeStream(uid)
        end
    end
end)

RegisterNetEvent(Config.Events.append)
AddEventHandler(Config.Events.append, function(_d)
    ClientObjectController.append(_d)
end)

RegisterNetEvent(Config.Events.remove)
AddEventHandler(Config.Events.remove, function(uid)
    ClientObjectController.remove(uid)
end)

RegisterNetEvent(Config.Events.set_position)
AddEventHandler(Config.Events.set_position, function(uid, value)
    if type(value) ~= 'vector3' then
        Config.DebugMsg(string.format('set_position value is not a vector3. (%s)', uid))
        return
    end

    if ClientObjectController._store[uid] then
        ClientObjectController._store[uid].position = value
    end

    if ClientObjectController.isStreamed(uid) then
        local object = ClientObjectController.getObjectByUID(uid)
        if object then
            local x, y, z = table.unpack(value)
            SetEntityCoords(object, x, y, z, false, false, false, false)
        end
    end
end)

RegisterNetEvent(Config.Events.set_alpha)
AddEventHandler(Config.Events.set_alpha, function(uid, value)
    if type(value) ~= 'number' then
        Config.DebugMsg(string.format('set_alpha value is not a number. (%s)', uid))
        return
    end

    if ClientObjectController._store[uid] then
        ClientObjectController._store[uid].alpha = value
    end

    if ClientObjectController.isStreamed(uid) then
        local object = ClientObjectController.getObjectByUID(uid)
        if object then
            SetEntityAlpha(object, value, false)
        end
    end
end)

RegisterNetEvent(Config.Events.set_rotation)
AddEventHandler(Config.Events.set_rotation, function(uid, value)
    if type(value) ~= 'vector3' then
        Config.DebugMsg(string.format('set_rotation value is not a vector3. (%s)', uid))
        return
    end

    if ClientObjectController._store[uid] then
        ClientObjectController._store[uid].rotation = value
    end

    if ClientObjectController.isStreamed(uid) then
        local object = ClientObjectController.getObjectByUID(uid)
        if object then
            local rx, ry, rz = table.unpack(value)
            SetEntityRotation(object, rx, ry, rz, 2, false)
        end
    end
end)

RegisterNetEvent(Config.Events.set_freeze)
AddEventHandler(Config.Events.set_freeze, function(uid, value)
    if type(value) ~= 'boolean' then
        Config.DebugMsg(string.format('set_freeze value is not a boolean. (%s)', uid))
        return
    end

    if ClientObjectController._store[uid] then
        ClientObjectController._store[uid].freezed = value
    end

    if ClientObjectController.isStreamed(uid) then
        local object = ClientObjectController.getObjectByUID(uid)
        if object then
            FreezeEntityPosition(object, value)
        end
    end
end)

RegisterNetEvent(Config.Events.set_model)
AddEventHandler(Config.Events.set_model, function(uid, value)
    if type(value) ~= 'string' then
        Config.DebugMsg(string.format('set_model value is not a string. (%s)', uid))
        return
    end

    if ClientObjectController._store[uid] then
        ClientObjectController._store[uid].model = value
    end

    if ClientObjectController.isStreamed(uid) then
        -- Restream the whole object & data
        Citizen.CreateThread(function()
            ClientObjectController.removeStream(uid)
            Citizen.Wait(100)
            ClientObjectController.addStream(uid)
        end)
    end
end)