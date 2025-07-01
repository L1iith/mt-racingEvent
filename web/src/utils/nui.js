class NUIManager {
  constructor() {
    this.callbacks = new Map();
    this.setupEventListeners();
  }

  setupEventListeners() {
    window.addEventListener('message', (event) => this.handleNUIMessage(event));
    
    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape') {
        this.post('closeTournament', {});
      }
    });
  }

  handleNUIMessage(event) {
    const { type, data } = event.data;
    
    if (this.callbacks.has(type)) {
      this.callbacks.get(type)(data);
    }
  }

  on(eventType, callback) {
    this.callbacks.set(eventType, callback);
  }

  off(eventType) {
    this.callbacks.delete(eventType);
  }

  async post(callback, data = {}) {
    try {
      const response = await fetch(`https://${GetParentResourceName()}/${callback}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data)
      });
      return await response.json();
    } catch (error) {
      console.error('NUI Post Error:', error);
      throw error;
    }
  }

  playSound(sound, soundSet = 'HUD_FRONTEND_DEFAULT_SOUNDSET') {
    this.post('playSound', { sound, soundSet });
  }

  formatMoney(amount) {
    return '$' + amount.toLocaleString();
  }
}

// Create global NUI manager instance
export const nui = new NUIManager();

// Make it available globally for backward compatibility
window.nui = nui;