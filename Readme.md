# Build Instructions

1. Download debian 64-bit version from https://www.plex.tv/downloads/
2. `cd lib/`
3. `rm -rf ./*`
4. `mkdir tmp && cd tmp/`
5. `ar x <deb file>`
6. `tar xvfx data.tar.gz`
7. `mv usr/lib/plexmediaserver/* ../`
8. `cd ../`
9. `rm -rf tmp`
