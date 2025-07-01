<script>
  import { notifications, removeNotification } from '../utils/notifications.js';

  function getNotificationIcon(type) {
    const icons = {
      success: 'fas fa-check-circle',
      error: 'fas fa-exclamation-circle',
      warning: 'fas fa-exclamation-triangle',
      info: 'fas fa-info-circle'
    };
    return icons[type] || 'fas fa-bell';
  }
</script>

<div class="fixed top-4 right-4 z-50 space-y-2 pointer-events-none">
  {#each $notifications as notification (notification.id)}
    <div class="notification notification-{notification.type} pointer-events-auto max-w-sm">
      <div class="flex items-start gap-3">
        <i class="{getNotificationIcon(notification.type)} text-lg mt-0.5"></i>
        <div class="flex-1">
          <p class="text-white text-sm">{notification.message}</p>
        </div>
        <button 
          class="text-gray-400 hover:text-white transition-colors"
          onclick={() => removeNotification(notification.id)}
          aria-label="Close notification"
        >
          <i class="fas fa-times"></i>
        </button>
      </div>
    </div>
  {/each}
</div>