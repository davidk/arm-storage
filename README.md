
# Documentation

Ahoy! [Documentation has moved to the wiki - click me to head over there](https://github.com/davidk/arm-storage/wiki).

# Dockerfiles

This repository holds Dockerfiles and/or scripts to repack vendor releases into 
Docker containers (where they aren't supplied for ARM architectures in an easy 
to find fashion).

For scripts: Release data from Github is fetched (via the public API), 
interpreted by the `jq` utility, and put into a Dockerfile for downloading
during the `docker build` process.