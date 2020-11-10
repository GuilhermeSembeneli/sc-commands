---------------------------------------------------------------------------------------------------------
--VRP
---------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
SC = Tunnel.getInterface("sc-commands")
---------------------------------------------------------------------------------------------------------
--Thread
---------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(2000)
        local ped = PlayerPedId()
        Swimming = false
        if IsPedSwimming(ped) then  
            Swimming = true
            SC.TryGetItens()    
        end
    end
end)
Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(0)
        if Swimming == true then
            DisableControlAction(0,311,true)
        end
    end
end)

Citizen.CreateThread(function ()
    while true do
        local th = 500
        local ped = PlayerPedId()
        local position = GetEntityCoords(ped)
        local objectcoords = GetClosestObjectOfType(position.x, position.y, position.z, 1.0, -742198632, false, false, false)
        local objectcoordsPosition = GetEntityCoords(objectcoords)
        local dist = GetDistanceBetweenCoords(position.x, position.y, position.z, objectcoordsPosition.x, objectcoordsPosition.y, objectcoordsPosition.z, true)
        if dist < 1.8 then
            th = 5
            DrawText3Ds(objectcoordsPosition.x, objectcoordsPosition.y, objectcoordsPosition.z + 1.0, 'PRESSIONE [~y~E~w~] PARA LIMPAR SUA GAZE')
            if IsControlJustReleased(0, 38) then
                if SC.CheckItem("gazeusada",1) then
                    TriggerEvent("progressBars", 15000,"Limpando")
                    vRP._playAnim(false, {{"amb@prop_human_parking_meter@female@idle_a", "idle_a_female"}}, true)
                    Wait(15000)
                    vRP._stopAnim(false)
                    SC.getItem("gaze",1)
                    
                end
            end
        end
        Citizen.Wait(th)
    end
end)

---------------------------------------------------------------------------------------------------------
--Event
---------------------------------------------------------------------------------------------------------
RegisterNetEvent("SwimmingGaze")
AddEventHandler("SwimmingGaze",function()
	local ped = PlayerPedId()
	if IsPedSwimming(ped) then
        if SC.CheckItem("gazeusada",1) then
           SC.getItem("gaze", 1) 
        end
	end
end)

function DrawText3Ds(x, y, z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local factor = #text / 460
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	
	SetTextScale(0.3, 0.3)
	SetTextFont(6)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 160)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	DrawRect(_x,_y + 0.0115, 0.02 + factor, 0.027, 28, 28, 28, 95)
end



