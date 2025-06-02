'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "938b01db6d6306bccc4ccc4573eba95e",
"assets/AssetManifest.bin.json": "997fe00ec01c867f0060005214399b05",
"assets/AssetManifest.json": "2718d3e7eee830000031b1f3ef18cda8",
"assets/assets/i18n/en.json": "3529798b6cae540650e44571a48439fe",
"assets/assets/i18n/es.json": "a037d37d267b4dd6af78d6fa812c0036",
"assets/assets/icon/ico.ico": "b335235108ed3e56ab82068fac7a5032",
"assets/assets/icon/icon_app.png": "cf2625d48109be1b0512987f7c86648d",
"assets/assets/icons/food.png": "2cbc65b2cf56e16ae596832734bd7ee1",
"assets/assets/icons/monuments.png": "1b5f3f45cfb173e90a6a5f05e410080f",
"assets/assets/images/puzzle_slider/Catedral%2520de%2520San%2520Bartolom%25C3%25A9.jpg": "d4a2cbee249ad498f1b41ceddd52c588",
"assets/assets/images/puzzle_slider/Mercado%2520de%2520Chill%25C3%25A1n.jpg": "b9cdd571162c0d038848d054cef8873d",
"assets/assets/images/puzzle_slider/Nevados%2520de%2520Chill%25C3%25A1n.jpg": "21bcdfe2dbf575a992f62de18b987904",
"assets/assets/images/puzzle_slider/Plaza%2520de%2520Armas%2520de%2520Chill%25C3%25A1n.jpg": "2e04e8a1f5a1bf8a9242f200fefcfb27",
"assets/assets/images/puzzle_slider/Termas%2520de%2520Chill%25C3%25A1n.jpg": "8fd0d61c95e2141a09fdb8ab21ba6eac",
"assets/assets/images/puzzle_slider/Vi%25C3%25B1edos%2520del%2520Valle%2520del%2520Itata.jpg": "00cc5142d9639225edb366b0553b1f7a",
"assets/assets/initial_content/missions/en.json": "e4262d12cf15f99b3743612fe23826b5",
"assets/assets/initial_content/missions/es.json": "2184fd9721cc7a155d5ce9466ae381cc",
"assets/assets/initial_content/puzzle_sliders/en.json": "cc1fadd8f6333593e6e64c1aeca89758",
"assets/assets/initial_content/puzzle_sliders/es.json": "a18d293065cd00d7d0e3ccabeff6fc19",
"assets/assets/initial_content/recommendations/en.json": "21dc220baf43ae4f69cc16356d4502a4",
"assets/assets/initial_content/recommendations/es.json": "ad2649673e42036c17ef9375982865d3",
"assets/assets/initial_content/stories/en.json": "6b5226339645e436362f53393abfe14d",
"assets/assets/initial_content/stories/es.json": "c0b855cd53947b975ed994ad52d559c9",
"assets/assets/initial_content/trivia/en.json": "d7c69aa2238a3f7f76427fa12f947164",
"assets/assets/initial_content/trivia/es.json": "c25b116db5c019422d34461890ae236d",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "7053ea66e29498fca6789637b805a584",
"assets/NOTICES": "10ba1703b3e0033c7d320abe8810da7e",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "825e75415ebd366b740bb49659d7a5c6",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "27361387bc24144b46a745f1afe92b50",
"canvaskit/canvaskit.wasm": "a37f2b0af4995714de856e21e882325c",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "f7c5e5502d577306fb6d530b1864ff86",
"canvaskit/chromium/canvaskit.wasm": "c054c2c892172308ca5a0bd1d7a7754b",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "9fe690d47b904d72c7d020bd303adf16",
"canvaskit/skwasm.wasm": "1c93738510f202d9ff44d36a4760126b",
"favicon.png": "5555298e28164585671e055215b6adfe",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"flutter_bootstrap.js": "4b10b2caca7403053dfebeb71badc700",
"icons/Icon-192.png": "cf0067e9d5ef97916cdbe8137ec96ee7",
"icons/Icon-512.png": "bf9d90d8b8c231fb35964f18a8e5b1f1",
"icons/Icon-maskable-192.png": "cf0067e9d5ef97916cdbe8137ec96ee7",
"icons/Icon-maskable-512.png": "bf9d90d8b8c231fb35964f18a8e5b1f1",
"index.html": "9425b8ca55c788b653e7141e4f50c6e3",
"/": "9425b8ca55c788b653e7141e4f50c6e3",
"main.dart.js": "6086981c904344d9727e3ca9ed5c0b65",
"manifest.json": "2918d71be8da59ab6482bf783eb4f4ae",
"version.json": "8f12f31d548037c522eeb3d7238ccc87"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
