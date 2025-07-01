import { onDestroy } from "svelte";

class NUIManager {
  constructor() {
    this.callbacks = new Map();
    this.eventListeners = new Map();
    this.resourceName = "mt-racingEvent";
    this.setupEventListeners();
  }

  setupEventListeners() {
    // Handle NUI messages
    window.addEventListener('message', (event) => this.handleMessage(event));

    // Handle escape key
    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape') {
        this.post('closeTournament');
        this.playSound('BACK');
      }
    });
  }

  handleMessage(event) {
    const { type, action, data } = event.data;

    // Handle callback-based events
    if (type && this.callbacks.has(type)) {
      this.callbacks.get(type)(data);
    }

    // Handle action-based events
    if (action && this.eventListeners.has(action)) {
      const handlers = this.eventListeners.get(action);
      handlers.forEach(handler => handler(data));
    }
  }

  // Callback-based event system
  on(eventType, callback) {
    this.callbacks.set(eventType, callback);
    return this;
  }

  off(eventType) {
    this.callbacks.delete(eventType);
    return this;
  }

  // Svelte-compatible event system with auto-cleanup
  useNuiEvent(action, handler) {
    const handlers = this.eventListeners.get(action) || [];
    handlers.push(handler);
    this.eventListeners.set(action, handlers);

    onDestroy(() => {
      const currentHandlers = this.eventListeners.get(action) || [];
      const filteredHandlers = currentHandlers.filter(h => h !== handler);

      if (filteredHandlers.length === 0) {
        this.eventListeners.delete(action);
      } else {
        this.eventListeners.set(action, filteredHandlers);
      }
    });

    return this;
  }

  // HTTP communication with the game
  async post(callback, data = {}) {
    try {
      const response = await fetch(`https://${this.resourceName}/${callback}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data)
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error(`NUI Post Error (${callback}):`, error);
      throw error;
    }
  }

  // Utility methods
  playSound(sound, soundSet = 'HUD_FRONTEND_DEFAULT_SOUNDSET') {
    return this.post('playSound', { sound, soundSet });
  }

  formatMoney(amount) {
    if (typeof amount !== 'number') {
      return '$0';
    }
    return '$' + amount.toLocaleString();
  }

  // Cleanup method for manual cleanup if needed
  destroy() {
    this.callbacks.clear();
    this.eventListeners.clear();
  }
}

// Create and export the global NUI manager instance
export const nui = new NUIManager();

// Make it available globally for backward compatibility
if (typeof window !== 'undefined') {
  window.nui = nui;
}