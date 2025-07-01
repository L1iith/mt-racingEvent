<script>
  import { tournaments } from '../stores/tournament.js';
  import { nui } from '../utils/nui.js';
  import { onMount } from 'svelte';

  let selectedTournamentId = $state('');
  let leaderboardData = $state([]);
  let loading = $state(false);

  async function loadLeaderboard(tournamentId) {
    if (!tournamentId) {
      leaderboardData = [];
      return;
    }

    loading = true;
    try {
      const data = await nui.post('getLeaderboards', { tournamentId });
      leaderboardData = data || [];
    } catch (error) {
      console.error('Failed to load leaderboard:', error);
      leaderboardData = [];
    } finally {
      loading = false;
    }
  }

  function getRankIcon(position) {
    switch (position) {
      case 1: return 'fas fa-trophy text-yellow-500';
      case 2: return 'fas fa-medal text-gray-400';
      case 3: return 'fas fa-medal text-amber-600';
      default: return 'fas fa-hashtag text-gray-600';
    }
  }

  function getRankClass(position) {
    switch (position) {
      case 1: return 'bg-gradient-to-r from-yellow-500/20 to-yellow-600/20 border-yellow-500/30';
      case 2: return 'bg-gradient-to-r from-gray-400/20 to-gray-500/20 border-gray-400/30';
      case 3: return 'bg-gradient-to-r from-amber-600/20 to-amber-700/20 border-amber-600/30';
      default: return 'bg-white/5 border-white/10';
    }
  }

  onMount(() => {
    nui.post('getTournaments', {});
  });

  $effect(() => {
    if (selectedTournamentId) {
      loadLeaderboard(selectedTournamentId);
    }
  });
</script>

<div class="max-w-7xl mx-auto p-6">
  <div class="mb-8">
    <h1 class="text-3xl font-bold text-white mb-2">Tournament Leaderboards</h1>
    <p class="text-gray-400">View current standings and team rankings</p>
  </div>

  <!-- Tournament Selection -->
  <div class="card mb-8">
    <h3 class="text-xl font-semibold text-white mb-4">Select Tournament</h3>
    <div class="flex gap-4 items-center">
      <select 
        class="select flex-1"
        bind:value={selectedTournamentId}
      >
        <option value="">Choose a tournament...</option>
        {#each $tournaments as tournament}
          <option value={tournament.id}>{tournament.name}</option>
        {/each}
      </select>
      
      {#if selectedTournamentId}
        <button 
          class="btn btn-secondary"
          onclick={() => loadLeaderboard(selectedTournamentId)}
          disabled={loading}
        >
          <i class="fas fa-sync-alt {loading ? 'animate-spin' : ''}"></i>
          Refresh
        </button>
      {/if}
    </div>
  </div>

  <!-- Leaderboard Content -->
  {#if !selectedTournamentId}
    <div class="card text-center py-12">
      <i class="fas fa-chart-line text-6xl text-gray-400 mb-4"></i>
      <h3 class="text-2xl font-semibold text-white mb-2">Select a Tournament</h3>
      <p class="text-gray-400">Choose a tournament from the dropdown above to view its leaderboard</p>
    </div>
  {:else if loading}
    <div class="card text-center py-12">
      <div class="animate-spin text-4xl text-primary-500 mb-4">
        <i class="fas fa-circle-notch"></i>
      </div>
      <p class="text-gray-300">Loading leaderboard...</p>
    </div>
  {:else if leaderboardData.length === 0}
    <div class="card text-center py-12">
      <i class="fas fa-users text-6xl text-gray-400 mb-4"></i>
      <h3 class="text-2xl font-semibold text-white mb-2">No Teams Yet</h3>
      <p class="text-gray-400">No teams have registered for this tournament yet</p>
    </div>
  {:else}
    <div class="space-y-4">
      <!-- Top 3 Podium -->
      {#if leaderboardData.length >= 3}
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <!-- 2nd Place -->
          <div class="card {getRankClass(2)} order-1 md:order-1">
            <div class="text-center">
              <i class="fas fa-medal text-gray-400 text-3xl mb-2"></i>
              <div class="text-lg font-semibold text-white">2nd Place</div>
              <div class="text-xl font-bold text-white">{leaderboardData[1].team_name}</div>
              <div class="text-2xl font-bold text-gray-400">{leaderboardData[1].total_points} pts</div>
              <div class="text-sm text-gray-400 mt-2">
                {leaderboardData[1].wins}W - {leaderboardData[1].losses}L
              </div>
            </div>
          </div>

          <!-- 1st Place -->
          <div class="card {getRankClass(1)} order-2 md:order-2 transform md:scale-110">
            <div class="text-center">
              <i class="fas fa-crown text-yellow-500 text-4xl mb-2 animate-pulse-slow"></i>
              <div class="text-lg font-semibold text-yellow-400">Champion</div>
              <div class="text-2xl font-bold text-white">{leaderboardData[0].team_name}</div>
              <div class="text-3xl font-bold text-yellow-400">{leaderboardData[0].total_points} pts</div>
              <div class="text-sm text-gray-400 mt-2">
                {leaderboardData[0].wins}W - {leaderboardData[0].losses}L
              </div>
            </div>
          </div>

          <!-- 3rd Place -->
          <div class="card {getRankClass(3)} order-3 md:order-3">
            <div class="text-center">
              <i class="fas fa-medal text-amber-600 text-3xl mb-2"></i>
              <div class="text-lg font-semibold text-white">3rd Place</div>
              <div class="text-xl font-bold text-white">{leaderboardData[2].team_name}</div>
              <div class="text-2xl font-bold text-amber-600">{leaderboardData[2].total_points} pts</div>
              <div class="text-sm text-gray-400 mt-2">
                {leaderboardData[2].wins}W - {leaderboardData[2].losses}L
              </div>
            </div>
          </div>
        </div>
      {/if}

      <!-- Full Rankings Table -->
      <div class="card">
        <h3 class="text-xl font-semibold text-white mb-6 flex items-center gap-2">
          <i class="fas fa-list-ol text-primary-500"></i>
          Full Rankings
        </h3>
        
        <div class="space-y-3">
          {#each leaderboardData as team, index}
            <div class="flex items-center justify-between p-4 rounded-lg {getRankClass(index + 1)} hover:bg-white/10 transition-colors">
              <div class="flex items-center gap-4">
                <div class="flex items-center justify-center w-10 h-10 rounded-full bg-white/10">
                  <i class="{getRankIcon(index + 1)}"></i>
                </div>
                
                <div>
                  <div class="flex items-center gap-2">
                    <span class="text-lg font-semibold text-white">{team.team_name}</span>
                    {#if team.team_tag}
                      <span class="text-primary-500 text-sm">[{team.team_tag}]</span>
                    {/if}
                  </div>
                  <div class="text-sm text-gray-400">
                    {team.member_count || 0}/4 members
                  </div>
                </div>
              </div>

              <div class="text-right">
                <div class="text-xl font-bold text-white">{team.total_points} pts</div>
                <div class="text-sm text-gray-400">
                  {team.wins}W - {team.losses}L
                  {#if team.wins + team.losses > 0}
                    (Win Rate: {Math.round((team.wins / (team.wins + team.losses)) * 100)}%)
                  {/if}
                </div>
              </div>
            </div>
          {/each}
        </div>
      </div>
    </div>
  {/if}
</div>