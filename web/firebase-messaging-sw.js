importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIza' + 'SyB73ovBXEht49nlvCfO4zSSJlPHrSvQROY',
  appId: '1:842933413489:web:e156d51865070a60fc1dd0',
  messagingSenderId: '842933413489',
  projectId: 'meal-manager-844f5',
  authDomain: 'meal-manager-844f5.firebaseapp.com',
  storageBucket: 'meal-manager-844f5.firebasestorage.app',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification.title || 'Mess Manager';
  const notificationOptions = {
    body: payload.notification.body || 'Cutoff reminder',
    icon: '/favicon.png',
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
