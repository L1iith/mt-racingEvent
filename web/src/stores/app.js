import { writable } from 'svelte/store';

export const currentView = writable('main');
export const isVisible = writable(false);
export const playerData = writable(null);
export const isAdmin = writable(false);
export const loading = writable(false);

export const appActions = {
  setView(view) {
    currentView.set(view);
  },

  setVisible(visible) {
    isVisible.set(visible);
  },

  setPlayerData(data) {
    playerData.set(data);
  },

  setAdmin(admin) {
    isAdmin.set(admin);
  },

  setLoading(loadingState) {
    loading.set(loadingState);
  },

  openTournament(admin = false, data = null) {
    isAdmin.set(admin);
    playerData.set(data);
    isVisible.set(true);
    currentView.set('main');
  },

  closeTournament() {
    isVisible.set(false);
    currentView.set('main');
    playerData.set(null);
    isAdmin.set(false);
  }
};