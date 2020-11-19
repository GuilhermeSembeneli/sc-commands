---------------------------------------------------------------------------------------------------------
--VRP
---------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
SC = {}
Tunnel.bindInterface("sc-commands",SC)
---------------------------------------------------------------------------------------------------------
--Objects Config
---------------------------------------------------------------------------------------------------------
items = {
    {item = 'dinheirosujo'},
    {item = 'radio'},
}
---------------------------------------------------------------------------------------------------------
--Functions
---------------------------------------------------------------------------------------------------------
function SC.TryGetItens()
    local source = source
    local user_id = vRP.getUserId(source)
    for k,v in pairs(items) do
        local amountget = vRP.getInventoryItemAmount(user_id, v.item)
        vRP.tryGetInventoryItem(user_id, v.item, amountget)
    end
end
function SC.CheckItem(item, amount)
    local source = source
    local user_id = vRP.getUserId(source)
    if vRP.tryGetInventoryItem(user_id, item, amount) then 
        return true
    end
end
function SC.getItem(item, amount)
    local source = source
    local user_id = vRP.getUserId(source)
    if vRP.giveInventoryItem(user_id, item, amount) then
        return true
    end
end

function SC.CheckPerm(perm)
    local source = source
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, perm) then
        return true
    end
end

local time = false
RegisterServerEvent("sc:payment:radar")
AddEventHandler("sc:payment:radar", function(pay)
    if not time then
        local source = source
        local user_id = vRP.getUserId(source)
        local value = vRP.getUData(parseInt(user_id),"vRP:multas")
        local multas = json.decode(value) or 0
        if vRP.hasPermission(user_id, 'policia.permissao') or vRP.hasPermission(user_id, "paramedico.permissao") or vRP.getInventoryItemAmount(user_id, "placa") then
            return
        else
            vRP.setUData(user_id,"vRP:multas",json.encode(parseInt(multas)+parseInt(pay)))
            TriggerClientEvent("Notify", source, "aviso", "Acabamos de adicionar " .. parseInt(pay) .. "R$ em multas!")
            time = true
        end
        SetTimeout(1000, function()
            time = false
        end)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- /COMMANDS
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterCommand('cobrar', function(source, args, rawCommand)
    local source = source 
    local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)
    if args[1] and args[2] then
        local nsource = vRP.getUserSource(parseInt(args[1]))
        if nsource == nil then
            TriggerClientEvent("Notify",source,"warning","Passaporte <b>"..vRP.format(args[1]).."</b> indisponível no momento.")
            return
        end
        local ok = vRP.request(nsource, "O jogador " ..identity.name.. " está te cobrando o valor de R$" ..args[2] ..". Deseja pagar?", 30) 
        if ok then
            nuser_id = vRP.getUserId(nsource)
			if vRP.tryFullPayment(nuser_id,parseInt(args[2])) then
				local bankget = vRP.getBankMoney(user_id)
                vRP.setBankMoney(user_id, (bankget + parseInt(args[2])))
                vRPclient._playAnim(source,true,{{"mp_common","givetake1_a"}},false)
                vRPclient._playAnim(nsource,true,{{"mp_common","givetake1_a"}},false)
                TriggerClientEvent("Notify",source, "sucesso", "Você recebeu a quantia de R$"..parseInt(args[2]).. "!")
                TriggerClientEvent("Notify",nsource, "sucesso", "Você pagou a quantia de R$"..parseInt(args[2]).. "!")
            end
        end
    end
end)

local tempo = {}
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		for k,v in pairs(tempo) do
			if v > 0 then
				tempo[k] = v - 1
				if v == 0 then
					tempo[k] = nil
				end
			end
		end	
	end
end)
RegisterCommand('cfix',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	local mec = vRP.getUsersByPermission('callmec.permissao')
	if tempo[user_id] == 0 or not tempo[user_id] then
		tempo[user_id] = 1*30*30
		if #mec >= 1 then
			return TriggerClientEvent('Notify', source, "aviso", "Atualmente existem " ..#mec .. " mecanicos em serviço. Comando só utilizado com 0")
		end
		local vehicle = vRPclient.getNearestVehicle(source,11)
        if vehicle  then
            if vRP.tryFullPayment(user_id,500) then
                TriggerClientEvent('reparar',source)
            else
                TriggerClientEvent("Notify", source, "aviso", "Dinheiro insuficiente")
            end
		end
	else
		TriggerClientEvent("Notify",source, "aviso", "Aguarde " ..tempo[user_id]..  " segundos")
	end
end)


-----------------------------------------------------------------------------------------------------------------------------------------
-- /WEBHOOK
-----------------------------------------------------------------------------------------------------------------------------------------

function SC.WebHookMsg(wbhook, msg)
    if wbhook ~= "" then
        PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
    end
end
