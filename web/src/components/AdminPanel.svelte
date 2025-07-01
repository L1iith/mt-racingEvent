<script>
  import { tournaments } from '../stores/tournament.js';
  import { nui } from '../utils/nui.js';
  import { showNotification } from '../utils/notifications.js';
  import { onMount } from 'svelte';

  let createTournamentForm = $state({
    name: '',
    description: '',
    maxTeams: 16,
    registrationFee: 50000,
    prizePool: 500000,
    startDate: ''
  });

  let showCreateModal = $state(false);
  let stats = $state({
    activeTournaments: 0,
    registrationOpen: 0,
    totalTeams: 0,
    totalPlayers: 0
  });

  function openCreateModal() {
    createTournamentForm = {
      name: '',
      description: '',
      maxTeams: 16,
      registrationFee: 50000,
      prizePool: 500000,
      startDate: ''
    };
    showCreateModal = true;
  }

  function closeCreateModal() {
    showCreateModal = false;
  }

  async function createTournament() {
    if (!createTournamentForm.name.trim()) {
      showNotification('error', 'Please enter a tournament name');
      return;
    }

    try {
      await nui.post('createTournament', createTournamentForm);
      showNotification('success', 'Tournament created successfully!');
      closeCreateModal();
      nui.post('getTournaments', {});
    } catch (error) {
      console.error('Create tournament error:', error);
      showNotification('error', 'Failed to create tournament');
    }
  }

  async function deleteTournament(tournamentId) {
    if (!confirm('Are you sure you want to delete this tournament? This action cannot be undone.')) {
      return;
    }

    try {
      await nui.post('deleteTournament', { tournamentId });
      showNotification('success', 'Tournament deleted successfully');
      nui.post('getTournaments', {});
    } catch (error) {
      console.error('Delete tournament error:', error);
      showNotification('error', 'Failed to delete tournament');
    }
  }

  async function toggleTournamentStatus(tournamentId, newStatus) {
    try {
      await nui.post('updateTournamentStatus', { tournamentId, status: newStatus });
      showNotification('success', `Tournament status updated to ${newStatus}`);
      nui.post('getTournaments', {});
    } catch (error) {
      console.error('Update tournament status error:', error);
      showNotification('error', 'Failed to update tournament status');
    }
  }

  function updateStats() {
    if ($tournaments) {
      const activeTournaments = $tournaments.filter(t => t.status === 'active').length;
      const registrationOpen = $tournaments.filter(t => t.status === 'registration').length;
      const totalTeams = $tournaments.reduce((sum, t) => sum + (t.current_teams || 0), 0);
      
      stats = {
        activeTournaments,
        registrationOpen,
        totalTeams,
        totalPlayers: totalTeams * 3 // Estimated average team size
      };
    }
  }

  onMount(() => {
    nui.post('getTournaments', {});
  });

  $effect(() => {
    updateStats();
  });
</script>

<div class="max-w-7xl mx-auto p-6">
  <div class="mb-8">
    <h1 class="text-3xl font-bold text-white mb-2 flex items-center gap-3">
      <i class="fas fa-shield-alt text-red-500"></i>
      Administration Panel
    </h1>
    <p class="text-gray-400">Manage tournaments, teams, and system settings</p>
  </div>

  <!-- Admin Stats -->
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
    <div class="card">
      <div class="flex items-center gap-4">
        <div class="w-16 h-16 bg-green-500/20 rounded-xl flex items-center justify-center">
          <i class="fas fa-play text-2xl text-green-500"></i>
        </div>
        <div>
          <div class="text-3xl font-bold text-white">{stats.activeTournaments}</div>
          <div class="text-sm text-gray-400">Active Tournaments</div>
        </div>
      </div>
    </div>

    <div class="card">
      <div class="flex items-center gap-4">
        <div class="w-16 h-16 bg-blue-500/20 rounded-xl flex items-center justify-center">
          <i class="fas fa-clock text-2xl text-blue-500"></i>
        </div>
        <div>
          <div class="text-3xl font-bold text-white">{stats.registrationOpen}</div>
          <div class="text-sm text-gray-400">Registration Open</div>
        </div>
      </div>
    </div>

    <div class="card">
      <div class="flex items-center gap-4">
        <div class="w-16 h-16 bg-purple-500/20 rounded-xl flex items-center justify-center">
          <i class="fas fa-users text-2xl text-purple-500"></i>
        </div>
        <div>
          <div class="text-3xl font-bold text-white">{stats.totalTeams}</div>
          <div class="text-sm text-gray-400">Total Teams</div>
        </div>
      </div>
    </div>

    <div class="card">
      <div class="flex items-center gap-4">
        <div class="w-16 h-16 bg-yellow-500/20 rounded-xl flex items-center justify-center">
          <i class="fas fa-user-friends text-2xl text-yellow-500"></i>
        </div>
        <div>
          <div class="text-3xl font-bold text-white">{stats.totalPlayers}</div>
          <div class="text-sm text-gray-400">Est. Players</div>
        </div>
      </div>
    </div>
  </div>

  <!-- Quick Actions -->
  <div class="card mb-8">
    <h3 class="text-xl font-semibold text-white mb-4">Quick Actions</h3>
    <div class="flex gap-4 flex-wrap">
      <button class="btn btn-primary" onclick={openCreateModal}>
        <i class="fas fa-plus"></i>
        Create Tournament
      </button>
      <!-- <button class="btn btn-secondary">
        <i class="fas fa-download"></i>
        Export Data
      </button> -->
      <button class="btn btn-secondary">
        <i class="fas fa-chart-bar"></i>
        View Analytics
      </button>
      <button class="btn btn-outline">
        <i class="fas fa-cog"></i>
        System Settings
      </button>
    </div>
  </div>

  <!-- Tournament Management -->
  <div class="card">
    <h3 class="text-xl font-semibold text-white mb-6">Tournament Management</h3>
    
    {#if $tournaments.length === 0}
      <div class="text-center py-8">
        <i class="fas fa-trophy text-4xl text-gray-400 mb-4"></i>
        <p class="text-gray-400">No tournaments created yet</p>
        <button class="btn btn-primary mt-4" onclick={openCreateModal}>
          Create Your First Tournament
        </button>
      </div>
    {:else}
      <div class="space-y-4">
        {#each $tournaments as tournament}
          <div class="bg-white/5 rounded-lg p-6 border border-white/10">
            <div class="flex justify-between items-start mb-4">
              <div>
                <h4 class="text-lg font-semibold text-white">{tournament.name}</h4>
                <p class="text-gray-400 text-sm">{tournament.description || 'No description'}</p>
              </div>
              <span class="status-badge {tournament.status === 'active' ? 'status-active' : tournament.status === 'registration' ? 'status-registration' : 'status-completed'}">
                {tournament.status.toUpperCase()}
              </span>
            </div>

            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4">
              <div>
                <div class="text-sm text-gray-400">Teams</div>
                <div class="text-white font-medium">{tournament.current_teams || 0}/{tournament.max_teams}</div>
              </div>
              <div>
                <div class="text-sm text-gray-400">Fee</div>
                <div class="text-white font-medium">{nui.formatMoney(tournament.registration_fee)}</div>
              </div>
              <div>
                <div class="text-sm text-gray-400">Prize Pool</div>
                <div class="text-white font-medium">{nui.formatMoney(tournament.prize_pool)}</div>
              </div>
              <div>
                <div class="text-sm text-gray-400">Start Date</div>
                <div class="text-white font-medium">{new Date(tournament.start_date).toLocaleDateString()}</div>
              </div>
            </div>

            <div class="flex gap-2 flex-wrap">
              {#if tournament.status === 'registration'}
                <button 
                  class="btn btn-success btn-small"
                  onclick={() => toggleTournamentStatus(tournament.id, 'active')}
                >
                  <i class="fas fa-play"></i>
                  Start Tournament
                </button>
              {/if}
              
              {#if tournament.status === 'active'}
                <button 
                  class="btn btn-secondary btn-small"
                  onclick={() => toggleTournamentStatus(tournament.id, 'completed')}
                >
                  <i class="fas fa-stop"></i>
                  End Tournament
                </button>
              {/if}

              <button class="btn btn-secondary btn-small">
                <i class="fas fa-edit"></i>
                Edit
              </button>
              
              <button class="btn btn-secondary btn-small">
                <i class="fas fa-users"></i>
                Manage Teams
              </button>
              
              <button 
                class="btn btn-danger btn-small"
                onclick={() => deleteTournament(tournament.id)}
              >
                <i class="fas fa-trash"></i>
                Delete
              </button>
            </div>
          </div>
        {/each}
      </div>
    {/if}
  </div>
</div>

<!-- Create Tournament Modal -->
{#if showCreateModal}
  <div class="fixed inset-0 bg-black/70 flex items-center justify-center z-50">
    <div class="bg-dark-800/95 border border-white/20 rounded-2xl p-8 max-w-lg w-full mx-4 animate-scale-in">
      <h3 class="text-2xl font-bold text-white mb-6 flex items-center gap-3">
        <i class="fas fa-trophy text-primary-500"></i>
        Create New Tournament
      </h3>

      <form onsubmit={(e) => { e.preventDefault(); createTournament(); }}>
        <div class="space-y-4 mb-6">
          <div>
            <label class="block text-sm font-medium text-gray-300 mb-2" for="tournament-name">
              Tournament Name *
            </label>
            <input
              type="text"
              id="tournament-name"
              class="input"
              bind:value={createTournamentForm.name}
              placeholder="Enter tournament name"
              required
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-300 mb-2" for="tournament-description">
              Description
            </label>
            <textarea
              id="tournament-description"
              class="textarea"
              bind:value={createTournamentForm.description}
              placeholder="Tournament description (optional)"
              rows="3"
            ></textarea>
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-300 mb-2" for="max-teams">
                Max Teams
              </label>
              <input
                type="number"
                id="max-teams"
                class="input"
                bind:value={createTournamentForm.maxTeams}
                min="4"
                max="64"
                required
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-300 mb-2" for="start-date">
                Start Date
              </label>
              <input
                type="datetime-local"
                id="start-date"
                class="input"
                bind:value={createTournamentForm.startDate}
                required
              />
            </div>
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-300 mb-2" for="registration-fee">
                Registration Fee ($)
              </label>
              <input
                type="number"
                id="registration-fee"
                class="input"
                bind:value={createTournamentForm.registrationFee}
                min="0"
                step="1000"
                required
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-300 mb-2" for="prize-pool">
                Prize Pool ($)
              </label>
              <input
                type="number"
                id="prize-pool"
                class="input"
                bind:value={createTournamentForm.prizePool}
                min="0"
                step="10000"
                required
              />
            </div>
          </div>
        </div>

        <div class="flex gap-3">
          <button type="submit" class="btn btn-primary flex-1">
            <i class="fas fa-check"></i>
            Create Tournament
          </button>
          <button type="button" class="btn btn-secondary" onclick={closeCreateModal}>
            Cancel
          </button>
        </div>
      </form>
    </div>
  </div>
{/if}