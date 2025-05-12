#!/bin/bash

#simple script to create xcframework, I was using this to build LSAutoInjector.framework for xcode

DEVICE_DYLIB_PATH=".theos/obj/debug/libSupport.dylib"
SIMULATOR_DYLIB_PATH=".theos/obj/iphone_simulator/debug/libSupport.dylib"
XC_FRAMEWORK_OUTPUT=".theos/libSupport.xcframework"

# array to hold our paths for our compiled dylibs
DYLIB_PATHS=()

#### some check checks to determine if some paths are present ####
if [ -f "$DEVICE_DYLIB_PATH" ]; then
    DYLIB_PATHS+=(-library "$DEVICE_DYLIB_PATH")
fi

if [ -f "$SIMULATOR_DYLIB_PATH" ]; then
    DYLIB_PATHS+=(-library "$SIMULATOR_DYLIB_PATH")
fi

if [ ${#DYLIB_PATHS[@]} -eq 0 ]; then
    echo "No dylibs found."
    exit 1
fi

# remove xcframework if it exists
[ -d "$XC_FRAMEWORK_OUTPUT" ] && rm -rf "$XC_FRAMEWORK_OUTPUT"

# create xcframework from provided dylibs
xcodebuild -create-xcframework \
    "${DYLIB_PATHS[@]}" \
    -output "$XC_FRAMEWORK_OUTPUT"

# check the succession of the build
if [ $? -eq 0 ]; then
    echo "created $XC_FRAMEWORK_OUTPUT"
    echo "  ${DYLIB_PATHS[@]}"
else
    echo "cannot create xcframework"
fi