#!/usr/bin/env bash
# =============================================================================
# mysql-common.sh
# Common MySQL utilities and credential management for all database scripts
# =============================================================================

set -euo pipefail

# =============================================================================
# Global Variables
# =============================================================================
DB_NAME="${DB_NAME:-lumanitech_erp_clients}"
DB_HOST="${DB_HOST:-localhost}"
DB_USER="${DB_USER:-}"
DB_PASS="${DB_PASS:-}"
LOGIN_PATH="${LOGIN_PATH:-}"
LOG_LEVEL="${LOG_LEVEL:-info}"

# =============================================================================
# Helper Functions
# =============================================================================

is_wsl2() {
    grep -qi microsoft /proc/version 2>/dev/null
}

# Print colored messages
print_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1" >&2
}

print_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1" >&2
}

print_warning() {
    echo -e "\033[0;33m[WARNING]\033[0m $1" >&2
}

print_debug() {
    if [[ "$LOG_LEVEL" == "debug" ]]; then
        echo -e "\033[0;36m[DEBUG]\033[0m $1" >&2
    fi
}

print_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1" >&2
}

# =============================================================================
# MySQL Connection Utilities
# =============================================================================

parse_mysql_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
                --host=*)
                    DB_HOST="${1#*=}"
                    shift
                    ;;
                --user=*)
                    DB_USER="${1#*=}"
                    shift
                    ;;
                --password=*)
                    DB_PASS="${1#*=}"
                    shift
                    ;;
                --database=*)
                    DB_NAME="${1#*=}"
                    shift
                    ;;
                --login-path=*)
                    LOGIN_PATH="${1#*=}"
                    shift
                    ;;
            --host)
                DB_HOST="$2"
                shift 2
                ;;
            --user)
                DB_USER="$2"
                shift 2
                ;;
            --password)
                DB_PASS="$2"
                shift 2
                ;;
            --database)
                DB_NAME="$2"
                shift 2
                ;;
            --login-path)
                LOGIN_PATH="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    # Set defaults
    DB_HOST="${DB_HOST:-localhost}"
    if [[ -z "$DB_USER" ]]; then
        if is_wsl2; then
            DB_USER="admin"
        else
            DB_USER="root"
        fi
    fi

    # When running under WSL2, prefer TCP loopback to avoid using a UNIX socket
    # (MySQL client treats 'localhost' as socket; 127.0.0.1 forces TCP).
    if is_wsl2; then
        if [[ -z "$DB_HOST" || "$DB_HOST" == "localhost" ]]; then
            DB_HOST="127.0.0.1"
            print_debug "WSL2 detected: forcing DB_HOST to 127.0.0.1 to use TCP"
        fi
    fi
}

get_mysql_cmd() {
    local cmd_args=()
    # If using a login-path, add it first then the host so mysql client
    # accepts the login-path correctly. Otherwise include host and explicit
    # user/password args.
    if [[ -n "$LOGIN_PATH" ]]; then
        cmd_args+=(--login-path="$LOGIN_PATH")
        if [[ -n "$DB_HOST" ]]; then
            cmd_args+=(-h "$DB_HOST")
        fi
    else
        if [[ -n "$DB_HOST" ]]; then
            cmd_args+=(-h "$DB_HOST")
        fi
        cmd_args+=(-u "$DB_USER")
        if [[ -n "$DB_PASS" ]]; then
            cmd_args+=(-p"$DB_PASS")
        fi
    fi
    
    if [[ -n "$DB_NAME" ]]; then
        cmd_args+=("$DB_NAME")
    fi
    
    echo "${cmd_args[@]}"
}

get_mysql_cmd_no_db() {
    local cmd_args=()

    if [[ -n "$LOGIN_PATH" ]]; then
        cmd_args+=(--login-path="$LOGIN_PATH")
        if [[ -n "$DB_HOST" ]]; then
            cmd_args+=(-h "$DB_HOST")
        fi
    else
        if [[ -n "$DB_HOST" ]]; then
            cmd_args+=(-h "$DB_HOST")
        fi
        cmd_args+=(-u "$DB_USER")
        if [[ -n "$DB_PASS" ]]; then
            cmd_args+=(-p"$DB_PASS")
        fi
    fi

    echo "${cmd_args[@]}"
}

mysql_exec() {
    local cmd_args
    read -ra cmd_args <<< "$(get_mysql_cmd)"
    mysql "${cmd_args[@]}" "$@"
}

mysql_exec_no_db() {
    local cmd_args
    read -ra cmd_args <<< "$(get_mysql_cmd_no_db)"
    mysql "${cmd_args[@]}" "$@"
}

test_connection() {
    local cmd_args
    read -ra cmd_args <<< "$(get_mysql_cmd_no_db)"
    if ! mysql "${cmd_args[@]}" -e "SELECT 1" &>/dev/null; then
        print_error "Failed to connect to MySQL"
        return 1
    fi
    print_success "MySQL connection successful"
    return 0
}

# =============================================================================
# Help Function
# =============================================================================

print_mysql_help() {
    local default_user="root"
    if is_wsl2; then
        default_user="admin"
    fi
    
    cat << EOF
MySQL Connection Options:
  --host HOST          MySQL host (default: localhost)
  --user USER          MySQL user (default: $default_user)
  --password PASS      MySQL password
  --database DB        Database name (default: lumanitech_erp_clients)
  --login-path PATH    Use mysql_config_editor login path

Examples:
  # Using login path (recommended)
  \$0 --login-path=local

  # Using explicit credentials
  \$0 --host=localhost --user=$default_user --password=secret

  # WSL2 users should configure a login path with user 'admin'
  mysql_config_editor set --login-path=local --host=localhost --user=admin --password
EOF
}
