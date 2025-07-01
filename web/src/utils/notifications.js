import { writable } from 'svelte/store';

export const notifications = writable([]);

let notificationId = 0;

export function showNotification(type, message, duration = 5000) {
  const id = ++notificationId;
  const notification = {
    id,
    type,
    message,
    duration
  };

  notifications.update(list => [...list, notification]);

  if (duration > 0) {
    setTimeout(() => {
      removeNotification(id);
    }, duration);
  }

  return id;
}

export function removeNotification(id) {
  notifications.update(list => list.filter(n => n.id !== id));
}

export function clearNotifications() {
  notifications.set([]);
}