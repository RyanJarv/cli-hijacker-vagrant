#!/usr/bin/env bash
set -euo pipefail

tcpdump -n -l -i enp0s8 -w - host 169.254.169.254 | tcpflow -C -r -
