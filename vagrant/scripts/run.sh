#!/usr/bin/env bash
#
# WARNING: This script runs aws-vault in server mode exposing credentials to any computer with network access.
# 
# See README.md for more info about why.
# 
set -euo pipefail

aws-vault --backend file exec -s attacker
