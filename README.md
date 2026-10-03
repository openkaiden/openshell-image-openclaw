# OpenShell image for OpenClaw

An OCI sandbox image containing [OpenClaw](https://github.com/openclaw/openclaw), built from the [openshell-image-base-builder](https://github.com/openkaiden/openshell-image-base-builder) image.

## Build

```sh
podman build --file Containerfile --tag openshell-image-openclaw .
```

The image is built for `linux/amd64` and `linux/arm64`. Published releases are available from `ghcr.io/openkaiden/openshell-image-openclaw`.
