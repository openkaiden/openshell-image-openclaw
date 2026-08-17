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

# OpenClaw requires Node.js 22.22.3+, 24.15+, or 25.9+. The pinned OpenShell
# base currently carries Node.js 22.22.1, so install OpenClaw in a compatible
# Node.js stage and copy that runtime into the sandbox image.
ARG BASE_IMAGE=ghcr.io/nvidia/openshell-community/sandboxes/base@sha256:aeef1c63f00e2913ea002ccb3aaf925f338b5c5d70e63576f0d95c16a138044e
ARG NODE_IMAGE=node:24.15.0-bookworm-slim
FROM ${NODE_IMAGE} AS openclaw

ARG NPM_VERSION=11.19.0
ARG OPENCLAW_VERSION=2026.7.1-2

RUN npm install --global "npm@${NPM_VERSION}" && \
    npm install --global "openclaw@${OPENCLAW_VERSION}" --allow-scripts=openclaw && \
    openclaw --version

FROM ${BASE_IMAGE}

USER root

COPY --from=openclaw /usr/local/ /usr/local/

RUN node --version && openclaw --version

USER sandbox

ENTRYPOINT ["/bin/bash"]
