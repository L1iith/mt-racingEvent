Config = {}

-- NPC Configuration
Config.NPC = {
    Model = 's_m_m_lawyer_01',
    Location = vector4(-544.28, -204.16, 37.65, 206.55), -- City Hall
    Animation = {
        Dict = 'missheistdockssetup1clipboard@base',
        Name = 'base',
        Flag = 49
    },
    Interaction = {
        Distance = 2.5,
        Icon = 'fas fa-trophy',
        Label = 'Racing Tournament Registration'
    }
}

-- Zone Configuration
Config.Zone = {
    Location = vector3(-544.28, -204.16, 37.65),
    Radius = 25.0,
    Debug = false
}

-- Tournament Configuration
Config.Tournament = {
    MaxTeamSize = 4,
    MinTeamSize = 2,
    MaxTeamsPerTournament = 16,
    DefaultRegistrationFee = 10000,
    TeamRoles = {
        'captain',
        'driver', 
        'navigator',
        'mechanic1',
        'mechanic2'
    },
    TournamentTypes = {
        'single_elimination',
        'double_elimination',
        'round_robin'
    },
    TournamentStatus = {
        'registration',
        'active',
        'completed',
        'cancelled'
    }
}

-- Team Configuration
Config.Team = {
    NameMinLength = 3,
    NameMaxLength = 30,
    TagMaxLength = 5,
    DefaultColor = '#FFFFFF',
    Status = {
        'registered',
        'active',
        'eliminated',
        'disqualified'
    }
}

-- UI Configuration
Config.UI = {
    Theme = 'dark',
    PrimaryColor = '#ff6b35',
    SecondaryColor = '#2c3e50',
    AccentColor = '#3498db',
    Animations = true,
    SoundEffects = true
}

-- Database Configuration
Config.Database = {
    Debug = false,
    SlowQueryTime = 1000 -- milliseconds
}

-- Permissions
Config.Permissions = {
    AdminCommands = {
        'group.admin',
        'tournament.admin'
    },
    ModeratorCommands = {
        'group.mod',
        'tournament.moderator'
    }
}

-- Commands
Config.Commands = {
    AdminPanel = 'tournamentadmin',
    PlayerPanel = 'tournament',
    ForceTeamRemoval = 'removeteam',
    CreateTournament = 'createtournament'
}

-- Notifications
Config.Notifications = {
    Duration = 5000,
    Position = 'top-right'
}

-- Race Integration (for future expansion)
Config.Race = {
    VehicleClasses = {
        'sports',
        'sportsclassics', 
        'super',
        'motorcycles'
    },
    CheckpointRadius = 15.0,
    LapTimeLimit = 300000, -- 5 minutes in milliseconds
    MaxLaps = 3
}