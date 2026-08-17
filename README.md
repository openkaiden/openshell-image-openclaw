# OpenShell image for OpenClaw

An OCI sandbox image containing [OpenClaw](https://github.com/openclaw/openclaw), built on the OpenShell community base image.

## Build

```sh
podman build --file Containerfile --tag openshell-image-openclaw .
```

The image is built for `linux/amd64` and `linux/arm64`. Published releases are available from `ghcr.io/openkaiden/openshell-image-openclaw`.
