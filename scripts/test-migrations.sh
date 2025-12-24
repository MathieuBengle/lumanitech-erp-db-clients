#!/usr/bin/env bash
# =============================================================================
# test-migrations.sh
# Test migrations on a temporary database
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
source "$SCRIPT_DIR/mysql-common.sh"

main() {
    print_info "Testing migrations on temporary database..."
    
    parse_mysql_args "$@"
    
    # Create temp database name
    TEMP_DB="${DB_NAME}_test_$(date +%s)"
    
    print_info "Creating temporary database: $TEMP_DB"
    
    # Override DB_NAME for temp testing
    export DB_NAME="$TEMP_DB"
    
    # Deploy to temp database
    "$SCRIPT_DIR/deploy.sh" "$@"
    
    # Clean up
    print_info "Cleaning up temporary database..."
    mysql_exec -e "DROP DATABASE IF EXISTS $TEMP_DB"
    
    print_success "Migration test completed successfully"
}

if [[ "${1:-}" =~ ^(-h|--help)$ ]]; then
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Test migrations on a temporary database."
    echo
    print_mysql_help
    exit 0
fi

main "$@"
