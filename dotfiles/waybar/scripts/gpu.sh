#!/bin/bash

GPU_PATH="/sys/class/drm/card0/device"

# -------------------------
# helpers (safe read)
# -------------------------
safe_read() {
    cat "$1" 2>/dev/null
}

# -------------------------
# GPU usage
# -------------------------
GPU_USE=$(safe_read "$GPU_PATH/gpu_busy_percent")
GPU_USE=${GPU_USE:-0}

# -------------------------
# temperature (milli °C → °C)
# -------------------------
TEMP_RAW=$(safe_read "$GPU_PATH/hwmon"/hwmon*/temp1_input)
if [ -n "$TEMP_RAW" ]; then
    TEMP=$((TEMP_RAW / 1000))
else
    TEMP=0
fi

# -------------------------
# VRAM
# -------------------------
VRAM_USED=$(safe_read "$GPU_PATH/mem_info_vram_used")
VRAM_TOTAL=$(safe_read "$GPU_PATH/mem_info_vram_total")

if [ -n "$VRAM_USED" ] && [ -n "$VRAM_TOTAL" ] && [ "$VRAM_TOTAL" -gt 0 ]; then
    VRAM_USED_GB=$(awk "BEGIN {printf \"%.1f\", $VRAM_USED/1024/1024/1024}")
    VRAM_TOTAL_GB=$(awk "BEGIN {printf \"%.1f\", $VRAM_TOTAL/1024/1024/1024}")
    VRAM_PERCENT=$(awk "BEGIN {printf \"%.0f\", $VRAM_USED/$VRAM_TOTAL*100}")
else
    VRAM_USED_GB="0.0"
    VRAM_TOTAL_GB="0.0"
    VRAM_PERCENT="0"
fi

# -------------------------
# GPU clock (current DPM state)
# -------------------------
CLOCK=$(awk '/\*/ {print $2}' "$GPU_PATH/pp_dpm_sclk" 2>/dev/null)
CLOCK=${CLOCK:-"?"}

# -------------------------
# power (optional, µW → W)
# -------------------------
POWER_RAW=$(safe_read "$GPU_PATH/hwmon"/hwmon*/power1_average)

if [ -n "$POWER_RAW" ]; then
    POWER=$(awk "BEGIN {printf \"%.0f\", $POWER_RAW/1000000}")
    POWER_TEXT="${POWER}W"
else
    POWER_TEXT=""
fi

# -------------------------
# icon + text
# -------------------------
ICON="󰢮"
TEXT="${ICON} ${GPU_USE}%"

# -------------------------
# class (for CSS)
# -------------------------
CLASS="normal"

if [ "$TEMP" -ge 80 ] || [ "$VRAM_PERCENT" -ge 90 ]; then
    CLASS="critical"
elif [ "$TEMP" -ge 70 ] || [ "$VRAM_PERCENT" -ge 75 ]; then
    CLASS="warning"
fi

# -------------------------
# tooltip
# -------------------------
TOOLTIP="GPU: ${GPU_USE}%\nClock: ${CLOCK}\nVRAM: ${VRAM_USED_GB}/${VRAM_TOTAL_GB} GB (${VRAM_PERCENT}%)\nTemp: ${TEMP}°C\nPower: ${POWER_TEXT}"

# -------------------------
# output (Waybar JSON)
# -------------------------
printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' \
"$TEXT" "$CLASS" "$TOOLTIP"
