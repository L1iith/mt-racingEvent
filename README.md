# MT Racing Tournament System - Event
A comprehensive FiveM racing tournament system.

## 🏁 Features

### Core Functionality
- **Tournament Management**: Create and manage racing tournaments with customizable settings
- **Team System**: Advanced team creation, member management, and role assignment
- **Registration System**: Streamlined team registration with fee management
- **Leaderboards**: Real-time tournament standings and statistics
- **NPC Interaction**: Immersive NPC-based registration at City Hall
- **Zone-Based Spawning**: Intelligent NPC spawning system using ox_lib zones

### Modern UI/UX (COMPLETELY REWRITTEN)
- **Svelte 5**: Latest Svelte framework with reactive runes and $state/$effect
- **Tailwind CSS**: Utility-first CSS framework with custom design system
- **Responsive Design**: Mobile-friendly interface with modern animations
- **Real-time Updates**: Live data synchronization between client and server
- **Interactive Components**: Modular, reusable UI components
- **Dark Theme**: Professionally designed racing-themed interface with glassmorphism
- **Performance**: Optimized bundle with tree-shaking and modern build tools

### Advanced Features
- **Role-Based Teams**: Captain, Driver, Navigator, and Mechanic roles
- **Player Search**: Advanced player lookup for team invitations
- **Team Statistics**: Comprehensive performance tracking
- **Tournament Brackets**: Single-elimination tournament structure
- **Administrative Tools**: Complete admin panel for tournament management

## 📋 Requirements

### Dependencies
- **qb-core**: QB-Core framework
- **oxmysql**: MySQL database connector
- **ox_lib**: Zones and notifications
- **interact**: NPC interaction system ([darktrovx/interact](https://github.com/darktrovx/interact))

### System Requirements
- FiveM Server (latest version recommended)
- MySQL 8.0+
- Modern web browser with JavaScript enabled

## 🚀 Installation

### 1. Download and Extract
```bash
cd resources
git clone https://github.com/L1iith/mt-racingEvent
```

### 2. Database Setup
```sql
-- Import the database schema
SOURCE mt-racingEvent/sql/tournament.sql;
```

### 3. Configuration
Edit `shared/config.lua` to customize:
- NPC location and model
- Tournament settings
- Team configurations
- UI preferences

### 4. Server Configuration
Add to your `server.cfg`:
```
ensure racing-tournament
```

### 5. Permissions (Optional)
Configure permissions in your QB-Core setup:
```lua
-- Admin permissions
'tournament.admin'
'tournament.moderator'
```

## 🎮 Usage

### For Players

#### Accessing the System
1. **Location**: Visit City Hall (coordinates configurable)
2. **NPC Interaction**: Approach the tournament registration officer
3. **UI Access**: Use the interaction prompt or `/tournament` command

#### Team Registration
1. Navigate to "Tournaments" section
2. Select an active tournament
3. Complete the team registration form:
   - Team name and tag
   - Team color
   - Member roles assignment
4. Pay the registration fee
5. Invite additional team members

#### Team Management
1. Access "My Teams" section
2. View team statistics and performance
3. Manage team members (Captain only)
4. Update team settings
5. Leave or disband teams

### For Administrators

#### Creating Tournaments
```lua
-- In-game command
/createtournament "Tournament Name"

-- Or use the admin panel
/tournamentadmin
```

#### Managing Tournaments
- Access the admin panel via `/tournamentadmin`
- Create, modify, or delete tournaments
- Manage team registrations
- View system statistics
- Handle player disputes

## 🔧 Configuration

### Main Configuration (`shared/config.lua`)

```lua
Config = {}

-- NPC Configuration
Config.NPC = {
    Model = 's_m_m_lawyer_01',
    Location = vector4(-544.28, -204.16, 37.65, 206.55),
    Animation = {
        Dict = 'missheistdockssetup1clipboard@base',
        Name = 'base',
        Flag = 49
    }
}

-- Tournament Settings
Config.Tournament = {
    MaxTeamSize = 4,
    MinTeamSize = 2,
    MaxTeamsPerTournament = 16,
    DefaultRegistrationFee = 10000
}
```

### Localization (`shared/locale.lua`)

The system supports full localization. Edit the `Locale.Strings` table to customize text:

```lua
Locale.Strings = {
    ['tournament_system'] = 'Racing Tournament System',
    ['team_registration'] = 'Team Registration',
    -- ... more strings
}
```

## 🗄️ Database Schema

### Main Tables
- **tournaments**: Tournament information and settings
- **teams**: Team data and statistics
- **team_members**: Individual team member records
- **tournament_brackets**: Bracket and match information
- **race_results**: Detailed race performance data

### Key Relationships
- Teams belong to tournaments
- Members belong to teams
- Brackets track tournament progression
- Results track individual performance

## 🎨 UI Components

### Svelte 5 Components
The system uses modern Svelte 5 with runes for reactive state management:

```javascript
// Tournament store example
export const tournaments = writable([]);
export const activeTournament = writable(null);

    activeTournaments: 0,
    registrationOpen: 0,
    myTeams: 0,
    totalPrizePool: 0
});

$effect(() => {
    if ($tournaments && $playerTeams) {
        updateStats();
    }
});

// Reactive actions
export const tournamentActions = {
    setTournaments(data) {
        tournaments.set(data || []);
    },
    // ... more actions
};
```

### State Management
- **Tournament Store**: Manages tournament data and operations
- **Team Store**: Handles team information and member management
- **Real-time Sync**: Automatic updates via NUI messaging

## 🔌 API Reference

### Client Events
```lua
-- Tournament data received
RegisterNetEvent('tournament:client:receiveTournaments')

-- Team registration success
RegisterNetEvent('tournament:client:teamRegistered')

-- Player teams updated
RegisterNetEvent('tournament:client:receivePlayerTeams')
```

### Server Events
```lua
-- Get tournament list
TriggerServerEvent('tournament:server:getTournaments')

-- Register new team
TriggerServerEvent('tournament:server:registerTeam', tournamentId, teamData)

-- Update team information
TriggerServerEvent('tournament:server:updateTeam', teamId, updateData)
```

### NUI Callbacks
```javascript
// Close tournament interface
RegisterNUICallback('closeTournament')

// Register team
RegisterNUICallback('registerTeam')

// Search players
RegisterNUICallback('searchPlayers')
```

## 🚨 Troubleshooting

### Common Issues

**NPC Not Spawning**
- Check if ox_lib is properly installed
- Verify zone coordinates in config
- Ensure interact system is running

**Database Errors**
- Verify MySQL connection
- Check if tables were created properly
- Ensure proper permissions

**UI Not Loading**
- Check browser console for errors
- Verify Svelte components are properly loaded
- Test with different browsers

**Team Registration Failing**
- Check player money balance
- Verify tournament is open for registration
- Ensure team name isn't already taken

### Debug Mode
Enable debug mode in `shared/config.lua`:
```lua
Config.Database.Debug = true
Config.Zone.Debug = true
```

## 🤝 Contributing

### Development Setup
1. Clone the repository
2. Install Node.js dependencies: `npm install`
3. Set up a FiveM development server
4. Install required dependencies (ox_lib, interact, etc.)
5. Configure database connection
6. For UI development: `npm run dev`
7. Build for production: `npm run build`
8. Test changes thoroughly

### Code Standards
- Follow QB-Core coding conventions
- Use meaningful variable names
- Comment complex logic
- Test all database operations
- Validate user inputs

### Submitting Changes
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **QB-Core Team**: For the excellent framework
- **Overextended**: For ox_lib utilities
- **darktrovx**: For the interact system
- **Svelte Team**: For the amazing UI framework
- **FiveM Community**: For continuous support and feedback

## 📞 Support

For support and questions:
- **Issues**: Report bugs via GitHub Issues
- **Documentation**: Check this README and inline comments
- **Community**: Join the FiveM development community
- **Updates**: Watch the repository for updates

## ⚡ Frontend Rewrite Highlights

### What's New
- **Complete UI Overhaul**: Rewritten from vanilla HTML/CSS/JS to modern Svelte 5
- **Tailwind CSS**: Utility-first styling with custom design tokens
- **Better Performance**: Smaller bundle size, faster loading, optimized rendering
- **Modern Tooling**: Vite for development, PostCSS for styling, npm for dependencies
- **Enhanced UX**: Smooth animations, better responsive design, improved accessibility
- **Maintainable Code**: Component-based architecture, proper state management

### Technical Improvements
- **Bundle Size**: Reduced from multiple files to optimized single bundle
- **Load Time**: Faster initial load with code splitting and tree shaking
- **Reactivity**: Svelte 5's fine-grained reactivity for better performance
- **Developer Experience**: Hot module replacement, better debugging, TypeScript support
- **Accessibility**: Proper ARIA labels, keyboard navigation, screen reader support

### Migration Benefits
- **Future-Proof**: Modern tech stack that's actively maintained
- **Scalability**: Easier to add new features and components
- **Team Development**: Better code organization for multiple developers
- **User Experience**: Smoother interactions and professional appearance

---

**Made with ❤️ for the FiveM Racing Community**
**Powered by Svelte 5 + Tailwind CSS**