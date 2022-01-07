function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)

    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov

    if onScreen then
        SetTextScale(0.0 * scale, 0.35 * scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Render out variables
FunctionController.add('render-names', function(data)
    DrawText3D(data.position.x, data.position.y, data.position.z + 1.2, json.encode(data.sharedvars))
end)

-- Add one more render function (eg. markers)
FunctionController.add('render-markers', function(data)
    local x, y, z = table.unpack(data.position)
    DrawMarker(2, x, y, z + 1.5, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.25, 0.25, 0.25, 255, 255, 0, 50, false, true, 2, nil,
        nil, false)
end)

-- Delete render function with timeout
-- Citizen.CreateThread(function()
--     Citizen.Wait(5000)
--     FunctionController.remove('render-names')
-- end)
