Config = {}

Config.Debug = false

-- SQL Setup
Config.GangsTable = "vorp_gangs"
Config.MembersTable = "vorp_gang_members"

-- Economy
Config.CreateCost = 150.00 -- Cost to create a gang
Config.InviteDistance = 5.0 -- Distance to invite players

-- Ranks (Ordered from highest to lowest)
-- Permissions: manage_ranks, manage_funds, invite, kick, delete_gang
Config.Ranks = {
    [5] = { name = "Leader", permissions = { "manage_ranks", "manage_funds", "invite", "kick", "delete_gang" } },
    [4] = { name = "Co-Leader", permissions = { "manage_ranks", "manage_funds", "invite", "kick" } },
    [3] = { name = "Enforcer", permissions = { "invite", "kick" } },
    [2] = { name = "Member", permissions = {} },
    [1] = { name = "Prospect", permissions = {} },
}

-- Keys
Config.OpenMenuKey = "O" -- Key to open gang menu

-- Webhooks
Config.Webhooks = {
    enabled = false,
    url = "YOUR_DISCORD_WEBHOOK_HERE"
}

-- Locales
Config.Locales = {
    ['create_gang'] = "Create Gang",
    ['not_enough_money'] = "You don't have enough money ($%s required)",
    ['gang_created'] = "Gang '%s' has been created!",
    ['already_in_gang'] = "You are already in a gang.",
    ['invited'] = "You have invited %s to join the gang.",
    ['promotion_success'] = "You promoted %s to %s.",
}
