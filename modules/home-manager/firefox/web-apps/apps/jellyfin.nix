let
  # Video zoom control: adds a segmented control to the Jellyfin video OSD
  # and remembers the chosen zoom per title in page localStorage.
  zoomScript = ''
    (function () {
        'use strict';

        const ZOOMS = [100, 134, 180];

        let ui = null;
        let currentZoomIndex = 0;
        let lastSrc = null;

        function getVideoContainer() {
            return document.querySelector('.videoPlayerContainer');
        }

        function getVideo() {
            return document.querySelector('video');
        }

        function getTitle() {
            return document.querySelector('.pageTitle');
        }

        function getVideoKey(video) {
            if (!video) return null;

            return video.textContent || null;
        }

        function storageKey(src) {
            return `jf-zoom-''${src}`;
        }

        function loadZoom(src) {
            if (!src) return 0;

            const val = localStorage.getItem(storageKey(src));
            if (!val) return 0;

            const idx = ZOOMS.indexOf(Number(val));
            return idx >= 0 ? idx : 0;
        }

        function saveZoom(src, index) {
            if (!src) return;
            localStorage.setItem(storageKey(src), ZOOMS[index]);
        }

        function applyZoom(video) {
            if (!video) return;

            const scale = ZOOMS[currentZoomIndex] / 100;

            video.style.transform = `scale(''${scale})`;
            video.style.transformOrigin = 'center center';
        }

        function createUI(src) {
            if (ui) return;

            currentZoomIndex = loadZoom(src);

            ui = document.createElement('div');
            ui.id = 'jf-zoom-segmented';

            ui.style.cssText = `
                margin-left: 8px;
                border-radius: 4px;
                overflow: hidden;
                display: flex;
            `;

            ui.style.pointerEvents = 'auto';


            const segments = ZOOMS.map((zoom, idx) => {
                const btn = document.createElement('button');

                btn.textContent =
                    idx === 0 ? '-' :
                        idx === 1 ? '+' :
                            '++';

                btn.style.cssText = `
                    background: white;
                    border: medium;
                    padding: 1px 10px;
                    cursor: pointer;
                    font-size: 12px;
                    font-weight: 800;
                `;


                function updateActive() {
                    btn.style.background =
                        idx === currentZoomIndex
                            ? '#00a4dc'
                            : 'white';
                }

                btn.addEventListener('click', () => {
                    currentZoomIndex = idx;

                    const video = getVideo();
                    applyZoom(video);

                    saveZoom(src, idx);

                    segments.forEach(b => b.__update());
                });

                btn.__update = updateActive;
                updateActive();

                return btn;
            });

            segments.forEach(b => ui.appendChild(b));
        }

        function attachUI() {
            if (!ui || ui.isConnected) return;

            const container = document.querySelector('#videoOsdPage:not(.hide) .osdControls .buttons');

            if (!container) return;

            const ref = container.querySelector('div.volumeButtons');

            if (ref) {
                container.insertBefore(ui, ref);
            } else {
                container.appendChild(ui);
            }
        }

        function removeUI() {
            if (ui) {
                ui.remove();
                ui = null;
            }
        }

        function update() {
            const container = getVideoContainer();
            const video = getVideo();
            const title = getTitle();

            if (!container || !video || !title) {
                removeUI();
                lastSrc = null;
                return;
            }

            const src = getVideoKey(title);

            if (!src) return;

            // detect new video
            if (src !== lastSrc) {
                lastSrc = src;

                currentZoomIndex = loadZoom(src);

                removeUI();
                createUI(src);
            }

            attachUI();
            applyZoom(video);
        }

        function init() {
            update();

            const observer = new MutationObserver(update);

            observer.observe(document.body, {
                childList: true,
                subtree: true,
                attributes: true
            });

            setInterval(update, 1500);
        }

        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', init);
        } else {
            init();
        }
    })();
  '';
in
{
  name = "Jellyfin";
  url = "https://jellyfin.homelab.reillymc.com/web";
  grantNotifications = true;
  savePasswords = true;
  persistWholeProfile = true;
  userscripts = [
    {
      name = "Jellyfin Fixed Zoom";
      hosts = [ "jellyfin.homelab.reillymc.com" ];
      script = zoomScript;
    }
  ];
}
