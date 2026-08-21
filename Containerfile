#
# Copyright (C) 2026 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

FROM ghcr.io/nvidia/openshell-community/sandboxes/base@sha256:aeef1c63f00e2913ea002ccb3aaf925f338b5c5d70e63576f0d95c16a138044e

USER root

ARG NODE_VERSION=22.22.3
ARG NPM_VERSION=11.19.0
ARG OPENCLAW_VERSION=2026.7.1-2

RUN case "$(uname -m)" in \
        x86_64) node_arch=x64; node_sha=2e5d13569282d016861fae7c8f935e741693c269101a5bebcf761a5376d1f99f ;; \
        aarch64) node_arch=arm64; node_sha=1c4a9933a5e45bc88f54f70b5f91232c127ec49f1a5989d23fb85824c7adf9b7 ;; \
        *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;; \
    esac && \
    node_archive="node-v${NODE_VERSION}-linux-${node_arch}.tar.xz" && \
    curl --fail --location --silent --show-error \
        "https://nodejs.org/dist/v${NODE_VERSION}/${node_archive}" \
        --output "/tmp/${node_archive}" && \
    echo "${node_sha}  /tmp/${node_archive}" | sha256sum --check --strict && \
    tar --extract --xz --file "/tmp/${node_archive}" --directory /usr/local --strip-components=1 && \
    rm "/tmp/${node_archive}" && \
    npm install --global "npm@${NPM_VERSION}" && \
    npm install --global "openclaw@${OPENCLAW_VERSION}" --allow-scripts=openclaw

RUN node --version && openclaw --version

USER sandbox

ENTRYPOINT ["/bin/bash"]
