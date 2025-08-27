#!/bin/bash
# FINAL, PORTABLE SCRIPT - Recursively bundles all native dependencies.

set -e
echo "✅ Starting native library build and bundle process..."

# 1. Build the native library
echo "🔨 Building native library..."
(cd native/build && cmake .. && make -j$(sysctl -n hw.ncpu))
echo "✅ Native library built successfully."

# 2. Build the Flutter app to create the bundle structure
echo "📦 Building Flutter app..."
flutter build macos --debug

# 3. Define paths and variables for tracking processed libraries
APP_BUNDLE="build/macos/Build/Products/Debug/crisp_calc.app"
FRAMEWORKS_DIR="${APP_BUNDLE}/Contents/Frameworks"
HOMEBREW_PREFIX=$(brew --prefix)

# Use a simple string with separators to track processed libraries for portability
processed_libs=" | "

# --- Recursive function to process a library and its dependencies ---
process_library() {
    local lib_path="$1"
    local lib_name=$(basename "$1")

    # Skip if we've already processed this library
    if [[ "$processed_libs" == *" | $lib_name | "* ]]; then
        return
    fi

    echo "⚙️  Processing: $lib_name"

    # Copy the library to the Frameworks directory
    cp "$lib_path" "${FRAMEWORKS_DIR}/"
    processed_libs="$processed_libs$lib_name | " # Mark as processed

    # Get a list of its Homebrew dependencies
    local dependencies
    dependencies=$(otool -L "${FRAMEWORKS_DIR}/$lib_name" | grep "$HOMEBREW_PREFIX" | awk '{print $1}' || true)

    for dep_path in $dependencies; do
        local dep_name=$(basename "$dep_path")
        echo "  ➡️  Found dependency: $dep_name"

        # Patch the current library to look for the dependency via @rpath
        echo "  🔗 Patching $lib_name to find $dep_name..."
        install_name_tool -change "$dep_path" "@rpath/$dep_name" "${FRAMEWORKS_DIR}/$lib_name"

        # Recursively process the dependency
        process_library "$dep_path"
    done
}

# 4. Start the recursive bundling process
echo "🚚 Bundling all required libraries..."
mkdir -p "${FRAMEWORKS_DIR}"
process_library "native/build/libcas_wrapper.dylib"

# 5. Re-sign the entire app bundle
echo "🖋️  Re-signing the app bundle for macOS..."
codesign --force --deep --sign - "${APP_BUNDLE}"

echo "✅ All native libraries successfully bundled, patched, and signed!"
echo "📋 Final dependencies for your library:"
otool -L "${FRAMEWORKS_DIR}/libcas_wrapper.dylib"

echo "🚀 Ready to run! Use: flutter run -d macos"