# Top Albums

A modular iOS application built with Swift Package Manager (SPM) that displays top albums from iTunes.

## Architecture

This project uses a modular architecture with SPM packages:

- **CoreAlbums** - Domain models and business logic for albums
- **CoreUI** - Shared UI components and utilities
- **CoreResources** - Shared resources (images, localizations)
- **Network** - Network layer with Alamofire
- **FeatureAlbumList** - Album list feature module
- **FeatureAlbumDetail** - Album detail feature module

## Requirements

- Xcode 16.0+
- iOS 16.0+
- Swift 5.0+

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/filipemvpereira/Top-Albums.git
cd Top-Albums
```

### 2. Open the Project

```bash
open TopAlbums.xcodeproj
```

Xcode will automatically resolve SPM dependencies on first open.

### 3. Select a Simulator

- Choose any iPhone simulator with iOS 16.0 or later
- Recommended: iPhone 16 Pro or iPhone 17

### 4. Build and Run

Press `⌘R` or click the Run button in Xcode.

## Running Tests

### Option 1: Using the Test Script (Recommended)

The project includes a convenient test runner script that runs all tests.

#### Run all SPM package tests:
```bash
./run-tests.sh
```

#### Run SPM + main app tests (includes UI tests):
```bash
./run-tests.sh -a
```

#### Run with verbose output:
```bash
./run-tests.sh -v
```

#### Run everything with verbose output:
```bash
./run-tests.sh -a -v
```

#### Show help:
```bash
./run-tests.sh -h
```

### Option 2: Running Tests in Xcode

#### Run All Tests
1. Press `⌘U` to run all tests in the TopAlbums scheme
2. This runs `TopAlbumsTests` and `TopAlbumsUITests`

#### Run Specific Test Targets
1. Open the **Test Navigator** (`⌘6`)
2. You'll see:
   - **TopAlbumsTests** - Main app unit tests
   - **TopAlbumsUITests** - Main app UI tests
3. Click the ▶️ icon next to any test suite or individual test

#### Run SPM Package Tests Individually

SPM package test targets don't appear in the Teya app scheme by default. To test them:

**Method 1: Open Package Directly**
1. Navigate to the package directory (e.g., `CoreAlbums/`)
2. Open `Package.swift` in Xcode
3. Select the package scheme (e.g., `CoreAlbums`)
4. Press `⌘U` to run tests

**Method 2: Using xcodebuild**
```bash
# Test CoreAlbums
cd CoreAlbums
xcodebuild test -scheme CoreAlbums -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Test FeatureAlbumList
cd FeatureAlbumList
xcodebuild test -scheme FeatureAlbumList -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

## Test Coverage

### CoreAlbums (12 tests)
- Album repository tests
- Caching behavior
- Network error handling

### FeatureAlbumList (23 tests)
- Album list view model tests
- Integration tests
- Loading states and error handling

### TopAlbums App
- TopAlbumsTests - Main app unit tests
- TopAlbumsUITests - UI automation tests

## Dependencies

- [Alamofire](https://github.com/Alamofire/Alamofire) (5.10.2) - HTTP networking
- [Swinject](https://github.com/Swinject/Swinject) (2.10.0) - Dependency injection

## Project Structure

```
TopAlbums/
├── TopAlbums/                 # Main app target
├── TopAlbumsTests/            # Main app unit tests
├── TopAlbumsUITests/          # Main app UI tests
├── CoreAlbums/                # SPM package
│   ├── Sources/
│   └── Tests/
├── CoreUI/                    # SPM package
├── CoreResources/             # SPM package
├── Network/                   # SPM package
├── FeatureAlbumList/          # SPM package
│   ├── Sources/
│   └── Tests/
├── FeatureAlbumDetail/        # SPM package
└── run-tests.sh              # Test runner script
```
