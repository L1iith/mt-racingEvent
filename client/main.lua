local QBCore = exports['qb-core']:GetCoreObject()

-- Client State
local PlayerData = {}
local isLoggedIn = false
local isNearNPC = false
local tournamentNUI = false

-- Player Events
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    isLoggedIn = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    isLoggedIn = false
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

-- Tournament Events
RegisterNetEvent('tournament:client:receiveTournaments', function(tournaments)
    SendNUIMessage({
        type = 'updateTournaments',
        data = tournaments
    })
end)

RegisterNetEvent('tournament:client:teamRegistered', function(data)
    SendNUIMessage({
        type = 'teamRegistered',
        data = data
    })
end)

RegisterNetEvent('tournament:client:receivePlayerTeams', function(teams)
    SendNUIMessage({
        type = 'updatePlayerTeams',
        data = teams
    })
end)

RegisterNetEvent('tournament:client:teamUpdated', function(data)
    SendNUIMessage({
        type = 'teamUpdated',
        data = data
    })
end)

RegisterNetEvent('tournament:client:leftTeam', function()
    SendNUIMessage({
        type = 'leftTeam'
    })
    -- Refresh player teams
    TriggerServerEvent('tournament:server:getPlayerTeams')
end)

RegisterNetEvent('tournament:client:teamDisbanded', function()
    SendNUIMessage({
        type = 'teamDisbanded'
    })
    -- Refresh player teams
    TriggerServerEvent('tournament:server:getPlayerTeams')
end)

RegisterNetEvent('tournament:client:memberAdded', function(data)
    SendNUIMessage({
        type = 'memberAdded',
        data = data
    })
end)

RegisterNetEvent('tournament:client:memberRemoved', function(data)
    SendNUIMessage({
        type = 'memberRemoved',
        data = data
    })
end)

RegisterNetEvent('tournament:client:roleChanged', function(data)
    SendNUIMessage({
        type = 'roleChanged',
        data = data
    })
end)

RegisterNetEvent('tournament:client:receiveLeaderboards', function(leaderboards)
    SendNUIMessage({
        type = 'updateLeaderboards',
        data = leaderboards
    })
end)

RegisterNetEvent('tournament:client:receivePlayerSearch', function(players)
    SendNUIMessage({
        type = 'updatePlayerSearch',
        data = players
    })
end)

RegisterNetEvent('tournament:client:openPlayerPanel', function()
    OpenTournamentNUI()
end)

RegisterNetEvent('tournament:client:openAdminPanel', function()
    OpenTournamentNUI(true)
end)

-- NUI Functions
function OpenTournamentNUI(isAdmin)
    if not isLoggedIn then return end
    
    tournamentNUI = true
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        type = 'openTournament',
        data = {
            isAdmin = isAdmin or false,
            playerData = {
                citizenid = PlayerData.citizenid,
                name = PlayerData.charinfo.firstname .. ' ' .. PlayerData.charinfo.lastname,
                money = PlayerData.money
            }
        }
    })
    
    -- Get initial data
    TriggerServerEvent('tournament:server:getTournaments')
    TriggerServerEvent('tournament:server:getPlayerTeams')
end

function CloseTournamentNUI()
    tournamentNUI = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 'closeTournament'
    })
end

-- NUI Callbacks
RegisterNUICallback('closeTournament', function(data, cb)
    CloseTournamentNUI()
    cb('ok')
end)

RegisterNUICallback('getTournaments', function(data, cb)
    TriggerServerEvent('tournament:server:getTournaments')
    cb('ok')
end)

RegisterNUICallback('registerTeam', function(data, cb)
    TriggerServerEvent('tournament:server:registerTeam', data.tournamentId, data.teamData)
    cb('ok')
end)

RegisterNUICallback('getPlayerTeams', function(data, cb)
    TriggerServerEvent('tournament:server:getPlayerTeams')
    cb('ok')
end)

RegisterNUICallback('updateTeam', function(data, cb)
    TriggerServerEvent('tournament:server:updateTeam', data.teamId, data.updateData)
    cb('ok')
end)

RegisterNUICallback('leaveTeam', function(data, cb)
    TriggerServerEvent('tournament:server:leaveTeam', data.teamId)
    cb('ok')
end)

RegisterNUICallback('disbandTeam', function(data, cb)
    TriggerServerEvent('tournament:server:disbandTeam', data.teamId)
    cb('ok')
end)

RegisterNUICallback('addTeamMember', function(data, cb)
    TriggerServerEvent('tournament:server:addTeamMember', data.teamId, data.citizenId, data.role)
    cb('ok')
end)

RegisterNUICallback('removeTeamMember', function(data, cb)
    TriggerServerEvent('tournament:server:removeTeamMember', data.teamId, data.citizenId)
    cb('ok')
end)

RegisterNUICallback('changePlayerRole', function(data, cb)
    TriggerServerEvent('tournament:server:changePlayerRole', data.teamId, data.citizenId, data.newRole)
    cb('ok')
end)

RegisterNUICallback('getLeaderboards', function(data, cb)
    TriggerServerEvent('tournament:server:getLeaderboards', data.tournamentId)
    cb('ok')
end)

RegisterNUICallback('searchPlayers', function(data, cb)
    TriggerServerEvent('tournament:server:searchPlayers', data.searchTerm)
    cb('ok')
end)

-- Key Mapping
RegisterKeyMapping(Config.Commands.PlayerPanel, 'Open Tournament Panel', 'keyboard', 'F7')

-- Exports
exports('OpenTournamentNUI', OpenTournamentNUI)
exports('CloseTournamentNUI', CloseTournamentNUI)
exports('IsNearNPC', function() return isNearNPC end)
exports('SetNearNPC', function(state) isNearNPC = state end)

-- Threads
CreateThread(function ()
    while not LocalPlayer.state.isLoggedIn do
        Wait(500)
        print("not isLoggedIn")
    end
    print("loaded")
    isLoggedIn = true
    PlayerData = QBCore.Functions.GetPlayerData()
end)