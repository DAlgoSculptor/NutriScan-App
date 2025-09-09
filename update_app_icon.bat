@echo off
echo NutriScan App Icon Update Script
echo ================================
echo.
echo This script will help you update the app icon using the nutriscan_logo.svg file.
echo.
echo Please follow these steps:
echo 1. Convert nutriscan_logo.svg to PNG (1024x1024) using any method from svg_conversion_guide.md
echo 2. Replace assets/images/app_icon.png with the new PNG file
echo 3. Run this script to generate all required icons
echo.
pause
echo.
echo Generating new app icons...
echo.
flutter pub run flutter_launcher_icons:main
echo.
echo App icons updated successfully!
echo.
echo Cleaning and rebuilding the app...
echo.
flutter clean
flutter pub get
echo.
echo You can now run the app with 'flutter run' to see the new icon
echo.
pause