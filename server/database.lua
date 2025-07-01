local QBCore = exports['qb-core']:GetCoreObject()

local Database = {}

-- Initialize Database
function Database.Initialize()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `tournaments` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `name` VARCHAR(255) NOT NULL,
            `status` ENUM('registration', 'active', 'completed', 'cancelled') DEFAULT 'registration',
            `start_date` DATETIME NOT NULL,
            `end_date` DATETIME NULL,
            `max_teams` INT(11) NOT NULL DEFAULT 16,
            `current_teams` INT(11) NOT NULL DEFAULT 0,
            `registration_fee` INT(11) NOT NULL DEFAULT 5000,
            `prize_pool` INT(11) NOT NULL DEFAULT 0,
            `tournament_type` ENUM('single_elimination', 'double_elimination', 'round_robin') DEFAULT 'single_elimination',
            `description` TEXT NULL,
            `rules` TEXT NULL,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            INDEX `idx_status` (`status`),
            INDEX `idx_start_date` (`start_date`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])
    
    if Config.Database.Debug then
        print('^2[Racing Tournament]^7 Database tables initialized')
    end
end

-- Tournament Functions
function Database.GetTournaments(status)
    local result = MySQL.query.await('SELECT * FROM tournaments WHERE status = ? ORDER BY start_date ASC', {status or 'registration'})
    return result or {}
end

function Database.GetTournamentById(tournamentId)
    local result = MySQL.query.await('SELECT * FROM tournaments WHERE id = ?', {tournamentId})
    return result and result[1] or nil
end

function Database.CreateTournament(data)
    local result = MySQL.insert.await([[
        INSERT INTO tournaments (name, start_date, max_teams, registration_fee, prize_pool, tournament_type, description, rules)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        data.name,
        data.start_date,
        data.max_teams or Config.Tournament.MaxTeamsPerTournament,
        data.registration_fee or Config.Tournament.DefaultRegistrationFee,
        data.prize_pool or 0,
        data.tournament_type or 'single_elimination',
        data.description or '',
        data.rules or ''
    })
    
    return result
end

function Database.UpdateTournament(tournamentId, data)
    local setClause = {}
    local values = {}
    
    for key, value in pairs(data) do
        table.insert(setClause, key .. ' = ?')
        table.insert(values, value)
    end
    
    table.insert(values, tournamentId)
    
    local result = MySQL.update.await('UPDATE tournaments SET ' .. table.concat(setClause, ', ') .. ' WHERE id = ?', values)
    return result
end

-- Team Functions
function Database.CreateTeam(tournamentId, teamData)
    local result = MySQL.insert.await([[
        INSERT INTO teams (tournament_id, team_name, captain_cid, team_tag, team_color)
        VALUES (?, ?, ?, ?, ?)
    ]], {
        tournamentId,
        teamData.name,
        teamData.captain_cid,
        teamData.tag or '',
        teamData.color or Config.Team.DefaultColor
    })
    
    if result then
        -- Update tournament team count
        MySQL.update.await('UPDATE tournaments SET current_teams = current_teams + 1 WHERE id = ?', {tournamentId})
    end
    
    return result
end

function Database.GetTeamById(teamId)
    local result = MySQL.query.await('SELECT * FROM teams WHERE id = ?', {teamId})
    return result and result[1] or nil
end

function Database.GetTeamsByTournament(tournamentId)
    local result = MySQL.query.await('SELECT * FROM teams WHERE tournament_id = ? ORDER BY total_points DESC, wins DESC', {tournamentId})
    return result or {}
end

function Database.GetPlayerTeams(citizenId)
    local result = MySQL.query.await([[
        SELECT t.*, tm.role, tm.status as member_status, tour.name as tournament_name, tour.status as tournament_status
        FROM teams t
        JOIN team_members tm ON t.id = tm.team_id
        JOIN tournaments tour ON t.tournament_id = tour.id
        WHERE tm.citizen_id = ? AND tm.status = 'active'
        ORDER BY tour.start_date DESC
    ]], {citizenId})
    
    return result or {}
end

function Database.UpdateTeam(teamId, data)
    local setClause = {}
    local values = {}
    
    for key, value in pairs(data) do
        table.insert(setClause, key .. ' = ?')
        table.insert(values, value)
    end
    
    table.insert(values, teamId)
    
    local result = MySQL.update.await('UPDATE teams SET ' .. table.concat(setClause, ', ') .. ' WHERE id = ?', values)
    return result
end

function Database.DeleteTeam(teamId)
    local team = Database.GetTeamById(teamId)
    if not team then return false end
    
    local result = MySQL.update.await('DELETE FROM teams WHERE id = ?', {teamId})
    
    if result then
        -- Update tournament team count
        MySQL.update.await('UPDATE tournaments SET current_teams = current_teams - 1 WHERE id = ?', {team.tournament_id})
    end
    
    return result
end

function Database.CheckTeamNameExists(tournamentId, teamName)
    local result = MySQL.query.await('SELECT id FROM teams WHERE tournament_id = ? AND team_name = ?', {tournamentId, teamName})
    return result and #result > 0
end

-- Team Member Functions
function Database.AddTeamMember(teamId, citizenId, playerName, role)
    local result = MySQL.insert.await([[
        INSERT INTO team_members (team_id, citizen_id, player_name, role)
        VALUES (?, ?, ?, ?)
    ]], {teamId, citizenId, playerName, role})
    
    return result
end

function Database.GetTeamMembers(teamId)
    local result = MySQL.query.await('SELECT * FROM team_members WHERE team_id = ? AND status = "active"', {teamId})
    return result or {}
end

function Database.RemoveTeamMember(teamId, citizenId)
    local result = MySQL.update.await('UPDATE team_members SET status = "kicked", left_date = NOW() WHERE team_id = ? AND citizen_id = ?', {teamId, citizenId})
    return result
end

function Database.UpdateTeamMemberRole(teamId, citizenId, newRole)
    local result = MySQL.update.await('UPDATE team_members SET role = ? WHERE team_id = ? AND citizen_id = ?', {newRole, teamId, citizenId})
    return result
end

function Database.GetPlayerTeamMembership(citizenId, tournamentId)
    local result = MySQL.query.await([[
        SELECT tm.*, t.tournament_id
        FROM team_members tm
        JOIN teams t ON tm.team_id = t.id
        WHERE tm.citizen_id = ? AND t.tournament_id = ? AND tm.status = 'active'
    ]], {citizenId, tournamentId})
    
    return result and result[1] or nil
end

function Database.IsTeamCaptain(teamId, citizenId)
    local result = MySQL.query.await('SELECT id FROM teams WHERE id = ? AND captain_cid = ?', {teamId, citizenId})
    return result and #result > 0
end

function Database.TransferCaptaincy(teamId, oldCaptainId, newCaptainId)
    local success = true
    
    -- Update team captain
    local result1 = MySQL.update.await('UPDATE teams SET captain_cid = ? WHERE id = ? AND captain_cid = ?', {newCaptainId, teamId, oldCaptainId})
    if not result1 then success = false end
    
    -- Update old captain role
    local result2 = MySQL.update.await('UPDATE team_members SET role = "driver" WHERE team_id = ? AND citizen_id = ?', {teamId, oldCaptainId})
    if not result2 then success = false end
    
    -- Update new captain role
    local result3 = MySQL.update.await('UPDATE team_members SET role = "captain" WHERE team_id = ? AND citizen_id = ?', {teamId, newCaptainId})
    if not result3 then success = false end
    
    return success
end

-- Leaderboard Functions
function Database.GetTournamentLeaderboard(tournamentId)
    local result = MySQL.query.await([[
        SELECT t.*, 
               COUNT(tm.id) as member_count,
               tour.name as tournament_name
        FROM teams t
        LEFT JOIN team_members tm ON t.id = tm.team_id AND tm.status = 'active'
        JOIN tournaments tour ON t.tournament_id = tour.id
        WHERE t.tournament_id = ?
        GROUP BY t.id
        ORDER BY t.total_points DESC, t.wins DESC, t.team_name ASC
    ]], {tournamentId})
    
    return result or {}
end

function Database.GetPlayerStats(citizenId, tournamentId)
    local result = MySQL.query.await([[
        SELECT tm.*, t.team_name, t.total_points, t.wins, t.losses
        FROM team_members tm
        JOIN teams t ON tm.team_id = t.id
        WHERE tm.citizen_id = ? AND t.tournament_id = ? AND tm.status = 'active'
    ]], {citizenId, tournamentId})
    
    return result and result[1] or nil
end

-- Search Functions
function Database.SearchPlayers(searchTerm, limit)
    local result = MySQL.query.await([[
        SELECT citizenid, JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname')) as firstname,
               JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname')) as lastname
        FROM players 
        WHERE JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname')) LIKE ? 
           OR JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname')) LIKE ?
        LIMIT ?
    ]], {'%' .. searchTerm .. '%', '%' .. searchTerm .. '%', limit or 10})
    
    return result or {}
end

-- Bracket Functions (for future race implementation)
function Database.CreateBracket(tournamentId, roundNumber, matchNumber, team1Id, team2Id)
    local result = MySQL.insert.await([[
        INSERT INTO tournament_brackets (tournament_id, round_number, match_number, team1_id, team2_id)
        VALUES (?, ?, ?, ?, ?)
    ]], {tournamentId, roundNumber, matchNumber, team1Id, team2Id})
    
    return result
end

function Database.GetTournamentBrackets(tournamentId)
    local result = MySQL.query.await('SELECT * FROM tournament_brackets WHERE tournament_id = ? ORDER BY round_number ASC, match_number ASC', {tournamentId})
    return result or {}
end

function Database.UpdateBracketResult(bracketId, winnerId, loserId, team1Score, team2Score)
    local result = MySQL.update.await([[
        UPDATE tournament_brackets 
        SET winner_id = ?, loser_id = ?, team1_score = ?, team2_score = ?, match_status = 'completed', completed_time = NOW()
        WHERE id = ?
    ]], {winnerId, loserId, team1Score, team2Score, bracketId})
    
    return result
end

-- Statistics Functions
function Database.GetTournamentStats()
    local result = MySQL.query.await([[
        SELECT 
            COUNT(*) as total_tournaments,
            SUM(CASE WHEN status = 'registration' THEN 1 ELSE 0 END) as registration_tournaments,
            SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as active_tournaments,
            SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_tournaments,
            SUM(current_teams) as total_teams,
            AVG(current_teams) as avg_teams_per_tournament
        FROM tournaments
    ]])
    
    return result and result[1] or {}
end

-- Export Database functions
exports('InitializeDatabase', Database.Initialize)
exports('GetTournaments', Database.GetTournaments)
exports('GetTournamentById', Database.GetTournamentById)
exports('CreateTournament', Database.CreateTournament)
exports('UpdateTournament', Database.UpdateTournament)
exports('CreateTeam', Database.CreateTeam)
exports('GetTeamById', Database.GetTeamById)
exports('GetTeamsByTournament', Database.GetTeamsByTournament)
exports('GetPlayerTeams', Database.GetPlayerTeams)
exports('UpdateTeam', Database.UpdateTeam)
exports('DeleteTeam', Database.DeleteTeam)
exports('CheckTeamNameExists', Database.CheckTeamNameExists)
exports('AddTeamMember', Database.AddTeamMember)
exports('GetTeamMembers', Database.GetTeamMembers)
exports('RemoveTeamMember', Database.RemoveTeamMember)
exports('UpdateTeamMemberRole', Database.UpdateTeamMemberRole)
exports('GetPlayerTeamMembership', Database.GetPlayerTeamMembership)
exports('IsTeamCaptain', Database.IsTeamCaptain)
exports('TransferCaptaincy', Database.TransferCaptaincy)
exports('GetTournamentLeaderboard', Database.GetTournamentLeaderboard)
exports('GetPlayerStats', Database.GetPlayerStats)
exports('SearchPlayers', Database.SearchPlayers)
exports('CreateBracket', Database.CreateBracket)
exports('GetTournamentBrackets', Database.GetTournamentBrackets)
exports('UpdateBracketResult', Database.UpdateBracketResult)
exports('GetTournamentStats', Database.GetTournamentStats)

return Database