
# Documentation

If you are interested in building out your own ARM storage kit, [documentation is available in the wiki - click me to head over there](https://github.com/davidk/arm-storage/wiki).

# Pre-built Container Images

[Images for Dockerfile'd software in this repository can be found here](https://hub.docker.com/r/keyglitch/arm-storage/tags/). These are automatically run by Docker's Cloud service (and do not appear tagged as 'automated build').

Run something like this to get the latest image (in this instance, the latest minio):

    docker pull keyglitch/arm-storage:minio-latest

# Dockerfiles

This repository holds Dockerfiles and/or scripts to repack vendor releases into 
Docker containers (where they aren't supplied for ARM architectures in an easy 
to find fashion).

For scripts: Release data from Github is fetched (via the public API), 
interpreted by the `jq` utility, and put into a Dockerfile for downloading
during the `docker build` process.
