#!/usr/bin/env bash
#
# WARNING: This script runs aws-vault in server mode exposing credentials to any computer with network access.
# 
# See README.md for more info about why.
# 
set -euo pipefail

aws-vault proxy --stop
sleep 1

pkill -f aws-vault
sleep 1

pkill -9 -f aws-vault

echo "aws-vault should be stopped now"
