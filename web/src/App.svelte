<script>
  import { onMount } from 'svelte';
  import { currentView, isVisible, playerData, isAdmin, appActions } from './stores/app.js';
  import { tournamentActions } from './stores/tournament.js';
  import { teamActions } from './stores/team.js';
  import { nui } from './utils/nui.js';
  import { showNotification } from './utils/notifications.js';

  // Components
  import MainMenu from './components/MainMenu.svelte';
  import TournamentList from './components/TournamentList.svelte';
  import TeamManagement from './components/TeamManagement.svelte';
  import Leaderboards from './components/Leaderboards.svelte';
  import TournamentRules from './components/TournamentRules.svelte';
  import AdminPanel from './components/AdminPanel.svelte';
  import Notifications from './components/Notifications.svelte';

  function switchView(view) {
    appActions.setView(view);
    nui.playSound('NAV_UP_DOWN');
  }

  function closeTournament() {
    appActions.closeTournament();
    nui.post('closeTournament', {});
    nui.playSound('BACK');
  }

  onMount(() => {
    // Set up NUI event handlers
    nui.on('openTournament', (data) => {
      appActions.openTournament(data.isAdmin, data.playerData);
    });

    nui.on('closeTournament', () => {
      appActions.closeTournament();
    });

    nui.on('updateTournaments', (data) => {
      tournamentActions.setTournaments(data);
    });

    nui.on('updatePlayerTeams', (data) => {
      teamActions.setPlayerTeams(data);
    });

    nui.on('teamRegistered', (data) => {
      showNotification('success', 'Team registered successfully!');
      nui.post('getPlayerTeams', {});
      nui.post('getTournaments', {});
    });

    nui.on('teamUpdated', (data) => {
      showNotification('success', 'Team updated successfully!');
      nui.post('getPlayerTeams', {});
    });

    nui.on('leftTeam', () => {
      showNotification('info', 'You have left the team');
      nui.post('getPlayerTeams', {});
    });

    nui.on('teamDisbanded', () => {
      showNotification('info', 'Team has been disbanded');
      nui.post('getPlayerTeams', {});
    });

    // Report ready to Lua
    nui.post('uiReady', {});
  });
</script>

<div id="tournament-app" class="font-sans">
  {#if $isVisible}
    <!-- Tablet Container -->
    <div class="w-screen h-screen flex items-center justify-center">
      <div class="w-[160vh] max-w-[90vw] h-[85vh] max-h-[85vh] bg-gradient-to-br from-dark-800/95 to-dark-900/95 rounded-2xl shadow-2xl border border-white/10 flex flex-col animate-fade-in overflow-hidden">
        
        <!-- Header -->
        <header class="bg-black/30 border-b-2 border-primary-500 px-6 py-3 flex-shrink-0">
          <div class="flex justify-between items-center">
            <div class="flex items-center gap-3">
              <i class="fas fa-trophy text-2xl text-primary-500 animate-pulse-slow"></i>
              <h1 class="text-xl font-bold bg-gradient-to-r from-primary-500 to-yellow-500 bg-clip-text text-transparent">
                Mystrey Town Racing Tournament
              </h1>
            </div>
            
            <div class="flex items-center gap-4">
              {#if $playerData}
                <div class="text-right">
                  <div class="text-white font-semibold text-sm">{$playerData.name}</div>
                  <div class="flex items-center gap-1 text-green-400 text-xs">
                    <i class="fas fa-dollar-sign"></i>
                    {nui.formatMoney($playerData.money?.cash || 0)}
                  </div>
                </div>
              {/if}
              
              <button 
                class="w-8 h-8 bg-red-500/80 hover:bg-red-500 rounded-full flex items-center justify-center transition-all duration-200 hover:scale-110"
                onclick={closeTournament}
                aria-label="Close tournament interface"
              >
                <i class="fas fa-times text-white text-sm"></i>
              </button>
            </div>
          </div>
        </header>

        <!-- Navigation -->
        <nav class="bg-black/20 border-b border-white/10 px-6 py-3 flex-shrink-0">
          <div class="flex gap-2 justify-center flex-wrap">
            <button 
              class="nav-btn {$currentView === 'main' ? 'active' : ''}"
              onclick={() => switchView('main')}
            >
              <i class="fas fa-home"></i>
              <span>Home</span>
            </button>
            
            <button 
              class="nav-btn {$currentView === 'tournaments' ? 'active' : ''}"
              onclick={() => switchView('tournaments')}
            >
              <i class="fas fa-list"></i>
              <span>Tournaments</span>
            </button>
            
            <button 
              class="nav-btn {$currentView === 'teams' ? 'active' : ''}"
              onclick={() => switchView('teams')}
            >
              <i class="fas fa-users"></i>
              <span>Teams</span>
            </button>
            
            <button 
              class="nav-btn {$currentView === 'leaderboards' ? 'active' : ''}"
              onclick={() => switchView('leaderboards')}
            >
              <i class="fas fa-medal"></i>
              <span>Leaderboards</span>
            </button>
            
            <button 
              class="nav-btn {$currentView === 'rules' ? 'active' : ''}"
              onclick={() => switchView('rules')}
            >
              <i class="fas fa-book"></i>
              <span>Rules</span>
            </button>
            
            {#if $isAdmin}
              <button 
                class="nav-btn admin-nav {$currentView === 'admin' ? 'active' : ''}"
                onclick={() => switchView('admin')}
              >
                <i class="fas fa-cog"></i>
                <span>Admin</span>
              </button>
            {/if}
          </div>
        </nav>

        <!-- Main Content -->
        <main class="flex-1 overflow-y-auto p-6">
          {#if $currentView === 'main'}
            <MainMenu />
          {:else if $currentView === 'tournaments'}
            <TournamentList />
          {:else if $currentView === 'teams'}
            <TeamManagement />
          {:else if $currentView === 'leaderboards'}
            <Leaderboards />
          {:else if $currentView === 'rules'}
            <TournamentRules />
          {:else if $currentView === 'admin' && $isAdmin}
            <AdminPanel />
          {:else}
            <div class="flex items-center justify-center h-full">
              <div class="text-center">
                <i class="fas fa-exclamation-triangle text-5xl text-yellow-500 mb-3"></i>
                <h2 class="text-xl font-bold text-white mb-2">Page Not Found</h2>
                <p class="text-gray-400 mb-4 text-sm">The requested page could not be found.</p>
                <button class="btn btn-primary" onclick={() => switchView('main')}>
                  <i class="fas fa-home"></i>
                  Go Home
                </button>
              </div>
            </div>
          {/if}
        </main>

        <!-- Footer -->
        <footer class="bg-black/30 border-t border-white/10 px-6 py-2 text-center flex-shrink-0">
          <p class="text-gray-500 text-xs">&copy; {new Date().getFullYear()} Mystrey Town | Powered by Laith & Jaser & Drak0ola</p>
        </footer>
      </div>
    </div>
  {/if}

  <!-- Notifications -->
  <Notifications />
</div>

<style>
  .nav-btn {
    @apply flex items-center gap-2 px-3 py-2 rounded-lg text-gray-400 hover:text-white hover:bg-white/10 transition-all duration-200 font-medium text-xs;
  }

  .nav-btn.active {
    @apply bg-primary-500 text-white shadow-lg;
  }

  .nav-btn.admin-nav {
    @apply border border-red-500/30 hover:bg-red-500/20 hover:border-red-500/50;
  }

  .nav-btn.admin-nav.active {
    @apply bg-red-500 border-red-500;
  }

  /* Tablet responsive adjustments */
  @media (max-width: 1024px) {
    .nav-btn {
      @apply px-2 py-1.5 text-xs;
    }
    
    .nav-btn span {
      @apply text-xs;
    }
  }

  /* Mobile adjustments */
  @media (max-width: 640px) {
    .nav-btn span {
      @apply hidden;
    }
    
    .nav-btn {
      @apply px-2 py-1.5;
    }
  }
</style>