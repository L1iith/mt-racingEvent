local QBCore = exports['qb-core']:GetCoreObject()

-- NPC State
local tournamentNPC = nil
local npcSpawned = false
local npcInteraction = nil

-- Spawn Tournament NPC
function SpawnTournamentNPC()
    if npcSpawned then return end
    
    local npcModel = Config.NPC.Model
    local npcCoords = Config.NPC.Location
    
    -- Request model
    RequestModel(npcModel)
    while not HasModelLoaded(npcModel) do
        Wait(10)
    end
    
    -- Create NPC
    tournamentNPC = CreatePed(4, npcModel, npcCoords.x, npcCoords.y, npcCoords.z - 1.0, npcCoords.w, false, true)
    
    -- Configure NPC
    FreezeEntityPosition(tournamentNPC, true)
    SetEntityInvincible(tournamentNPC, true)
    SetBlockingOfNonTemporaryEvents(tournamentNPC, true)
    SetPedDiesWhenInjured(tournamentNPC, false)
    SetPedCanPlayAmbientAnims(tournamentNPC, true)
    SetPedCanRagdollFromPlayerImpact(tournamentNPC, false)
    SetEntityCanBeDamaged(tournamentNPC, false)
    SetPedCanBeTargetted(tournamentNPC, false)
    
    -- Load and play animation
    RequestAnimDict(Config.NPC.Animation.Dict)
    while not HasAnimDictLoaded(Config.NPC.Animation.Dict) do
        Wait(10)
    end
    
    TaskPlayAnim(tournamentNPC, Config.NPC.Animation.Dict, Config.NPC.Animation.Name, 8.0, 8.0, -1, Config.NPC.Animation.Flag, 0, false, false, false)
    
    -- Create interaction using darktrovx/interact
    npcInteraction = exports.interact:AddEntityInteraction({
        entity = tournamentNPC,
        name = 'tournament_npc',
        id = 'tournament_registration',
        distance = Config.NPC.Interaction.Distance,
        interactDst = Config.NPC.Interaction.Distance,
        options = {
            {
                label = Config.NPC.Interaction.Label,
                icon = Config.NPC.Interaction.Icon,
                action = function()
                    exports['racing-tournament']:OpenTournamentNUI()
                end
            }
        }
    })
    
    npcSpawned = true
    
    -- Notification
    if Config.Zone.Debug then
        lib.notify({
            title = _U('tournament_system'),
            description = _U('npc_spawned'),
            type = 'inform',
            duration = Config.Notifications.Duration,
            position = Config.Notifications.Position
        })
    end
    
    print('^2[Racing Tournament]^7 NPC spawned at City Hall')
end

-- Despawn Tournament NPC
function DespawnTournamentNPC()
    if not npcSpawned then return end
    
    -- Remove interaction
    if npcInteraction then
        exports.interact:RemoveEntityInteraction(tournamentNPC, 'tournament_registration')
        npcInteraction = nil
    end
    
    -- Delete NPC
    if DoesEntityExist(tournamentNPC) then
        DeleteEntity(tournamentNPC)
    end
    
    tournamentNPC = nil
    npcSpawned = false
    
    -- Notification
    if Config.Zone.Debug then
        lib.notify({
            title = _U('tournament_system'),
            description = _U('npc_despawned'),
            type = 'inform',
            duration = Config.Notifications.Duration,
            position = Config.Notifications.Position
        })
    end
    
    print('^2[Racing Tournament]^7 NPC despawned from City Hall')
end

-- Check if NPC is spawned
function IsNPCSpawned()
    return npcSpawned and DoesEntityExist(tournamentNPC)
end

-- Get NPC entity
function GetTournamentNPC()
    return tournamentNPC
end

-- NPC Health Check (runs every 30 seconds when spawned)
CreateThread(function()
    while true do
        Wait(30000) -- 30 seconds
        
        if npcSpawned and not DoesEntityExist(tournamentNPC) then
            print('^1[Racing Tournament]^7 NPC entity lost, respawning...')
            npcSpawned = false
            
            -- Respawn if zone is still active
            if exports['racing-tournament']:IsZoneActive() then
                SpawnTournamentNPC()
            end
        end
        
        -- Ensure animation is still playing
        if npcSpawned and DoesEntityExist(tournamentNPC) then
            if not IsEntityPlayingAnim(tournamentNPC, Config.NPC.Animation.Dict, Config.NPC.Animation.Name, 3) then
                TaskPlayAnim(tournamentNPC, Config.NPC.Animation.Dict, Config.NPC.Animation.Name, 8.0, 8.0, -1, Config.NPC.Animation.Flag, 0, false, false, false)
            end
        end
    end
end)

-- Clean up on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        DespawnTournamentNPC()
    end
end)

-- Exports
exports('SpawnTournamentNPC', SpawnTournamentNPC)
exports('DespawnTournamentNPC', DespawnTournamentNPC)
exports('IsNPCSpawned', IsNPCSpawned)
exports('GetTournamentNPC', GetTournamentNPC)