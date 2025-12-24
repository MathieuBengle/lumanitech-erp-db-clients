#!/usr/bin/env bash
# =============================================================================
# validate-migrations.sh
# Validate migration file naming and structure
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0

print_ok() {
    echo -e "${GREEN}✓${NC} $1"
}

print_fail() {
    echo -e "${RED}✗${NC} $1"
    ERRORS=$((ERRORS + 1))
}

main() {
    migrations_dir="$PROJECT_ROOT/migrations"
    
    # Check TEMPLATE.sql exists
    if [[ -f "$migrations_dir/TEMPLATE.sql" ]]; then
        print_ok "TEMPLATE.sql exists"
    else
        print_fail "TEMPLATE.sql not found"
    fi
    
    # Validate migration naming
    mapfile -t migrations < <(find "$migrations_dir" -name "V*.sql" | sort)
    
    if [[ ${#migrations[@]} -eq 0 ]]; then
        print_fail "No migration files found"
        return 1
    fi
    
    for migration in "${migrations[@]}"; do
        basename_file=$(basename "$migration")
        
        # Check naming convention: V###_description.sql
        if [[ ! "$basename_file" =~ ^V[0-9]{3}_[a-z0-9_]+\.sql$ ]]; then
            print_fail "Invalid migration name: $basename_file (expected V###_description.sql)"
        else
            print_ok "$basename_file"
        fi
        
        # Check for migration header
        if grep -q "^-- Migration: " "$migration"; then
            :
        else
            print_fail "$basename_file: Missing migration header"
        fi
        
        # Check for self-tracking INSERT
        if grep -q "INSERT INTO schema_migrations" "$migration"; then
            :
        else
            print_fail "$basename_file: Missing self-tracking INSERT"
        fi
    done
    
    return $ERRORS
}

main "$@"
