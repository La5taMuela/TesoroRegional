'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "93e0ae6dad538ee88ba37003d558bbbb",
"assets/AssetManifest.bin.json": "652a0d22646339adb24899a9140fd3e3",
"assets/AssetManifest.json": "7b67b7d02e19cab33052a70df02ad514",
"assets/assets/i18n/en.json": "a1e5d0f5f8bbb27f8aec2becd52e2ec2",
"assets/assets/i18n/es.json": "3d1dcaad9c7e77c620037618e73ed936",
"assets/assets/icon/icon_app.png": "cf2625d48109be1b0512987f7c86648d",
"assets/assets/icons/cathedral_icon.png": "bfc4f047bc0a84d5c8b44de766da1be8",
"assets/assets/icons/food.png": "2cbc65b2cf56e16ae596832734bd7ee1",
"assets/assets/icons/inacap.png": "3e09eb320b552085ed32f8f9e24e395e",
"assets/assets/icons/market_icon.png": "75c158b7549ddf2627f0a09fde3db7a7",
"assets/assets/icons/monuments.png": "1b5f3f45cfb173e90a6a5f05e410080f",
"assets/assets/icons/plaza_icon.png": "e5c79c4fa1a037e0d31d95bb027a3894",
"assets/assets/images/puzzle_slider/Catedral%2520de%2520San%2520Bartolom%25C3%25A9.jpg": "d4a2cbee249ad498f1b41ceddd52c588",
"assets/assets/images/puzzle_slider/Mercado%2520de%2520Chill%25C3%25A1n.jpg": "b9cdd571162c0d038848d054cef8873d",
"assets/assets/images/puzzle_slider/Nevados%2520de%2520Chill%25C3%25A1n.jpg": "21bcdfe2dbf575a992f62de18b987904",
"assets/assets/images/puzzle_slider/Plaza%2520de%2520Armas%2520de%2520Chill%25C3%25A1n.jpg": "2e04e8a1f5a1bf8a9242f200fefcfb27",
"assets/assets/images/puzzle_slider/Termas%2520de%2520Chill%25C3%25A1n.jpg": "8fd0d61c95e2141a09fdb8ab21ba6eac",
"assets/assets/images/puzzle_slider/Vi%25C3%25B1edos%2520del%2520Valle%2520del%2520Itata.jpg": "00cc5142d9639225edb366b0553b1f7a",
"assets/assets/initial_content/memory_cards/en.json": "962b007b6b90a5b391f15f273a579e65",
"assets/assets/initial_content/memory_cards/es.json": "6bbfb7250c727bbb5740f309492f6e98",
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
"assets/assets/nuble_svg/diguillin.svg": "3851f9a4cda96a5f4ce466b16e296086",
"assets/assets/nuble_svg/itata.svg": "df21f92cdbd1b8d6cf6d877375ca2b9e",
"assets/assets/nuble_svg/Provincias_de_%25C3%2591uble_sind.svg": "49a2cb2853930ea2e8b592e74a1cc4bc",
"assets/assets/nuble_svg/Provincias_de_Nuble.svg": "f2d768c561e079540ee51a0bff348c90",
"assets/assets/nuble_svg/punilla.svg": "6879b2212608e82ef2f41298edb8c016",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "6bf04ba282be5f4a248a141b9bc2a743",
"assets/NOTICES": "95bc7b164e79afcca74ea7b9e8188148",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/flutter_map/lib/assets/flutter_map_logo.png": "208d63cc917af9713fc9572bd5c09362",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"favicon.png": "5555298e28164585671e055215b6adfe",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"flutter_bootstrap.js": "016453687793c68a85391bd96aab3bca",
"icons/Icon-192.png": "cf0067e9d5ef97916cdbe8137ec96ee7",
"icons/Icon-512.png": "bf9d90d8b8c231fb35964f18a8e5b1f1",
"icons/Icon-maskable-192.png": "cf0067e9d5ef97916cdbe8137ec96ee7",
"icons/Icon-maskable-512.png": "bf9d90d8b8c231fb35964f18a8e5b1f1",
"index.html": "9e95d3f2069c12967e6e131880d132d2",
"/": "9e95d3f2069c12967e6e131880d132d2",
"main.dart.js": "4617365b8f89305433b32906aecff456",
"manifest.json": "5f9379aeae7be3ae99e9a69f4efda54d",
"splash/img/dark-1x.png": "3df636e7fe935071ceb01863b6df2577",
"splash/img/dark-2x.png": "bf9d90d8b8c231fb35964f18a8e5b1f1",
"splash/img/dark-3x.png": "6388c4796757a5740e68ac87315f5cc5",
"splash/img/dark-4x.png": "16376fb64c4570de91f19250e77cd532",
"splash/img/light-1x.png": "3df636e7fe935071ceb01863b6df2577",
"splash/img/light-2x.png": "bf9d90d8b8c231fb35964f18a8e5b1f1",
"splash/img/light-3x.png": "6388c4796757a5740e68ac87315f5cc5",
"splash/img/light-4x.png": "16376fb64c4570de91f19250e77cd532",
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
