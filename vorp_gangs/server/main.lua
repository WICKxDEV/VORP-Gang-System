local VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)

local Gangs = {} -- In-memory cache of gangs

-- Initialize Gangs from DB
Citizen.CreateThread(function()
    while VORPcore == nil do Wait(100) end
    
    MySQL.Async.fetchAll('SELECT * FROM vorp_gangs', {}, function(results)
        for _, gang in ipairs(results) do
            Gangs[gang.id] = {
                id = gang.id,
                name = gang.name,
                owner = gang.owner,
                balance = tonumber(gang.balance),
                members = {}
            }
            
            -- Load members for this gang with names
            MySQL.Async.fetchAll('SELECT m.*, c.firstname, c.lastname FROM vorp_gang_members m LEFT JOIN characters c ON m.char_identifier = c.charidentifier WHERE m.gang_id = @id', {['@id'] = gang.id}, function(members)
                for _, member in ipairs(members) do
                    local fullName = (member.firstname or "Unknown") .. " " .. (member.lastname or "Outlaw")
                    Gangs[gang.id].members[tostring(member.char_identifier)] = {
                        char_id = member.char_identifier,
                        name = fullName,
                        rank = tonumber(member.rank)
                    }
                end
            end)
        end
        print("^2[VORP Gangs]^7 Loaded " .. #results .. " gangs.")
    end)
end)

-- Function: Get Player Gang Info
function GetPlayerGang(char_id)
    local charKey = tostring(char_id)
    for id, gang in pairs(Gangs) do
        if gang.members[charKey] then
            return gang, gang.members[charKey]
        end
    end
    return nil, nil
end

-- Function: Create Gang Logic
local function CreateGangInternal(src, gangName)
    local User = VORPcore.getUser(src)
    if not User then return end
    local Character = User.getUsedCharacter
    if not Character then return end
    
    local char_id = Character.charIdentifier
    local firstName = Character.firstname
    local lastName = Character.lastname
    local fullName = firstName .. " " .. lastName
    local money = Character.money

    if GetPlayerGang(char_id) then
        VORPcore.NotifyLeft(src, "Gang", Config.Locales['already_in_gang'], "generic_textures", "tick", 4000)
        return
    end

    if money < Config.CreateCost then
        VORPcore.NotifyLeft(src, "Gang", string.format(Config.Locales['not_enough_money'], Config.CreateCost), "generic_textures", "tick", 4000)
        return
    end

    MySQL.Async.insert('INSERT INTO vorp_gangs (name, owner) VALUES (@name, @owner)', {
        ['@name'] = gangName,
        ['@owner'] = char_id
    }, function(insertId)
        if insertId > 0 then
            Character.removeCurrency(0, Config.CreateCost)
            
            MySQL.Async.execute('INSERT INTO vorp_gang_members (gang_id, char_identifier, rank) VALUES (@gid, @cid, @rank)', {
                ['@gid'] = insertId,
                ['@cid'] = char_id,
                ['@rank'] = 5 -- Leader
            })

            Gangs[insertId] = {
                id = insertId,
                name = gangName,
                owner = char_id,
                balance = 0.0,
                members = {
                    [tostring(char_id)] = { char_id = char_id, name = fullName, rank = 5 }
                }
            }
            VORPcore.NotifyLeft(src, "Gang", string.format(Config.Locales['gang_created'], gangName), "generic_textures", "tick", 4000)
            TriggerClientEvent('vorp_gangs:client:UpdateSync', -1, Gangs)
        end
    end)
end

-- Create Gang Command
RegisterCommand('creategang', function(source, args, rawCommand)
    local src = source
    if src == 0 then return end -- Console cannot create a gang
    
    local gangName = table.concat(args, " ")
    if gangName == "" then
        VORPcore.NotifyLeft(src, "Gang", "Usage: /creategang [name]", "generic_textures", "tick", 4000)
        return
    end
    CreateGangInternal(src, gangName)
end, false) -- Anyone can run this command

-- Create Gang Event
RegisterServerEvent('vorp_gangs:server:CreateGang')
AddEventHandler('vorp_gangs:server:CreateGang', function(gangName)
    CreateGangInternal(source, gangName)
end)

-- Command: My Gang Info
RegisterCommand('mygang', function(source)
    local Character = VORPcore.getUser(source).getUsedCharacter
    if not Character then return end
    
    local gang, member = GetPlayerGang(Character.charIdentifier)
    if gang then
        local rankName = Config.Ranks[member.rank] and Config.Ranks[member.rank].name or "Unknown"
        VORPcore.NotifyLeft(source, "Gang Info", "Gang: " .. gang.name .. "\nRank: " .. rankName, "generic_textures", "tick", 5000)
    else
        VORPcore.NotifyLeft(source, "Gang", "You are not in a gang.", "generic_textures", "tick", 4000)
    end
end, false)

-- Command: Leave Gang
RegisterCommand('leavegang', function(source)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    if not Character then return end
    
    local char_id = Character.charIdentifier
    local gang, member = GetPlayerGang(char_id)
    
    if not gang then
        VORPcore.NotifyLeft(src, "Gang", "You are not in a gang.", "generic_textures", "tick", 4000)
        return
    end

    if member.rank == 5 then
        VORPcore.NotifyLeft(src, "Gang", "Leaders cannot leave. You must delete the gang or transfer ownership (feature coming soon).", "generic_textures", "tick", 5000)
        return
    end

    MySQL.Async.execute('DELETE FROM vorp_gang_members WHERE gang_id = @gid AND char_identifier = @cid', {
        ['@gid'] = gang.id,
        ['@cid'] = char_id
    }, function()
        gang.members[tostring(char_id)] = nil
        VORPcore.NotifyLeft(src, "Gang", "You have left " .. gang.name, "generic_textures", "tick", 4000)
        TriggerClientEvent('vorp_gangs:client:UpdateSync', -1, Gangs)
    end)
end, false)

-- Command: Gang Invite (by ID)
RegisterCommand('ganginvite', function(source, args)
    local targetId = tonumber(args[1])
    if not targetId then
        VORPcore.NotifyLeft(source, "Gang", "Usage: /ganginvite [ID]", "generic_textures", "tick", 4000)
        return
    end
    
    local src = source
    local playerGang, playerMember = GetPlayerGang(VORPcore.getUser(src).getUsedCharacter.charIdentifier)
    
    if not playerGang or playerMember.rank < 3 then
        VORPcore.NotifyLeft(src, "Gang", "You don't have permission to invite.", "generic_textures", "tick", 4000)
        return
    end

    local TargetChar = VORPcore.getUser(targetId)
    if not TargetChar then
        VORPcore.NotifyLeft(src, "Gang", "Player not found.", "generic_textures", "tick", 4000)
        return
    end

    local TargetCharData = TargetChar.getUsedCharacter
    if GetPlayerGang(TargetCharData.charIdentifier) then
        VORPcore.NotifyLeft(src, "Gang", "Player is already in a gang.", "generic_textures", "tick", 4000)
        return
    end

    TriggerClientEvent('vorp_gangs:client:ReceiveInvite', targetId, playerGang.name, playerGang.id, src)
    VORPcore.NotifyLeft(src, "Gang", "Invitation sent to ID " .. targetId, "generic_textures", "tick", 4000)
end, false)

-- Command: Gang Kick (by ID)
RegisterCommand('gangkick', function(source, args)
    local targetId = tonumber(args[1])
    if not targetId then
        VORPcore.NotifyLeft(source, "Gang", "Usage: /gangkick [ID]", "generic_textures", "tick", 4000)
        return
    end

    local src = source
    local playerGang, playerMember = GetPlayerGang(VORPcore.getUser(src).getUsedCharacter.charIdentifier)

    if not playerGang or playerMember.rank < 3 then
        VORPcore.NotifyLeft(src, "Gang", "Permission denied.", "generic_textures", "tick", 4000)
        return
    end

    local TargetChar = VORPcore.getUser(targetId)
    if not TargetChar then
        VORPcore.NotifyLeft(src, "Gang", "Player not online.", "generic_textures", "tick", 4000)
        return
    end

    local targetCharId = TargetChar.getUsedCharacter.charIdentifier
    local targetKey = tostring(targetCharId)
    if not playerGang.members[targetKey] then
        VORPcore.NotifyLeft(src, "Gang", "Player is not in your gang.", "generic_textures", "tick", 4000)
        return
    end

    if playerMember.rank <= playerGang.members[targetKey].rank and playerMember.rank ~= 5 then
        VORPcore.NotifyLeft(src, "Gang", "You cannot kick someone of higher or equal rank.", "generic_textures", "tick", 4000)
        return
    end

    MySQL.Async.execute('DELETE FROM vorp_gang_members WHERE gang_id = @gid AND char_identifier = @cid', {
        ['@gid'] = playerGang.id,
        ['@cid'] = targetCharId
    }, function()
        playerGang.members[targetKey] = nil
        VORPcore.NotifyLeft(src, "Gang", "Kicked member with ID " .. targetId, "generic_textures", "tick", 4000)
        VORPcore.NotifyLeft(targetId, "Gang", "You were kicked from " .. playerGang.name, "generic_textures", "tick", 4000)
        TriggerClientEvent('vorp_gangs:client:UpdateSync', -1, Gangs)
    end)
end, false)

-- Invite Player
RegisterServerEvent('vorp_gangs:server:InvitePlayer')
AddEventHandler('vorp_gangs:server:InvitePlayer', function(targetId)
    local src = source
    local playerGang, playerMember = GetPlayerGang(VORPcore.getUser(src).getUsedCharacter.charIdentifier)
    
    if not playerGang or playerMember.rank < 3 then -- Rank 3+ can invite
        VORPcore.NotifyLeft(src, "Gang", "You don't have permission to invite.", "generic_textures", "tick", 4000)
        return
    end

    local TargetChar = VORPcore.getUser(targetId).getUsedCharacter
    if GetPlayerGang(TargetChar.charIdentifier) then
        VORPcore.NotifyLeft(src, "Gang", "Player is already in a gang.", "generic_textures", "tick", 4000)
        return
    end

    -- Trigger Invite on Client (UI Popup for Target)
    TriggerClientEvent('vorp_gangs:client:ReceiveInvite', targetId, playerGang.name, playerGang.id, src)
end)

-- Accept Invite
RegisterServerEvent('vorp_gangs:server:AcceptInvite')
AddEventHandler('vorp_gangs:server:AcceptInvite', function(gangId)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local char_id = Character.charIdentifier

    if GetPlayerGang(char_id) then return end

    MySQL.Async.execute('INSERT INTO vorp_gang_members (gang_id, char_identifier, rank) VALUES (@gid, @cid, @rank)', {
        ['@gid'] = gangId,
        ['@cid'] = char_id,
        ['@rank'] = 1
    }, function(changed)
        if changed > 0 then
            local fullName = Character.firstname .. " " .. Character.lastname
            Gangs[gangId].members[tostring(char_id)] = { char_id = char_id, name = fullName, rank = 1 }
            VORPcore.NotifyLeft(src, "Gang", "You joined the gang!", "generic_textures", "tick", 4000)
            TriggerClientEvent('vorp_gangs:client:UpdateSync', -1, Gangs) -- Sync
        end
    end)
end)

-- Promote / Demote
RegisterServerEvent('vorp_gangs:server:UpdateRank')
AddEventHandler('vorp_gangs:server:UpdateRank', function(targetCharId, newRank)
    local src = source
    local playerGang, playerMember = GetPlayerGang(VORPcore.getUser(src).getUsedCharacter.charIdentifier)
    local targetKey = tostring(targetCharId)

    if not playerGang or playerMember.rank < 4 then return end -- Co-Leader+
    if not playerGang.members[targetKey] then return end
    if playerMember.rank <= playerGang.members[targetKey].rank and playerMember.rank ~= 5 then return end

    MySQL.Async.execute('UPDATE vorp_gang_members SET rank = @rank WHERE gang_id = @gid AND char_identifier = @cid', {
        ['@rank'] = newRank,
        ['@gid'] = playerGang.id,
        ['@cid'] = targetCharId
    }, function()
        playerGang.members[targetKey].rank = newRank
        TriggerClientEvent('vorp_gangs:client:UpdateSync', -1, Gangs)
    end)
end)

-- Kick Member
RegisterServerEvent('vorp_gangs:server:KickMember')
AddEventHandler('vorp_gangs:server:KickMember', function(targetCharId)
    local src = source
    local playerGang, playerMember = GetPlayerGang(VORPcore.getUser(src).getUsedCharacter.charIdentifier)
    local targetKey = tostring(targetCharId)

    if not playerGang or playerMember.rank < 3 then return end
    if not playerGang.members[targetKey] then return end
    if playerMember.rank <= playerGang.members[targetKey].rank and playerMember.rank ~= 5 then return end

    MySQL.Async.execute('DELETE FROM vorp_gang_members WHERE gang_id = @gid AND char_identifier = @cid', {
        ['@gid'] = playerGang.id,
        ['@cid'] = targetCharId
    }, function()
        playerGang.members[targetKey] = nil
        TriggerClientEvent('vorp_gangs:client:UpdateSync', -1, Gangs)
    end)
end)

-- Fetch My Gang Data (Event based)
RegisterServerEvent('vorp_gangs:server:GetMyGangData')
AddEventHandler('vorp_gangs:server:GetMyGangData', function()
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    if not Character then return end
    
    local char_id = Character.charIdentifier
    local gang, member = GetPlayerGang(char_id)
    if gang then
        TriggerClientEvent('vorp_gangs:client:OpenMenu', src, { gang = gang, myRank = member.rank })
    else
        TriggerClientEvent('vorp_gangs:client:OpenMenu', src, nil)
    end
end)
