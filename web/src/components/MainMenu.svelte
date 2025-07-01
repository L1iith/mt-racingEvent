<script>
  import { tournaments } from '../stores/tournament.js';
  import { playerTeams } from '../stores/team.js';
  import { playerData, isAdmin, appActions } from '../stores/app.js';
  import { nui } from '../utils/nui.js';
  import { onMount } from 'svelte';

  let stats = $state({
    activeTournaments: 0,
    registrationOpen: 0,
    myTeams: 0,
    totalPrizePool: 0
  });

  let loading = $state(true);

  $effect(() => {
    if ($tournaments && $playerTeams) {
      updateStats();
    }
  });

  function updateStats() {
    const activeTournaments = $tournaments.filter(t => t.status === 'active').length;
    const registrationOpen = $tournaments.filter(t => t.status === 'registration').length;
    const myTeams = $playerTeams.length;
    const totalPrizePool = $tournaments.reduce((sum, t) => sum + (t.prize_pool || 0), 0);

    stats = {
      activeTournaments,
      registrationOpen,
      myTeams,
      totalPrizePool
    };
    
    loading = false;
  }

  function navigateTo(view) {
    appActions.setView(view);
    nui.playSound('NAV_UP_DOWN');
  }

  onMount(() => {
    nui.post('getTournaments', {});
    nui.post('getPlayerTeams', {});
  });
</script>

{#if loading}
  <div class="flex flex-col items-center justify-center h-96 gap-4">
    <div class="animate-spin text-4xl text-primary-500">
      <i class="fas fa-circle-notch"></i>
    </div>
    <p class="text-gray-300">Loading tournament data...</p>
  </div>
{:else}
  <div class="max-w-7xl mx-auto p-6 space-y-8">
    <!-- Welcome Section -->
    <div class="bg-gradient-to-br from-primary-500/20 to-blue-500/20 rounded-2xl p-8 text-center border border-white/10">
      <h1 class="text-4xl font-bold mb-4 text-white flex items-center justify-center gap-3">
        <i class="fas fa-trophy text-primary-500 animate-pulse-slow"></i>
        Welcome to Racing Tournament
      </h1>
      <p class="text-xl text-gray-300 mb-6 max-w-2xl mx-auto">
        Join competitive racing tournaments, form teams with friends, and compete for glory and prizes!
      </p>
      {#if $playerData}
        <div class="flex items-center justify-center gap-6 flex-wrap">
          <span class="text-lg">Welcome back, <span class="font-semibold text-primary-400">{$playerData.name}</span>!</span>
          <div class="flex items-center gap-2 text-green-400 font-semibold">
            <i class="fas fa-dollar-sign"></i>
            {nui.formatMoney($playerData.money?.cash || 0)}
          </div>
        </div>
      {/if}
    </div>

    <!-- Statistics Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <div class="card group">
        <div class="flex items-center gap-4">
          <div class="w-16 h-16 bg-primary-500/20 rounded-xl flex items-center justify-center">
            <i class="fas fa-trophy text-2xl text-primary-500 group-hover:scale-110 transition-transform"></i>
          </div>
          <div>
            <div class="text-3xl font-bold text-white">{stats.activeTournaments}</div>
            <div class="text-sm text-gray-400">Active Tournaments</div>
          </div>
        </div>
      </div>

      <div class="card group">
        <div class="flex items-center gap-4">
          <div class="w-16 h-16 bg-green-500/20 rounded-xl flex items-center justify-center">
            <i class="fas fa-clock text-2xl text-green-500 group-hover:scale-110 transition-transform"></i>
          </div>
          <div>
            <div class="text-3xl font-bold text-white">{stats.registrationOpen}</div>
            <div class="text-sm text-gray-400">Registration Open</div>
          </div>
        </div>
      </div>

      <div class="card group">
        <div class="flex items-center gap-4">
          <div class="w-16 h-16 bg-blue-500/20 rounded-xl flex items-center justify-center">
            <i class="fas fa-users text-2xl text-blue-500 group-hover:scale-110 transition-transform"></i>
          </div>
          <div>
            <div class="text-3xl font-bold text-white">{stats.myTeams}</div>
            <div class="text-sm text-gray-400">My Teams</div>
          </div>
        </div>
      </div>

      <div class="card group">
        <div class="flex items-center gap-4">
          <div class="w-16 h-16 bg-yellow-500/20 rounded-xl flex items-center justify-center">
            <i class="fas fa-dollar-sign text-2xl text-yellow-500 group-hover:scale-110 transition-transform"></i>
          </div>
          <div>
            <div class="text-2xl font-bold text-white">{nui.formatMoney(stats.totalPrizePool)}</div>
            <div class="text-sm text-gray-400">Total Prize Pool</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Action Cards -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <div class="card group">
        <div class="mb-4">
          <h3 class="text-2xl font-semibold text-white flex items-center gap-3 mb-2">
            <i class="fas fa-list text-primary-500"></i>
            Browse Tournaments
          </h3>
        </div>
        <p class="text-gray-300 mb-6">
          Explore available tournaments and find the perfect competition for your skill level.
        </p>
        <ul class="space-y-2 mb-6">
          <li class="flex items-center gap-2 text-gray-300">
            <i class="fas fa-check text-green-500 text-sm"></i>
            View tournament details
          </li>
          <li class="flex items-center gap-2 text-gray-300">
            <i class="fas fa-check text-green-500 text-sm"></i>
            Check registration status
          </li>
          <li class="flex items-center gap-2 text-gray-300">
            <i class="fas fa-check text-green-500 text-sm"></i>
            See prize pools
          </li>
          <li class="flex items-center gap-2 text-gray-300">
            <i class="fas fa-check text-green-500 text-sm"></i>
            Register new teams
          </li>
        </ul>
        <button class="btn btn-primary w-full" onclick={() => navigateTo('tournaments')}>
          <i class="fas fa-list"></i>
          View Tournaments
        </button>
      </div>

      <div class="card group">
        <div class="mb-4">
          <h3 class="text-2xl font-semibold text-white flex items-center gap-3 mb-2">
            <i class="fas fa-users text-primary-500"></i>
            Team Management
          </h3>
        </div>
        <p class="text-gray-300 mb-6">
          Create and manage your racing teams. Coordinate with teammates for optimal performance.
        </p>
        <ul class="space-y-2 mb-6">
          <li class="flex items-center gap-2 text-gray-300">
            <i class="fas fa-check text-green-500 text-sm"></i>
            Manage team members
          </li>
          <li class="flex items-center gap-2 text-gray-300">
            <i class="fas fa-check text-green-500 text-sm"></i>
            Assign player roles
          </li>
          <li class="flex items-center gap-2 text-gray-300">
            <i class="fas fa-check text-green-500 text-sm"></i>
            Track team statistics
          </li>
          <li class="flex items-center gap-2 text-gray-300">
            <i class="fas fa-check text-green-500 text-sm"></i>
            Invite new players
          </li>
        </ul>
        <button class="btn btn-secondary w-full" onclick={() => navigateTo('teams')}>
          <i class="fas fa-users"></i>
          My Teams
        </button>
      </div>

      <div class="card group">
        <div class="mb-4">
          <h3 class="text-2xl font-semibold text-white flex items-center gap-3 mb-2">
            <i class="fas fa-medal text-primary-500"></i>
            Leaderboards
          </h3>
        </div>
        <p class="text-gray-300 mb-6">
          Check current tournament standings and see how your team compares to the competition.
        </p>
        <ul class="space-y-2 mb-6">
          <li class="flex items-center gap-2 text-gray-300">
            <i class="fas fa-check text-green-500 text-sm"></i>
            Tournament rankings
          </li>
          <li class="flex items-center gap-2 text-gray-300">
            <i class="fas fa-check text-green-500 text-sm"></i>
            Team statistics
          </li>
          <li class="flex items-center gap-2 text-gray-300">
            <i class="fas fa-check text-green-500 text-sm"></i>
            Player performance
          </li>
          <li class="flex items-center gap-2 text-gray-300">
            <i class="fas fa-check text-green-500 text-sm"></i>
            Historical data
          </li>
        </ul>
        <button class="btn btn-secondary w-full" onclick={() => navigateTo('leaderboards')}>
          <i class="fas fa-medal"></i>
          View Rankings
        </button>
      </div>

      <div class="card group">
        <div class="mb-4">
          <h3 class="text-2xl font-semibold text-white flex items-center gap-3 mb-2">
            <i class="fas fa-book text-primary-500"></i>
            Tournament Rules
          </h3>
        </div>
        <p class="text-gray-300 mb-6">
          Read the tournament rules and regulations to ensure fair play and understand the format.
        </p>
        <ul class="space-y-2 mb-6">
          <li class="flex items-center gap-2 text-gray-300">
            <i class="fas fa-check text-green-500 text-sm"></i>
            Competition rules
          </li>
          <li class="flex items-center gap-2 text-gray-300">
            <i class="fas fa-check text-green-500 text-sm"></i>
            Team requirements
          </li>
          <li class="flex items-center gap-2 text-gray-300">
            <i class="fas fa-check text-green-500 text-sm"></i>
            Scoring system
          </li>
          <li class="flex items-center gap-2 text-gray-300">
            <i class="fas fa-check text-green-500 text-sm"></i>
            Code of conduct
          </li>
        </ul>
        <button class="btn btn-secondary w-full" onclick={() => navigateTo('rules')}>
          <i class="fas fa-book"></i>
          Read Rules
        </button>
      </div>
    </div>

    <!-- Admin Section -->
    {#if $isAdmin}
      <div class="card border-red-500/30 bg-red-500/5">
        <div class="mb-4">
          <h3 class="text-2xl font-semibold text-white flex items-center gap-3 mb-2">
            <i class="fas fa-cog text-red-500"></i>
            Administration Panel
          </h3>
        </div>
        <p class="text-gray-300 mb-6">
          Manage tournaments, teams, and system settings. Administrative privileges required.
        </p>
        <ul class="space-y-2 mb-6">
          <li class="flex items-center gap-2 text-gray-300">
            <i class="fas fa-check text-green-500 text-sm"></i>
            Create tournaments
          </li>
          <li class="flex items-center gap-2 text-gray-300">
            <i class="fas fa-check text-green-500 text-sm"></i>
            Manage teams
          </li>
          <li class="flex items-center gap-2 text-gray-300">
            <i class="fas fa-check text-green-500 text-sm"></i>
            System statistics
          </li>
          <li class="flex items-center gap-2 text-gray-300">
            <i class="fas fa-check text-green-500 text-sm"></i>
            User management
          </li>
        </ul>
        <button class="btn btn-danger w-full" onclick={() => navigateTo('admin')}>
          <i class="fas fa-cog"></i>
          Admin Panel
        </button>
      </div>
    {/if}

    <!-- Quick Actions -->
    <div class="text-center">
      <h3 class="text-xl font-semibold text-white mb-4">Quick Actions</h3>
      <div class="flex justify-center gap-4 flex-wrap">
        <button class="btn btn-outline" onclick={() => navigateTo('tournaments')}>
          <i class="fas fa-plus"></i>
          Register Team
        </button>
        <button class="btn btn-outline" onclick={() => navigateTo('leaderboards')}>
          <i class="fas fa-chart-line"></i>
          View Standings
        </button>
        <button class="btn btn-outline" onclick={() => navigateTo('rules')}>
          <i class="fas fa-question-circle"></i>
          Help & Rules
        </button>
      </div>
    </div>
  </div>
{/if}