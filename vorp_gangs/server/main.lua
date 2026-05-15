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
                balance = gang.balance,
                members = {}
            }
            
            -- Load members for this gang
            MySQL.Async.fetchAll('SELECT * FROM vorp_gang_members WHERE gang_id = @id', {['@id'] = gang.id}, function(members)
                for _, member in ipairs(members) do
                    Gangs[gang.id].members[member.char_identifier] = {
                        char_id = member.char_identifier,
                        rank = member.rank
                    }
                end
            end)
        end
        print("^2[VORP Gangs]^7 Loaded " .. #results .. " gangs.")
    end)
end)

-- Function: Get Player Gang Info
function GetPlayerGang(char_id)
    for id, gang in pairs(Gangs) do
        if gang.members[char_id] then
            return gang, gang.members[char_id]
        end
    end
    return nil, nil
end

-- Create Gang Command
RegisterServerEvent('vorp_gangs:server:CreateGang')
AddEventHandler('vorp_gangs:server:CreateGang', function(gangName)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local charIdentifier = Character.identifier
    local char_id = Character.charIdentifier
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
                    [char_id] = { char_id = char_id, rank = 5 }
                }
            }
            VORPcore.NotifyLeft(src, "Gang", string.format(Config.Locales['gang_created'], gangName), "generic_textures", "tick", 4000)
        end
    end)
end)

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
            Gangs[gangId].members[char_id] = { char_id = char_id, rank = 1 }
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

    if not playerGang or playerMember.rank < 4 then return end -- Co-Leader+
    if not playerGang.members[targetCharId] then return end
    if playerMember.rank <= playerGang.members[targetCharId].rank and playerMember.rank ~= 5 then return end

    MySQL.Async.execute('UPDATE vorp_gang_members SET rank = @rank WHERE gang_id = @gid AND char_identifier = @cid', {
        ['@rank'] = newRank,
        ['@gid'] = playerGang.id,
        ['@cid'] = targetCharId
    }, function()
        playerGang.members[targetCharId].rank = newRank
        TriggerClientEvent('vorp_gangs:client:UpdateSync', -1, Gangs)
    end)
end)

-- Kick Member
RegisterServerEvent('vorp_gangs:server:KickMember')
AddEventHandler('vorp_gangs:server:KickMember', function(targetCharId)
    local src = source
    local playerGang, playerMember = GetPlayerGang(VORPcore.getUser(src).getUsedCharacter.charIdentifier)

    if not playerGang or playerMember.rank < 3 then return end
    if not playerGang.members[targetCharId] then return end
    if playerMember.rank <= playerGang.members[targetCharId].rank and playerMember.rank ~= 5 then return end

    MySQL.Async.execute('DELETE FROM vorp_gang_members WHERE gang_id = @gid AND char_identifier = @cid', {
        ['@gid'] = playerGang.id,
        ['@cid'] = targetCharId
    }, function()
        playerGang.members[targetCharId] = nil
        TriggerClientEvent('vorp_gangs:client:UpdateSync', -1, Gangs)
    end)
end)

-- Fetch My Gang Data
VORPcore.addRpcCallback('vorp_gangs:callback:GetMyGang', function(source, cb)
    local char_id = VORPcore.getUser(source).getUsedCharacter.charIdentifier
    local gang, member = GetPlayerGang(char_id)
    if gang then
        cb({ gang = gang, myRank = member.rank })
    else
        cb(nil)
    end
end)
