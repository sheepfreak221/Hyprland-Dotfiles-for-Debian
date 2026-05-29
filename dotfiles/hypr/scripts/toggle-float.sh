#!/bin/bash

# Prüft, ob das aktive Fenster bereits floatet
FLOATING=$(hyprctl activewindow -j | grep -o '"floating":[^,]*' | cut -d':' -f2)

if [[ "$FLOATING" == "false" ]]; then
    # Floating an -> auf 80% Breite, 70% Höhe setzen + zentrieren
    hyprctl dispatch togglefloating
    hyprctl dispatch resizeactive exact 80% 70%
    hyprctl dispatch centerwindow
else
    # Floating aus -> zurück zu Tiling (maximiert)
    hyprctl dispatch togglefloating
fi
