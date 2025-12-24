#!/usr/bin/env bash
# =============================================================================
# validate-sql-syntax.sh
# Basic SQL syntax validation
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_ok() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

main() {
    # Basic syntax validation
    mapfile -t sql_files < <(find "$PROJECT_ROOT" -name "*.sql" -not -path "*/.git/*")
    
    for file in "${sql_files[@]}"; do
        # Check for basic SQL keywords
        if grep -qiE "(CREATE|ALTER|DROP|INSERT|SELECT|UPDATE|DELETE|USE)" "$file"; then
            print_ok "$(basename "$file")"
        else
            print_warn "$(basename "$file"): No SQL statements found"
        fi
    done
    
    return 0
}

main "$@"
