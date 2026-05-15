local VORPcore = {}
local MyGangData = nil
local isMenuOpen = false

TriggerEvent("getCore", function(core)
    VORPcore = core
end)

-- Keybind to open Menu
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 0xF155C67B) then -- 'O' key (0xF155C67B)
            OpenGangMenu()
        end
    end
end)

-- Command to open Menu
RegisterCommand('gang', function()
    OpenGangMenu()
end, false)

function OpenGangMenu()
    if isMenuOpen then return end
    
    TriggerServerEvent('vorp_gangs:server:GetMyGangData')
end

RegisterNetEvent('vorp_gangs:client:OpenMenu')
AddEventHandler('vorp_gangs:client:OpenMenu', function(data)
    if not data then
        -- Use standard VORP Inputs for gang creation
        TriggerEvent("vorp_inputs:get", function(cb)
            local gangName = cb({
                title = "Create Gang",
                text = "Enter Name",
                type = "text",
                placeholder = "Gang Name",
                style = "glass",
            })
            
            if gangName and gangName ~= "" then
                TriggerServerEvent('vorp_gangs:server:CreateGang', gangName)
            end
        end)
        return
    end

    MyGangData = data
    isMenuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openMenu",
        gang = data.gang,
        myRank = data.myRank,
        ranks = Config.Ranks
    })
end)

-- Invite received from server
RegisterNetEvent('vorp_gangs:client:ReceiveInvite')
AddEventHandler('vorp_gangs:client:ReceiveInvite', function(gangName, gangId, inviterId)
    local inviterName = GetPlayerName(GetPlayerFromServerId(inviterId))
    
    VORPcore.NotifyLeft("Invitation", "You've been invited to join " .. gangName .. " by " .. inviterName, "generic_textures", "tick", 10000)
    
    -- Show UI choice
    SendNUIMessage({
        action = "showInvite",
        gangName = gangName,
        gangId = gangId
    })
    SetNuiFocus(true, true)
end)

-- Update local cache from server sync
RegisterNetEvent('vorp_gangs:client:UpdateSync')
AddEventHandler('vorp_gangs:client:UpdateSync', function(allGangs)
    -- If menu is open and my gang is updated, refresh UI
    if isMenuOpen and MyGangData then
        -- Find my updated gang in the sync data
        for id, gang in pairs(allGangs) do
            if id == MyGangData.gang.id then
                MyGangData.gang = gang
                SendNUIMessage({
                    action = "updateData",
                    gang = gang
                })
                break
            end
        end
    end
end)

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    isMenuOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('acceptInvite', function(data, cb)
    TriggerServerEvent('vorp_gangs:server:AcceptInvite', data.gangId)
    isMenuOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('invitePlayer', function(data, cb)
    local closestPlayer, closestDistance = VORPcore.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance < Config.InviteDistance then
        TriggerServerEvent('vorp_gangs:server:InvitePlayer', GetPlayerServerId(closestPlayer))
    else
        VORPcore.NotifyLeft("Gang", "No player nearby.", "generic_textures", "tick", 4000)
    end
    cb('ok')
end)

RegisterNUICallback('kickMember', function(data, cb)
    TriggerServerEvent('vorp_gangs:server:KickMember', data.charId)
    cb('ok')
end)

RegisterNUICallback('updateRank', function(data, cb)
    TriggerServerEvent('vorp_gangs:server:UpdateRank', data.charId, data.newRank)
    cb('ok')
end)
