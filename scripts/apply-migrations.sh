#!/usr/bin/env bash
# =============================================================================
# apply-migrations.sh
# Apply database migrations in order
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source common utilities
source "$SCRIPT_DIR/mysql-common.sh"

main() {
    print_info "Applying migrations..."
    
    parse_mysql_args "$@"
    
    migrations_dir="$PROJECT_ROOT/migrations"
    
    # Get all migration files sorted
    mapfile -t migrations < <(find "$migrations_dir" -name "V*.sql" | sort)
    
    if [[ ${#migrations[@]} -eq 0 ]]; then
        print_warning "No migrations found"
        return 0
    fi
    
    for migration in "${migrations[@]}"; do
        basename_file=$(basename "$migration")
        print_info "  - $basename_file"
        mysql_exec < "$migration"
    done
    
    print_success "All migrations applied"
}

if [[ "${1:-}" =~ ^(-h|--help)$ ]]; then
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Apply all database migrations in order."
    echo
    print_mysql_help
    exit 0
fi

main "$@"
