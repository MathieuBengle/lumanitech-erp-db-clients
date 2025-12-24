#!/usr/bin/env bash
# =============================================================================
# validate.sh
# Main validation script - runs all validation checks
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

print_step() {
    echo -e "${BLUE}$1${NC}"
}

print_ok() {
    echo -e "${GREEN}✓${NC} $1"
}

print_fail() {
    echo -e "${RED}✗${NC} $1"
    ERRORS=$((ERRORS + 1))
}

print_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    WARNINGS=$((WARNINGS + 1))
}

main() {
    echo "=================================================================="
    echo "Database Validation - lumanitech_erp_clients"
    echo "=================================================================="
    echo
    
    # Step 1: Validate migration files
    print_step "Step 1: Validate migration files..."
    "$SCRIPT_DIR/validate-migrations.sh" || ERRORS=$((ERRORS + 1))
    echo
    
    # Step 2: Validate SQL syntax
    print_step "Step 2: Validate SQL syntax..."
    "$SCRIPT_DIR/validate-sql-syntax.sh" || ERRORS=$((ERRORS + 1))
    echo
    
    # Step 3: Validate repository structure
    print_step "Step 3: Validate repository structure..."
    for dir in migrations schema seeds scripts docs; do
        if [[ -d "$PROJECT_ROOT/$dir" ]]; then
            print_ok "Directory exists: $dir/"
        else
            print_fail "Missing directory: $dir/"
        fi
    done
    echo
    
    # Step 4: Validate schema structure
    print_step "Step 4: Validate schema structure..."
    schema_dir="$PROJECT_ROOT/schema"
    for subdir in tables views procedures functions triggers indexes; do
        if [[ -d "$schema_dir/$subdir" ]]; then
            print_ok "Schema subdirectory exists: $subdir/"
        else
            print_fail "Missing schema subdirectory: $subdir/"
        fi
    done
    echo
    
    # Step 5: Validate schema file naming
    print_step "Step 5: Validate schema file naming..."
    
    check_dir="$schema_dir/procedures"
    if [[ -d "$check_dir" ]]; then
        for f in "$check_dir"/*.sql; do
            [[ -f "$f" ]] || continue
            name=$(basename "$f")
            if [[ ! "$name" =~ ^sp_[a-z0-9_]+\.sql$ ]]; then
                print_fail "Invalid procedure filename: $name (expected sp_name.sql)"
            else
                print_ok "$name"
            fi
        done
    fi
    
    check_dir="$schema_dir/triggers"
    if [[ -d "$check_dir" ]]; then
        for f in "$check_dir"/*.sql; do
            [[ -f "$f" ]] || continue
            name=$(basename "$f")
            if [[ ! "$name" =~ ^trg_[a-z0-9_]+\.sql$ ]]; then
                print_fail "Invalid trigger filename: $name (expected trg_name.sql)"
            else
                print_ok "$name"
            fi
        done
    fi
    echo
    
    # Summary
    echo "=================================================================="
    echo "Validation Summary"
    echo "=================================================================="
    echo "Errors: $ERRORS"
    echo "Warnings: $WARNINGS"
    
    if [[ $ERRORS -gt 0 ]]; then
        echo -e "${RED}Validation FAILED${NC}"
        exit 1
    elif [[ $WARNINGS -gt 0 ]]; then
        echo -e "${YELLOW}Validation passed with warnings${NC}"
        exit 0
    else
        echo -e "${GREEN}Validation PASSED${NC}"
        exit 0
    fi
}

main "$@"
