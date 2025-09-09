# NutriScan App Icon Update Guide

## Overview
This guide explains how to update the app icon for NutriScan using the provided `nutriscan_logo.svg` file.

## Prerequisites
- Flutter SDK installed
- Access to image editing software or online conversion tools

## Steps to Update the App Icon

### 1. Convert SVG to PNG
The flutter_launcher_icons package requires a PNG file. You need to convert the `nutriscan_logo.svg` to PNG format:

1. Open `assets/images/nutriscan_logo.svg` in a vector editor or online converter
2. Export as PNG with dimensions 1024x1024 pixels
3. Save the file as `assets/images/app_icon.png` (replace the existing file)

### 2. Generate App Icons
Run the following command to generate all required icon sizes for different devices:

```bash
flutter pub run flutter_launcher_icons:main
```

Alternatively, you can run the provided batch script:
```bash
update_app_icon.bat
```

### 3. Verify the Changes
1. Clean and rebuild the project:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. Check that the new icon appears:
   - On the app launcher screen
   - In the app switcher
   - In settings/apps list

## Troubleshooting

### Icon Not Updating
If the icon doesn't appear to change:
1. Uninstall the app from your device/emulator
2. Run `flutter clean`
3. Run `flutter pub get`
4. Rebuild and install the app

### Platform-Specific Issues
- **Android**: Icons are stored in `android/app/src/main/res/mipmap-*`
- **iOS**: Icons are stored in `ios/Runner/Assets.xcassets/AppIcon.appiconset`

## Design Notes
The new icon features:
- A leaf symbol representing health and nutrition
- Scanning lines representing technology
- Green color scheme consistent with the app's branding
- Clean, modern design suitable for both light and dark backgrounds

## Files Reference
- `assets/images/nutriscan_logo.svg` - Source vector logo
- `assets/images/app_icon.png` - Generated PNG for icon generation
- `flutter_launcher_icons.yaml` - Configuration file
- `assets/images/svg_conversion_guide.md` - Detailed conversion instructions
- `update_app_icon.bat` - Automation script