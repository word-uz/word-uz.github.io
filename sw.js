// Hujjat Pro — offline ishlash uchun service worker
const VER = 'hujjat-v5';
const SHELL = ['./', './index.html', './favicon.svg', './manifest.webmanifest', './icons/icon-192.png', './icons/icon-512.png'];
const LIBS = [
  'https://cdn.jsdelivr.net/npm/docx@9.0.2/build/index.umd.js',
  'https://cdn.jsdelivr.net/npm/mammoth@1.8.0/mammoth.browser.min.js',
  'https://cdn.jsdelivr.net/npm/jszip@3.10.1/dist/jszip.min.js',
  'https://cdn.jsdelivr.net/npm/mathlive@0.101.0/dist/mathlive.min.js',
  'https://cdn.jsdelivr.net/npm/mathlive@0.101.0/dist/mathlive-static.css'
];

self.addEventListener('install', e => {
  e.waitUntil((async () => {
    const c = await caches.open(VER);
    await c.addAll(SHELL);
    // kutubxonalar: biri yuklanmasa ham o'rnatish to'xtamaydi
    await Promise.all(LIBS.map(u => c.add(u).catch(() => {})));
    self.skipWaiting();
  })());
});

self.addEventListener('activate', e => {
  e.waitUntil((async () => {
    for (const k of await caches.keys()) if (k !== VER) await caches.delete(k);
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  // sahifaning o'zi: avval internetdan (yangilanishlar uchun), bo'lmasa keshdan
  if (req.mode === 'navigate') {
    e.respondWith(fetch(req).then(r => { caches.open(VER).then(c => c.put('./index.html', r.clone())); return r; })
      .catch(() => caches.match('./index.html')));
    return;
  }
  // qolganlari (ikonkalar, kutubxonalar): avval keshdan
  if (url.origin === location.origin || url.hostname === 'cdn.jsdelivr.net') {
    e.respondWith(caches.match(req).then(hit => hit || fetch(req).then(r => {
      if (r.ok) { const cp = r.clone(); caches.open(VER).then(c => c.put(req, cp)); }
      return r;
    })));
  }
});
