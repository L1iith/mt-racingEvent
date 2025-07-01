import { writable } from 'svelte/store';

export const playerTeams = writable([]);
export const activeTeam = writable(null);
export const teamMembers = writable([]);
export const teamStatus = writable('loading');
export const searchResults = writable([]);

export const teamActions = {
  setPlayerTeams(data) {
    playerTeams.set(data || []);
    teamStatus.set('ready');
  },

  setActiveTeam(team) {
    activeTeam.set(team);
    if (team && team.members) {
      teamMembers.set(team.members);
    }
  },

  setStatus(status) {
    teamStatus.set(status);
  },

  addTeam(team) {
    playerTeams.update(list => [...list, team]);
  },

  updateTeam(teamId, updates) {
    playerTeams.update(list => 
      list.map(t => t.id === teamId ? { ...t, ...updates } : t)
    );
    
    activeTeam.update(current => 
      current && current.id === teamId ? { ...current, ...updates } : current
    );
  },

  removeTeam(teamId) {
    playerTeams.update(list => list.filter(t => t.id !== teamId));
    
    activeTeam.update(current => 
      current && current.id === teamId ? null : current
    );
  },

  addMember(teamId, member) {
    playerTeams.update(list => 
      list.map(team => {
        if (team.id === teamId) {
          const updatedMembers = [...(team.members || []), member];
          return { ...team, members: updatedMembers };
        }
        return team;
      })
    );

    activeTeam.update(current => {
      if (current && current.id === teamId) {
        const updatedMembers = [...(current.members || []), member];
        teamMembers.set(updatedMembers);
        return { ...current, members: updatedMembers };
      }
      return current;
    });
  },

  removeMember(teamId, memberId) {
    playerTeams.update(list => 
      list.map(team => {
        if (team.id === teamId) {
          const updatedMembers = (team.members || []).filter(m => m.id !== memberId);
          return { ...team, members: updatedMembers };
        }
        return team;
      })
    );

    activeTeam.update(current => {
      if (current && current.id === teamId) {
        const updatedMembers = (current.members || []).filter(m => m.id !== memberId);
        teamMembers.set(updatedMembers);
        return { ...current, members: updatedMembers };
      }
      return current;
    });
  },

  setSearchResults(results) {
    searchResults.set(results || []);
  },

  clear() {
    playerTeams.set([]);
    activeTeam.set(null);
    teamMembers.set([]);
    teamStatus.set('loading');
    searchResults.set([]);
  }
};

export const teamFormatters = {
  formatRole(role) {
    const roleMap = {
      'captain': 'Captain',
      'driver': 'Driver',
      'navigator': 'Navigator',
      'mechanic1': 'Mechanic',
      'mechanic2': 'Mechanic'
    };
    return roleMap[role] || role;
  },

  formatStatus(status) {
    const statusMap = {
      'registered': 'Registered',
      'active': 'Active',
      'eliminated': 'Eliminated',
      'disqualified': 'Disqualified'
    };
    return statusMap[status] || status;
  },

  getRoleIcon(role) {
    const iconMap = {
      'captain': 'fas fa-crown',
      'driver': 'fas fa-car',
      'navigator': 'fas fa-map',
      'mechanic1': 'fas fa-wrench',
      'mechanic2': 'fas fa-tools'
    };
    return iconMap[role] || 'fas fa-user';
  },

  formatRecord(wins, losses) {
    return `${wins}W - ${losses}L`;
  }
};