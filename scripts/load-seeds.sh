#!/usr/bin/env bash
# =============================================================================
# load-seeds.sh
# Load development seed data
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source common utilities
source "$SCRIPT_DIR/mysql-common.sh"

main() {
    print_info "Loading seed data..."
    
    parse_mysql_args "$@"
    
    seeds_dir="$PROJECT_ROOT/seeds/dev"
    
    if [[ ! -d "$seeds_dir" ]]; then
        print_warning "Seeds directory not found: $seeds_dir"
        return 0
    fi
    
    for seed_file in "$seeds_dir"/*.sql; do
        [[ -f "$seed_file" ]] || continue
        basename_file=$(basename "$seed_file")
        print_info "  - $basename_file"
        mysql_exec < "$seed_file"
    done
    
    print_success "Seed data loaded"
}

if [[ "${1:-}" =~ ^(-h|--help)$ ]]; then
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Load development seed data."
    echo
    print_mysql_help
    exit 0
fi

main "$@"
