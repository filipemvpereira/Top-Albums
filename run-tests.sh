#!/bin/bash

# TopAlbums Test Runner
# Runs tests for all SPM packages with test targets

set -o pipefail

# Parse arguments
VERBOSE=false
INCLUDE_APP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose) VERBOSE=true; shift ;;
        -a|--app) INCLUDE_APP=true; shift ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -v, --verbose    Show detailed test output"
            echo "  -a, --app        Also run main app tests"
            echo "  -h, --help       Show this help"
            echo ""
            echo "Examples:"
            echo "  $0               # Run all SPM package tests"
            echo "  $0 -v            # Run with detailed output"
            echo "  $0 -a            # Run SPM + app tests"
            exit 0
            ;;
        *) echo "Unknown option: $1 (use -h for help)"; exit 1 ;;
    esac
done

echo "🧪 Running TopAlbums Tests"
echo ""

# Find iPhone simulator (explicitly exclude real devices)
SIMULATOR=$(xcrun simctl list devices available 2>/dev/null | grep "iPhone" | grep -v "unavailable" | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')

if [ -z "$SIMULATOR" ]; then
    echo "❌ No iPhone simulator found"
    echo "Please install iOS simulators via Xcode > Settings > Platforms"
    exit 1
fi

SIMULATOR_NAME=$(xcrun simctl list devices 2>/dev/null | grep "$SIMULATOR" | sed -E 's/^ +//' | sed 's/ (.*//')
echo "Using simulator: $SIMULATOR_NAME"
echo ""

# Track results
PASSED=()
FAILED=()
START_TIME=$(date +%s)

# Test a package
test_package() {
    local name=$1
    local path=$2

    echo "📦 Testing $name..."

    cd "$path" || { echo "❌ Directory not found: $path"; FAILED+=("$name"); return; }

    local result
    if [ "$VERBOSE" = true ]; then
        xcodebuild test \
            -scheme "$name" \
            -destination "platform=iOS Simulator,id=$SIMULATOR" \
            -only-testing:"${name}Tests" 2>&1 | grep -v "Ineligible destinations"
        result=${PIPESTATUS[0]}
    else
        xcodebuild test \
            -scheme "$name" \
            -destination "platform=iOS Simulator,id=$SIMULATOR" \
            -only-testing:"${name}Tests" \
            -quiet 2>&1 | grep -v "Ineligible destinations"
        result=${PIPESTATUS[0]}
    fi

    if [ $result -eq 0 ]; then
        echo "✅ $name"
        PASSED+=("$name")
    else
        echo "❌ $name"
        FAILED+=("$name")
    fi

    cd - > /dev/null
    echo ""
}

# Test main app (includes both unit and UI tests)
test_app() {
    echo "🏗️  Testing TopAlbums (main app + UI tests)..."

    local result
    if [ "$VERBOSE" = true ]; then
        xcodebuild test \
            -scheme TopAlbums \
            -destination "platform=iOS Simulator,id=$SIMULATOR" 2>&1 | grep -v "Ineligible destinations"
        result=${PIPESTATUS[0]}
    else
        xcodebuild test \
            -scheme TopAlbums \
            -destination "platform=iOS Simulator,id=$SIMULATOR" \
            -quiet 2>&1 | grep -v "Ineligible destinations"
        result=${PIPESTATUS[0]}
    fi

    if [ $result -eq 0 ]; then
        echo "✅ TopAlbums (TopAlbumsTests + TopAlbumsUITests)"
        PASSED+=("TopAlbums")
    else
        echo "❌ TopAlbums"
        FAILED+=("TopAlbums")
    fi
    echo ""
}

# Run tests
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

test_package "CoreAlbums" "$SCRIPT_DIR/CoreAlbums"
test_package "FeatureAlbumList" "$SCRIPT_DIR/FeatureAlbumList"

if [ "$INCLUDE_APP" = true ]; then
    test_app
fi

# Summary
DURATION=$(($(date +%s) - START_TIME))

echo "════════════════════════════════════"
echo "📊 Summary"
echo "════════════════════════════════════"
echo "Passed: ${#PASSED[@]}"
echo "Failed: ${#FAILED[@]}"
echo "Duration: ${DURATION}s"
echo ""

if [ ${#PASSED[@]} -gt 0 ]; then
    echo "✅ Passed:"
    printf '   - %s\n' "${PASSED[@]}"
    echo ""
fi

if [ ${#FAILED[@]} -gt 0 ]; then
    echo "❌ Failed:"
    printf '   - %s\n' "${FAILED[@]}"
    echo ""
    exit 1
fi

echo "🎉 All tests passed!"
exit 0
