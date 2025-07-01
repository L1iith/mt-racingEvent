<script>
  import { tournaments } from '../stores/tournament.js';
  import { nui } from '../utils/nui.js';
  import { showNotification } from '../utils/notifications.js';
  import { onMount } from 'svelte';

  let showRegistrationModal = $state(false);
  let selectedTournament = $state(null);
  let registrationForm = $state({
    teamName: '',
    teamTag: '',
    teamColor: '#ff6b35'
  });

  function openRegistrationModal(tournament) {
    selectedTournament = tournament;
    showRegistrationModal = true;
    registrationForm = {
      teamName: '',
      teamTag: '',
      teamColor: '#ff6b35'
    };
  }

  function closeRegistrationModal() {
    showRegistrationModal = false;
    selectedTournament = null;
  }

  async function submitRegistration() {
    if (!selectedTournament || !registrationForm.teamName.trim()) {
      showNotification('error', 'Please enter a team name');
      return;
    }

    try {
      await nui.post('registerTeam', {
        tournamentId: selectedTournament.id,
        teamData: {
          name: registrationForm.teamName.trim(),
          tag: registrationForm.teamTag.trim(),
          color: registrationForm.teamColor
        }
      });
      
      showNotification('success', 'Team registered successfully!');
      closeRegistrationModal();
      nui.playSound('SELECT');
    } catch (error) {
      console.error('Registration error:', error);
      showNotification('error', 'Failed to register team');
    }
  }

  function getStatusClass(status) {
    const classes = {
      'registration': 'status-registration',
      'active': 'status-active',
      'completed': 'status-completed',
      'cancelled': 'status-cancelled'
    };
    return classes[status] || 'status-registration';
  }

  onMount(() => {
    nui.post('getTournaments', {});
  });
</script>

<div class="max-w-7xl mx-auto p-6">
  <div class="mb-8">
    <h1 class="text-3xl font-bold text-white mb-2">Available Tournaments</h1>
    <p class="text-gray-400">Register your team and compete for glory and prizes</p>
  </div>

  {#if $tournaments.length === 0}
    <div class="card text-center py-12">
      <i class="fas fa-trophy text-6xl text-gray-400 mb-4"></i>
      <h3 class="text-2xl font-semibold text-white mb-2">No Active Tournaments</h3>
      <p class="text-gray-400">There are currently no tournaments available for registration.</p>
    </div>
  {:else}
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      {#each $tournaments as tournament}
        <div class="card group">
          <div class="flex justify-between items-start mb-4">
            <h3 class="text-xl font-semibold text-white">{tournament.name}</h3>
            <span class="status-badge {getStatusClass(tournament.status)}">
              <i class="fas fa-circle text-xs"></i>
              {tournament.status.toUpperCase()}
            </span>
          </div>

          <div class="space-y-3 mb-6">
            <div class="flex justify-between">
              <span class="text-gray-400">Start Date:</span>
              <span class="text-white">{new Date(tournament.start_date).toLocaleString()}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-400">Teams:</span>
              <span class="text-white">{tournament.current_teams}/{tournament.max_teams}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-400">Registration Fee:</span>
              <span class="text-green-400 font-semibold">{nui.formatMoney(tournament.registration_fee)}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-400">Prize Pool:</span>
              <span class="text-yellow-400 font-semibold">{nui.formatMoney(tournament.prize_pool)}</span>
            </div>
          </div>

          {#if tournament.description}
            <p class="text-gray-300 text-sm mb-6">{tournament.description}</p>
          {/if}

          <div class="flex gap-2">
            {#if tournament.status === 'registration'}
              <button 
                class="btn btn-primary flex-1"
                onclick={() => openRegistrationModal(tournament)}
              >
                <i class="fas fa-plus"></i>
                Register Team
              </button>
            {:else}
              <button class="btn btn-secondary flex-1" disabled>
                <i class="fas fa-clock"></i>
                Registration Closed
              </button>
            {/if}
            <button class="btn btn-outline">
              <i class="fas fa-info-circle"></i>
              Details
            </button>
          </div>
        </div>
      {/each}
    </div>
  {/if}
</div>

<!-- Registration Modal -->
{#if showRegistrationModal && selectedTournament}
  <div class="fixed inset-0 bg-black/70 flex items-center justify-center z-50 backdrop-blur-sm">
    <div class="bg-dark-800/95 border border-white/20 rounded-2xl p-8 max-w-md w-full mx-4 animate-scale-in">
      <h3 class="text-2xl font-bold text-white mb-6 flex items-center gap-3">
        <i class="fas fa-trophy text-primary-500"></i>
        Register for {selectedTournament.name}
      </h3>

      <form onsubmit={(e) => { e.preventDefault(); submitRegistration(); }}>
        <div class="space-y-4 mb-6">
          <div>
            <label class="block text-sm font-medium text-gray-300 mb-2" for="team-name">
              Team Name *
            </label>
            <input
              type="text"
              id="team-name"
              class="input"
              bind:value={registrationForm.teamName}
              placeholder="Enter team name"
              required
              minlength="3"
              maxlength="30"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-300 mb-2" for="team-tag">
              Team Tag (Optional)
            </label>
            <input
              type="text"
              id="team-tag"
              class="input"
              bind:value={registrationForm.teamTag}
              placeholder="TAG"
              maxlength="5"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-300 mb-2" for="team-color">
              Team Color
            </label>
            <input
              type="color"
              id="team-color"
              class="input h-12"
              bind:value={registrationForm.teamColor}
            />
          </div>

          <div class="bg-yellow-500/10 border border-yellow-500/30 rounded-lg p-4">
            <div class="flex items-center gap-2 text-yellow-400 mb-2">
              <i class="fas fa-exclamation-triangle"></i>
              <span class="font-medium">Registration Fee</span>
            </div>
            <p class="text-white font-semibold">{nui.formatMoney(selectedTournament.registration_fee)}</p>
          </div>
        </div>

        <div class="flex gap-3">
          <button type="submit" class="btn btn-primary flex-1">
            <i class="fas fa-check"></i>
            Register Team
          </button>
          <button type="button" class="btn btn-secondary" onclick={closeRegistrationModal}>
            Cancel
          </button>
        </div>
      </form>
    </div>
  </div>
{/if}