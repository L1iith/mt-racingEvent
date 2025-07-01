local QBCore = exports['qb-core']:GetCoreObject()

-- Tournament Management
RegisterNetEvent('tournament:server:getTournaments', function()
    local src = source
    local tournaments = exports['racing-tournament']:GetActiveTournaments()
    TriggerClientEvent('tournament:client:receiveTournaments', src, tournaments)
end)

RegisterNetEvent('tournament:server:registerTeam', function(tournamentId, teamData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = _U('error_player_not_found')
        })
        return
    end

    local success, message = exports['racing-tournament']:RegisterTeam(Player.PlayerData.citizenid, tournamentId, teamData)
    
    if success then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'success',
            description = _U('success_team_registered')
        })
        TriggerClientEvent('tournament:client:teamRegistered', src, message)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = message
        })
    end
end)

RegisterNetEvent('tournament:server:getPlayerTeams', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local teams = exports['racing-tournament']:GetPlayerTeams(Player.PlayerData.citizenid)
    TriggerClientEvent('tournament:client:receivePlayerTeams', src, teams)
end)

RegisterNetEvent('tournament:server:updateTeam', function(teamId, updateData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local success, message = exports['racing-tournament']:UpdateTeam(Player.PlayerData.citizenid, teamId, updateData)
    
    if success then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'success',
            description = _U('success_team_updated')
        })
        TriggerClientEvent('tournament:client:teamUpdated', src, message)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = message
        })
    end
end)

RegisterNetEvent('tournament:server:leaveTeam', function(teamId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local success, message = exports['racing-tournament']:LeaveTeam(Player.PlayerData.citizenid, teamId)
    
    if success then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'success',
            description = _U('success_left_team')
        })
        TriggerClientEvent('tournament:client:leftTeam', src)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = message
        })
    end
end)

RegisterNetEvent('tournament:server:disbandTeam', function(teamId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local success, message = exports['racing-tournament']:DisbandTeam(Player.PlayerData.citizenid, teamId)
    
    if success then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'success',
            description = _U('success_team_disbanded')
        })
        TriggerClientEvent('tournament:client:teamDisbanded', src)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = message
        })
    end
end)

RegisterNetEvent('tournament:server:addTeamMember', function(teamId, targetCitizenId, role)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local success, message = exports['racing-tournament']:AddTeamMember(Player.PlayerData.citizenid, teamId, targetCitizenId, role)
    
    if success then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'success',
            description = _U('success_player_added')
        })
        TriggerClientEvent('tournament:client:memberAdded', src, message)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = message
        })
    end
end)

RegisterNetEvent('tournament:server:removeTeamMember', function(teamId, targetCitizenId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local success, message = exports['racing-tournament']:RemoveTeamMember(Player.PlayerData.citizenid, teamId, targetCitizenId)
    
    if success then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'success',
            description = _U('success_player_removed')
        })
        TriggerClientEvent('tournament:client:memberRemoved', src, message)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = message
        })
    end
end)

RegisterNetEvent('tournament:server:changePlayerRole', function(teamId, targetCitizenId, newRole)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local success, message = exports['racing-tournament']:ChangePlayerRole(Player.PlayerData.citizenid, teamId, targetCitizenId, newRole)
    
    if success then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'success',
            description = _U('success_role_changed')
        })
        TriggerClientEvent('tournament:client:roleChanged', src, message)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = message
        })
    end
end)

RegisterNetEvent('tournament:server:getLeaderboards', function(tournamentId)
    local src = source
    local leaderboards = exports['racing-tournament']:GetLeaderboards(tournamentId)
    TriggerClientEvent('tournament:client:receiveLeaderboards', src, leaderboards)
end)

RegisterNetEvent('tournament:server:searchPlayers', function(searchTerm)
    local src = source
    local players = exports['racing-tournament']:SearchPlayers(searchTerm)
    TriggerClientEvent('tournament:client:receivePlayerSearch', src, players)
end)

-- Admin Commands
RegisterCommand(Config.Commands.AdminPanel, function(source, args, rawCommand)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    if not QBCore.Functions.HasPermission(src, Config.Permissions.AdminCommands) then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = _U('error_permission_denied')
        })
        return
    end
    
    TriggerClientEvent('tournament:client:openAdminPanel', src)
end, false)

RegisterCommand(Config.Commands.PlayerPanel, function(source, args, rawCommand)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    TriggerClientEvent('tournament:client:openPlayerPanel', src)
end, false)

RegisterCommand(Config.Commands.CreateTournament, function(source, args, rawCommand)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    if not QBCore.Functions.HasPermission(src, Config.Permissions.AdminCommands) then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = _U('error_permission_denied')
        })
        return
    end
    
    if not args[1] then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'Usage: /' .. Config.Commands.CreateTournament .. ' [tournament_name]'
        })
        return
    end
    
    local tournamentName = table.concat(args, ' ')
    local success, message = exports['racing-tournament']:CreateTournament(tournamentName, Player.PlayerData.citizenid)
    
    if success then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'success',
            description = _U('success_tournament_created')
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = message
        })
    end
end, false)

-- Player Connection Events
RegisterNetEvent('QBCore:Server:PlayerLoaded', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        -- Send player their tournament data
        local teams = exports['racing-tournament']:GetPlayerTeams(Player.PlayerData.citizenid)
        TriggerClientEvent('tournament:client:receivePlayerTeams', src, teams)
    end
end)

-- Export Functions
exports('GetActiveTournaments', function()
    return exports['racing-tournament']:GetActiveTournaments()
end)

exports('GetPlayerTeams', function(citizenId)
    return exports['racing-tournament']:GetPlayerTeams(citizenId)
end)

exports('RegisterTeam', function(citizenId, tournamentId, teamData)
    return exports['racing-tournament']:RegisterTeam(citizenId, tournamentId, teamData)
end)

-- Resource Events
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print('^2[Racing Tournament]^7 Resource started successfully')
        -- Initialize database tables if needed
        exports['racing-tournament']:InitializeDatabase()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print('^2[Racing Tournament]^7 Resource stopped')
    end
end)