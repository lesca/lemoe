# This file includes quick fix for known issues.

# fix audio issue for HUAWEI devices
fix_audio() {
    echo "Fixing audio ..."
    sed -i "s|load-module module-sles-sink|#load-module module-sles-sink|g" $PREFIX/etc/pulse/default.pa
    sed -i "s|#load-module module-aaudio-sink|load-module module-aaudio-sink|g" $PREFIX/etc/pulse/default.pa
    echo "Done. Exit termux completely and start again to make it take effect."
}

# fix tips for signal 9 on Android 12 and above
fix_signal9() {
    echo "Run below commands with adb shell to fix singal9 "
    echo "device_config set_sync_disabled_for_tests persistent" 
    echo "device_config put activity_manager max_phantom_processes 2147483647"
}
