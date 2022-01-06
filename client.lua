RegisterNetEvent(Config.Events.append)
AddEventHandler(Config.Events.append, function(_d)
    print(json.encode(_d))
end)

RegisterNetEvent(Config.Events.remove)
AddEventHandler(Config.Events.remove, function(uid)

end)
