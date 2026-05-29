#!/bin/bash

# --- CONFIGURATION ---
API_KEY=""
LAT="48.20833333333316"
LON="16.373055555556"
UNITS="metric"
# ---------------------

CURRENT=$(curl -s "https://api.openweathermap.org/data/2.5/weather?lat=${LAT}&lon=${LON}&appid=${API_KEY}&units=${UNITS}")
FORECAST=$(curl -s "https://api.openweathermap.org/data/2.5/forecast?lat=${LAT}&lon=${LON}&appid=${API_KEY}&units=${UNITS}")

TEMP=$(echo "$CURRENT" | jq '.main.temp | round')
ICON_CODE=$(echo "$CURRENT" | jq -r '.weather[0].icon')
DESC=$(echo "$CURRENT" | jq -r '.weather[0].description')

case $ICON_CODE in
"01d") ICON="󰖙" ;;  # clear day
"01n") ICON="󰖔" ;;  # clear night

"02d") ICON="󰖕" ;;  # few clouds day
"02n") ICON="󰼱" ;;  # few clouds night

"03d"|"03n") ICON="󰖐" ;;  # scattered clouds
"04d"|"04n") ICON="󰖐" ;;  # broken clouds

"09d"|"09n") ICON="󰖗" ;;  # shower rain

"10d") ICON="󰖕" ;;       # rain day
"10n") ICON="󰖔" ;;       # rain night

"11d"|"11n") ICON="󰖓" ;;  # thunderstorm

"13d"|"13n") ICON="󰖘" ;;  # snow

"50d"|"50n") ICON="󰖑" ;;  # mist/fog

*) ICON="󰘥" ;;            # unknown
esac

TOOLTIP="Aktuell: ${DESC}\n━━━━━━━━━━━━━━━━\n"

# Nächste 4 Tage (jeweils zur Mittagszeit ca.)
for i in 0 1 2 3 4; do
    INDEX=$((i * 8))
    DT=$(echo "$FORECAST" | jq -r ".list[$INDEX].dt_txt" 2>/dev/null)
    if [ -n "$DT" ] && [ "$DT" != "null" ]; then
        TEMP_F=$(echo "$FORECAST" | jq ".list[$INDEX].main.temp | round")
        WEEKDAY=$(date -d "$DT" +%A 2>/dev/null)
        # Ins Deutsche übersetzen
        case $WEEKDAY in
            "Monday") WEEKDAY="Mo" ;; "Tuesday") WEEKDAY="Di" ;;
            "Wednesday") WEEKDAY="Mi" ;; "Thursday") WEEKDAY="Do" ;;
            "Friday") WEEKDAY="Fr" ;; "Saturday") WEEKDAY="Sa" ;;
            "Sunday") WEEKDAY="So" ;;
        esac
        TOOLTIP="${TOOLTIP}${WEEKDAY}: ${TEMP_F}°C\n"
    fi
done

echo "{\"text\": \"${ICON} ${TEMP}°C\", \"tooltip\": \"${TOOLTIP}\", \"class\": \"weather\"}"
