Locale = {}

Locale.Strings = {
    -- General
    ['tournament_system'] = 'Racing Tournament System',
    ['loading'] = 'Loading...',
    ['error'] = 'Error',
    ['success'] = 'Success',
    ['warning'] = 'Warning',
    ['info'] = 'Information',
    ['confirm'] = 'Confirm',
    ['cancel'] = 'Cancel',
    ['close'] = 'Close',
    ['save'] = 'Save',
    ['delete'] = 'Delete',
    ['edit'] = 'Edit',
    ['view'] = 'View',
    ['back'] = 'Back',
    ['next'] = 'Next',
    ['previous'] = 'Previous',
    ['submit'] = 'Submit',
    ['search'] = 'Search',
    ['filter'] = 'Filter',
    ['refresh'] = 'Refresh',
    ['yes'] = 'Yes',
    ['no'] = 'No',

    -- NPC Interaction
    ['npc_interaction_label'] = 'Racing Tournament Registration',
    ['npc_interaction_help'] = 'Press ~INPUT_CONTEXT~ to access racing tournaments',
    ['npc_spawned'] = 'Tournament registration officer has arrived',
    ['npc_despawned'] = 'Tournament registration officer has left',

    -- Main Menu
    ['main_menu_title'] = 'Racing Tournament Hub',
    ['view_tournaments'] = 'View Active Tournaments',
    ['register_team'] = 'Register New Team',
    ['manage_teams'] = 'Manage My Teams',
    ['leaderboards'] = 'Tournament Leaderboards',
    ['tournament_rules'] = 'Tournament Rules',
    ['admin_panel'] = 'Admin Panel',

    -- Team Registration
    ['team_registration'] = 'Team Registration',
    ['team_name'] = 'Team Name',
    ['team_name_placeholder'] = 'Enter your team name',
    ['team_tag'] = 'Team Tag',
    ['team_tag_placeholder'] = 'TAG',
    ['team_color'] = 'Team Color',
    ['select_tournament'] = 'Select Tournament',
    ['registration_fee'] = 'Registration Fee',
    ['team_captain'] = 'Team Captain',
    ['add_team_member'] = 'Add Team Member',
    ['team_member_search'] = 'Search for player...',
    ['select_role'] = 'Select Role',
    ['team_full'] = 'Team is full',
    ['register_team_btn'] = 'Register Team',
    ['team_preview'] = 'Team Preview',

    -- Team Roles
    ['role_captain'] = 'Captain',
    ['role_driver'] = 'Driver',
    ['role_navigator'] = 'Navigator',
    ['role_mechanic1'] = 'Mechanic 1',
    ['role_mechanic2'] = 'Mechanic 2',

    -- Team Management
    ['team_management'] = 'Team Management',
    ['my_teams'] = 'My Teams',
    ['team_overview'] = 'Team Overview',
    ['team_members'] = 'Team Members',
    ['team_stats'] = 'Team Statistics',
    ['team_settings'] = 'Team Settings',
    ['leave_team'] = 'Leave Team',
    ['disband_team'] = 'Disband Team',
    ['kick_member'] = 'Kick Member',
    ['change_role'] = 'Change Role',
    ['promote_captain'] = 'Promote to Captain',
    ['invite_player'] = 'Invite Player',
    ['team_victories'] = 'Victories',
    ['team_losses'] = 'Losses',
    ['team_points'] = 'Total Points',
    ['team_rank'] = 'Team Rank',

    -- Tournament Info
    ['tournament_details'] = 'Tournament Details',
    ['tournament_name'] = 'Tournament Name',
    ['tournament_status'] = 'Status',
    ['start_date'] = 'Start Date',
    ['end_date'] = 'End Date',
    ['max_teams'] = 'Maximum Teams',
    ['current_teams'] = 'Registered Teams',
    ['prize_pool'] = 'Prize Pool',
    ['tournament_type'] = 'Tournament Type',
    ['tournament_description'] = 'Description',
    ['registration_open'] = 'Registration Open',
    ['registration_closed'] = 'Registration Closed',
    ['tournament_active'] = 'Active',
    ['tournament_completed'] = 'Completed',
    ['tournament_cancelled'] = 'Cancelled',

    -- Leaderboards
    ['leaderboards_title'] = 'Tournament Leaderboards',
    ['current_standings'] = 'Current Standings',
    ['team_statistics'] = 'Team Statistics',
    ['player_statistics'] = 'Player Statistics',
    ['tournament_history'] = 'Tournament History',
    ['top_teams'] = 'Top Teams',
    ['top_players'] = 'Top Players',
    ['position'] = 'Position',
    ['points'] = 'Points',
    ['wins'] = 'Wins',
    ['losses'] = 'Losses',
    ['win_rate'] = 'Win Rate',
    ['best_lap'] = 'Best Lap Time',
    ['total_races'] = 'Total Races',

    -- Tournament Rules
    ['rules_title'] = 'Tournament Rules & Regulations',
    ['general_rules'] = 'General Rules',
    ['team_requirements'] = 'Team Requirements',
    ['race_format'] = 'Race Format',
    ['scoring_system'] = 'Scoring System',
    ['penalties'] = 'Penalties & Violations',
    ['vehicle_regulations'] = 'Vehicle Regulations',
    ['conduct_rules'] = 'Code of Conduct',
    ['faq'] = 'Frequently Asked Questions',

    -- Admin Panel
    ['admin_panel_title'] = 'Tournament Administration',
    ['create_tournament'] = 'Create Tournament',
    ['manage_tournaments'] = 'Manage Tournaments',
    ['manage_teams'] = 'Manage Teams',
    ['manage_players'] = 'Manage Players',
    ['tournament_settings'] = 'Tournament Settings',
    ['system_logs'] = 'System Logs',
    ['statistics'] = 'Statistics',

    -- Error Messages
    ['error_insufficient_funds'] = 'Insufficient funds for registration fee',
    ['error_team_name_taken'] = 'Team name is already taken',
    ['error_team_name_invalid'] = 'Invalid team name',
    ['error_player_not_found'] = 'Player not found',
    ['error_player_already_in_team'] = 'Player is already in a team for this tournament',
    ['error_team_full'] = 'Team is already full',
    ['error_not_team_captain'] = 'Only team captain can perform this action',
    ['error_tournament_not_found'] = 'Tournament not found',
    ['error_registration_closed'] = 'Registration for this tournament is closed',
    ['error_database'] = 'Database error occurred',
    ['error_permission_denied'] = 'Permission denied',
    ['error_invalid_role'] = 'Invalid team role',
    ['error_cannot_leave_as_captain'] = 'Cannot leave team as captain. Transfer leadership first',

    -- Success Messages
    ['success_team_registered'] = 'Team successfully registered for tournament',
    ['success_team_updated'] = 'Team information updated successfully',
    ['success_player_added'] = 'Player added to team successfully',
    ['success_player_removed'] = 'Player removed from team successfully',
    ['success_role_changed'] = 'Player role changed successfully',
    ['success_team_disbanded'] = 'Team disbanded successfully',
    ['success_left_team'] = 'Successfully left the team',
    ['success_tournament_created'] = 'Tournament created successfully',
    ['success_settings_saved'] = 'Settings saved successfully',

    -- Warning Messages
    ['warning_team_disband'] = 'Are you sure you want to disband this team? This action cannot be undone',
    ['warning_leave_team'] = 'Are you sure you want to leave this team?',
    ['warning_kick_player'] = 'Are you sure you want to kick this player from the team?',
    ['warning_delete_tournament'] = 'Are you sure you want to delete this tournament?',

    -- Info Messages
    ['info_registration_fee'] = 'Registration fee: $%s',
    ['info_team_slots'] = '%d/%d team slots filled',
    ['info_tournament_starts_in'] = 'Tournament starts in: %s',
    ['info_no_active_tournaments'] = 'No active tournaments available',
    ['info_no_teams'] = 'You are not part of any teams',
    ['info_tournament_full'] = 'This tournament is full'
}

function _U(str, ...)
    if Locale.Strings[str] then
        return string.format(Locale.Strings[str], ...)
    else
        return 'Translation [' .. str .. '] does not exist'
    end
end