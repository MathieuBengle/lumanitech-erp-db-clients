#!/usr/bin/env bash
# =============================================================================
# setup.sh
# Create database and deploy schema (tables, views, procedures, functions, triggers, indexes)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source common utilities
source "$SCRIPT_DIR/mysql-common.sh"

main() {
    print_info "Setting up database schema..."
    
    parse_mysql_args "$@"
    
    # Create database
    print_info "Creating database if not exists..."
    mysql_exec < "$PROJECT_ROOT/schema/01_create_database.sql"
    
    # Deploy schema components in order
    for dir in tables views procedures functions triggers indexes; do
        schema_dir="$PROJECT_ROOT/schema/$dir"
        if [[ -d "$schema_dir" ]]; then
            print_info "Deploying $dir..."
            for sql_file in "$schema_dir"/*.sql; do
                [[ -f "$sql_file" ]] || continue
                basename_file=$(basename "$sql_file")
                [[ "$basename_file" == "placeholder.sql" ]] && continue
                [[ "$basename_file" == "README.md" ]] && continue
                print_info "  - $basename_file"
                mysql_exec < "$sql_file"
            done
        fi
    done
    
    print_success "Schema setup complete"
}

if [[ "${1:-}" =~ ^(-h|--help)$ ]]; then
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Setup database and deploy schema components."
    echo
    print_mysql_help
    exit 0
fi

main "$@"
