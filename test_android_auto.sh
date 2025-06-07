#!/bin/bash

# Android Auto Testing Script for My Tube App
# This script helps test the Android Auto fixes

echo "🚗 My Tube - Android Auto Testing Script"
echo "=========================================="
echo ""

# Check if adb is available
if ! command -v adb &> /dev/null; then
    echo "❌ ADB not found. Please install Android SDK tools."
    exit 1
fi

# Check connected devices
echo "📱 Checking connected Android devices..."
DEVICES=$(adb devices | grep -v "List of devices" | grep "device$" | wc -l)

if [ "$DEVICES" -eq 0 ]; then
    echo "❌ No Android devices connected."
    echo "   Please connect your Android device and enable USB debugging."
    exit 1
fi

echo "✅ Found $DEVICES Android device(s) connected."
echo ""

# Check if app is installed
echo "📦 Checking if My Tube app is installed..."
PACKAGE_NAME="it.gmstyle.my_tube"  # Updated with correct package name
APP_INSTALLED=$(adb shell pm list packages | grep "$PACKAGE_NAME" | wc -l)

if [ "$APP_INSTALLED" -eq 0 ]; then
    echo "❌ My Tube app not found on device."
    echo "   Building and installing app..."
    
    # Build and install the app
    cd /home/gmstyle/VisualStudioCodeProjects/my_tube
    flutter build apk --release
    
    if [ $? -eq 0 ]; then
        echo "✅ App built successfully."
        flutter install --release
        
        if [ $? -eq 0 ]; then
            echo "✅ App installed successfully."
        else
            echo "❌ Failed to install app."
            exit 1
        fi
    else
        echo "❌ Failed to build app."
        exit 1
    fi
else
    echo "✅ My Tube app is installed."
fi

echo ""
echo "🔍 Testing Scenarios:"
echo "===================="
echo ""

echo "1. 📱 Testing normal app launch (without Android Auto)..."
adb shell am start -n "$PACKAGE_NAME/.MainActivity" > /dev/null 2>&1
sleep 3

# Check if app is running
APP_RUNNING=$(adb shell ps | grep "$PACKAGE_NAME" | wc -l)
if [ "$APP_RUNNING" -gt 0 ]; then
    echo "   ✅ App launched successfully on phone"
else
    echo "   ❌ App failed to launch on phone"
fi

echo ""
echo "2. 🔊 Testing AudioService functionality..."
# Check for AudioService in logs (last 50 lines)
AUDIO_SERVICE_LOGS=$(adb logcat -d | tail -50 | grep -i "audioservice\|mtplayerservice" | wc -l)
if [ "$AUDIO_SERVICE_LOGS" -gt 0 ]; then
    echo "   ✅ AudioService activity detected in logs"
    echo "   Recent AudioService logs:"
    adb logcat -d | tail -50 | grep -i "audioservice\|mtplayerservice" | tail -3
else
    echo "   ⚠️  No recent AudioService activity in logs"
fi

echo ""
echo "3. 🚗 Android Auto Testing Instructions:"
echo "======================================="
echo ""
echo "To test Android Auto functionality:"
echo ""
echo "Option A - Physical Car:"
echo "  1. Connect your phone to Android Auto in your car"
echo "  2. Launch 'My Tube' from Android Auto interface"
echo "  3. Verify app doesn't freeze on splash screen"
echo "  4. Test media controls from car interface"
echo ""
echo "Option B - Android Auto Desktop Head Unit (DHU):"
echo "  1. Install Android Auto DHU from Android Studio"
echo "  2. Run: desktop-head-unit"
echo "  3. Connect via ADB wireless or USB"
echo "  4. Launch 'My Tube' from DHU interface"
echo ""
echo "Option C - Android Auto Emulator:"
echo "  1. Use Android Auto simulator if available"
echo "  2. Test app launch and media functionality"
echo ""

echo "🔧 Debug Commands:"
echo "=================="
echo ""
echo "Monitor logs during Android Auto testing:"
echo "  adb logcat | grep -E \"(MtPlayerService|AudioService|MyTube|AndroidAuto)\""
echo ""
echo "Check Android Auto specific logs:"
echo "  adb logcat | grep -E \"(AndroidAuto|MediaSession|AudioFocus)\""
echo ""
echo "Clear logs before testing:"
echo "  adb logcat -c"
echo ""
echo "Check app permissions:"
echo "  adb shell dumpsys package $PACKAGE_NAME | grep permission"
echo ""

echo "📋 Test Results Checklist:"
echo "=========================="
echo ""
echo "[ ] App launches normally on phone (without Android Auto)"
echo "[ ] App launches from Android Auto interface (no splash screen freeze)"
echo "[ ] Media controls work in Android Auto"
echo "[ ] Audio playback functions correctly in Android Auto"
echo "[ ] No error messages in logs during Android Auto usage"
echo "[ ] App continues to work normally after disconnecting from Android Auto"
echo ""

echo "🏁 Testing script completed!"
echo ""
echo "💡 Remember to test with actual Android Auto connection for full validation."
echo "   The applied fixes should resolve the splash screen freeze issue."
