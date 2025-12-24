#!/usr/bin/env bash
# =============================================================================
# deploy.sh
# Deploy complete database: schema + migrations + optional seeds
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source common utilities
# shellcheck source=scripts/mysql-common.sh
source "$SCRIPT_DIR/mysql-common.sh"

# =============================================================================
# Main Deployment
# =============================================================================

main() {
    print_info "==================================================================="
    print_info "Database Deployment - lumanitech_erp_clients"
    print_info "==================================================================="
    
    if is_wsl2; then
        print_info "WSL2 detected. Use --login-path configured with user 'admin'."
    fi
    
    parse_mysql_args "$@"
    
    print_info "Target database: $DB_NAME"
    print_info "Host: $DB_HOST"
    print_info "User: $DB_USER"
    
    # Test connection
    test_connection || exit 1
    
    # Deploy schema
    print_info "Deploying schema..."
    "$SCRIPT_DIR/setup.sh" "$@"
    
    # Apply migrations
    print_info "Applying migrations..."
    "$SCRIPT_DIR/apply-migrations.sh" "$@"
    
    # Load seeds if requested
    if [[ "${WITH_SEEDS:-false}" == "true" ]] || [[ "${1:-}" == "--with-seeds" ]]; then
        print_info "Loading seed data..."
        "$SCRIPT_DIR/load-seeds.sh" "$@"
    fi
    
    print_success "==================================================================="
    print_success "Deployment complete!"
    print_success "==================================================================="
}

# Show help if requested
if [[ "${1:-}" =~ ^(-h|--help)$ ]]; then
    cat << EOF
Usage: $0 [OPTIONS]

Deploy the complete database including schema, migrations, and optional seed data.

Options:
  --with-seeds         Load development seed data
  -h, --help           Show this help message

EOF
    print_mysql_help
    exit 0
fi

main "$@"
