#!/bin/bash

# amdgpu

gpu_edge=$(cat /sys/class/hwmon/hwmon2/temp1_input 2>/dev/null)
gpu_junction=$(cat /sys/class/hwmon/hwmon2/temp2_input 2>/dev/null)
gpu_mem=$(cat /sys/class/hwmon/hwmon2/temp3_input 2>/dev/null)

if [ -n "$gpu_edge" ]; then
    gpu_edge=$((gpu_edge / 1000))
    gpu_junction=$((gpu_junction / 1000))
    gpu_mem=$((gpu_mem / 1000))
    # Hotspot ist meist junction oder der höchste Wert
    gpu_hotspot=$gpu_junction
else
    gpu_edge="N/A"
    gpu_junction="N/A"
    gpu_mem="N/A"
    gpu_hotspot="N/A"
fi

# cpu

cpu_temp=$(cat /sys/class/hwmon/hwmon3/temp1_input 2>/dev/null)
if [ -n "$cpu_temp" ]; then
    cpu_temp=$((cpu_temp / 1000))
else
    cpu_temp="N/A"
fi

# nvme

nvme1_temp=$(cat /sys/class/hwmon/hwmon0/temp1_input 2>/dev/null)
nvme2_temp=$(cat /sys/class/hwmon/hwmon1/temp1_input 2>/dev/null)

if [ -n "$nvme1_temp" ]; then
    nvme1_temp=$((nvme1_temp / 1000))
else
    nvme1_temp="N/A"
fi

if [ -n "$nvme2_temp" ]; then
    nvme2_temp=$((nvme2_temp / 1000))
else
    nvme2_temp="N/A"
fi

main_temp=$cpu_temp

tooltip="GPU Edge: ${gpu_edge}°C\nGPU Hotspot: ${gpu_hotspot}°C\nGPU Mem: ${gpu_mem}°C\n━━━━━━━━━━━━━━━━\nCPU: ${cpu_temp}°C\n━━━━━━━━━━━━━━━━\nNVMe1: ${nvme1_temp}°C\nNVMe2: ${nvme2_temp}°C"

echo "{\"text\": \" ${main_temp}°C\", \"tooltip\": \"$tooltip\", \"class\": \"temperature\"}"
