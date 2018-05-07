# ARM Storage: Use + Objective

This system is essentially a bunch of drives rubber-banded together to form a local S3 clone. A bunch
of things are possible, but for now, this is mostly useful for doing [backups with Restic](https://docs.minio.io/docs/restic-with-minio).

The goals of this system are to be reasonably performant while being sized for something that sits underneath a desk. 
Noise is also important too. Not everyone has the ability (or desire) to procure/provision/manage several Us (or more) worth of metal at home.

# Getting Started Documentation

If you are interested in building this out, [documentation is available in the wiki](https://github.com/davidk/arm-storage/wiki).

# Current Applications

* Minio (storage service with redundant capabilities) - "Minio is a high performance distributed object storage server, designed for
large-scale private cloud infrastructure." - [https://www.minio.io/](https://www.minio.io/)

* Lego (provides SSL certificates to all services) - "Let's Encrypt client and ACME library written in Go " - [https://github.com/xenolf/lego](https://github.com/xenolf/lego)

* Perkeep - "...your personal storage system for life: a way of storing, syncing, sharing, modelling and backing up content." - [https://github.com/perkeep/perkeep](https://github.com/perkeep/perkeep)

# Pre-built Container Images

[Images for Dockerfile'd software in this repository can be found here](https://hub.docker.com/r/keyglitch/arm-storage/tags/). These are automatically built on push (to this repo) by Docker's Cloud service (and do not appear tagged as 'automated build').

Run something like this to get the latest image (in this instance, the latest minio):

    docker pull keyglitch/arm-storage:minio-latest

# Dockerfiles

This repository holds Dockerfiles and/or scripts to repack vendor releases into 
Docker containers (where they aren't supplied for ARM architectures in an easy 
to find fashion).

For scripts: Release data from Github is fetched (via the public API), 
interpreted by the `jq` utility, and put into a Dockerfile for downloading
during the `docker build` process.
