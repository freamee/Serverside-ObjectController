AimController = {}
AimController._aiming = false
AimController._aimedData = nil

RegisterCommand('aimingentity', function()
    AimController._aiming = not AimController._aiming

    if not AimController._aiming then -- Reset when not aiming.
        AimController._aimedData = nil
    end

    if AimController._aiming then
        SetMouseCursorSprite(Config.AimEntity.CursorSpriteDefault)

        if Config.AimEntity.CenterCursorOnOpen then
            SetCursorLocation(0.5, 0.5)
        end

        Citizen.CreateThread(function()
            while AimController._aiming do
                Citizen.Wait(0)

                DisableAllControlActions(2)

                EnableControlAction(2, 30, true)
                EnableControlAction(2, 31, true)
                EnableControlAction(2, 32, true)
                EnableControlAction(2, 33, true)
                EnableControlAction(2, 34, true)
                EnableControlAction(2, 35, true)

                SetMouseCursorActiveThisFrame()

                if AimController._aimedData then
                    if IsDisabledControlJustPressed(0, 24) then
                        local data = ClientObjectController.getObjectByHandle(AimController._aimedData.entity)
                        if data then
                            TriggerEvent(Config.Events.object_clicked, data.uid, data)
                            TriggerServerEvent(Config.Events.object_clicked, data.uid, data)
                        end
                    end

                    if Config.AimEntity.EnableDrawLine then
                        local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
                        local ox, oy, oz = table.unpack(AimController._aimedData.hitcoords)
                        DrawLine(x, y, z, ox, oy, oz, 255, 255, 255, 255)
                    end

                    if Config.AimEntity.EnableSprite then
                        local onScreen, rx, ry = GetScreenCoordFromWorldCoord(ox, oy, oz)
                        if onScreen then
                            RequestStreamedTextureDict(Config.AimEntity.SpriteDict, false)
                            DrawSprite(Config.AimEntity.SpriteDict, Config.AimEntity.SpriteName, rx, ry, 0.015, 0.03,
                                0.0, 255, 255, 255, 255)
                        end
                    end
                end
            end
        end)

        Citizen.CreateThread(function()
            while AimController._aiming do
                Citizen.Wait(Config.AimEntity.RefreshRateMS)

                local found, hitcoords, entity = screenToWorld(16, 0)
                if found >= 1 then
                    local dist = #(GetEntityCoords(PlayerPedId()) - hitcoords)

                    if Config.AimEntity.Distance > dist then
                        local data = ClientObjectController.getObjectByHandle(entity)
                        if data and data.clickable then
                            SetMouseCursorSprite(Config.AimEntity.CursorSpriteOnAim)
                            AimController._aimedData = {
                                entity = entity,
                                hitcoords = hitcoords
                            }
                            goto continue
                        end
                    end
                end

                if AimController._aimedData ~= nil then
                    AimController._aimedData = nil
                    SetMouseCursorSprite(Config.AimEntity.CursorSpriteDefault)
                end

                ::continue::
            end
        end)
    end
end, false)

RegisterKeyMapping('aimingentity', 'Enable Entity Cursor', 'keyboard', Config.AimEntity.Key)
