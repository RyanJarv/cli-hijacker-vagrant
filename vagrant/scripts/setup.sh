#!/usr/bin/env bash
set -euo pipefail

cat <<EOH
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	The key's entered here should be for an empty account that you do not use for anything else.

After running this scriptaws-vault will serve the credentials you enter here to any computer that has network access.

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
EOH

set -v

aws-vault --backend file add attacker

ip addr add 169.254.169.254 dev enp0s8

set +v
echo "Done"

