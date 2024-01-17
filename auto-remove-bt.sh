#!/bin/bash
    connected_devices=$(bluetoothctl devices | grep 'Device' | awk '{print $2}')

    for device in $connected_devices; do
        # Check if each device is connected
        if ! bluetoothctl info "$device" | grep -q "Connected: yes"; then
            # If not connected, remove the device
            bluetoothctl remove "$device"
        fi
    done
