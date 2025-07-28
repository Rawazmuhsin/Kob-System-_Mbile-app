#!/bin/bash
# Script to generate app icons

# Check if the icon file exists
if [ ! -f "assets/icon/app_icon.png" ]; then
  echo "Error: app_icon.png not found in assets/icon directory."
  exit 1
fi

# Run flutter pub get to ensure dependencies are up to date
flutter pub get

# Generate the icons
flutter pub run flutter_launcher_icons
