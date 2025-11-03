#!/usr/bin/env bash
# Test runner for macbuild with coverage reporting

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Running macbuild test suite..."
echo "=============================="

# Run the test suite
if "${SCRIPT_DIR}/tests/test_macbuild_simple.sh"; then
    echo
    echo "Coverage Report:"
    echo "==============="
    cat "${SCRIPT_DIR}/coverage/coverage_report.txt"

    echo
    echo "✅ Test suite completed successfully!"
    echo "📊 Coverage data: ${SCRIPT_DIR}/coverage/"
else
    echo "❌ Tests failed."
    exit 1
fi
