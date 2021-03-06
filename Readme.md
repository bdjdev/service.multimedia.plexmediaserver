# Build Instructions

## Automated Instructions

1. Download debian 64-bit version from https://www.plex.tv/downloads/
2. Run the build script: `build.sh <plexmediaserver_version_amd64.deb>`
3. `scp service.multimedia.plexmediaserver-<version>.zip <kodi_box>:Downloads/`
4. Inside Kodi, install the plugin by selecting the ZIP file

## Manual Instructions

1. Download debian 64-bit version from https://www.plex.tv/downloads/
2. Change version in `addon.xml` to match downloaded version
3. Update `changelog.txt`
4. `cd lib/`
5. `rm -rf ./*`
6. `mkdir tmp && cd tmp/`
7. `ar x <deb file>`
8. `tar xvfx data.tar.gz`
9. `mv usr/lib/plexmediaserver/* ../`
10. `cd ../`
11. `rm -rf tmp`
12. `cd ../..`
13. `zip -r service.multimedia.plexmediaserver-<version>.zip service.multimedia.plexmediaserver/ -x *.git*`
14. `scp service.multimedia.plexmediaserver-<version>.zip <kodi_box>:Downloads/`
15. Inside Kodi, install the plugin by selecting the ZIP file
