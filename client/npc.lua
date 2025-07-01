local QBCore = exports['qb-core']:GetCoreObject()

-- State
local tournamentZone
local tournamentNPC = nil
local npcSpawned = false
local npcInteraction = nil

function InitZone()
    tournamentZone = lib.zones.sphere({
        coords = Config.NPC.Location.xyz,
        radius = Config.Zone.Radius,
        debug = Config.Zone.Debug,
        onEnter = function()
            if npcSpawned or tournamentNPC then
                DespawnTournamentNPC()
            end
            SpawnTournamentNPC()
        end,
        
        onExit = function()
            if npcSpawned or tournamentNPC then
                DespawnTournamentNPC()
            end
        end
    })    
end

-- Spawn Tournament NPC
function SpawnTournamentNPC()
    if npcSpawned then return end
    
    local npcModel = Config.NPC.Model
    local npcCoords = Config.NPC.Location
    
    lib.requestModel(npcModel)
    
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
                   OpenTournamentNUI()
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
    while not LocalPlayer.state.isLoggedIn do
        Wait(500) -- 30 seconds
    end
    InitZone()
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