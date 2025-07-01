<script>
  import { playerTeams } from '../stores/team.js';
  import { teamFormatters } from '../stores/team.js';
  import { nui } from '../utils/nui.js';
  import { showNotification } from '../utils/notifications.js';
  import { onMount } from 'svelte';

  let showTeamModal = $state(false);
  let selectedTeam = $state(null);
  let modalType = $state('details'); // 'details', 'manage', 'leave'

  function openTeamModal(team, type = 'details') {
    selectedTeam = team;
    modalType = type;
    showTeamModal = true;
  }

  function closeTeamModal() {
    showTeamModal = false;
    selectedTeam = null;
  }

  async function leaveTeam(teamId) {
    try {
      await nui.post('leaveTeam', { teamId });
      showNotification('info', 'You have left the team');
      closeTeamModal();
      nui.playSound('BACK');
    } catch (error) {
      console.error('Leave team error:', error);
      showNotification('error', 'Failed to leave team');
    }
  }

  function getStatusClass(status) {
    const classes = {
      'registered': 'status-registration',
      'active': 'status-active',
      'eliminated': 'status-cancelled',
      'disqualified': 'status-cancelled'
    };
    return classes[status] || 'status-registration';
  }

  onMount(() => {
    nui.post('getPlayerTeams', {});
  });
</script>

<div class="max-w-7xl mx-auto p-6">
  <div class="mb-8">
    <h1 class="text-3xl font-bold text-white mb-2">My Teams</h1>
    <p class="text-gray-400">Manage your racing teams and track performance</p>
  </div>

  {#if $playerTeams.length === 0}
    <div class="card text-center py-12">
      <i class="fas fa-users text-6xl text-gray-400 mb-4"></i>
      <h3 class="text-2xl font-semibold text-white mb-2">No Teams Found</h3>
      <p class="text-gray-400 mb-6">You are not currently part of any teams. Join a tournament to create or join a team!</p>
      <button class="btn btn-primary" onclick={() => window.app?.switchView('tournaments')}>
        <i class="fas fa-trophy"></i>
        View Tournaments
      </button>
    </div>
  {:else}
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      {#each $playerTeams as team}
        <div class="card group">
          <div class="flex justify-between items-start mb-4">
            <div>
              <h3 class="text-xl font-semibold text-white flex items-center gap-2">
                {#if team.team_tag}
                  <span class="text-primary-500">[{team.team_tag}]</span>
                {/if}
                {team.team_name}
              </h3>
              <p class="text-sm text-gray-400">{team.tournament_name}</p>
            </div>
            <span class="status-badge {getStatusClass(team.status)}">
              <i class="fas fa-circle text-xs"></i>
              {teamFormatters.formatStatus(team.status)}
            </span>
          </div>

          <div class="grid grid-cols-2 gap-4 mb-6">
            <div class="text-center">
              <div class="text-2xl font-bold text-white">{team.total_points || 0}</div>
              <div class="text-xs text-gray-400">Points</div>
            </div>
            <div class="text-center">
              <div class="text-2xl font-bold text-white">{teamFormatters.formatRecord(team.wins || 0, team.losses || 0)}</div>
              <div class="text-xs text-gray-400">Record</div>
            </div>
          </div>

          <div class="mb-4">
            <div class="flex items-center gap-2 mb-2">
              <i class="{teamFormatters.getRoleIcon(team.role)} text-primary-500"></i>
              <span class="text-white font-medium">{teamFormatters.formatRole(team.role)}</span>
            </div>
            {#if team.members}
              <div class="text-sm text-gray-400">
                {team.members.length}/4 members
              </div>
            {/if}
          </div>

          <div class="flex gap-2">
            <button 
              class="btn btn-secondary btn-small flex-1"
              onclick={() => openTeamModal(team, 'details')}
            >
              <i class="fas fa-eye"></i>
              Details
            </button>
            
            {#if team.role === 'captain'}
              <button 
                class="btn btn-primary btn-small"
                onclick={() => openTeamModal(team, 'manage')}
              >
                <i class="fas fa-cog"></i>
                Manage
              </button>
            {/if}
            
            <button 
              class="btn btn-danger btn-small"
              onclick={() => openTeamModal(team, 'leave')}
            >
              <i class="fas fa-sign-out-alt"></i>
              Leave
            </button>
          </div>
        </div>
      {/each}
    </div>
  {/if}
</div>

<!-- Team Modal -->
{#if showTeamModal && selectedTeam}
  <div class="fixed inset-0 bg-black/70 flex items-center justify-center z-50 backdrop-blur-sm">
    <div class="bg-dark-800/95 border border-white/20 rounded-2xl p-8 max-w-2xl w-full mx-4 animate-scale-in max-h-[90vh] overflow-y-auto">
      
      {#if modalType === 'details'}
        <div class="mb-6">
          <h3 class="text-2xl font-bold text-white mb-2 flex items-center gap-3">
            <i class="fas fa-users text-primary-500"></i>
            {selectedTeam.team_name}
          </h3>
          <p class="text-gray-400">{selectedTeam.tournament_name}</p>
        </div>

        <div class="grid grid-cols-2 gap-6 mb-6">
          <div>
            <h4 class="text-lg font-semibold text-white mb-3">Team Statistics</h4>
            <div class="space-y-2">
              <div class="flex justify-between">
                <span class="text-gray-400">Points:</span>
                <span class="text-white font-medium">{selectedTeam.total_points || 0}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-400">Wins:</span>
                <span class="text-green-400 font-medium">{selectedTeam.wins || 0}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-400">Losses:</span>
                <span class="text-red-400 font-medium">{selectedTeam.losses || 0}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-400">Status:</span>
                <span class="status-badge {getStatusClass(selectedTeam.status)} text-xs">
                  {teamFormatters.formatStatus(selectedTeam.status)}
                </span>
              </div>
            </div>
          </div>
          
          <div>
            <h4 class="text-lg font-semibold text-white mb-3">Your Role</h4>
            <div class="flex items-center gap-3 p-3 bg-white/5 rounded-lg">
              <i class="{teamFormatters.getRoleIcon(selectedTeam.role)} text-primary-500 text-xl"></i>
              <div>
                <div class="text-white font-medium">{teamFormatters.formatRole(selectedTeam.role)}</div>
                <div class="text-gray-400 text-sm">Team {selectedTeam.role}</div>
              </div>
            </div>
          </div>
        </div>

        {#if selectedTeam.members}
          <div class="mb-6">
            <h4 class="text-lg font-semibold text-white mb-3">Team Members ({selectedTeam.members.length}/4)</h4>
            <div class="space-y-2">
              {#each selectedTeam.members as member}
                <div class="flex items-center justify-between p-3 bg-white/5 rounded-lg">
                  <div class="flex items-center gap-3">
                    <i class="{teamFormatters.getRoleIcon(member.role)} text-primary-500"></i>
                    <div>
                      <div class="text-white font-medium">{member.name}</div>
                      <div class="text-gray-400 text-sm">{teamFormatters.formatRole(member.role)}</div>
                    </div>
                  </div>
                  {#if member.role === 'captain'}
                    <span class="text-yellow-400 text-sm">
                      <i class="fas fa-crown"></i>
                      Captain
                    </span>
                  {/if}
                </div>
              {/each}
            </div>
          </div>
        {/if}

      {:else if modalType === 'leave'}
        <div class="text-center">
          <i class="fas fa-exclamation-triangle text-6xl text-yellow-500 mb-4"></i>
          <h3 class="text-2xl font-bold text-white mb-4">Leave Team</h3>
          <p class="text-gray-400 mb-6">
            Are you sure you want to leave <span class="text-white font-semibold">{selectedTeam.team_name}</span>? 
            This action cannot be undone.
          </p>
          
          <div class="flex gap-3 justify-center">
            <button 
              class="btn btn-danger"
              onclick={() => leaveTeam(selectedTeam.id)}
            >
              <i class="fas fa-sign-out-alt"></i>
              Leave Team
            </button>
            <button class="btn btn-secondary" onclick={closeTeamModal}>
              Cancel
            </button>
          </div>
        </div>

      {:else if modalType === 'manage'}
        <div class="mb-6">
          <h3 class="text-2xl font-bold text-white mb-2 flex items-center gap-3">
            <i class="fas fa-cog text-primary-500"></i>
            Manage {selectedTeam.team_name}
          </h3>
          <p class="text-gray-400">Team management features coming soon...</p>
        </div>
      {/if}

      <div class="flex justify-end pt-4 border-t border-white/10">
        <button class="btn btn-secondary" onclick={closeTeamModal}>
          Close
        </button>
      </div>
    </div>
  </div>
{/if}