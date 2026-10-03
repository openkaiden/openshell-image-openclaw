#!/usr/bin/env bash
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

# Smoke test of the built image, run by the shared oci-image workflow once per platform.
# IMAGE and PLATFORM are provided by the workflow.
set -euo pipefail

expected=$(sed -n 's/^ARG OPENCLAW_VERSION=//p' Containerfile)
# the version is followed by the commit, like "OpenClaw 2026.9.8 (fc23bc8)"
version=$(podman run --rm --platform "${PLATFORM}" "${IMAGE}" openclaw --version)
echo "openclaw --version: ${version}"
[[ "${version}" == "OpenClaw ${expected} ("* ]] || { echo "::error::expected OpenClaw ${expected}, got ${version}"; exit 1; }

# openclaw --version also answers on a Node.js runtime that OpenClaw refuses to run on:
# check a command that goes through its runtime check (Node.js and SQLite versions).
# There is no ACP check: openclaw acp is a bridge that needs a running OpenClaw Gateway.
podman run --rm --platform "${PLATFORM}" "${IMAGE}" openclaw doctor --help > /dev/null \
  || { echo "::error::openclaw refuses to run on the Node.js runtime of the image"; exit 1; }
echo "openclaw doctor --help: ok"
