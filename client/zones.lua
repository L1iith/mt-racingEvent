local QBCore = exports['qb-core']:GetCoreObject()

-- Zone state
local inZone = false
local zoneActive = false
local playersInZone = {}

-- Create Tournament Zone
local tournamentZone = lib.zones.sphere({
    coords = Config.Zone.Location,
    radius = Config.Zone.Radius,
    debug = Config.Zone.Debug,
    onEnter = function()
        if not zoneActive then
            zoneActive = true
            exports['racing-tournament']:SpawnTournamentNPC()
            
            if Config.Zone.Debug then
                print('^2[Racing Tournament]^7 Player entered tournament zone')
            end
        end
        
        inZone = true
        exports['racing-tournament']:SetNearNPC(true)
        
        -- Add player to zone tracking
        local playerId = PlayerId()
        playersInZone[playerId] = true
    end,
    
    onExit = function()
        inZone = false
        exports['racing-tournament']:SetNearNPC(false)
        
        -- Remove player from zone tracking
        local playerId = PlayerId()
        playersInZone[playerId] = nil
        
        -- Check if any players are still in zone
        CreateThread(function()
            Wait(1000) -- Small delay to ensure proper cleanup
            
            local anyPlayersInZone = false
            for _ in pairs(playersInZone) do
                anyPlayersInZone = true
                break
            end
            
            if not anyPlayersInZone and zoneActive then
                zoneActive = false
                exports['racing-tournament']:DespawnTournamentNPC()
                
                if Config.Zone.Debug then
                    print('^2[Racing Tournament]^7 All players left tournament zone')
                end
            end
        end)
    end
})

-- Zone utility functions
function IsInTournamentZone()
    return inZone
end

function IsZoneActive()
    return zoneActive
end

function GetPlayersInZone()
    local count = 0
    for _ in pairs(playersInZone) do
        count = count + 1
    end
    return count
end

-- Clean up on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if zoneActive then
            exports['racing-tournament']:DespawnTournamentNPC()
        end
        
        if tournamentZone then
            tournamentZone:remove()
        end
    end
end)

-- Player disconnect cleanup
AddEventHandler('playerDropped', function(playerId)
    if playersInZone[playerId] then
        playersInZone[playerId] = nil
        
        -- Check if zone should be deactivated
        CreateThread(function()
            Wait(1000)
            
            local anyPlayersInZone = false
            for _ in pairs(playersInZone) do
                anyPlayersInZone = true
                break
            end
            
            if not anyPlayersInZone and zoneActive then
                zoneActive = false
                exports['racing-tournament']:DespawnTournamentNPC()
                
                if Config.Zone.Debug then
                    print('^2[Racing Tournament]^7 Zone deactivated - no players remaining')
                end
            end
        end)
    end
end)

-- Exports
exports('IsInTournamentZone', IsInTournamentZone)
exports('IsZoneActive', IsZoneActive)
exports('GetPlayersInZone', GetPlayersInZone)