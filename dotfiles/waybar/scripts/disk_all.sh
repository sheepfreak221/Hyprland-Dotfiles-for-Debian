#!/bin/bash

# Root (/)
root_used=$(df -h / | awk 'NR==2 {print $3}')
root_free=$(df -h / | awk 'NR==2 {print $4}')
root_total=$(df -h / | awk 'NR==2 {print $2}')
root_percent=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

# Home (/home)
home_used=$(df -h /home | awk 'NR==2 {print $3}')
home_free=$(df -h /home | awk 'NR==2 {print $4}')
home_total=$(df -h /home | awk 'NR==2 {print $2}')
home_percent=$(df -h /home | awk 'NR==2 {print $5}' | sed 's/%//')

main_percent=$home_percent

# Tooltip mit Root und Home
tooltip="ROOT (/)\n━━━━━━━━━━━━━━━━\nVerwendet: ${root_used}\nFrei: ${root_free}\nGesamt: ${root_total}\nAuslastung: ${root_percent}%\n\nHOME (/home)\n━━━━━━━━━━━━━━━━\nVerwendet: ${home_used}\nFrei: ${home_free}\nGesamt: ${home_total}\nAuslastung: ${home_percent}%"

# externe Geräte erkennen
# Suche in /media und /run/media nach Mountpoints (üblich für Debian)
external_drives=$(df -h | grep -E "(/media|/run/media)" | awk '{print $6}')

if [ -n "$external_drives" ]; then
    # Zähler für USB-Geräte
    usb_count=0
    
    while IFS= read -r mountpoint; do
        if [ -n "$mountpoint" ]; then
            # Daten für dieses externe Gerät holen
            ext_used=$(df -h "$mountpoint" | awk 'NR==2 {print $3}')
            ext_free=$(df -h "$mountpoint" | awk 'NR==2 {print $4}')
            ext_total=$(df -h "$mountpoint" | awk 'NR==2 {print $2}')
            ext_percent=$(df -h "$mountpoint" | awk 'NR==2 {print $5}' | sed 's/%//')
            
            # Namen des Geräts (letzter Teil des Pfads)
            ext_name=$(basename "$mountpoint")
            
            # Zum Tooltip hinzufügen
            tooltip="${tooltip}\n\n${ext_name} (${mountpoint})\n━━━━━━━━━━━━━━━━\nVerwendet: ${ext_used}\nFrei: ${ext_free}\nGesamt: ${ext_total}\nAuslastung: ${ext_percent}%"
            
            usb_count=$((usb_count + 1))
        fi
    done <<< "$external_drives"
fi

echo "{\"text\": \" ${main_percent}%\", \"tooltip\": \"$tooltip\", \"class\": \"disk\"}"
