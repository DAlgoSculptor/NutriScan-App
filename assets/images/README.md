# NutriScan Assets

## Current Assets
This directory contains the visual assets for the NutriScan application.

### Images
- `nutriscan_logo.svg` - The official NutriScan logo in SVG format
- `NutriScan .jpg` - Original logo image

### Animations
- `splash_animation.json` - Lottie animation for splash screen

## App Icon Update Instructions

To update the app icon:

1. Convert `nutriscan_logo.svg` to PNG format (1024x1024 pixels)
2. Save the result as `app_icon.png` in this directory
3. Run `flutter pub run flutter_launcher_icons:main` to generate all required icon sizes

## Temporary Solution

If you want to see immediate changes without creating a new icon:

1. Delete the current `app_icon.png` file
2. Run the app - it will now show a green leaf icon as a placeholder
3. This makes it obvious that the icon system is working

The placeholder icon is a solid green circle with a white leaf symbol, which is clearly different from any previous icon.