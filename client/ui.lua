-- UI Management for Tournament System
local QBCore = exports['qb-core']:GetCoreObject()

-- UI State
local uiOpen = false
local currentView = 'main'

-- NUI Focus Management
function SetUIFocus(state)
    SetNuiFocus(state, state)
    uiOpen = state
end

-- Send NUI Message
function SendTournamentNUIMessage(data)
    SendNUIMessage(data)
end

-- NUI Callback Handlers
RegisterNUICallback('uiReady', function(data, cb)
    cb('ok')
end)

RegisterNUICallback('playSound', function(data, cb)
    if Config.UI.SoundEffects then
        PlaySoundFrontend(-1, data.sound or 'SELECT', data.soundSet or 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    end
    cb('ok')
end)

RegisterNUICallback('debugLog', function(data, cb)
    if Config.Database.Debug then
        print('^3[Tournament NUI Debug]^7', json.encode(data))
    end
    cb('ok')
end)

RegisterNUICallback('requestNotification', function(data, cb)
    lib.notify({
        title = data.title or _U('tournament_system'),
        description = data.message,
        type = data.type or 'inform',
        duration = data.duration or Config.Notifications.Duration,
        position = Config.Notifications.Position
    })
    cb('ok')
end)

-- View Management
RegisterNUICallback('changeView', function(data, cb)
    currentView = data.view or 'main'
    
    -- Handle view-specific logic
    if currentView == 'tournaments' then
        TriggerServerEvent('tournament:server:getTournaments')
    elseif currentView == 'teams' then
        TriggerServerEvent('tournament:server:getPlayerTeams')
    elseif currentView == 'leaderboards' and data.tournamentId then
        TriggerServerEvent('tournament:server:getLeaderboards', data.tournamentId)
    end
    
    cb('ok')
end)

-- Team Name Validation
RegisterNUICallback('validateTeamName', function(data, cb)
    local isValid = true
    local message = ''
    
    if not data.name or #data.name < Config.Team.NameMinLength then
        isValid = false
        message = 'Team name must be at least ' .. Config.Team.NameMinLength .. ' characters'
    elseif #data.name > Config.Team.NameMaxLength then
        isValid = false
        message = 'Team name must be less than ' .. Config.Team.NameMaxLength .. ' characters'
    elseif string.match(data.name, '[^%w%s%-_]') then
        isValid = false
        message = 'Team name contains invalid characters'
    end
    
    cb({
        valid = isValid,
        message = message
    })
end)

-- Money Format Helper
RegisterNUICallback('formatMoney', function(data, cb)
    local amount = data.amount or 0
    local formatted = '$' .. string.format("%,d", amount):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
    cb(formatted)
end)

-- Player Status Check
RegisterNUICallback('getPlayerStatus', function(data, cb)
    local PlayerData = QBCore.Functions.GetPlayerData()
    
    cb({
        citizenid = PlayerData.citizenid,
        name = PlayerData.charinfo.firstname .. ' ' .. PlayerData.charinfo.lastname,
        money = PlayerData.money,
        job = PlayerData.job,
        gang = PlayerData.gang
    })
end)

-- Configuration Requests
RegisterNUICallback('getConfig', function(data, cb)
    cb({
        tournament = Config.Tournament,
        team = Config.Team,
        ui = Config.UI,
        commands = Config.Commands
    })
end)

-- Time Formatting
RegisterNUICallback('formatTime', function(data, cb)
    local timestamp = data.timestamp
    local formatted = os.date('%Y-%m-%d %H:%M:%S', timestamp)
    cb(formatted)
end)

-- Distance Calculation (for future use)
RegisterNUICallback('calculateDistance', function(data, cb)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local targetCoords = vector3(data.x, data.y, data.z)
    local distance = #(playerCoords - targetCoords)
    
    cb({
        distance = distance,
        inRange = distance <= (data.maxDistance or 100.0)
    })
end)

-- Input Validation Helpers
local function ValidateEmail(email)
    return string.match(email, '^[%w%._%+%-]+@[%w%._%+%-]+%.%a%a+$') ~= nil
end

local function SanitizeInput(input)
    if not input then return '' end
    return string.gsub(input, '[<>"\']', '')
end

RegisterNUICallback('validateInput', function(data, cb)
    local inputType = data.type
    local value = data.value
    local isValid = true
    local message = ''
    
    if inputType == 'teamName' then
        value = SanitizeInput(value)
        if #value < Config.Team.NameMinLength then
            isValid = false
            message = 'Team name too short'
        elseif #value > Config.Team.NameMaxLength then
            isValid = false
            message = 'Team name too long'
        end
    elseif inputType == 'teamTag' then
        value = SanitizeInput(value)
        if #value > Config.Team.TagMaxLength then
            isValid = false
            message = 'Team tag too long'
        end
    elseif inputType == 'color' then
        if not string.match(value, '^#[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]$') then
            isValid = false
            message = 'Invalid color format'
        end
    end
    
    cb({
        valid = isValid,
        message = message,
        sanitized = value
    })
end)

-- Error Handler
RegisterNUICallback('reportError', function(data, cb)
    print('^1[Tournament NUI Error]^7', data.error)
    print('^1[Stack Trace]^7', data.stack or 'No stack trace available')
    cb('ok')
end)

-- Performance Monitoring
local performanceMetrics = {
    viewChanges = 0,
    apiCalls = 0,
    errors = 0,
    startTime = GetGameTimer()
}

RegisterNUICallback('reportMetrics', function(data, cb)
    performanceMetrics.viewChanges = performanceMetrics.viewChanges + (data.viewChanges or 0)
    performanceMetrics.apiCalls = performanceMetrics.apiCalls + (data.apiCalls or 0)
    performanceMetrics.errors = performanceMetrics.errors + (data.errors or 0)
    
    if Config.Database.Debug then
        local uptime = (GetGameTimer() - performanceMetrics.startTime) / 1000
        print('^2[Tournament UI Metrics]^7')
        print('Uptime:', math.floor(uptime), 'seconds')
        print('View Changes:', performanceMetrics.viewChanges)
        print('API Calls:', performanceMetrics.apiCalls)
        print('Errors:', performanceMetrics.errors)
    end
    
    cb('ok')
end)

RegisterNuiCallback("createTournament", function(data, cb)
    lib.print.info(data, cb)
    local created, message = lib.callback.await("mt-racingEvent/server/createTournament", 2000, data)
    cb({
        created, message
    })
end)

-- Utility Functions
function GetCurrentView()
    return currentView
end

function IsUIOpen()
    return uiOpen
end

-- Exports
exports('SetUIFocus', SetUIFocus)
exports('SendTournamentNUIMessage', SendTournamentNUIMessage)
exports('GetCurrentView', GetCurrentView)
exports('IsUIOpen', IsUIOpen)