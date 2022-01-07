FunctionController = {}
FunctionController._store = {}

FunctionController.add = function(uid, func)
    if type(func) ~= 'function' then
        print('functionController.add failed: func is not a function.')
        return
    end

    if FunctionController._store[uid] then
        print(string.format('functionController.add warning: %s uid already exist.', uid))
        return
    end

    FunctionController._store[uid] = func
end

FunctionController.remove = function(uid)
    if FunctionController._store[uid] then
        FunctionController._store[uid] = nil
    end
end

function tableLength(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

Citizen.CreateThread(function()
    while true do

        if tableLength(FunctionController._store) < 1 then
            Citizen.Wait(5000)
        end

        for uid, _ in pairs(ClientObjectController._streamed) do
            local data = ClientObjectController._store[uid]
            if data then
                for _, func in pairs(FunctionController._store) do
                    if type(func) == 'function' then
                        func(data)
                    end
                end
            end
        end

        Citizen.Wait(1)
    end
end)

exports('oc_addfunction', FunctionController.add)
exports('oc_removefunction', FunctionController.remove)