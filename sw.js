/* Anje's Recipes: offline helper.
   Keeps a copy of the site on the device so it opens without internet.
   VERSION is filled in by build.sh on every build. */
const VERSION = '20261111033511';
const CORE = 'anje-core-' + VERSION;
const LIBS = 'anje-libs-v1';      // fonts and pinned library versions never change, keep across builds
const PICS = 'anje-photos-v1';    // recipe photos

const CORE_FILES = ['./', './index.html', './manifest.webmanifest', './icon-192.png', './icon-512.png',
  './photos/mustard-fish.jpg', './photos/bang-bang-prawns.jpg', './photos/brownies.jpg'];
const LIB_FILES = [
  'https://cdn.jsdelivr.net/npm/cropperjs@1.6.2/dist/cropper.min.js',
  'https://cdn.jsdelivr.net/npm/cropperjs@1.6.2/dist/cropper.min.css',
  'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.49.4/dist/umd/supabase.js',
];

self.addEventListener('install', e => {
  e.waitUntil((async () => {
    const core = await caches.open(CORE);
    await core.addAll(CORE_FILES.map(u => new Request(u, { cache: 'reload' })));
    const libs = await caches.open(LIBS);
    await Promise.all(LIB_FILES.map(u => libs.match(u).then(hit => hit || libs.add(u)).catch(() => {})));
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', e => {
  e.waitUntil((async () => {
    for (const k of await caches.keys()) if (k.startsWith('anje-core-') && k !== CORE) await caches.delete(k);
    await self.clients.claim();
  })());
});

const fromCache = async (cacheName, req) => (await caches.open(cacheName)).match(req, { ignoreSearch: cacheName === CORE });
async function put(cacheName, req, res){
  if (res && (res.ok || res.type === 'opaque')) { try { (await caches.open(cacheName)).put(req, res.clone()); } catch {} }
  return res;
}

self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);

  // the page itself: newest version when online, saved copy when offline
  if (req.mode === 'navigate') {
    e.respondWith(fetch(req).then(res => put(CORE, './index.html', res))
      .catch(async () => (await fromCache(CORE, './index.html')) || (await fromCache(CORE, './'))));
    return;
  }
  // sync traffic and sign-in always go to the network
  if (url.hostname.endsWith('supabase.co') && !url.pathname.startsWith('/storage/v1/object/public/')) return;

  // recipe photos stored in the cloud: saved once, then served from the device
  if (url.hostname.endsWith('supabase.co')) {
    e.respondWith(fromCache(PICS, req).then(hit => hit || fetch(req).then(res => put(PICS, req, res))));
    return;
  }
  // fonts and libraries (crop tool, text reader, sync): saved the first time they're used
  if (url.hostname === 'fonts.googleapis.com' || url.hostname === 'fonts.gstatic.com' || url.hostname === 'cdn.jsdelivr.net') {
    e.respondWith(fromCache(LIBS, req).then(hit => hit || fetch(req).then(res => put(LIBS, req, res))));
    return;
  }
  // the site's own files
  if (url.origin === self.location.origin) {
    e.respondWith(fetch(req).then(res => put(CORE, req, res)).catch(() => fromCache(CORE, req)));
  }
});
