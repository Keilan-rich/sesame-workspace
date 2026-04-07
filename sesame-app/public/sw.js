const CACHE_NAME = 'sesame-v4';
const ASSETS = [
  '/manifest.json',
  '/icon.svg'
];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE_NAME).then(c => c.addAll(ASSETS)));
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

// ─── PUSH NOTIFICATIONS ─────────────────────────────────────────────────────
self.addEventListener('push', e => {
  const data = e.data ? e.data.json() : {};
  const title = data.title || 'Sesame Train';
  const options = {
    body: data.body || 'Ta session du jour t\'attend !',
    icon: '/icon-192.png',
    badge: '/icon-192.png',
    tag: 'sesame-daily',
    renotify: true,
  };
  e.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener('notificationclick', e => {
  e.notification.close();
  e.waitUntil(clients.openWindow('/'));
});

// ─── PERIODIC LOCAL NOTIFICATIONS ───────────────────────────────────────────
// Since we don't have a push server, schedule local notifications via message
self.addEventListener('message', e => {
  if (e.data && e.data.type === 'SCHEDULE_NOTIF') {
    const delay = e.data.delay || 8 * 3600 * 1000; // default 8h
    const msgs = [
      'Ta session du jour t\'attend !',
      'Ne perds pas ton streak — reviens faire une session.',
      'J-2 avant le concours. Chaque question compte.',
      'Revise tes erreurs, c\'est la que tu gagnes le plus de points.',
    ];
    const body = msgs[Math.floor(Math.random() * msgs.length)];
    setTimeout(() => {
      self.registration.showNotification('Sesame Train', {
        body,
        icon: '/icon-192.png',
        badge: '/icon-192.png',
        tag: 'sesame-reminder',
        renotify: true,
      });
    }, delay);
  }
});

self.addEventListener('fetch', e => {
  const url = new URL(e.request.url);

  // NEVER cache HTML pages or Supabase auth — always network
  if (e.request.mode === 'navigate' ||
      url.pathname.endsWith('.html') ||
      url.pathname === '/' ||
      url.hostname.includes('supabase')) {
    e.respondWith(fetch(e.request).catch(() => caches.match(e.request)));
    return;
  }

  // Network-first for API calls
  if (url.pathname.includes('/rest/') || url.pathname.includes('/api/')) {
    e.respondWith(fetch(e.request).catch(() => caches.match(e.request)));
    return;
  }

  // Cache-first only for static assets (icons, manifest, fonts)
  e.respondWith(
    caches.match(e.request).then(r => r || fetch(e.request).then(res => {
      const clone = res.clone();
      caches.open(CACHE_NAME).then(c => c.put(e.request, clone));
      return res;
    }))
  );
});
