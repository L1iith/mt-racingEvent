import { writable } from 'svelte/store';

export const tournaments = writable([]);
export const activeTournament = writable(null);
export const tournamentStatus = writable('loading');

export const tournamentActions = {
  setTournaments(data) {
    tournaments.set(data || []);
    tournamentStatus.set('ready');
  },

  setActiveTournament(tournament) {
    activeTournament.set(tournament);
  },

  setStatus(status) {
    tournamentStatus.set(status);
  },

  addTournament(tournament) {
    tournaments.update(list => [...list, tournament]);
  },

  updateTournament(tournamentId, updates) {
    tournaments.update(list => 
      list.map(t => t.id === tournamentId ? { ...t, ...updates } : t)
    );
    
    activeTournament.update(current => 
      current && current.id === tournamentId ? { ...current, ...updates } : current
    );
  },

  removeTournament(tournamentId) {
    tournaments.update(list => list.filter(t => t.id !== tournamentId));
    
    activeTournament.update(current => 
      current && current.id === tournamentId ? null : current
    );
  },

  clear() {
    tournaments.set([]);
    activeTournament.set(null);
    tournamentStatus.set('loading');
  }
};

export const tournamentFormatters = {
  formatMoney(amount) {
    return '$' + amount.toLocaleString();
  },

  formatDate(dateString) {
    return new Date(dateString).toLocaleString();
  },

  formatStatus(status) {
    const statusMap = {
      'registration': 'Registration Open',
      'active': 'Active',
      'completed': 'Completed',
      'cancelled': 'Cancelled'
    };
    return statusMap[status] || status;
  },

  getStatusIcon(status) {
    const iconMap = {
      'registration': 'fas fa-clock',
      'active': 'fas fa-play',
      'completed': 'fas fa-trophy',
      'cancelled': 'fas fa-ban'
    };
    return iconMap[status] || 'fas fa-question';
  }
};