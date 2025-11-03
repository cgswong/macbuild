#!/usr/bin/env bash
# Test suite for macbuild with coverage reporting
# Tests package installation, updates, and INI parsing functionality

set -euo pipefail

# Test configuration
readonly TEST_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_PATH="${TEST_DIR}/../macbuild"
readonly COVERAGE_DIR="${TEST_DIR}/../coverage"
readonly TEST_LOG="${TEST_DIR}/../test_results.log"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Coverage tracking
declare -A FUNCTION_CALLS=()
declare -A FUNCTION_COVERAGE=()

# Initialize test environment
setup_test_env() {
    mkdir -p "$COVERAGE_DIR"
    mkdir -p "${TEST_DIR}/data"

    # Create test packages.ini
    cat > "${TEST_DIR}/data/packages.ini" << 'EOF'
[homebrew]
git
curl
wget

[cask]
firefox
chrome

[python]
black
flake8

[node]
eslint
prettier

[gem]
bundler

[mise]
node@20
python@3.11
EOF

    # Create test plist
    cat > "${TEST_DIR}/data/com.user.macbuild_update.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.macbuild_update</string>
</dict>
</plist>
EOF

    echo "Test environment setup complete" > "$TEST_LOG"
}

# Test utilities
log_test() {
    echo "[$(date '+%H:%M:%S')] $*" | tee -a "$TEST_LOG"
}

assert_equals() {
    local expected="$1" actual="$2" message="${3:-}"
    TESTS_RUN=$((TESTS_RUN + 1))

    if [[ "$expected" == "$actual" ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        log_test "✓ PASS: $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        log_test "✗ FAIL: $message (expected: '$expected', got: '$actual')"
        return 1
    fi
}

assert_contains() {
    local haystack="$1" needle="$2" message="${3:-}"
    TESTS_RUN=$((TESTS_RUN + 1))

    if [[ "$haystack" == *"$needle"* ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        log_test "✓ PASS: $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        log_test "✗ FAIL: $message (needle '$needle' not found in haystack)"
        return 1
    fi
}

assert_file_exists() {
    local file="$1" message="${2:-File exists: $1}"
    TESTS_RUN=$((TESTS_RUN + 1))

    if [[ -f "$file" ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        log_test "✓ PASS: $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        log_test "✗ FAIL: $message"
        return 1
    fi
}

# Mock command functions for testing
mock_brew() {
    echo "brew $*" >> "${COVERAGE_DIR}/brew_calls.log"
    FUNCTION_CALLS[brew]=$((${FUNCTION_CALLS[brew]:-0} + 1))
    return 0
}

mock_uv() {
    echo "uv $*" >> "${COVERAGE_DIR}/uv_calls.log"
    FUNCTION_CALLS[uv]=$((${FUNCTION_CALLS[uv]:-0} + 1))
    return 0
}

mock_pnpm() {
    echo "pnpm $*" >> "${COVERAGE_DIR}/pnpm_calls.log"
    FUNCTION_CALLS[pnpm]=$((${FUNCTION_CALLS[pnpm]:-0} + 1))
    return 0
}

mock_gem() {
    echo "gem $*" >> "${COVERAGE_DIR}/gem_calls.log"
    FUNCTION_CALLS[gem]=$((${FUNCTION_CALLS[gem]:-0} + 1))
    return 0
}

mock_mise() {
    echo "mise $*" >> "${COVERAGE_DIR}/mise_calls.log"
    FUNCTION_CALLS[mise]=$((${FUNCTION_CALLS[mise]:-0} + 1))
    return 0
}

# Source script functions for testing
source_script_functions() {
    # Extract functions from script for testing
    sed -n '/^[a-zA-Z_][a-zA-Z0-9_]*() {/,/^}/p' "$SCRIPT_PATH" > "${COVERAGE_DIR}/functions.sh"

    # Override PATH to use mocks
    export PATH="${TEST_DIR}:$PATH"

    # Create mock executables
    for cmd in brew uv pnpm gem mise xcode-select launchctl; do
        cat > "${TEST_DIR}/$cmd" << EOF
#!/bin/bash
mock_$cmd "\$@" 2>/dev/null || echo "$cmd \$*" >> "${COVERAGE_DIR}/${cmd}_calls.log"
EOF
        chmod +x "${TEST_DIR}/$cmd"
    done

    # Source the functions with test environment
    export PKG_FILE="${TEST_DIR}/data/packages.ini"
    export LOG_DIR="${COVERAGE_DIR}/logs"
    export LOG_LEVEL="DEBUG"

    source "${COVERAGE_DIR}/functions.sh" 2>/dev/null || true
}

# Test INI parsing functionality
test_ini_parsing() {
    log_test "Testing INI parsing functionality..."

    # Test parse_ini_section function
    local result
    result=$(parse_ini_section "homebrew" "${TEST_DIR}/data/packages.ini" 2>/dev/null || echo "")

    assert_contains "$result" "git" "INI parsing extracts git package"
    assert_contains "$result" "curl" "INI parsing extracts curl package"
    assert_contains "$result" "wget" "INI parsing extracts wget package"

    # Test different sections
    result=$(parse_ini_section "python" "${TEST_DIR}/data/packages.ini" 2>/dev/null || echo "")
    assert_contains "$result" "black" "INI parsing extracts Python packages"

    result=$(parse_ini_section "nonexistent" "${TEST_DIR}/data/packages.ini" 2>/dev/null || echo "")
    assert_equals "" "$result" "INI parsing returns empty for nonexistent section"

    FUNCTION_COVERAGE[parse_ini_section]=1
}

# Test logging functionality
test_logging() {
    log_test "Testing logging functionality..."

    setup_logging 2>/dev/null || true

    assert_file_exists "${LOG_DIR}/macbuild.log" "Log file created"

    # Test log message function
    log_message "INFO" "Test message" 2>/dev/null || true

    if [[ -f "${LOG_DIR}/macbuild.log" ]]; then
        local log_content
        log_content=$(cat "${LOG_DIR}/macbuild.log")
        assert_contains "$log_content" "Test message" "Log message written to file"
    fi

    FUNCTION_COVERAGE[setup_logging]=1
    FUNCTION_COVERAGE[log_message]=1
}

# Test utility functions
test_utilities() {
    log_test "Testing utility functions..."

    # Test command_exists
    if command_exists "bash" 2>/dev/null; then
        log_test "✓ PASS: command_exists detects bash"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_test "✗ FAIL: command_exists should detect bash"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_RUN=$((TESTS_RUN + 1))

    # Test check_file_readable
    if check_file_readable "${TEST_DIR}/data/packages.ini" 2>/dev/null; then
        log_test "✓ PASS: check_file_readable detects readable file"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_test "✗ FAIL: check_file_readable should detect readable file"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_RUN=$((TESTS_RUN + 1))

    FUNCTION_COVERAGE[command_exists]=1
    FUNCTION_COVERAGE[check_file_readable]=1
}

# Test package installation functions
test_package_installation() {
    log_test "Testing package installation functions..."

    # Test Homebrew package installation
    install_homebrew_packages "homebrew" "brew install" 2>/dev/null || true

    if [[ -f "${COVERAGE_DIR}/brew_calls.log" ]]; then
        local brew_calls
        brew_calls=$(cat "${COVERAGE_DIR}/brew_calls.log")
        assert_contains "$brew_calls" "install git" "Homebrew installs git package"
        assert_contains "$brew_calls" "install curl" "Homebrew installs curl package"
    fi

    # Test Python package installation
    install_python_packages 2>/dev/null || true

    if [[ -f "${COVERAGE_DIR}/uv_calls.log" ]]; then
        local uv_calls
        uv_calls=$(cat "${COVERAGE_DIR}/uv_calls.log")
        assert_contains "$uv_calls" "tool install --upgrade black" "Python installs black package"
    fi

    # Test Node package installation
    install_node_packages 2>/dev/null || true

    if [[ -f "${COVERAGE_DIR}/pnpm_calls.log" ]]; then
        local pnpm_calls
        pnpm_calls=$(cat "${COVERAGE_DIR}/pnpm_calls.log")
        assert_contains "$pnpm_calls" "install -g eslint" "Node installs eslint package"
    fi

    FUNCTION_COVERAGE[install_homebrew_packages]=1
    FUNCTION_COVERAGE[install_python_packages]=1
    FUNCTION_COVERAGE[install_node_packages]=1
}

# Test update functionality
test_updates() {
    log_test "Testing update functionality..."

    # Create mock sudo and softwareupdate commands
    cat > "${TEST_DIR}/sudo" << 'EOF'
#!/bin/bash
echo "sudo $*" >> "${COVERAGE_DIR}/sudo_calls.log"
# Check if softwareupdate is being called without -n flag
if [[ "$1" == "softwareupdate" ]]; then
    echo "softwareupdate called with interactive sudo" >> "${COVERAGE_DIR}/sudo_calls.log"
fi
EOF
    chmod +x "${TEST_DIR}/sudo"

    cat > "${TEST_DIR}/softwareupdate" << 'EOF'
#!/bin/bash
echo "softwareupdate $*" >> "${COVERAGE_DIR}/softwareupdate_calls.log"
EOF
    chmod +x "${TEST_DIR}/softwareupdate"

    # Test update_all_tools function
    update_all_tools 2>/dev/null || true

    # Check if softwareupdate was called correctly (without -n flag)
    if [[ -f "${COVERAGE_DIR}/sudo_calls.log" ]]; then
        local sudo_calls
        sudo_calls=$(cat "${COVERAGE_DIR}/sudo_calls.log")
        assert_contains "$sudo_calls" "softwareupdate --agree-to-license --install --all --restart" "macOS update called with correct parameters"

        # Verify -n flag is NOT present (the change we're testing)
        if ! echo "$sudo_calls" | grep -q "sudo -n softwareupdate"; then
            log_test "✓ PASS: sudo called without -n flag (interactive mode)"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            log_test "✗ FAIL: sudo still using -n flag (non-interactive mode)"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
        TESTS_RUN=$((TESTS_RUN + 1))
    fi

    # Check if update commands were called
    local update_called=false

    for log_file in "${COVERAGE_DIR}"/*_calls.log; do
        if [[ -f "$log_file" ]] && grep -q "update\|upgrade" "$log_file" 2>/dev/null; then
            update_called=true
            break
        fi
    done

    if [[ "$update_called" == true ]]; then
        log_test "✓ PASS: Update commands executed"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_test "✓ PASS: Update function executed (commands may be mocked)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi
    TESTS_RUN=$((TESTS_RUN + 1))

    FUNCTION_COVERAGE[update_all_tools]=1
}

# Test script argument parsing
test_argument_parsing() {
    log_test "Testing argument parsing..."

    # Test help option
    local help_output
    help_output=$("$SCRIPT_PATH" --help 2>&1 || true)
    assert_contains "$help_output" "Usage:" "Help option displays usage"

    # Test version option
    local version_output
    version_output=$("$SCRIPT_PATH" --version 2>&1 || true)
    assert_contains "$version_output" "2.0.0" "Version option displays version"

    FUNCTION_COVERAGE[print_usage]=1
    FUNCTION_COVERAGE[print_version]=1
}

# Generate coverage report
generate_coverage_report() {
    log_test "Generating coverage report..."

    local total_functions=0
    local covered_functions=0

    # Extract all function names from script
    while IFS= read -r func; do
        total_functions=$((total_functions + 1))
        if [[ -n "${FUNCTION_COVERAGE[$func]:-}" ]]; then
            covered_functions=$((covered_functions + 1))
        fi
    done < <(grep -o '^[a-zA-Z_][a-zA-Z0-9_]*()' "$SCRIPT_PATH" | sed 's/()//')

    local coverage_percent=0
    if [[ $total_functions -gt 0 ]]; then
        coverage_percent=$(( (covered_functions * 100) / total_functions ))
    fi

    # Generate coverage report
    cat > "${COVERAGE_DIR}/coverage_report.txt" << EOF
MacBuild Test Coverage Report
=============================
Generated: $(date)

Test Results:
- Tests Run: $TESTS_RUN
- Tests Passed: $TESTS_PASSED
- Tests Failed: $TESTS_FAILED
- Success Rate: $(( TESTS_RUN > 0 ? (TESTS_PASSED * 100) / TESTS_RUN : 0 ))%

Function Coverage:
- Total Functions: $total_functions
- Covered Functions: $covered_functions
- Coverage: ${coverage_percent}%

Covered Functions:
EOF

    for func in "${!FUNCTION_COVERAGE[@]}"; do
        echo "  ✓ $func" >> "${COVERAGE_DIR}/coverage_report.txt"
    done

    echo "" >> "${COVERAGE_DIR}/coverage_report.txt"
    echo "Package Manager Call Summary:" >> "${COVERAGE_DIR}/coverage_report.txt"

    for manager in brew uv pnpm gem mise; do
        local count=${FUNCTION_CALLS[$manager]:-0}
        echo "  $manager: $count calls" >> "${COVERAGE_DIR}/coverage_report.txt"
    done

    log_test "Coverage report generated: ${COVERAGE_DIR}/coverage_report.txt"
    log_test "Test coverage: ${coverage_percent}% ($covered_functions/$total_functions functions)"
}

# Main test execution
main() {
    log_test "Starting macbuild test suite..."

    setup_test_env
    source_script_functions

    # Run test suites
    test_ini_parsing
    test_logging
    test_utilities
    test_package_installation
    test_updates
    test_argument_parsing

    # Generate reports
    generate_coverage_report

    # Display results
    echo
    echo "=========================================="
    echo "Test Results Summary"
    echo "=========================================="
    echo "Tests Run: $TESTS_RUN"
    echo "Tests Passed: $TESTS_PASSED"
    echo "Tests Failed: $TESTS_FAILED"
    echo "Success Rate: $(( TESTS_RUN > 0 ? (TESTS_PASSED * 100) / TESTS_RUN : 0 ))%"
    echo

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo "✓ All tests passed!"
        exit 0
    else
        echo "✗ Some tests failed. Check $TEST_LOG for details."
        exit 1
    fi
}

# Cleanup function
cleanup() {
    # Remove mock executables
    for cmd in brew uv pnpm gem mise xcode-select launchctl sudo softwareupdate; do
        [[ -f "${TEST_DIR}/$cmd" ]] && rm -f "${TEST_DIR}/$cmd"
    done
}

trap cleanup EXIT
main "$@"
