local QBCore = exports['qb-core']:GetCoreObject()

-- Tournament Business Logic
local TournamentCallbacks = {}

-- Get Active Tournaments
function TournamentCallbacks.GetActiveTournaments()
    local tournaments = exports['racing-tournament']:GetTournaments('registration')
    local activeTournaments = exports['racing-tournament']:GetTournaments('active')
    
    for _, tournament in pairs(activeTournaments) do
        table.insert(tournaments, tournament)
    end
    
    return tournaments
end

-- Register Team
function TournamentCallbacks.RegisterTeam(citizenId, tournamentId, teamData)
    -- Validate tournament exists and is open for registration
    local tournament = exports['racing-tournament']:GetTournamentById(tournamentId)
    if not tournament then
        return false, _U('error_tournament_not_found')
    end
    
    if tournament.status ~= 'registration' then
        return false, _U('error_registration_closed')
    end
    
    if tournament.current_teams >= tournament.max_teams then
        return false, _U('info_tournament_full')
    end
    
    -- Check if player is already in a team for this tournament
    local existingMembership = exports['racing-tournament']:GetPlayerTeamMembership(citizenId, tournamentId)
    if existingMembership then
        return false, _U('error_player_already_in_team')
    end
    
    -- Validate team name
    if not teamData.name or #teamData.name < Config.Team.NameMinLength or #teamData.name > Config.Team.NameMaxLength then
        return false, _U('error_team_name_invalid')
    end
    
    -- Check if team name is already taken
    if exports['racing-tournament']:CheckTeamNameExists(tournamentId, teamData.name) then
        return false, _U('error_team_name_taken')
    end
    
    -- Get player data
    local Player = QBCore.Functions.GetPlayerByCitizenId(citizenId)
    if not Player then
        return false, _U('error_player_not_found')
    end
    
    -- Check if player has enough money
    if Player.PlayerData.money.cash < tournament.registration_fee then
        return false, _U('error_insufficient_funds')
    end
    
    -- Create team
    teamData.captain_cid = citizenId
    local teamId = exports['racing-tournament']:CreateTeam(tournamentId, teamData)
    
    if not teamId then
        return false, _U('error_database')
    end
    
    -- Add captain as team member
    local playerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    local memberAdded = exports['racing-tournament']:AddTeamMember(teamId, citizenId, playerName, 'captain')
    
    if not memberAdded then
        -- Rollback team creation
        exports['racing-tournament']:DeleteTeam(teamId)
        return false, _U('error_database')
    end
    
    -- Deduct registration fee
    Player.Functions.RemoveMoney('cash', tournament.registration_fee, 'tournament-registration')
    
    -- Update team registration fee status
    exports['racing-tournament']:UpdateTeam(teamId, {registration_fee_paid = 1})
    
    -- Update tournament prize pool
    local newPrizePool = tournament.prize_pool + tournament.registration_fee
    exports['racing-tournament']:UpdateTournament(tournamentId, {prize_pool = newPrizePool})
    
    return true, {
        teamId = teamId,
        tournamentName = tournament.name,
        registrationFee = tournament.registration_fee
    }
end

-- Update Team
function TournamentCallbacks.UpdateTeam(citizenId, teamId, updateData)
    -- Check if player is team captain
    if not exports['racing-tournament']:IsTeamCaptain(teamId, citizenId) then
        return false, _U('error_not_team_captain')
    end
    
    local team = exports['racing-tournament']:GetTeamById(teamId)
    if not team then
        return false, _U('error_team_not_found')
    end
    
    -- Validate team name if being updated
    if updateData.team_name then
        if #updateData.team_name < Config.Team.NameMinLength or #updateData.team_name > Config.Team.NameMaxLength then
            return false, _U('error_team_name_invalid')
        end
        
        -- Check if new name is already taken (excluding current team)
        local existingTeam = exports['racing-tournament']:CheckTeamNameExists(team.tournament_id, updateData.team_name)
        if existingTeam and existingTeam ~= teamId then
            return false, _U('error_team_name_taken')
        end
    end
    
    local success = exports['racing-tournament']:UpdateTeam(teamId, updateData)
    
    if success then
        return true, {teamId = teamId, updateData = updateData}
    else
        return false, _U('error_database')
    end
end

-- Leave Team
function TournamentCallbacks.LeaveTeam(citizenId, teamId)
    local team = exports['racing-tournament']:GetTeamById(teamId)
    if not team then
        return false, _U('error_team_not_found')
    end
    
    -- Check if player is team captain
    if team.captain_cid == citizenId then
        local members = exports['racing-tournament']:GetTeamMembers(teamId)
        if #members > 1 then
            return false, _U('error_cannot_leave_as_captain')
        end
    end
    
    local success = exports['racing-tournament']:RemoveTeamMember(teamId, citizenId)
    
    if success then
        -- If captain left and was the only member, delete the team
        if team.captain_cid == citizenId then
            exports['racing-tournament']:DeleteTeam(teamId)
        end
        
        return true, {teamId = teamId}
    else
        return false, _U('error_database')
    end
end

-- Disband Team
function TournamentCallbacks.DisbandTeam(citizenId, teamId)
    -- Check if player is team captain
    if not exports['racing-tournament']:IsTeamCaptain(teamId, citizenId) then
        return false, _U('error_not_team_captain')
    end
    
    local success = exports['racing-tournament']:DeleteTeam(teamId)
    
    if success then
        return true, {teamId = teamId}
    else
        return false, _U('error_database')
    end
end

-- Add Team Member
function TournamentCallbacks.AddTeamMember(captainId, teamId, targetCitizenId, role)
    -- Check if player is team captain
    if not exports['racing-tournament']:IsTeamCaptain(teamId, captainId) then
        return false, _U('error_not_team_captain')
    end
    
    local team = exports['racing-tournament']:GetTeamById(teamId)
    if not team then
        return false, _U('error_team_not_found')
    end
    
    -- Check if target player exists
    local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(targetCitizenId)
    if not targetPlayer then
        return false, _U('error_player_not_found')
    end
    
    -- Check if target player is already in a team for this tournament
    local existingMembership = exports['racing-tournament']:GetPlayerTeamMembership(targetCitizenId, team.tournament_id)
    if existingMembership then
        return false, _U('error_player_already_in_team')
    end
    
    -- Check if team is full
    local members = exports['racing-tournament']:GetTeamMembers(teamId)
    if #members >= Config.Tournament.MaxTeamSize then
        return false, _U('error_team_full')
    end
    
    -- Validate role
    local validRole = false
    for _, validRoleOption in pairs(Config.Tournament.TeamRoles) do
        if role == validRoleOption then
            validRole = true
            break
        end
    end
    
    if not validRole then
        return false, _U('error_invalid_role')
    end
    
    local playerName = targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname
    local success = exports['racing-tournament']:AddTeamMember(teamId, targetCitizenId, playerName, role)
    
    if success then
        return true, {
            teamId = teamId,
            playerId = targetCitizenId,
            playerName = playerName,
            role = role
        }
    else
        return false, _U('error_database')
    end
end

-- Remove Team Member
function TournamentCallbacks.RemoveTeamMember(captainId, teamId, targetCitizenId)
    -- Check if player is team captain
    if not exports['racing-tournament']:IsTeamCaptain(teamId, captainId) then
        return false, _U('error_not_team_captain')
    end
    
    -- Cannot remove captain
    if captainId == targetCitizenId then
        return false, _U('error_cannot_remove_captain')
    end
    
    local success = exports['racing-tournament']:RemoveTeamMember(teamId, targetCitizenId)
    
    if success then
        return true, {teamId = teamId, playerId = targetCitizenId}
    else
        return false, _U('error_database')
    end
end

-- Change Player Role
function TournamentCallbacks.ChangePlayerRole(captainId, teamId, targetCitizenId, newRole)
    -- Check if player is team captain
    if not exports['racing-tournament']:IsTeamCaptain(teamId, captainId) then
        return false, _U('error_not_team_captain')
    end
    
    -- Cannot change captain role
    if captainId == targetCitizenId and newRole ~= 'captain' then
        return false, _U('error_cannot_change_captain_role')
    end
    
    -- Validate role
    local validRole = false
    for _, validRoleOption in pairs(Config.Tournament.TeamRoles) do
        if newRole == validRoleOption then
            validRole = true
            break
        end
    end
    
    if not validRole then
        return false, _U('error_invalid_role')
    end
    
    local success = exports['racing-tournament']:UpdateTeamMemberRole(teamId, targetCitizenId, newRole)
    
    if success then
        return true, {
            teamId = teamId,
            playerId = targetCitizenId,
            newRole = newRole
        }
    else
        return false, _U('error_database')
    end
end

-- Get Player Teams
function TournamentCallbacks.GetPlayerTeams(citizenId)
    return exports['racing-tournament']:GetPlayerTeams(citizenId)
end

-- Get Leaderboards
function TournamentCallbacks.GetLeaderboards(tournamentId)
    local leaderboard = exports['racing-tournament']:GetTournamentLeaderboard(tournamentId)
    
    -- Add member details to each team
    for i, team in pairs(leaderboard) do
        local members = exports['racing-tournament']:GetTeamMembers(team.id)
        leaderboard[i].members = members
    end
    
    return leaderboard
end

-- Search Players
function TournamentCallbacks.SearchPlayers(searchTerm)
    if not searchTerm or #searchTerm < 2 then
        return {}
    end
    
    return exports['racing-tournament']:SearchPlayers(searchTerm, 10)
end

-- Create Tournament (Admin)
function TournamentCallbacks.CreateTournament(tournamentName, creatorId)
    if not tournamentName or #tournamentName < 3 then
        return false, 'Tournament name must be at least 3 characters long'
    end
    
    local tournamentData = {
        name = tournamentName,
        start_date = os.date('%Y-%m-%d %H:%M:%S', os.time() + 3600), -- Start in 1 hour
        max_teams = Config.Tournament.MaxTeamsPerTournament,
        registration_fee = Config.Tournament.DefaultRegistrationFee,
        tournament_type = 'single_elimination',
        description = 'Tournament created by administrator'
    }
    
    local tournamentId = exports['racing-tournament']:CreateTournament(tournamentData)
    
    if tournamentId then
        return true, {
            tournamentId = tournamentId,
            tournamentName = tournamentName
        }
    else
        return false, _U('error_database')
    end
end

-- Export Callback Functions
exports('GetActiveTournaments', TournamentCallbacks.GetActiveTournaments)
exports('RegisterTeam', TournamentCallbacks.RegisterTeam)
exports('UpdateTeam', TournamentCallbacks.UpdateTeam)
exports('LeaveTeam', TournamentCallbacks.LeaveTeam)
exports('DisbandTeam', TournamentCallbacks.DisbandTeam)
exports('AddTeamMember', TournamentCallbacks.AddTeamMember)
exports('RemoveTeamMember', TournamentCallbacks.RemoveTeamMember)
exports('ChangePlayerRole', TournamentCallbacks.ChangePlayerRole)
exports('GetPlayerTeams', TournamentCallbacks.GetPlayerTeams)
exports('GetLeaderboards', TournamentCallbacks.GetLeaderboards)
exports('SearchPlayers', TournamentCallbacks.SearchPlayers)
exports('CreateTournament', TournamentCallbacks.CreateTournament)

return TournamentCallbacks