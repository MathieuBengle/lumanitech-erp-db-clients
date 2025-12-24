#!/usr/bin/env bash
# =============================================================================
# setup_login.sh
# Helper script to configure mysql_config_editor login path
# =============================================================================

set -euo pipefail

cat << 'EOF'
=================================================================
MySQL Login Path Configuration
=================================================================

This script helps you configure a login path for secure MySQL
authentication without storing passwords in plain text.

Recommended login path name: local
Recommended user for WSL2: admin
Recommended user for others: root

Run the following command:

  mysql_config_editor set --login-path=local \
    --host=localhost \
    --user=admin \
    --password

You will be prompted to enter your MySQL password.

After configuration, you can use it with:

  ./scripts/deploy.sh --login-path=local

=================================================================
EOF
