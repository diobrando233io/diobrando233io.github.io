const assets = [
  { 
    name: 'data-v9',
    urls: [
      './data/accessories.json',
      './data/accessories2.json',
      './data/shaders/ham/config.json',
      './data/shaders/ham/custom.fragment.fx',
    ],
  },
  { 
    name: 'fonts-v7',
    urls: [
      './fonts/ham-font.eot',
      './fonts/ham-font.svg',
      './fonts/ham-font.ttf',
      './fonts/ham-font.woff',
      './fonts/muli_v22_latin.woff2',
    ],
  },
  { 
    name: 'images-v8',
    urls: [
      './images/starter1.png',
      './images/starter2.png',
      './images/starter3.png',
      './images/starter4.png',
      './images/splash.png',
      './images/spinner_512.png',
      './images/icon_192.png',
      './images/icon_512.png',
      './images/maskable_icon_x64.png',
      './images/maskable_icon_x72.png',
      './images/maskable_icon_x96.png',
      './images/maskable_icon_x128.png',
      './images/maskable_icon_x144.png',
      './images/maskable_icon_x152.png',
      './images/maskable_icon_x512.png',
      './favicon.ico'
    ],
  },
  { 
    name: 'jslibs-v17',
    urls: [
      './js/pep.min.js',
      './js/babylon.js',
      './js/libs.js',
    ],
  },
  { 
    name: 'ham-v455',
    urls: [
      './css/styles.min.css',
      './js/ham.min.js',
      './index.html',
      './'
    ],
  },
];

self.addEventListener('install', function(event) {
  event.waitUntil(
    assets.map(function (myCache) {
      return caches.open(myCache.name).then(function(cache) {
        return cache.addAll(myCache.urls);
      })
    })
  );
});

self.addEventListener('activate', event => {
  let cacheAllowlist = assets.map((cache) => cache.name);
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheAllowlist.indexOf(cacheName) === -1) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

self.addEventListener("fetch", fetchEvent => {
  fetchEvent.respondWith(
    caches.match(fetchEvent.request, {ignoreSearch:true}).then(res => {
      return res || fetch(fetchEvent.request);
      //return fetch(fetchEvent.request) || res;
      //return fetch(fetchEvent.request);
    })
  )
});