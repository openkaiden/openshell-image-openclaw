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

# ghcr.io/openkaiden/openshell-image-base-builder:next
FROM ghcr.io/openkaiden/openshell-image-base-builder@sha256:27c5cb3411afcd4950ec89308425d54685a7c07b8de094260e8e92c0c9c9e43e AS builder
ARG NODE_VERSION=24.21.0
ARG OPENCLAW_VERSION=2026.9.8

# OpenClaw is a Node.js application: copy Node.js inside the root filesystem to run it
# The Node.js of nodejs.org is used and not the one of the UBI repositories: OpenClaw needs
# the SQLite bundled in Node.js, and refuses the older system SQLite the UBI one is linked to
RUN set -eux; \
    case "$(uname -m)" in \
        x86_64) node_arch=x64; node_sha=6e1db87ef58b8819e5d5402eff1536491b18edd8eb7bee5ef7897876e88dc5ff ;; \
        aarch64) node_arch=arm64; node_sha=724282c3b43aec998aa9527380465b45d229e021b58035f5f4f63095eabfe5d5 ;; \
        *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;; \
    esac; \
    node_archive="node-v${NODE_VERSION}-linux-${node_arch}.tar.gz"; \
    curl -fsSL -o "/tmp/${node_archive}" "https://nodejs.org/dist/v${NODE_VERSION}/${node_archive}"; \
    echo "${node_sha}  /tmp/${node_archive}" | sha256sum --check --strict; \
    # node and npm for the builder, only node for the root filesystem
    tar -xzf "/tmp/${node_archive}" -C /usr/local --strip-components=1; \
    install -D -m 0755 /usr/local/bin/node /mnt/rootfs/usr/local/bin/node; \
    # the node binary needs the C++ standard library
    dnf install --installroot /mnt/rootfs --setopt=reposdir=/etc/yum.repos.d/ \
        libstdc++ \
        --releasever 10 --setopt install_weak_deps=false --nodocs -y; \
    dnf --installroot /mnt/rootfs clean all; \
    rm -rf /mnt/rootfs/var/cache/* /mnt/rootfs/var/log/dnf* /mnt/rootfs/var/log/yum.*

# Install OpenClaw inside the root filesystem, with the npm of the builder
RUN set -eux; \
    npm install --global --prefix /mnt/rootfs/usr/local "openclaw@${OPENCLAW_VERSION}" --allow-scripts=openclaw

# Now create our final image with reduced layers
FROM scratch
COPY --from=builder /mnt/rootfs/ /
CMD ["openclaw"]
